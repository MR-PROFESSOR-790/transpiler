class StackEmulator:
    """
    Emulates EVM stack operations using RISC-V registers and memory
    
    The EVM uses a stack-based architecture with operations like PUSH, POP,
    DUP, and SWAP. This class maps those operations to RISC-V register operations
    and handles register spilling when necessary.
    """
    
    def __init__(self, register_allocator):
        self.register_allocator = register_allocator
        self.stack = []  # List of register names that represent stack items
        self.spill_base = "sp"  # Base register for spilled stack items
        self.spill_offset = 0   # Current offset for spilled items
        self.max_stack_size = 1024  # Maximum allowed stack size in EVM
    
    def push(self):
        """
        Simulate PUSH operation
        
        Allocates a register for a new stack item and returns it
        """
        if len(self.stack) >= self.max_stack_size:
            raise ValueError("Stack overflow: exceeded EVM maximum stack size")
        
        # Try to get a register
        reg = self.register_allocator.allocate_register()
        
        if reg:
            # Register available, use it
            self.stack.append(reg)
            return reg
        else:
            # No registers available, spill to memory
            return self._spill_and_push()
    
    def pop(self):
        """
        Simulate POP operation
        
        Removes the top stack item and returns its register
        """
        if not self.stack:
            raise ValueError("Stack underflow: attempted to pop from empty stack")
        
        reg = self.stack.pop()
        
        # If this was a spilled register, mark the spill slot as free
        if reg.startswith("spill:"):
            # This was a spilled value, load it before returning
            spill_slot = int(reg[6:])
            real_reg = self.register_allocator.allocate_register(temporary=True)
            return self._load_from_spill(real_reg, spill_slot)
        else:
            # Free the register for reuse
            self.register_allocator.free_register(reg)
            return reg
    
    def get_top(self):
        """Get the register of the top stack item without popping it"""
        if not self.stack:
            raise ValueError("Stack underflow: attempted to access empty stack")
        
        reg = self.stack[-1]
        
        # If this is a spilled register, load it
        if reg.startswith("spill:"):
            spill_slot = int(reg[6:])
            real_reg = self.register_allocator.allocate_register(temporary=True)
            return self._load_from_spill(real_reg, spill_slot)
        
        return reg
    
    def get_nth_from_top(self, n):
        """
        Get the register of the nth item from the top of stack
        
        Used for DUP and SWAP operations
        """
        if n <= 0 or n > len(self.stack):
            raise ValueError(f"Invalid stack access: attempted to access item {n} from stack of size {len(self.stack)}")
        
        reg = self.stack[-n]
        
        # If this is a spilled register, load it
        if reg.startswith("spill:"):
            spill_slot = int(reg[6:])
            real_reg = self.register_allocator.allocate_register(temporary=True)
            return self._load_from_spill(real_reg, spill_slot)
        
        return reg
    
    def dup(self, n):
        """
        Implement DUP<n> operation
        
        Duplicates the nth stack item from the top and pushes it
        """
        if n <= 0 or n > len(self.stack):
            raise ValueError(f"Invalid DUP: attempted to duplicate item {n} from stack of size {len(self.stack)}")
        
        # Get register of item to duplicate
        src_reg = self.get_nth_from_top(n)
        
        # Push new register on stack
        dest_reg = self.push()
        
        # If dest_reg is a spill slot, we need to store to it
        if dest_reg.startswith("spill:"):
            spill_slot = int(dest_reg[6:])
            temp_reg = self.register_allocator.allocate_register(temporary=True)
            self.register_allocator.emit(f"mv {temp_reg}, {src_reg}")
            self._store_to_spill(temp_reg, spill_slot)
            self.register_allocator.free_register(temp_reg)
            return dest_reg
        
        # Copy the value
        self.register_allocator.emit(f"mv {dest_reg}, {src_reg}")
        return dest_reg
    
    def swap(self, n):
        """
        Implement SWAP<n> operation
        
        Swaps the top stack item with the (n+1)th item
        """
        if n <= 0 or n + 1 > len(self.stack):
            raise ValueError(f"Invalid SWAP: attempted to swap with item {n+1} from stack of size {len(self.stack)}")
        
        # Get registers to swap
        top_reg = self.get_top()
        other_reg = self.get_nth_from_top(n + 1)
        
        # Swap the values
        # Need to handle cases where one or both are spill slots
        if top_reg.startswith("spill:") or other_reg.startswith("spill:"):
            # Complex case with spill slots - use temporary register
            temp_reg = self.register_allocator.allocate_register(temporary=True)
            
            # Load both values into registers if needed
            if top_reg.startswith("spill:"):
                top_spill = int(top_reg[6:])
                top_real_reg = self._load_from_spill(temp_reg, top_spill)
            else:
                top_real_reg = top_reg
                self.register_allocator.emit(f"mv {temp_reg}, {top_reg}")
            
            if other_reg.startswith("spill:"):
                other_spill = int(other_reg[6:])
                other_real_reg = self.register_allocator.allocate_register(temporary=True)
                other_real_reg = self._load_from_spill(other_real_reg, other_spill)
                
                # Store other value to top's location
                if top_reg.startswith("spill:"):
                    self._store_to_spill(other_real_reg, top_spill)
                else:
                    self.register_allocator.emit(f"mv {top_reg}, {other_real_reg}")
                
                self.register_allocator.free_register(other_real_reg)
            else:
                # Store other value to top's location
                if top_reg.startswith("spill:"):
                    self._store_to_spill(other_reg, top_spill)
                else:
                    self.register_allocator.emit(f"mv {top_reg}, {other_reg}")
            
            # Store temp (original top) to other's location
            if other_reg.startswith("spill:"):
                self._store_to_spill(temp_reg, other_spill)
            else:
                self.register_allocator.emit(f"mv {other_reg}, {temp_reg}")
            
            self.register_allocator.free_register(temp_reg)
        else:
            # Simple case - both are registers
            self.register_allocator.emit(f"mv t0, {top_reg}")
            self.register_allocator.emit(f"mv {top_reg}, {other_reg}")
            self.register_allocator.emit(f"mv {other_reg}, t0")
    
    def _spill_and_push(self):
        """Spill a value to memory and return spill slot identifier"""
        spill_slot = self.spill_offset // 4
        self.spill_offset += 4
        spill_id = f"spill:{spill_slot}"
        self.stack.append(spill_id)
        return spill_id
    
    def _store_to_spill(self, reg, slot):
        """Store a register value to a spill slot"""
        offset = slot * 4
        self.register_allocator.emit(f"sw {reg}, {offset}({self.spill_base})")
    
    def _load_from_spill(self, reg, slot):
        """Load a value from a spill slot into a register"""
        offset = slot * 4
        self.register_allocator.emit(f"lw {reg}, {offset}({self.spill_base})")
        return reg
    
    def reset(self):
        """Reset the stack to empty state"""
        # Free all allocated registers
        for reg in self.stack:
            if not reg.startswith("spill:"):
                self.register_allocator.free_register(reg)
        self.stack.clear()
        self.spill_offset = 0
    
    def validate_stack_size(self, required_size):
        """Validate stack has enough items"""
        if len(self.stack) < required_size:
            raise ValueError(f"Stack underflow: required {required_size} items but stack has {len(self.stack)}")
    
    def optimize_stack_layout(self):
        """Optimize stack layout by minimizing spills"""
        new_stack = []
        spilled = []
        
        # Try to move spilled values back to registers where possible
        for item in self.stack:
            if item.startswith("spill:"):
                spilled.append(item)
            else:
                new_stack.append(item)
        
        # Try to allocate registers for spilled values
        for spill in spilled:
            reg = self.register_allocator.allocate_register()
            if reg:
                # Load from spill to register
                slot = int(spill[6:])
                self._load_from_spill(reg, slot)
                new_stack.append(reg)
            else:
                new_stack.append(spill)
        
        self.stack = new_stack
    
    def get_stack_size(self):
        """Return current stack size"""
        return len(self.stack)
    
    def get_spill_count(self):
        """Return number of spilled stack items"""
        return sum(1 for item in self.stack if item.startswith("spill:"))