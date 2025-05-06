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
            logger.error(f"Stack overflow: tried to push {value} at position {self.stack_ptr}")
            raise OverflowError("EVM Stack overflow")
        self.stack.append(value)
        self.stack_ptr += 1
        logger.debug(f"Pushed {value} to stack. SP={self.stack_ptr}")

    def pop(self):
        if self.stack_ptr <= 0:
            logger.error("Stack underflow: tried to pop from empty stack")
            raise IndexError("EVM Stack underflow")
        self.stack_ptr -= 1
        value = self.stack.pop()
        logger.debug(f"Popped {value} from stack. SP={self.stack_ptr}")
        return value

    def peek(self, depth=0):
        """
        Peek at a value in the stack without removing it.
        Args:
            depth: How far down the stack to look (0 = top of stack)
        Returns:
            The value at the specified depth, or 0 if stack is empty/out of bounds
        """
        # Add bounds checking
        if depth < 0:
            logger.error(f"Invalid peek depth: {depth}")
            return 0
        
        if self.stack_ptr == 0:
            logger.warning("Cannot peek: stack is empty, returning 0")
            return 0

        if depth >= self.stack_ptr:
            logger.warning(f"Stack peek out of bounds: depth={depth}, stack_ptr={self.stack_ptr}, returning 0")
            return 0
            
        value = self.stack[self.stack_ptr - 1 - depth]
        logger.debug(f"Peeked at depth {depth}: {value}")
        return value

    def set(self, depth, value):
        """
        Set a value at a specific depth in the stack.
        Args:
            depth: How far down the stack to set (0 = top of stack)
            value: Value to set
        """
        if depth < 0:
            logger.error(f"Invalid set depth: {depth}")
            raise ValueError("Set depth cannot be negative")
            
        if depth >= self.stack_ptr:
            logger.error(f"Stack set out of bounds: depth={depth}, stack_ptr={self.stack_ptr}")
            return False
            
        self.stack[self.stack_ptr - 1 - depth] = value
        logger.debug(f"Set value at depth {depth} to {value}")
        return True

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
