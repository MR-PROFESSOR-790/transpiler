import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class StackEmulator:
    def __init__(self, stack_base=0x80000000, stack_size=1024):
        if stack_size > 1024:
            raise ValueError("EVM stack size cannot exceed 1024")
        self.stack_base = stack_base
        self.stack_size = stack_size
        self.stack_ptr = 0
        self.stack = []

    def push(self, value):
        if self.stack_ptr >= self.stack_size:
            raise OverflowError("EVM Stack overflow")
        self.stack.append(value)
        self.stack_ptr += 1
        logger.debug(f"Pushed {value} to stack. SP={self.stack_ptr}")

    def pop(self):
        if self.stack_ptr <= 0:
            raise IndexError("EVM Stack underflow")
        self.stack_ptr -= 1
        value = self.stack.pop()
        logger.debug(f"Popped {value} from stack. SP={self.stack_ptr}")
        return value

    def peek(self, depth=0):
        if depth >= self.stack_ptr:
            raise IndexError("EVM stack peek out of bounds")
        value = self.stack[self.stack_ptr - 1 - depth]
        logger.debug(f"Peeked at depth {depth}: {value}")
        return value

    def set(self, depth, value):
        if depth >= self.stack_ptr:
            raise IndexError("EVM stack set out of bounds")
        self.stack[self.stack_ptr - 1 - depth] = value
        logger.debug(f"Set value at depth {depth} to {value}")

    def dump(self):
        return self.stack[:self.stack_ptr][::-1]

    def reset(self):
        self.stack_ptr = 0
        self.stack = []
        logger.debug("Stack reset to empty")

    def map_to_registers(self, register_allocator):
        """
        Maps the current stack state to RISC-V registers using a register allocator.
        Only the top few elements of the stack are loaded into registers, as per availability.

        Args:
            register_allocator: An instance of a register allocator that manages RISC-V registers.

        Returns:
            A tuple:
              - List of RISC-V instructions to load stack values into registers.
              - Dictionary mapping stack indices (0 = top) to registers.
        """
        instructions = []
        stack_to_register_map = {}

        stack_snapshot = self.dump()  # Top of stack is index 0
        for i, value in enumerate(stack_snapshot):
            reg = register_allocator.allocate()
            if reg.startswith("spill["):
                instructions.append(f"# Warning: Value {value} at stack[{i}] spilled, not in register")
                continue
            instructions.append(f"li {reg}, {value}  # Stack[{i}] -> {reg}")
            stack_to_register_map[i] = reg
            logger.debug(f"Mapped stack[{i}] = {value} to register {reg}")

        return instructions, stack_to_register_map
