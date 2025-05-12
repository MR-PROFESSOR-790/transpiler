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
            logging.error(f"Error: File '{input_file}' does not exist.")
            return False
        if not input_file.endswith(".asm"):
            logging.error(f"Error: Input must be an .asm file")
            return False
        # Check if file is empty
        if os.path.getsize(input_file) == 0:
            logging.error(f"Error: File '{input_file}' is empty.")
            return False
        try:
            with open(input_file, 'r') as f:
                content = f.read().strip()
                if not content:
                    logging.error(f"Error: File '{input_file}' contains no EVM assembly instructions.")
                    return False
        except Exception as e:
            logging.error(f"Error reading file '{input_file}': {str(e)}")
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
        from datetime import datetime
        stats = self.stats.copy()
        stats["start_time"] = datetime.now()
        stats["success"] = False
        stats["optimization_passes"] = []
        try:
            # Step 1: Parse EVM Assembly
            logging.debug(f"Reading input file: {input_file}")
            try:
                with open(input_file, 'r') as f:
                    content = f.read()
                    if not content.strip():
                        logging.error("Input file is empty")
                        stats["error"] = "Input file is empty"
                        return stats
                logging.debug(f"File contents loaded ({len(content)} bytes)")
            except FileNotFoundError:
                logging.error(f"Input file not found: {input_file}")
                stats["error"] = f"Input file not found: {input_file}"
                return stats
            except Exception as e:
                logging.error(f"Error reading input file: {str(e)}")
                stats["error"] = f"Error reading input file: {str(e)}"
                return stats
            logging.info(f"Parsing EVM assembly from {input_file}")
            try:
                # Make sure parser is initialized
                if not hasattr(self, 'parser') or self.parser is None:
                    from .evm_parser import EvmParser
                    self.parser = EvmParser(self.context)
                parse_result = self.parser.parse_evm_assembly(input_file)
                logging.debug(f"Parse result received with {len(parse_result.get('instructions', []))} instructions")
                if not parse_result:
                    logging.error("Parser returned None")
                    stats["error"] = "Parser returned None"
                    return stats
                if not parse_result.get("instructions"):
                    logging.error("No instructions found in parse result")
                    stats["error"] = "No instructions parsed"
                    logging.debug(f"Full parse result: {parse_result}")
                    return stats
                instructions = parse_result["instructions"]
                logging.debug(f"Parsed {len(instructions)} instructions")
            except Exception as e:
                logging.error(f"Parser error: {str(e)}", exc_info=True)
                stats["error"] = f"Parser error: {str(e)}"
                return stats
            labels = parse_result.get("labels", {})
            # Use parsed context if available, otherwise use the default context
            context = parse_result.get("context", self.context)
            stats["evm_instruction_count"] = len(instructions)
            # Optional: Generate debug info
            if hasattr(options, 'debug_info') and options.debug_info:
                logging.info("Generating debug info")
                if hasattr(self.context, 'generate_debug_info'):
                    self.context.generate_debug_info(instructions)
                else:
                    logging.warning("Debug info generation not available in context")
            # Step 2: Optimize Instructions
            optimized_ir = instructions  # Default to unoptimized
            if hasattr(options, 'optimize') and options.optimize:
                logging.info("Running optimizations...")
                try:
                    # Make sure optimizer is initialized
                    if not hasattr(self, 'optimizer') or self.optimizer is None:
                        from .optimizer import InstructionOptimizer
                        self.optimizer = InstructionOptimizer(self.context)
                    # Pass context explicitly to ensure it's available during optimization
                    optimized_ir = self.optimizer.optimize_instructions(instructions, context)
                    stats["optimization_passes"].append("instruction_optimization")
                    stats["evm_instruction_count_after_opt"] = len(optimized_ir)
                    logging.info(f"Optimization reduced instructions from {len(instructions)} to {len(optimized_ir)}")
                except Exception as e:
                    logging.error(f"Optimization error: {str(e)}", exc_info=True)
                    logging.warning("Continuing with unoptimized code")
                    # Continue with unoptimized instructions instead of failing
                    optimized_ir = instructions
                    stats["optimization_error"] = str(e)
            # Step 3: Emit RISC-V Assembly
            logging.info(f"Emitting RISC-V code to {output_file}")
            try:
                # Make sure emitter is initialized
                if not hasattr(self, 'emitter') or self.emitter is None:
                    from .riscv_emitter import RiscvEmitter
                    self.emitter = RiscvEmitter(self.context)
                riscv_code = self.emitter.emit_riscv_assembly(optimized_ir, output_file=output_file)
                stats["riscv_instruction_count"] = len(riscv_code.splitlines())
                # Write the output if emitter didn't already do it
                if output_file and not getattr(self.emitter, 'writes_output', False):
                    try:
                        with open(output_file, 'w', encoding='utf-8') as f:
                            f.write(riscv_code)
                        logging.info(f"RISC-V assembly written to {output_file}")
                    except Exception as e:
                        logging.error(f"Failed to write output file: {str(e)}")
                        stats["error"] = f"Failed to write output file: {str(e)}"
                        return stats
            except Exception as e:
                logging.error(f"RISC-V emission error: {str(e)}", exc_info=True)
                stats["error"] = f"RISC-V emission error: {str(e)}"
                return stats
            # Optional: Source Map Generation
            if hasattr(options, 'source_map') and options.source_map:
                logging.info("Generating source map")
                try:
                    if hasattr(self.context, 'create_source_map'):
                        self.context.create_source_map(instructions, riscv_code.splitlines())
                    else:
                        logging.warning("Source map generation not available in context")
                except Exception as e:
                    logging.error(f"Source map generation error: {str(e)}")
                    # Don't fail the whole pipeline for source map issues
            # Optional: Pattern Detection Report
            try:
                if hasattr(self, 'pattern_recognizer') and self.pattern_recognizer is not None:
                    patterns = self.pattern_recognizer.detect_patterns(instructions)
                    stats["patterns_found"] = {k: len(v) for k, v in patterns.items()}
                else:
                    # Try to initialize pattern recognizer
                    try:
                        from .pattern import PatternRecognizer
                        self.pattern_recognizer = PatternRecognizer()
                        self.pattern_recognizer.set_context(context)
                        patterns = self.pattern_recognizer.detect_patterns(instructions)
                        stats["patterns_found"] = {k: len(v) for k, v in patterns.items()}
                    except Exception as pattern_err:
                        logging.warning(f"Could not initialize pattern recognizer: {str(pattern_err)}")
                        stats["patterns_found"] = {}
            except Exception as e:
                logging.warning(f"Pattern detection error: {str(e)}")
                stats["patterns_found"] = {}
            # Calculate gas metrics if available
            if hasattr(context, 'gas_meter') and isinstance(context.gas_meter, dict):
                stats["gas_estimate"] = context.gas_meter.get("total", 0)
            else:
                stats["gas_estimate"] = 0
            stats["success"] = True
        except Exception as e:
            logging.error(f"Transpilation pipeline error: {str(e)}", exc_info=True)
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