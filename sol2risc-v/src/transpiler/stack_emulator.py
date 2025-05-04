class StackEmulator:
    def __init__(self, stack_base=0x80000000, stack_size=1024):
        if stack_size > 1024:
            raise ValueError("EVM stack size cannot exceed 1024")
        self.stack_base = stack_base
        self.stack_size = stack_size
        self.stack_ptr = 0
        self.stack = []  # Initialize the stack as an empty list
    
    def push(self, value):
        if self.stack_ptr >= self.stack_size:
            raise OverflowError("EVM Stack overflow")
        self.stack.append(value)
        self.stack_ptr += 1
    
    def pop(self):
        if self.stack_ptr <= 0:
            raise IndexError("EVM Stack underflow")
        self.stack_ptr -= 1
        return self.stack.pop()
    
    def peek(self, depth=0):
        if depth >= self.stack_ptr:
            raise IndexError("EVM stack peek out of bounds")
        return self.stack[self.stack_ptr - 1 - depth]
    
    def set(self, depth, value):
        if depth >= self.stack_ptr:
            raise IndexError("EVM stack set out of bounds")
        self.stack[self.stack_ptr - 1 - depth] = value
    
    def dump(self):
        # Return a reversed view of the active stack
        return self.stack[:self.stack_ptr][::-1]
    
    def reset(self):
        self.stack_ptr = 0
        self.stack = []

    def map_to_registers(self, register_allocator):
        """
        Maps the current stack state to RISC-V registers using a register allocator.
        Only the top few elements of the stack are loaded into registers, as per availability.

        Args:
            register_allocator: An instance of a register allocator that manages RISC-V registers.

        Returns:
            A tuple:
              - List of RISC-V instructions to load stack values into registers.
              - Dictionary mapping stack indices to registers (0 is top).
        """
        instructions = []
        stack_to_register_map = {}

        stack_snapshot = self.dump()  # Top of stack is index 0
        for i, value in enumerate(stack_snapshot):
            reg = register_allocator.allocate()
            if reg is None:
                instructions.append(f"# Warning: No register available for stack index {i}")
                break
            instructions.append(f"li {reg}, {value}  # Stack[{i}] -> {reg}")
            stack_to_register_map[i] = reg

        return instructions, stack_to_register_map
