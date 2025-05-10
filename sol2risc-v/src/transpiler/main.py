# main.py - Entry point for EVM-to-RISC-V transpiler

import argparse
import sys
import os
import json
from datetime import datetime

# Update imports to use correct paths
from .context_manager import create_transpilation_context
from .evm_parser import parse_evm_assembly
from .optimizer import optimize_instructions
from .riscv_emitter import emit_riscv_assembly
from .pattern import detect_patterns
from .logging import initialize_logger, log, generate_debug_info, create_source_map


def parse_arguments():
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


def validate_input_file(input_file):
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


def configure_logging(args):
    """
    Configure logging system based on command-line flags.
    
    Args:
        args (argparse.Namespace): Command-line arguments
    """
    initialize_logger(log_level=args.log_level)
    log(f"Logger configured at level: {args.log_level}", level="INFO")


def run_transpilation_pipeline(input_file, output_file, options):
    """
    Run the complete transpilation pipeline from EVM ASM to RISC-V ASM.
    
    Args:
        input_file (str): Path to input EVM assembly file
        output_file (str): Path to output RISC-V assembly file
        options (argparse.Namespace): Additional options
    Returns:
        dict: Statistics about the transpilation process
    """
    stats = {
        "start_time": datetime.now(),
        "end_time": None,
        "evm_instruction_count": 0,
        "riscv_instruction_count": 0,
        "optimization_passes": [],
        "gas_estimate": 0,
        "success": False
    }

    try:
        # Step 1: Parse EVM Assembly
        log(f"Parsing EVM assembly from {input_file}", level="INFO")
        parse_result = parse_evm_assembly(input_file)

        if not parse_result or not parse_result.get("instructions"):
            log("Failed to parse EVM assembly", level="ERROR")
            return stats

        instructions = parse_result["instructions"]
        context = parse_result["context"]
        labels = parse_result.get("labels", {})

        stats["evm_instruction_count"] = len(instructions)

        # Optional: Generate debug info
        if options.debug_info:
            generate_debug_info(instructions)

        # Step 2: Optimize Instructions
        if options.optimize:
            log("Running optimizations...", level="INFO")
            optimized_ir = optimize_instructions(instructions, context)
            stats["optimization_passes"].append("instruction_optimization")
            stats["evm_instruction_count_after_opt"] = len(optimized_ir)
        else:
            optimized_ir = instructions

        # Step 3: Emit RISC-V Assembly
        log(f"Emitting RISC-V code to {output_file}", level="INFO")
        riscv_code = emit_riscv_assembly(optimized_ir, context, output_file=output_file)
        stats["riscv_instruction_count"] = len(riscv_code.splitlines())

        # Optional: Source Map Generation
        if options.source_map:
            create_source_map(instructions, riscv_code.splitlines())

        # Optional: Pattern Detection Report
        patterns = detect_patterns(instructions)
        stats["patterns_found"] = {k: len(v) for k, v in patterns.items()}

        stats["gas_estimate"] = context.gas_meter.get("total", 0)
        stats["success"] = True

    except Exception as e:
        log(f"Transpilation failed: {e}", level="ERROR")
        stats["error"] = str(e)
        stats["success"] = False

    finally:
        stats["end_time"] = datetime.now()
        stats["duration"] = (stats["end_time"] - stats["start_time"]).total_seconds()

    return stats


def display_statistics(stats):
    """
    Display transpilation statistics to user.
    
    Args:
        stats (dict): Statistics dictionary
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


def handle_errors(error, context=None):
    """
    Handle and report errors during transpilation.
    
    Args:
        error (Exception): Exception object
        context (CompilationContext): Current state if available
    """
    log(f"Unhandled error: {str(error)}", level="ERROR")
    print(f"\n🚨 Critical Error: {str(error)}")
    if context and hasattr(context, "function_info"):
        print(f"Current function: {context.function_info.get('name', 'unknown')}")
    sys.exit(1)


def main():
    """
    Main entry point for CLI execution.
    """
    args = parse_arguments()

    if not validate_input_file(args.input):
        sys.exit(1)

    configure_logging(args)

    log(f"Starting EVM-to-RISC-V transpiler", level="INFO")

    try:
        stats = run_transpilation_pipeline(
            input_file=args.input,
            output_file=args.output,
            options=args
        )

        display_statistics(stats)

        if not stats["success"]:
            sys.exit(1)

    except Exception as e:
        handle_errors(e)


if __name__ == "__main__":
    main()