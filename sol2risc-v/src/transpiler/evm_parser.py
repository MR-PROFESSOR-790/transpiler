# evm_parser.py - Parser for EVM assembly into structured IR

import re
import logging


class EvmParser:
    """
    Class responsible for parsing EVM assembly into structured IR.
    
    Handles tokenization, validation, control flow graph construction,
    jump resolution, function boundary detection, and stack effect analysis.
    """

    KNOWN_OPCODES = {
        "STOP", "ADD", "MUL", "SUB", "DIV", "SDIV", "MOD", "SMOD", "ADDMOD", "MULMOD",
        "EXP", "SIGNEXTEND", "LT", "GT", "SLT", "SGT", "EQ", "ISZERO", "AND", "OR", "XOR",
        "NOT", "BYTE", "SHL", "SHR", "SAR", "POP", "MLOAD", "MSTORE", "MSTORE8",
        "SLOAD", "SSTORE", "JUMP", "JUMPI", "PC", "MSIZE", "GAS", "JUMPDEST",
        "PUSH0", "PUSH1", "PUSH2", "PUSH3", "PUSH4", "PUSH5", "PUSH6", "PUSH7", "PUSH8",
        "PUSH9", "PUSH10", "PUSH11", "PUSH12", "PUSH13", "PUSH14", "PUSH15", "PUSH16",
        "PUSH17", "PUSH18", "PUSH19", "PUSH20", "PUSH21", "PUSH22", "PUSH23", "PUSH24",
        "PUSH25", "PUSH26", "PUSH27", "PUSH28", "PUSH29", "PUSH30", "PUSH31", "PUSH32",
        "DUP1", "DUP2", "DUP3", "DUP4", "DUP5", "DUP6", "DUP7", "DUP8", "DUP9", "DUP10",
        "DUP11", "DUP12", "DUP13", "DUP14", "DUP15", "DUP16",
        "SWAP1", "SWAP2", "SWAP3", "SWAP4", "SWAP5", "SWAP6", "SWAP7", "SWAP8", "SWAP9",
        "SWAP10", "SWAP11", "SWAP12", "SWAP13", "SWAP14", "SWAP15", "SWAP16",
        "LOG0", "LOG1", "LOG2", "LOG3", "LOG4", "CREATE", "CALL", "CALLCODE", "DELEGATECALL",
        "STATICCALL", "RETURN", "REVERT", "SELFDESTRUCT", "INVALID", "TIMESTAMP", "NUMBER",
        "DIFFICULTY", "GASLIMIT", "CHAINID", "SELFBALANCE", "BASEFEE", "COINBASE",
        "ADDRESS", "BALANCE", "ORIGIN", "CALLER", "CALLVALUE", "CALLDATALOAD", "CALLDATASIZE",
        "CALLDATACOPY", "CODESIZE", "CODECOPY", "RETURNDATASIZE", "RETURNDATACOPY", "EXTCODESIZE",
        "EXTCODECOPY", "EXTCODEHASH", "BLOCKHASH", "PUSH0", "SHA3", "CODECOPY", "TIMESTAMP", "MSIZE",
    }

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
        self.pattern_recognizer = PatternRecognizer()
        self.pattern_recognizer.set_context(self.context)

        logging.debug("Parser dependencies initialized")

    def parse_evm_assembly(self, input_file: str):
        """
        Main entry point to parse EVM assembly into structured IR.
        
        Args:
            input_file (str): Path to .asm file containing EVM assembly
        Returns:
            dict: Parsed instruction list in IR format + metadata
        """
        logging.info(f"Parsing EVM assembly from {input_file}")
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
                logging.error(f"Failed to parse line: {line}")
                continue

            # Validate instruction
            if not self.validate_instruction(instr):
                logging.warning(f"Invalid instruction skipped: {instr}")
                continue

            # Track jump destinations
            if instr["opcode"] == "JUMPDEST":
                instr["jumpdest"] = True

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

        logging.info(f"Parsed {len(instructions)} instructions")
        return {
            "instructions": instructions,
            "cfg": self.cfg,
            "functions": self.function_boundaries,
            "labels": self.labels,
            "context": self.context
        }

    def _read_input_lines(self, input_file: str):
        try:
            with open(input_file, 'r') as f:
                return f.readlines()
        except Exception as e:
            logging.error(f"Failed to read input file: {e}")
            return []

    def tokenize_instruction(self, line: str) -> dict:
        """
        Convert a single EVM assembly line into an instruction dictionary.
        
        Args:
            line (str): Line of EVM assembly
        Returns:
            dict: Parsed instruction with opcode and args
        """
        if not line or line.startswith(";"):
            return None
        

        # Remove hex address prefix like '001A:'
        line = re.sub(r'^[0-9a-fA-F]{2,}:\s*', '', line).strip()

        if not line:
            return None

        parts = re.split(r'\s+', line, maxsplit=1)
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
        if not instruction:
            return False

        opcode = instruction.get("opcode", "").upper()
        args = instruction.get("args", [])

        if not opcode:
            return False

        if opcode not in self.KNOWN_OPCODES and not opcode.startswith(("UNKNOWN_", "0x")):
            logging.warning(f"Unknown opcode for validation: {opcode}")
            return True  # Allow unknown opcodes but skip further checks

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
        logging.info("Building control flow graph...")
        cfg = {}

        for i, instr in enumerate(instructions):
            opcode = instr.get("opcode", "")
            if opcode in ["JUMP", "JUMPI"]:
                cfg[i] = []
            elif opcode == "JUMPDEST":
                pass
            else:
                cfg[i] = [i + 1] if i + 1 < len(instructions) else []

        for i, instr in enumerate(instructions):
            opcode = instr.get("opcode", "")
            if opcode == "JUMP" and "target_index" in instr:
                cfg[i].append(instr["target_index"])
            elif opcode == "JUMPI" and "target_index" in instr:
                cfg[i].append(instr["target_index"])

        return cfg

    def resolve_jumps(self, instructions: list, labels: dict):
        logging.info("Resolving jump destinations...")
        for instr in instructions:
            if instr.get("opcode") in ["JUMP", "JUMPI"]:
                target_label = instr.get("value", "").strip()
                instr["target_index"] = labels.get(target_label, -1)

    def detect_function_boundaries(self, instructions: list):
        logging.info("Detecting function boundaries...")
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
        logging.info("Analyzing stack effects...")
        for instr in instructions:
            if instr.get("type") == "label":
                continue

            opcode = instr.get("opcode", "").upper()
            delta = self.calculate_stack_effect(opcode)
            instr["stack_effect"] = delta