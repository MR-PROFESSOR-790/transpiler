# stack_emulator.py - Stack emulation for EVM-to-RISC-V transpiler

import logging


class StackEmulator:
    """
    Class responsible for simulating the EVM stack and tracking its effects.
    
    Provides push/pop, DUP/SWAP handling, stack effect calculation,
    and consistency validation across instructions.
    """

    MAX_EVM_STACK_SIZE = 1024  # Maximum allowed stack size per EVM spec

    def __init__(self, context):
        """
        Initialize stack emulator with shared compilation context.

        Args:
            context (object): Shared state object (e.g., Context)
        """
        self.context = context
        self.initialize_stack_model()
        self.initialize_memory_model()
    
    def initialize_memory_model(self):
        """
        Initialize the memory model within the compilation context.
        """
        if not hasattr(self.context, "memory"):
            self.context.memory = {
                "base": "MEM_BASE",  # Symbolic constant defined in runtime.s
                "size": 0,
                "allocated": {},     # Map offset -> value (for testing/debugging)
                "last_used": 0
            }
        logging.debug("Memory model initialized")

    def initialize_stack_model(self):
        """
        Initialize the stack simulation within the compilation context.
        """
        self.context.stack_height = 0
        if not hasattr(self.context, "stack"):
            self.context.stack = {
                "size": 0,
                "max_size": 0,
                "history": [],
                "spill_offsets": {}  # Used by register allocator
            }
        logging.debug("Stack model initialized")

    def push_value(self, value, stack_state=None):
        """
        Push a value onto the simulated stack.
        
        Args:
            value: Value to push
            stack_state (dict): Optional custom stack state
        Returns:
            bool: True if successful, False on overflow
        """
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
        """
        Pop a value from the simulated stack.
        
        Args:
            stack_state (dict): Current stack state
        Returns:
            any: Popped value or None on underflow
        """
        if stack_state is None:
            stack_state = self.context.stack

        if stack_state["size"] <= 0:
            logging.error("Stack underflow detected")
            return None

        value = stack_state["history"].pop()
        stack_state["size"] -= 1
        logging.debug(f"Popped value {value}, new stack size: {stack_state['size']}")
        return value

    def dup_value(self, position: int, stack_state=None):
        """
        Duplicate the value at the given position (DUP1 to DUP16).
        
        Args:
            position (int): 1-based index of item to duplicate
            stack_state (dict): Current stack state
        Returns:
            bool: True if successful
        """
        if stack_state is None:
            stack_state = self.context.stack

        if position < 1 or position > 16:
            logging.error("Invalid DUP position")
            return False

        if stack_state["size"] < position:
            logging.error(f"Not enough elements to DUP{position}")
            return False

        val = stack_state["history"][-position]
        return self.push_value(val, stack_state)

    def swap_values(self, position: int, stack_state=None):
        """
        Swap top of stack with the value at the given position (SWAP1 to SWAP16).
        
        Args:
            position (int): 1-based index of item to swap with top
            stack_state (dict): Current stack state
        Returns:
            bool: True if successful
        """
        if stack_state is None:
            stack_state = self.context.stack

        if position < 1 or position > 16:
            logging.error("Invalid SWAP position")
            return False

        if stack_state["size"] < position + 1:
            logging.error(f"Not enough elements to SWAP{position}")
            return False

        top = stack_state["history"][-1]
        target = stack_state["history"][-(position + 1)]

        stack_state["history"][-1] = target
        stack_state["history"][-(position + 1)] = top

        return True

    def calculate_stack_effect(self, opcode: str) -> int:
        """
        Calculate net effect of an opcode on the stack.
        
        Args:
            opcode (str): EVM instruction name
        Returns:
            int: Net change in stack size
        """
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

            "AND": -1,
            "OR": -1,
            "XOR": -1,
            "NOT": 0,
            "BYTE": -1,

            "CALLDATALOAD": 0,
            "CALLDATACOPY": -2,
            "CODECOPY": -2,

            "POP": -1,
            "MLOAD": 0,
            "MSTORE": -2,
            "MSTORE8": -2,
            "JUMP": -1,
            "JUMPI": -2,
            "PC": +1,
            "MSIZE": +1,
            "GAS": +1,

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
            "INVALID": 0
        }

        return stack_effects.get(opcode, 0)

    def simulate_instruction_stack_effect(self, instruction: dict, stack_state=None):
        """
        Apply the stack effect of a single instruction.
        
        Args:
            instruction (dict): EVM instruction
            stack_state (dict): Optional custom stack state
        Returns:
            bool: True if operation was safe
        """
        if stack_state is None:
            stack_state = self.context.stack

        opcode = instruction.get("opcode", "")
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
            opcode = instr.get("opcode", "")

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


# Make it available at module level
__all__ = ['StackEmulator']