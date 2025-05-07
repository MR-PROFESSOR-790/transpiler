from typing import List, Dict

class StackManager:
    def __init__(self, register_allocator):
        self.register_allocator = register_allocator
        self.stack_height = 0
        self.max_stack = 1024
        self.cached_values = {}

    def push(self, value):
        """Push value to stack with register optimization"""
        if self.stack_height >= self.max_stack:
            raise Exception("Stack overflow")
            
        reg = self.register_allocator.allocate()
        if reg:
            self.cached_values[self.stack_height] = reg
            return reg
        return self._fallback_to_memory(value)
