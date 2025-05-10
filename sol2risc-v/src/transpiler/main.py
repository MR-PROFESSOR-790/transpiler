#!/usr/bin/env python3
"""
EVM to RISC-V Transpiler - Main Driver

Orchestrates the complete transpilation process from EVM bytecode or assembly
to RISC-V assembly.
"""

import sys
import os
import argparse
import logging
from pathlib import Path

# Import all components
from transpiler.evm_parser import EVMParser
from transpiler.optimizer import IROptimizer
from transpiler.pattern import EVMPattern

from transpiler.opcode_mapping import OpcodeMapper
from transpiler.riscv_emitter import RISCVEmitter
from transpiler.environment import EVMEnvironment
from transpiler.arithmetic import ArithmeticHandler
from transpiler.memory_model import EVMMemoryModel


def setup_logging(debug_mode: bool):
    """Configure logging based on debug mode."""
    log_level = logging.DEBUG if debug_mode else logging.INFO
    logging.basicConfig(
        level=log_level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )


def main():
    parser = argparse.ArgumentParser(description="EVM to RISC-V Transpiler")
    parser.add_argument("input_file", help="Path to the input file containing EVM bytecode or assembly")
    parser.add_argument("-o", "--output", dest="output", help="Path to output file")
    parser.add_argument("-a", "--asm", dest="is_assembly", action="store_true",
                        help="Indicates that input is EVM assembly")
    parser.add_argument("-d", "--debug", dest="debug_mode", action="store_true",
                        help="Enable debug mode")
    parser.add_argument("-O", "--optimize", dest="optimization_level", type=int,
                        choices=range(0, 4), default=1, help="Optimization level (0-3)")

    args = parser.parse_args()
    setup_logging(args.debug_mode)
    logger = logging.getLogger(__name__)

    # Resolve absolute paths
    try:
        input_path = Path(args.input_file).resolve(strict=True)
        output_path = Path(args.output).resolve() if args.output else input_path.with_suffix('.s')
    except FileNotFoundError:
        logger.error(f"Input file not found: {args.input_file}")
        logger.info("Available files in current directory:")
        for file in Path.cwd().glob('*'):
            logger.info(f"  {file.name}")
        sys.exit(1)

    logger.info(f"Transpiling {input_path} to {output_path}")
    logger.debug(f"Options: is_assembly={args.is_assembly}, optimize={args.optimization_level}")

    try:
        # Step 1: Parse EVM input
        if not input_path.exists():
            raise FileNotFoundError(f"Input file does not exist: {input_path}")
        if not input_path.is_file():
            raise ValueError(f"Input path is not a file: {input_path}")

        logger.info("Parsing EVM input")
        evm_parser = EVMParser()
        ir_instructions = evm_parser.parse_file(input_path)
        logger.info(f"Parsed {len(ir_instructions)} instructions")

        # Step 2: Analyze stack usage
        logger.info("Analyzing stack usage")
        try:
            stack_analysis = evm_parser.analyze_stack_usage()
            logger.debug(f"Max stack depth: {stack_analysis['max_stack']}")
            if not stack_analysis['balanced']:
                logger.warning("Stack is not balanced at the end of execution")
        except Exception as e:
            logger.warning(f"Stack analysis failed: {e}, continuing without stack information")
            stack_analysis = {'max_stack': 0, 'balanced': False}

        # Step 3: Optimize IR
        logger.info("Optimizing intermediate representation")
        optimizer = IROptimizer()
        ir_data = {
            'instructions': ir_instructions,
            'basic_blocks': evm_parser.basic_blocks,
            'control_flow_graph': evm_parser.control_flow_graph
        }
        optimizer.load_ir(ir_data)
        optimizer.optimize()

        optimization_stats = optimizer.get_stats()
        logger.info(f"Reduced from {optimization_stats['original_count']} to "
                    f"{optimization_stats['optimized_count']} instructions")

        # Step 4: Apply pattern-based optimizations
        logger.info("Applying pattern recognition and optimizations")
        pattern_matcher = EVMPattern(name="DefaultPattern", opcodes=["*"])
        patterns_found = pattern_matcher.scan_instructions(optimizer.optimized_ir)
        logger.debug(f"Found {len(patterns_found)} optimization patterns")
        optimized_with_patterns = pattern_matcher.apply_optimizations(optimizer.optimized_ir, patterns_found)

        # Step 5: Setup runtime environment
        logger.info("Setting up runtime environment")
        emitter = RISCVEmitter(input_path.as_posix(), output_path.as_posix())
        env = EVMEnvironment(emitter)
        mem = EVMMemoryModel(emitter)
        arith = ArithmeticHandler(emitter)
        # Pass only the required arguments to OpcodeMapper
        mapper = OpcodeMapper(emitter, mem, arith)

        # Step 6: Map opcodes to RISC-V instructions
        logger.info("Mapping EVM opcodes to RISC-V instructions")
        emitter.emit_header()

        for instr in optimized_with_patterns:
            try:
                mapper.map_opcode(instr.opcode, instr.args)
            except ValueError as ve:
                logger.warning(f"Ignoring unknown opcode '{instr.opcode}' at PC={instr.pc}: {ve}")

        emitter.emit_footer()

        # Step 7: Generate final RISC-V assembly
        logger.info("Generating final RISC-V assembly")
        emitter.transpile()

        stats = emitter.analyze_stack_usage()
        logger.info("Stack analysis:")
        logger.info(f"  Max stack depth: {stats['max_stack_depth']}")
        logger.info(f"  Register slots used: {stats['register_stack_slots']}")
        logger.info(f"  Memory stack slots used: {stats['memory_stack_slots']}")
        logger.info("Transpilation completed successfully!")

    except FileNotFoundError as e:
        logger.error(f"File error: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Transpilation failed: {e}", exc_info=args.debug_mode)
        sys.exit(1)


if __name__ == "__main__":
    main()