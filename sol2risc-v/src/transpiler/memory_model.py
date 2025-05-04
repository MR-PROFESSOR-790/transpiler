import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MemoryModel:
    WORD_SIZE = 4  
    INITIAL_MEMORY_SIZE = 1024 

    def __init__(self):
        self.memory = [0] * self.INITIAL_MEMORY_SIZE  
        self.stack = []  
        self.sp_pointer = 0  

    def push(self, value: int):
        """Push an integer onto the simulated stack."""
        self.stack.append(value)
        self.sp_pointer += 1
        logger.debug(f"Pushed to stack: {value}")

    def pop(self) -> int:
        """Pop an integer from the simulated stack."""
        if self.sp_pointer == 0:
            raise IndexError("Stack underflow")
        self.sp_pointer -= 1
        value = self.stack.pop()
        logger.debug(f"Popped from stack: {value}")
        return value

    def peek(self) -> int:
        """Peek at the top value of the stack."""
        if self.sp_pointer == 0:
            raise IndexError("Stack is empty")
        return self.stack[-1]

    def store(self, index: int, value: int):
        """Store a 4-byte word (int) at memory index (word-aligned)."""
        if index < 0:
            raise IndexError("Negative memory access")
        if not isinstance(value, int):
            raise ValueError("Only integer values are supported for memory store")

        # Ensure enough space
        while index + self.WORD_SIZE > len(self.memory):
            self.memory.extend([0] * self.WORD_SIZE)

        # Store 4 bytes (little endian)
        bytes_value = value.to_bytes(self.WORD_SIZE, byteorder="little")
        for i in range(self.WORD_SIZE):
            self.memory[index + i] = bytes_value[i]
        logger.info(f"Stored int value at index {index}: {value} (bytes: {bytes_value.hex()})")

    def load(self, index: int) -> int:
        """Load a 4-byte word from memory and return as integer."""
        if index < 0 or index + self.WORD_SIZE > len(self.memory):
            raise IndexError("Memory access out of bounds")

        bytes_value = bytes(self.memory[index:index + self.WORD_SIZE])
        value = int.from_bytes(bytes_value, byteorder="little")
        logger.info(f"Loaded int value from index {index}: {value} (bytes: {bytes_value.hex()})")
        return value

    def reset(self):
        """Reset memory and stack."""
        self.memory = [0] * self.INITIAL_MEMORY_SIZE
        self.stack = []
        self.sp_pointer = 0
        logger.info("Memory and stack reset")

    def dump(self):
        return {
            "stack": self.stack.copy(),
            "memory": self.memory.copy()
        }

    def size(self):
        return len(self.memory)

    def __str__(self):
        return f"MemoryModel(size={self.size()}, sp={self.sp_pointer}, stack={self.stack})"
