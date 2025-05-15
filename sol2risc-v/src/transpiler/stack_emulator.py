# stack_emulator.py - Stack emulation for EVM-to-RISC-V transpiler

import re
import logging


class StackEmulator:
    """
    Class responsible for simulating the EVM stack and tracking its effects.
    """

    MAX_EVM_STACK_SIZE = 1024  # Maximum allowed stack size per EVM spec

    def __init__(self, context=None):
        self.context = context
        self.initialize_stack_model()
        self.initialize_memory_model()

    def initialize_memory_model(self):
        """Initialize the memory model within the compilation context."""
        if not hasattr(self.context, "memory"):
            self.context.memory = {
                "base": 0x80000000,  # Use actual address instead of symbolic
                "size": 4096,        # Initial 4KB
                "allocated": {},
                "last_used": 0
            }
        logging.debug("Memory model initialized")

    def initialize_stack_model(self):
        if not hasattr(self.context, "stack"):
            self.context.stack = {
                "size": 0,
                "history": [],
                "max_size": 0
            }
        logging.debug("Stack model initialized")

    def push_value(self, value, stack_state=None):
        if stack_state is None:
            stack_state = self.context.stack

        if stack_state["size"] >= self.MAX_EVM_STACK_SIZE:
            logging.error("Stack overflow detected")
            return False

        stack_state["size"] += 1
        stack_state["history"].append(value)
        stack_state["max_size"] = max(stack_state["max_size"], stack_state["size"])
        logging.debug(f"Pushed value {value}, new stack size: {stack_state['size']}")
        return True

    def pop_value(self, stack_state=None):
        if stack_state is None:
            stack_state = self.context.stack

        if stack_state["size"] <= 0:
            logging.error("Stack underflow detected")
            return None

        value = stack_state["history"].pop()
        stack_state["size"] -= 1
        logging.debug(f"Popped value {value}, new stack size: {stack_state['size']}")
        return value

    def calculate_stack_effect(self, opcode: str) -> int:
        """
        Calculate net change in stack size for a given EVM opcode.
        Uses internal mapping and handles PUSH/DUP/SWAP/LOG patterns.
        """
        base_opcode = re.split(r'\s|:', opcode)[0].upper()

        stack_effects = {
            "STOP": 0,
            "ADD": -1,
            "MUL": -1,
            "SUB": -1,
            "DIV": -1,
            "SDIV": -1,
            "MOD": -1,
            "SMOD": -1,
            "ADDMOD": -2,
            "MULMOD": -2,
            "EXP": -1,
            "LT": -1,
            "GT": -1,
            "SLT": -1,
            "SGT": -1,
            "EQ": -1,
            "ISZERO": -1,
            "AND": -1,
            "OR": -1,
            "XOR": -1,
            "NOT": 0,
            "BYTE": -1,
            "SHL": -1,
            "SHR": -1,
            "SAR": -1,
            "SHA3": -1,
            "TIMESTAMP": +1,
            "MSIZE": +1,
            "CODECOPY": -2,
            "CALLVALUE": +1,
            "POP": -1,
            "MLOAD": 0,
            "MSTORE": -2,
            "MSTORE8": -2,
            "SLOAD": 0,
            "SSTORE": -2,
            "JUMP": -1,
            "JUMPI": -2,
            "PC": +1,
            "MSIZE": +1,
            "GAS": +1,
            "JUMPDEST": 0,
            "PUSH0": +1,
            "PUSH1": +1,
            "PUSH2": +1,
            "PUSH3": +1,
            "PUSH4": +1,
            "PUSH5": +1,
            "PUSH6": +1,
            "PUSH7": +1,
            "PUSH8": +1,
            "PUSH9": +1,
            "PUSH10": +1,
            "PUSH11": +1,
            "PUSH12": +1,
            "PUSH13": +1,
            "PUSH14": +1,
            "PUSH15": +1,
            "PUSH16": +1,
            "PUSH17": +1,
            "PUSH18": +1,
            "PUSH19": +1,
            "PUSH20": +1,
            "PUSH21": +1,
            "PUSH22": +1,
            "PUSH23": +1,
            "PUSH24": +1,
            "PUSH25": +1,
            "PUSH26": +1,
            "PUSH27": +1,
            "PUSH28": +1,
            "PUSH29": +1,
            "PUSH30": +1,
            "PUSH31": +1,
            "PUSH32": +1,
            "DUP1": +1,
            "DUP2": +1,
            "DUP3": +1,
            "DUP4": +1,
            "DUP5": +1,
            "DUP6": +1,
            "DUP7": +1,
            "DUP8": +1,
            "DUP9": +1,
            "DUP10": +1,
            "DUP11": +1,
            "DUP12": +1,
            "DUP13": +1,
            "DUP14": +1,
            "DUP15": +1,
            "DUP16": +1,
            "SWAP1": 0,
            "SWAP2": 0,
            "SWAP3": 0,
            "SWAP4": 0,
            "SWAP5": 0,
            "SWAP6": 0,
            "SWAP7": 0,
            "SWAP8": 0,
            "SWAP9": 0,
            "SWAP10": 0,
            "SWAP11": 0,
            "SWAP12": 0,
            "SWAP13": 0,
            "SWAP14": 0,
            "SWAP15": 0,
            "SWAP16": 0,
            "LOG0": -2,
            "LOG1": -3,
            "LOG2": -4,
            "LOG3": -5,
            "LOG4": -6,
            "CREATE": -3,
            "CALL": -7,
            "CALLCODE": -7,
            "DELEGATECALL": -6,
            "STATICCALL": -6,
            "RETURN": -2,
            "REVERT": -2,
            "SELFDESTRUCT": -1,
            "INVALID": 0,
            "CALLVALUE": +1,
            "CALLDATASIZE": +1,
            "CALLDATACOPY": -2,
            "CODESIZE": +1,
            "CODECOPY": -2,
            "TIMESTAMP": +1,
            "NUMBER": +1,
            "DIFFICULTY": +1,
            "GASLIMIT": +1,
            "CHAINID": +1,
            "SELFBALANCE": +1,
            "BASEFEE": +1,
            "COINBASE": +1,
            "ADDRESS": +1,
            "BALANCE": +1,
            "ORIGIN": +1,
            "CALLER": +1,
            "CALLDATALOAD": 0,
            "CALLDATACOPY": -2,
            "RETURNDATASIZE": +1,
            "RETURNDATACOPY": -2,
            "EXTCODESIZE": +1,
            "EXTCODECOPY": -2,
            "EXTCODEHASH": +1,
            "BLOCKHASH": +1,
            
        }

        # Handle numbered opcodes via pattern matching
        if base_opcode.startswith("PUSH") and base_opcode != "PUSH0":
            return +1
        elif base_opcode.startswith("DUP"):
            return +1
        elif base_opcode.startswith("SWAP"):
            return 0
        elif base_opcode.startswith("LOG"):
            try:
                n = int(base_opcode[3:])
                return -(n + 2)
            except ValueError:
                pass

        return stack_effects.get(base_opcode, 0)

    def simulate_instruction_stack_effect(self, instruction: dict, stack_state=None):
        """
        Simulate how this instruction affects the stack.
        
        Args:
            instruction (dict): EVM instruction
            stack_state (dict): Optional custom stack state
        Returns:
            bool: True if operation was safe
        """
        if stack_state is None:
            stack_state = self.context.stack

        opcode = instruction.get("opcode", "").upper()
        delta = self.calculate_stack_effect(opcode)

        if delta > 0:
            for _ in range(delta):
                if not self.push_value(0, stack_state):  # Placeholder value
                    return False
        elif delta < 0:
            for _ in range(-delta):
                if self.pop_value(stack_state) is None:
                    return False

        return True

    def validate_stack_consistency(self, instructions: list):
        """
        Validate that the stack remains consistent across all instructions.
        
        Args:
            instructions (list): List of parsed EVM instructions
        Returns:
            bool: True if valid, False if inconsistent
        """
        stack_depth = 0
        for idx, instr in enumerate(instructions):
            if instr.get("type") == "label":
                continue

            opcode = instr.get("opcode", "").upper()
            delta = self.calculate_stack_effect(opcode)
            stack_depth += delta

            if stack_depth < 0:
                logging.error(f"Stack underflow at instruction {idx}: {opcode}")
                return False

            if stack_depth > self.MAX_EVM_STACK_SIZE:
                logging.error(f"Stack overflow at instruction {idx}: {opcode}")
                return False

        if stack_depth != 0:
            logging.warning(f"Final stack imbalance: {stack_depth} remaining items")

        logging.debug("Stack consistency check passed")
        return True