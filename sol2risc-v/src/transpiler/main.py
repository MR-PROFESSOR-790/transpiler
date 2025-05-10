#!/usr/bin/env python3
"""
EVM to RISC-V Transpiler

This script orchestrates the complete transpilation process from EVM bytecode
to RISC-V assembly. It parses EVM bytecode, applies optimizations,
emulates stack operations, and generates RISC-V assembly output.

Usage:
    python main.py input_file [options]

Arguments:
    input_file      Path to file containing EVM bytecode or assembly

Options:
    --output, -o    Output file path (default: input_file.s)
    --asm, -a       Input is already in EVM assembly format (default: bytecode)
    --debug, -d     Enable debug mode with additional logging
    --optimize, -O  Optimization level (0-3, default: 1)
    --gas-report    Generate gas usage report
    --help, -h      Show this help message
"""

import os
import sys
import argparse
import logging
import time
from typing import Dict, List, Optional, Tuple, Union

# Import our transpiler components
from transpiler.evm_parser import EVMParser
from transpiler.stack_emulator import StackEmulator
from transpiler.riscv_emitter import RISCVEmitter
from transpiler.pattern import EVMPattern, StackOperation, RegisterAllocator
from transpiler.memory_model import EVMMemoryModel
from transpiler.optimizer import IROptimizer
from transpiler.environment import EVMEnvironment
from transpiler.opcode_mapping import OpcodeMapper
from transpiler.arithmetic import ArithmeticHandler
from transpiler.gas_costs import GasCostCalculator

class EVMTranspiler:
    """Main transpiler class that coordinates the transpilation process."""
    
    def __init__(self, 
                 debug_mode: bool = False, 
                 optimization_level: int = 1,
                 gas_report: bool = False):
        """
        Initialize the transpiler with configuration options.
        
        Args:
            debug_mode: If True, enables verbose logging
            optimization_level: Level of optimization (0-3)
            gas_report: If True, generates gas usage report
        """
        # Configure logging
        log_level = logging.DEBUG if debug_mode else logging.INFO
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
        
        # Initialize components
        self.parser = EVMParser()
        self.register_allocator = RegisterAllocator()
        self.pattern_matcher = EVMPattern(name="EVMPattern", opcodes=["*"], riscv_generator= lambda x: x)
        self.gas_analyzer = GasCostCalculator()
        self.optimizer = IROptimizer()
        
        # These will be initialized when we have file paths
        self.riscv_emitter = None
        self.stack_emulator = None
        self.memory_handler = None
        self.env = None
        
        # Configuration
        self.debug_mode = debug_mode
        self.optimization_level = optimization_level
        self.gas_report = gas_report

        self.logger.info(f"Initialized transpiler with optimization level {optimization_level}")

    def transpile_file(self, input_path: str, output_path: Optional[str] = None, 
                      is_assembly: bool = False) -> str:
        """
        Transpile EVM bytecode or assembly from a file to RISC-V assembly.
        
        Args:
            input_path: Path to the input file
            output_path: Path to the output file (defaults to input_path.s)
            is_assembly: Whether the input is EVM assembly (vs bytecode)
            
        Returns:
            Path to the generated RISC-V assembly file
        """
        self.logger.info(f"Processing input file: {input_path}")
        
        # Determine output path if not specified
        if output_path is None:
            output_path = os.path.splitext(input_path)[0] + '.s'
        
        # Initialize components that need file paths
        self.riscv_emitter = RISCVEmitter(input_path, output_path)
        self.stack_emulator = StackEmulator(self.register_allocator)
        self.memory_handler = EVMMemoryModel(self.riscv_emitter)
        
        # Set initial section before environment initialization
        self.riscv_emitter.current_section = ".text"
        self.env = EVMEnvironment(self.riscv_emitter)
        
        # Initialize environment
        self.env.setup()
        
        # Read input file
        try:
            with open(input_path, 'r') as f:
                input_content = f.read().strip()
        except Exception as e:
            self.logger.error(f"Failed to read input file: {e}")
            raise
            
        # Process the input
        if is_assembly:
            riscv_assembly = self.transpile_assembly(input_content)
        else:
            riscv_assembly = self.transpile_bytecode(input_content)
            
        # Write output file
        try:
            with open(output_path, 'w') as f:
                f.write(riscv_assembly)
            self.logger.info(f"Generated RISC-V assembly written to: {output_path}")
        except Exception as e:
            self.logger.error(f"Failed to write output file: {e}")
            raise
            
        return output_path
    
    def transpile_bytecode(self, bytecode: str) -> List[Dict]:
        """
        Transpile EVM bytecode to RISC-V assembly.
        
        Args:
            bytecode: EVM bytecode as a hex string
            
        Returns:
            RISC-V assembly code as a string
        """
        start_time = time.time()
        self.logger.info("Starting bytecode transpilation process")
        
        # Step 1: Parse bytecode to instructions
        self.logger.debug("Parsing bytecode")
        instructions = self.parser.parse_bytecode(bytecode)
        
        # Step 2: Process instructions through transpilation pipeline
        riscv_code = self._process_instructions(instructions)
        
        elapsed_time = time.time() - start_time
        self.logger.info(f"Transpilation completed in {elapsed_time:.2f} seconds")
        
        return riscv_code
    
    def transpile_assembly(self, assembly: str) -> List[Dict]:
        """
        Transpile EVM assembly to RISC-V assembly.
        
        Args:
            assembly: EVM assembly as a string
            
        Returns:
            RISC-V assembly code as a string
        """
        start_time = time.time()
        self.logger.info("Starting assembly transpilation process")
        
        # Step 1: Parse assembly to instructions
        self.logger.debug("Parsing assembly")
        instructions = self.parser.parse_assembly(assembly)
        
        # Step 2: Process instructions through transpilation pipeline
        riscv_code = self._process_instructions(instructions)
        
        elapsed_time = time.time() - start_time
        self.logger.info(f"Transpilation completed in {elapsed_time:.2f} seconds")
        
        return riscv_code
    
    def _process_instructions(self, instructions: List[Dict]) -> str:
        """
        Process parsed EVM instructions through the transpilation pipeline.
        
        Args:
            instructions: List of parsed EVM instructions
            
        Returns:
            RISC-V assembly code as a string
        """
        # Step 1: Analyze program structure
        self.logger.debug("Analyzing program structure")
        basic_blocks = self._create_basic_blocks(instructions)
        
        # Step 2: Apply optimizations if enabled
        if self.optimization_level > 0:
            self.logger.debug(f"Applying optimizations (level {self.optimization_level})")
            optimized_blocks = self.optimizer.optimize_blocks(basic_blocks)
        else:
            optimized_blocks = basic_blocks
            
        # Step 3: Identify patterns for better code generation
        self.logger.debug("Identifying code patterns")
        patterns = self.pattern_matcher.identify_patterns(optimized_blocks)
        
        # Step 4: Prepare environment and memory model
        self.logger.debug("Setting up environment and memory model")
        self.memory_handler.initialize()
        
        # Step 5: Emulate stack operations and convert to register-based operations
        self.logger.debug("Emulating stack operations")
        register_operations = self.stack_emulator.convert_stack_to_registers(
            optimized_blocks, patterns)
        
        # Step 6: Handle memory operations
        self.logger.debug("Processing memory operations")
        memory_processed_ops = self.memory_handler.process_memory_operations(
            register_operations)
        
        # Step 7: Final sanitization of operations
        self.logger.debug("Sanitizing operations")
        sanitized_ops = [
            ArithmeticHandler(op) for op in memory_processed_ops
        ]
        
        # Step 8: Generate RISC-V assembly
        self.logger.debug("Generating RISC-V assembly")
        riscv_assembly = self.riscv_emitter.generate_assembly(sanitized_ops)
        
        # Step 9: Generate gas report if requested
        if self.gas_report:
            self.logger.debug("Generating gas usage report")
            gas_report = self.gas_analyzer.generate_report(instructions)
            riscv_assembly = self._add_gas_report_to_assembly(riscv_assembly, gas_report)
        
        return riscv_assembly
    
    def _create_basic_blocks(self, instructions: List[Dict]) -> List[Dict]:
        """
        Create basic blocks from instructions for analysis.
        
        Args:
            instructions: List of parsed EVM instructions
            
        Returns:
            List of basic blocks containing instructions
        """
        blocks = []
        current_block = []
        
        for i, instr in enumerate(instructions):
            current_block.append(instr)
            
            # Check if this instruction is a block terminator
            opcode = instr.get('opcode')
            if opcode in ('JUMP', 'JUMPI', 'RETURN', 'REVERT', 'STOP', 'SELFDESTRUCT'):
                blocks.append({
                    'id': len(blocks),
                    'instructions': current_block,
                    'start_offset': current_block[0].get('offset', 0),
                    'end_offset': instr.get('offset', 0),
                    'terminator': opcode
                })
                current_block = []
            
            # Also end block if next instruction is a JUMPDEST
            if i < len(instructions) - 1 and instructions[i+1].get('opcode') == 'JUMPDEST':
                if current_block:  # Only create block if there are instructions
                    blocks.append({
                        'id': len(blocks),
                        'instructions': current_block,
                        'start_offset': current_block[0].get('offset', 0),
                        'end_offset': instr.get('offset', 0),
                        'terminator': 'FALLTHROUGH'
                    })
                    current_block = []
        
        # Add remaining instructions as the final block if any
        if current_block:
            blocks.append({
                'id': len(blocks),
                'instructions': current_block,
                'start_offset': current_block[0].get('offset', 0),
                'end_offset': current_block[-1].get('offset', 0),
                'terminator': 'END'
            })
        
        return blocks
    
    def _add_gas_report_to_assembly(self, assembly: str, gas_report: str) -> str:
        """
        Add gas usage report as comments to the generated assembly.
        
        Args:
            assembly: Generated RISC-V assembly
            gas_report: Gas usage report string
            
        Returns:
            RISC-V assembly with gas report comments
        """
        report_comment = "# Gas Usage Report\n"
        for line in gas_report.split('\n'):
            report_comment += f"# {line}\n"
            
        return f"{report_comment}\n{assembly}"


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description='EVM to RISC-V Transpiler',
        formatter_class=argparse.RawDescriptionHelpFormatter)
    
    parser.add_argument('input_file', help='Path to file containing EVM bytecode or assembly')
    parser.add_argument('--output', '-o', help='Output file path (default: input_file.s)')
    parser.add_argument('--asm', '-a', action='store_true', 
                        help='Input is already in EVM assembly format')
    parser.add_argument('--debug', '-d', action='store_true',
                        help='Enable debug mode with additional logging')
    parser.add_argument('--optimize', '-O', type=int, choices=range(4), default=1,
                        help='Optimization level (0-3, default: 1)')
    parser.add_argument('--gas-report', action='store_true',
                        help='Generate gas usage report')
    
    return parser.parse_args()


def main():
    parser = argparse.ArgumentParser(description="EVM to RISC-V Transpiler")

    parser.add_argument("input_file", help="Path to the input file")
    parser.add_argument("-o", "--output", dest="output", help="Path to output file")
    parser.add_argument("-a", "--asm", dest="is_assembly", action="store_true",
                        help="Indicates that input is EVM assembly")
    parser.add_argument("-d", "--debug", dest="debug_mode", action="store_true",
                        help="Enable debug mode")
    parser.add_argument("-O", "--optimize", dest="optimization_level", type=int, choices=range(0, 4), default=1,
                        help="Optimization level (0-3)")
    parser.add_argument("--gas-report", dest="gas_report", action="store_true",
                        help="Generate gas usage report")

    args = parser.parse_args()

    transpiler = EVMTranspiler(
        debug_mode=args.debug_mode,
        optimization_level=args.optimization_level,
        gas_report=args.gas_report
    )

    output_path = transpiler.transpile_file(
        input_path=args.input_file,
        output_path=args.output,
        is_assembly=args.is_assembly
    )

    print(f"Transpilation complete. Output saved to {output_path}")


if __name__ == "__main__":
    main()