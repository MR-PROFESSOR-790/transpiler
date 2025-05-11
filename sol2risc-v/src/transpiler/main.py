# main.py - Entry point for EVM-to-RISC-V transpiler

import argparse
import sys
import os
import json
import logging
from datetime import datetime

# Change relative imports to absolute imports
from transpiler.context_manager import CompilationContext
from transpiler.evm_parser import EvmParser
from transpiler.optimizer import InstructionOptimizer
from transpiler.riscv_emitter import RiscvEmitter
from transpiler.pattern import PatternRecognizer

class TranspilerCLI:
    """
    Command-line interface and main pipeline controller for EVM-to-RISC-V transpiler.
    
    Handles:
    - Argument parsing
    - Input validation
    - Logging setup
    - Pipeline orchestration
    - Statistics display
    - Error handling
    """

    def __init__(self):
        # Configure logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )

        # Initialize context first
        self.context = CompilationContext()
        
        # Initialize parser with context
        self.parser = EvmParser()
        self.parser.set_context(self.context)
        
        # Initialize optimizer with context
        self.optimizer = InstructionOptimizer()
        self.optimizer.set_context(self.context)
        
        # Initialize other components
        self.emitter = RiscvEmitter()
        self.emitter.set_context(self.context)
        
        self.pattern_recognizer = PatternRecognizer()
        self.pattern_recognizer.set_context(self.context)

        # Stats tracking
        self.stats = {
            "start_time": None,
            "end_time": None,
            "duration": 0,
            "evm_instruction_count": 0,
            "riscv_instruction_count": 0,
            "evm_instruction_count_after_opt": 0,
            "patterns_found": {},
            "gas_estimate": 0,
            "success": False,
            "error": "",
            "optimization_passes": []
        }

    def set_log_level(self, level):
        """
        Set logging level based on CLI args.
        """
        log_levels = {
            "DEBUG": logging.DEBUG,
            "INFO": logging.INFO,
            "WARNING": logging.WARNING,
            "ERROR": logging.ERROR
        }
        logging.getLogger().setLevel(log_levels.get(level, logging.INFO))

    def parse_arguments(self):
        """
        Parse command line arguments.
        
        Returns:
            argparse.Namespace: Parsed arguments
        """
        parser = argparse.ArgumentParser(description="EVM-to-RISC-V Transpiler")

        parser.add_argument("input", help="Input EVM assembly file (.asm)")
        parser.add_argument("-o", "--output", help="Output RISC-V assembly file (.s)", default="output.s")
        parser.add_argument("--log-level", choices=["NONE", "ERROR", "WARN", "INFO", "DEBUG"],
                            default="INFO", help="Logging verbosity level")
        parser.add_argument("--debug-info", action="store_true", help="Generate debug info JSON")
        parser.add_argument("--source-map", action="store_true", help="Generate source map between EVM and RISC-V")
        parser.add_argument("--optimize", action="store_true", help="Enable optimization passes")

        return parser.parse_args()

    def validate_input_file(self, input_file):
        """
        Validate that input file exists and has correct format.
        
        Args:
            input_file (str): Path to input file
        Returns:
            bool: True if valid
        """
        if not os.path.isfile(input_file):
            print(f"Error: File '{input_file}' does not exist.")
            return False

        if not input_file.endswith(".asm"):
            print(f"Error: Input must be an .asm file")
            return False

        return True

    def configure_logging(self, args):
        """
        Configure logging system based on command-line flags.
        
        Args:
            args (argparse.Namespace): Command-line arguments
        """
        self.set_log_level(args.log_level)
        logging.info(f"Logger configured at level: {args.log_level}")

    def run_transpilation_pipeline(self, input_file, output_file, options):
        """
        Run the complete transpilation pipeline from EVM ASM to RISC-V ASM.
        
        Args:
            input_file (str): Path to input EVM assembly file
            output_file (str): Path to output RISC-V assembly file
            options (argparse.Namespace): Additional options
        Returns:
            dict: Statistics about the transpilation process
        """
        stats = self.stats.copy()
        stats["start_time"] = datetime.now()
        stats["success"] = False

        try:
            # Step 1: Parse EVM Assembly
            logging.info(f"Parsing EVM assembly from {input_file}")
            parse_result = self.parser.parse_evm_assembly(input_file)

            if not parse_result or not parse_result.get("instructions"):
                logging.error("Failed to parse EVM assembly")
                return stats

            instructions = parse_result["instructions"]
            labels = parse_result.get("labels", {})
            context = parse_result.get("context", self.context)  # Use parsed context if available

            stats["evm_instruction_count"] = len(instructions)

            # Optional: Generate debug info
            if options.debug_info:
                logging.info("Generating debug info")
                self.context.generate_debug_info(instructions)

            # Step 2: Optimize Instructions
            if options.optimize:
                logging.info("Running optimizations...")
                optimized_ir = self.optimizer.optimize_instructions(instructions, context)
                stats["optimization_passes"].append("instruction_optimization")
                stats["evm_instruction_count_after_opt"] = len(optimized_ir)
            else:
                optimized_ir = instructions

            # Step 3: Emit RISC-V Assembly
            logging.info(f"Emitting RISC-V code to {output_file}")
            riscv_code = self.emitter.emit_riscv_assembly(optimized_ir, context, output_file=output_file)
            stats["riscv_instruction_count"] = len(riscv_code.splitlines())

            # Optional: Source Map Generation
            if options.source_map:
                logging.info("Generating source map")
                self.context.create_source_map(instructions, riscv_code.splitlines())

            # Optional: Pattern Detection Report
            patterns = self.pattern_recognizer.detect_patterns(instructions)
            stats["patterns_found"] = {k: len(v) for k, v in patterns.items()}

            stats["gas_estimate"] = context.gas_meter.get("total", 0)
            stats["success"] = True

        except Exception as e:
            stats["error"] = str(e)
            stats["success"] = False

        finally:
            stats["end_time"] = datetime.now()
            stats["duration"] = (stats["end_time"] - stats["start_time"]).total_seconds()

        return stats

    def display_statistics(self, stats):
        """
        Display transpilation statistics to user.
        """
        print("\n📊 Transpilation Statistics:")
        print(f"Started at       : {stats['start_time']}")
        print(f"Finished at      : {stats['end_time']}")
        print(f"Duration         : {stats['duration']:.2f} seconds")
        print(f"Success          : {'✅' if stats['success'] else '❌'}")
        print(f"EVM Instructions : {stats['evm_instruction_count']}")
        if "evm_instruction_count_after_opt" in stats:
            print(f"EVM Instructions (after opt): {stats['evm_instruction_count_after_opt']}")
        print(f"RISC-V Instructions: {stats['riscv_instruction_count']}")
        print(f"Estimated Gas Cost: {stats.get('gas_estimate', 0)}")

        if "patterns_found" in stats:
            print("\n🔍 Detected Patterns:")
            for pattern, count in stats["patterns_found"].items():
                if count > 0:
                    print(f"  - {pattern}: {count}")

    def handle_errors(self, error, context=None):
        """
        Handle and report errors during transpilation.
        """
        logging.error(f"Unhandled error: {str(error)}")
        print(f"\n🚨 Critical Error: {str(error)}")
        if context and hasattr(context, "function_info"):
            print(f"Current function: {context.function_info.get('name', 'unknown')}")
        sys.exit(1)

    def main(self):
        """
        Main entry point for CLI execution.
        """
        args = self.parse_arguments()

        if not self.validate_input_file(args.input):
            sys.exit(1)

        self.configure_logging(args)

        logging.info("Starting EVM-to-RISC-V transpiler")

        try:
            stats = self.run_transpilation_pipeline(
                input_file=args.input,
                output_file=args.output,
                options=args
            )

            self.display_statistics(stats)

            if not stats["success"]:
                sys.exit(1)

        except Exception as e:
            self.handle_errors(e, self.context)


if __name__ == "__main__":
    # Ensure root directory is in Python path
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
    if root_dir not in sys.path:
        sys.path.insert(0, root_dir)

    # Now run the CLI
    cli = TranspilerCLI()
    cli.main()