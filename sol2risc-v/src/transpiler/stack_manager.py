from typing import List, Dict

class StackManager:
    def __init__(self, register_allocator):
        self.stack: List[str] = []
        self.reg_allocator = register_allocator
        self.stack_to_reg: Dict[int, str] = {}
        self.spill_offset = 0
        
    def push(self, value_or_reg: str) -> str:
        """Push value to stack, return assigned register"""
        reg = self.reg_allocator.allocate()
        if reg is None:
            # Handle register spilling
            spill_reg = self.spill_least_used()
            reg = spill_reg
            
        if isinstance(value_or_reg, str) and value_or_reg.startswith('x'):
            # Copy from existing register
            self.emit(f"mv {reg}, {value_or_reg}")
        else:
            # Load immediate value
            self.emit(f"li {reg}, {value_or_reg}")
            
        self.stack.append(reg)
        self.stack_to_reg[len(self.stack) - 1] = reg
        return reg

    def pop(self) -> str:
        """Pop value from stack, return register containing value"""
        if not self.stack:
            raise Exception("Stack underflow")
        reg = self.stack.pop()
        del self.stack_to_reg[len(self.stack)]
        return reg

    def spill_least_used(self) -> str:
        """Spill least recently used register to memory"""
        reg_to_spill = self.reg_allocator.get_least_used()
        self.spill_offset += 8
        self.emit(f"sd {reg_to_spill}, -{self.spill_offset}(sp)")
        return reg_to_spill

    def restore_spilled(self, reg: str):
        """Restore previously spilled register"""
        self.emit(f"ld {reg}, -{self.spill_offset}(sp)")
        self.spill_offset -= 8
