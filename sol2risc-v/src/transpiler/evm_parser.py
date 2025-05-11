# evm_parser.py - Parser for EVM assembly into intermediate representation

import re
import logging
from pprint import pformat
import json


class EvmParser:
    """
    Class responsible for parsing EVM assembly into structured IR.
    
    Handles tokenization, validation, control flow graph construction,
    jump resolution, function boundary detection, and stack effect analysis.
    """

    def __init__(self, context=None):
        """Initialize EVM parser."""
        self.context = context
        if context is not None:
            self._init_dependencies()

    def set_context(self, context):
        """Set context after initialization."""
        self.context = context
        self._init_dependencies()

    def _init_dependencies(self):
        """Initialize parser dependencies."""
        from .stack_emulator import StackEmulator
        from .context_manager import ContextManager
        from .pattern import PatternRecognizer
        
        # Initialize stack emulator
        self.stack_emulator = StackEmulator(self.context)
        self.calculate_stack_effect = self.stack_emulator.calculate_stack_effect
        
        # Initialize other components
        self.context_manager = ContextManager()
        
        # Create pattern recognizer instance correctly
        self.pattern_recognizer = PatternRecognizer()
        self.pattern_recognizer.set_context(self.context)
        self.detect_patterns = self.pattern_recognizer.detect_patterns
        
        logging.debug("Parser dependencies initialized")

    # --- Public Methods ---

    def parse_evm_assembly(self, input_file: str):
        """
        Main entry point to parse EVM assembly file into structured IR.
        
        Args:
            input_file (str): Path to .asm file containing EVM assembly
        Returns:
            dict: Parsed instruction list in IR format + metadata
        """
        logging.log(f"Parsing EVM assembly from {input_file}")
        lines = self._read_input_lines(input_file)
        instructions = []

        self.context = self.context_manager.create_transpilation_context()
        self.labels = {}
        self.label_counter = 0

        for line_num, line in enumerate(lines):
            line = line.strip()
            if not line or line.startswith(";"):
                continue

            # Handle labels
            if line.endswith(":"):
                label_name = line[:-1].strip()
                self.labels[label_name] = len(instructions)
                instructions.append({
                    "type": "label",
                    "name": label_name,
                    "index": len(instructions),
                    "line": line_num
                })
                continue

            # Tokenize line into components
            instr = self.tokenize_instruction(line)
            if not instr:
                logging.log_error(f"Failed to parse line: {line}", {"line": line}, self.context)
                continue

            # Add metadata
            instr["line"] = line_num
            instr["index"] = len(instructions)

            # Validate instruction
            if not self.validate_instruction(instr):
                logging.log_error(f"Invalid instruction: {instr}", instr, self.context)
                continue

            # Track jump destinations
            if instr["opcode"] == "JUMPDEST":
                instr["jumpdest"] = True

            # Process using shared context
            self.context_manager.update_context_for_instruction(instr, self.context)

            # Append to instruction stream
            instructions.append(instr)

        # Build CFG
        self.cfg = self.build_control_flow_graph(instructions)

        # Resolve jumps
        self.resolve_jumps(instructions, self.labels)

        # Detect function boundaries
        self.function_boundaries = self.detect_function_boundaries(instructions)

        # Analyze stack effects
        self.analyze_stack_effects(instructions)

        logging.log(f"Parsed {len(instructions)} instructions")
        return {
            "instructions": instructions,
            "cfg": self.cfg,
            "functions": self.function_boundaries,
            "labels": self.labels,
            "context": self.context
        }

    # ---------------------------
    # Internal Helpers
    # ---------------------------

    def _read_input_lines(self, input_file: str):
        """Read input file line by line."""
        try:
            with open(input_file, 'r') as f:
                return f.readlines()
        except Exception as e:
            logging.log_error(f"Failed to read input file: {e}", {})
            return []

    def tokenize_instruction(self, line: str) -> dict:
        """
        Convert a single EVM assembly line into an instruction dictionary.
        
        Args:
            line (str): Line of EVM assembly
        Returns:
            dict: Parsed instruction with opcode and args
        """
        parts = re.split(r'\s+', line.strip(), maxsplit=1)
        if not parts:
            return None

        opcode = parts[0].upper()

        args = []
        if len(parts) > 1:
            args = [arg.strip() for arg in parts[1].split(",")]

        return {
            "opcode": opcode,
            "args": args,
            "value": args[0] if len(args) == 1 else None
        }

    def validate_instruction(self, instruction: dict) -> bool:
        """
        Check if instruction conforms to expected format.
        
        Args:
            instruction (dict): Instruction dictionary
        Returns:
            bool: True if valid
        """
        opcode = instruction.get("opcode", "")
        args = instruction.get("args", [])

        if not opcode:
            return False

        # Basic validation rules
        if opcode.startswith("PUSH") and len(args) != 1:
            return False
        elif opcode.startswith("DUP") and len(args) != 0:
            return False
        elif opcode.startswith("SWAP") and len(args) != 0:
            return False
        elif opcode in ["JUMP", "JUMPI"] and len(args) != 0:
            return False

        return True

    def build_control_flow_graph(self, instructions: list) -> dict:
        """
        Build control flow graph from instruction stream.
        
        Args:
            instructions (list): List of parsed instructions
        Returns:
            dict: Control flow graph
        """
        logging.log("Building control flow graph...")
        cfg = {}

        for i, instr in enumerate(instructions):
            opcode = instr.get("opcode", "")
            if opcode in ["JUMP", "JUMPI"]:
                cfg[i] = []
            elif opcode == "JUMPDEST":
                pass  # Start of new block
            else:
                cfg[i] = [i + 1] if i + 1 < len(instructions) else []

        # Connect JUMP destinations
        for i, instr in enumerate(instructions):
            opcode = instr.get("opcode", "")
            if opcode == "JUMP":
                target = instr.get("target_index")
                if target is not None:
                    cfg[i].append(target)
            elif opcode == "JUMPI":
                target = instr.get("target_index")
                if target is not None:
                    cfg[i].append(target)

        return cfg

    def resolve_jumps(self, instructions: list, labels: dict):
        """
        Resolve symbolic jump destinations.
        
        Args:
            instructions (list): List of parsed instructions
            labels (dict): Map of label names to instruction indices
        """
        logging.log("Resolving jump destinations...")
        for instr in instructions:
            if instr.get("opcode") in ["JUMP", "JUMPI"]:
                target_label = instr.get("value", "").strip()
                if target_label in labels:
                    instr["target_index"] = labels[target_label]
                else:
                    instr["target_index"] = -1  # Unresolved

    def detect_function_boundaries(self, instructions: list):
        """
        Identify likely function boundaries based on JUMPDEST usage.
        
        Args:
            instructions (list): List of parsed instructions
        Returns:
            list: List of function boundary tuples (start, end)
        """
        logging.log("Detecting function boundaries...")
        boundaries = []
        start_idx = None

        for i, instr in enumerate(instructions):
            if instr.get("opcode") == "JUMPDEST":
                if start_idx is not None:
                    boundaries.append((start_idx, i))
                start_idx = i

        if start_idx is not None:
            boundaries.append((start_idx, len(instructions)))

        return boundaries

    def analyze_stack_effects(self, instructions: list):
        """
        Analyze and annotate each instruction with its stack effect.
        
        Args:
            instructions (list): List of parsed instructions
        """
        logging.log("Analyzing stack effects...")
        for instr in instructions:
            opcode = instr.get("opcode", "")
            delta = self.calculate_stack_effect(opcode)
            instr["stack_effect"] = delta