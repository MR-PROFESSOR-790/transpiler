import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MemoryModel:
    WORD_SIZE = 4  # RISC-V standard word size
    INITIAL_MEMORY_SIZE = 1024  # Initial memory size in bytes

    def __init__(self):
        self.memory = [0] * self.INITIAL_MEMORY_SIZE  # byte-addressable memory
        self.stack = []  # RISC-V stack is typically memory-based, simulated here
        self.sp_pointer = 0  # Stack pointer index

    # --- Stack operations ---

    def push(self, value: int):
        """Push an integer onto the simulated stack."""
        self._validate_int(value)
        self.stack.append(value)
        self.sp_pointer += 1
        logger.debug(f"Pushed to stack: {value}")

    def pop(self) -> int:
        """Pop an integer from the simulated stack."""
        if self.sp_pointer == 0:
            logger.error("Stack underflow attempted")
            raise IndexError("Stack underflow")
        self.sp_pointer -= 1
        value = self.stack.pop()
        logger.debug(f"Popped from stack: {value}")
        return value

    def peek(self) -> int:
        """Peek at the top value of the stack."""
        if self.sp_pointer == 0:
            logger.error("Peek attempted on empty stack")
            raise IndexError("Stack is empty")
        return self.stack[-1]

    # --- Memory operations ---

    def store(self, index: int, value: int):
        """
        Store a 4-byte word at memory index.
        Must be word-aligned (i.e., divisible by 4).
        """
        self._validate_index(index)
        self._validate_int(value)
        self._ensure_memory(index + self.WORD_SIZE)

        if index % self.WORD_SIZE != 0:
            logger.error(f"Unaligned memory store at index {index}")
            raise ValueError(f"Memory index {index} is not word-aligned")

        bytes_value = value.to_bytes(self.WORD_SIZE, byteorder="little", signed=True)
        for i in range(self.WORD_SIZE):
            self.memory[index + i] = bytes_value[i]

        logger.info(f"Stored {value} at index {index} (bytes: {bytes_value.hex()})")

    def load(self, index: int) -> int:
        """
        Load a 4-byte word from memory.
        Must be word-aligned.
        """
        self._validate_index(index)
        if index % self.WORD_SIZE != 0:
            logger.error(f"Unaligned memory load at index {index}")
            raise ValueError(f"Memory index {index} is not word-aligned")

        self._ensure_memory(index + self.WORD_SIZE)
        bytes_value = bytes(self.memory[index:index + self.WORD_SIZE])
        value = int.from_bytes(bytes_value, byteorder="little", signed=True)
        logger.info(f"Loaded {value} from index {index} (bytes: {bytes_value.hex()})")
        return value

    # --- Utilities ---

    def reset(self):
        """Reset memory and stack to initial state."""
        self.memory = [0] * self.INITIAL_MEMORY_SIZE
        self.stack.clear()
        self.sp_pointer = 0
        logger.info("Memory and stack reset")

    def dump(self):
        """Return current memory and stack state."""
        return {
            "stack": self.stack.copy(),
            "memory": self.memory.copy()
        }

    def size(self):
        """Return size of memory in bytes."""
        return len(self.memory)

    def __str__(self):
        return f"MemoryModel(size={self.size()}, sp={self.sp_pointer}, stack={self.stack})"

    # --- Internal validation & memory growth ---

    def _validate_index(self, index: int):
        if index < 0:
            logger.error(f"Negative memory index access: {index}")
            raise IndexError("Negative memory index is invalid")

    def _validate_int(self, value: int):
        if not isinstance(value, int):
            logger.error(f"Non-integer value used: {value}")
            raise ValueError("Only integer values are allowed")

    def _ensure_memory(self, required_size: int):
        if required_size > len(self.memory):
            additional_bytes = required_size - len(self.memory)
            logger.debug(f"Expanding memory by {additional_bytes} bytes")
            self.memory.extend([0] * additional_bytes)
