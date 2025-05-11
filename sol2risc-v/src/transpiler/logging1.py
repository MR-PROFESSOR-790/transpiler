# logging.py - Unified logging and debugging infrastructure for the transpiler

import os
import json
from datetime import datetime
from pprint import pformat


LOG_LEVELS = {
    "NONE": 0,
    "ERROR": 1,
    "WARN": 2,
    "INFO": 3,
    "DEBUG": 4
}

CURRENT_LOG_LEVEL = LOG_LEVELS["INFO"]


class TranspilerLogger:
    """
    Class responsible for providing structured logging across all components.
    
    Supports instruction processing, transformations, optimizations, errors,
    debug info generation, and source mapping.
    """

    def __init__(self):
        self.current_log_level = CURRENT_LOG_LEVEL
        self.log_levels = LOG_LEVELS

    # --- Public Methods ---

    def initialize_logger(self, log_level="INFO"):
        """
        Initialize the logger with a given log level.

        Args:
            log_level (str): One of NONE, ERROR, WARN, INFO, DEBUG
        """
        if log_level in self.log_levels:
            self.current_log_level = self.log_levels[log_level]
        else:
            raise ValueError(f"Invalid log level: {log_level}")
        self.log("Logger initialized", level="INFO")

    def log(self, message, level="INFO"):
        """
        Log a message if the current log level allows it.

        Args:
            message (str): Message to log
            level (str): Severity level (ERROR/WARN/INFO/DEBUG)
        """
        if self.log_levels[level] <= self.current_log_level:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{timestamp}] [{level}] {message}")

    def log_instruction_processing(self, instruction, context=None):
        """
        Log that an instruction is being processed.

        Args:
            instruction (dict): EVM instruction dictionary
            context (object): Optional compilation state
        """
        opcode = instruction.get("opcode", "UNKNOWN")
        self.log(f"Processing instruction: {opcode}", level="DEBUG")

    def log_transformation(self, original_instr, transformed_instr):
        """
        Log when an instruction or sequence is transformed.

        Args:
            original_instr (list or dict): Original instruction(s)
            transformed_instr (list or dict): Transformed instruction(s)
        """
        self.log(
            f"Instruction transformation:\nOriginal:\n{pformat(original_instr)}\n→\nTransformed:\n{pformat(transformed_instr)}",
            level="INFO"
        )

    def log_optimization(self, before, after, reason):
        """
        Log an optimization pass result.

        Args:
            before (list): Instructions before optimization
            after (list): Instructions after optimization
            reason (str): Why the optimization was applied
        """
        self.log(f"Optimization applied: {reason}", level="INFO")
        self.log(f"Before: {before}", level="DEBUG")
        self.log(f"After: {after}", level="DEBUG")

    def log_error(self, error_message, instruction=None, context=None):
        """
        Log an error during compilation.

        Args:
            error_message (str): Description of the error
            instruction (dict or None): Instruction where error occurred
            context (object or None): Current compilation state
        """
        msg = f"[ERROR] {error_message}"
        if instruction:
            msg += f"\nAt instruction: {instruction.get('opcode', 'unknown')}"
        self.log(msg, level="ERROR")

    def generate_debug_info(self, instructions, output_file="debug_info.json"):
        """
        Generate a JSON file containing detailed debug info about the instruction stream.

        Args:
            instructions (list): List of EVM instructions
            output_file (str): File to write debug info to
        """
        debug_data = []
        for idx, instr in enumerate(instructions):
            debug_data.append({
                "index": idx,
                "opcode": instr.get("opcode"),
                "args": instr.get("args", []),
                "source_line": instr.get("source_line", -1),
                "comment": instr.get("comment", "")
            })

        with open(output_file, "w") as f:
            json.dump(debug_data, f, indent=2)

        self.log(f"Debug info written to {output_file}", level="INFO")

    def create_source_map(self, evm_instructions, riscv_instructions, output_file="sourcemap.json"):
        """
        Create a mapping between EVM and RISC-V instructions for debugging.

        Args:
            evm_instructions (list): EVM IR list
            riscv_instructions (list): RISC-V assembly list
            output_file (str): Path to save the sourcemap
        """
        sourcemap = {}
        riscv_index = 0
        for evm_idx, evm_instr in enumerate(evm_instructions):
            sourcemap[f"evm_{evm_idx}"] = []
            while riscv_index < len(riscv_instructions):
                riscv_instr = riscv_instructions[riscv_index]
                sourcemap[f"evm_{evm_idx}"].append(riscv_index)
                riscv_index += 1
                # Stop at label boundaries or clear instruction boundaries
                if isinstance(riscv_instr, str) and riscv_instr.endswith(":"):
                    break
                elif isinstance(riscv_instr, dict) and riscv_instr.get("type") == "label":
                    break

        with open(output_file, "w") as f:
            json.dump(sourcemap, f, indent=2)

        self.log(f"Source map written to {output_file}", level="INFO")