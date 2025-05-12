# memory_model.py - Simulates EVM memory and maps it to RISC-V memory
import logging


class MemoryModel:
    """
    Class responsible for simulating EVM memory and translating it to RISC-V.
    Handles memory allocation, MLOAD/MSTORE operations, and gas cost calculation.
    """

    def __init__(self, context=None):
        self.memory = bytearray()
        self.max_size = 0
        self.current_opcode = None
        self.warnings = []
        self.errors = []
        self.context = context
        if context:
            self.set_context(context)

    def initialize_memory_model(self):
        """Initialize internal memory model state."""
        self.memory = bytearray()  # Reset memory
        self.max_size = 0
        self.current_opcode = None
        logging.info("Memory model initialized")

    def set_context(self, context):
        """Set compilation context."""
        self.context = context

    def set_current_opcode(self, opcode):
        """Set the current opcode being processed."""
        self.current_opcode = opcode
        if self.context:
            self.context.current_opcode = opcode

    def expand(self, size):
        """
        Expand memory to at least the given size.
        Args:
            size (int): Minimum size required
        Returns:
            bool: True if successful
        """
        if size > self.max_size:
            self.max_size = size
            if self.context:
                self.context.memory_size = size
        return True

    def write(self, offset, data):
        """
        Write data to memory at the given offset.
        Args:
            offset (int): Memory offset
            data (bytes): Data to write
        Returns:
            bool: True if successful
        """
        try:
            # Expand memory if needed
            required_size = offset + len(data)
            if not self.expand(required_size):
                return False
            # Write data
            while len(self.memory) < required_size:
                self.memory.append(0)
            self.memory[offset:offset + len(data)] = data
            if self.context:
                self.context.memory_writes.append({
                    "offset": offset,
                    "size": len(data),
                    "opcode": self.current_opcode
                })
            return True
        except Exception as e:
            error = f"Memory write error: {str(e)}"
            self.errors.append(error)
            if self.context:
                self.context.add_error(error)
            return False

    def read(self, offset, size):
        """
        Read data from memory at the given offset.
        Args:
            offset (int): Memory offset
            size (int): Number of bytes to read
        Returns:
            bytes: Read data or None on error
        """
        try:
            # Check bounds
            if offset + size > len(self.memory):
                error = f"Memory read out of bounds: offset={offset}, size={size}"
                self.errors.append(error)
                if self.context:
                    self.context.add_error(error)
                return None
            # Read data
            data = bytes(self.memory[offset:offset + len(data)])
            if self.context:
                self.context.memory_reads.append({
                    "offset": offset,
                    "size": size,
                    "opcode": self.current_opcode
                })
            return data
        except Exception as e:
            error = f"Memory read error: {str(e)}"
            self.errors.append(error)
            if self.context:
                self.context.add_error(error)
            return None

    def get_memory_state(self):
        """Get current memory state."""
        return {
            "size": len(self.memory),
            "max_size": self.max_size,
            "current_opcode": self.current_opcode,
            "warnings": self.warnings,
            "errors": self.errors
        }

    def clear(self):
        """Clear memory and reset state."""
        self.memory = bytearray()
        self.max_size = 0
        self.current_opcode = None
        self.warnings = []
        self.errors = []
        if self.context:
            self.context.memory_size = 0
            self.context.current_opcode = None
            self.context.memory_writes = []
            self.context.memory_reads = []

    def track_memory_usage(self, opcode):
        """
        Track memory usage for an opcode.
        Args:
            opcode (str): EVM opcode
        """
        if self.context:
            self.context.memory_usage[opcode] = len(self.memory)
            self.context.max_memory_size = max(self.context.max_memory_size, len(self.memory))

    def mload_operation(self, offset: int):
        """
        Emulate EVM MLOAD instruction by reading from memory.
        Args:
            offset (int): Offset in bytes
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.debug(f"Emulating MLOAD at offset {offset}")
        self.allocate_memory(offset + 32)
        base_reg = "s0"  # MEM_BASE loaded into s0 by prologue
        dest_reg = "a0"
        return [
            f"li t0, {offset}",
            f"add t1, {base_reg}, t0",
            f"lw {dest_reg}, 0(t1)",
            "sw a0, 0(sp)",
            "addi sp, sp, -4"
        ]

    def mstore_operation(self, offset: int, value: int):
        """
        Emulate EVM MSTORE instruction by writing 32 bytes to memory.
        Args:
            offset (int): Offset in bytes
            value (int): Value to store
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.debug(f"Emulating MSTORE at offset {offset}, value {value}")
        self.allocate_memory(offset + 32)
        base_reg = "s0"
        src_reg = "t2"
        return [
            f"li {src_reg}, {value}",
            f"li t0, {offset}",
            f"add t1, {base_reg}, t0",
            f"sw {src_reg}, 0(t1)"
        ]

    def mstore8_operation(self, offset: int, value: int):
        """
        Emulate EVM MSTORE8 instruction by writing 1 byte to memory.
        Args:
            offset (int): Offset in bytes
            value (int): Byte value to store
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.debug(f"Emulating MSTORE8 at offset {offset}, value {value}")
        self.allocate_memory(offset + 1)
        base_reg = "s0"
        src_reg = "t2"
        return [
            f"li {src_reg}, {value}",
            f"li t0, {offset}",
            f"add t1, {base_reg}, t0",
            f"sb {src_reg}, 0(t1)"
        ]

    def mcopy_operation(self, dest: int, src: int, size: int):
        """
        Emulate EVM MCOPY / CALLDATACOPY / CODECOPY operation.
        Args:
            dest (int): Destination offset
            src (int): Source offset
            size (int): Number of bytes to copy
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.debug(f"Emulating MCOPY from {src} to {dest}, size {size}")
        self.allocate_memory(dest + size)
        base_reg = "s0"
        return [
            f"li a0, {dest}",
            f"li a1, {src}",
            f"li a2, {size}",
            "jal ra, mcopy"
        ]

    def allocate_memory(self, size: int):
        """
        Allocate memory if needed and update usage tracking.
        Args:
            size (int): Required memory size in bytes
        """
        mem = self.context.memory
        if size > mem["size"]:
            old_size = mem["size"]
            mem["size"] = ((size + 31) // 32) * 32  # Round up to 32-byte boundary
            logging.debug(f"Memory expanded from {old_size} to {mem['size']} bytes")
            # Track memory expansion cost
            from .gas_costs import calculate_memory_expansion_cost  # Lazy import
            calculate_memory_expansion_cost(old_size, mem["size"], self.context)

    def map_evm_memory_to_riscv(self, memory_op: dict):
        """
        Translate EVM memory access to RISC-V memory layout.
        Args:
            memory_op (dict): Memory operation metadata
        Returns:
            dict: Updated memory_op with RISC-V-specific info
        """
        op_type = memory_op.get("type")
        offset = memory_op.get("offset", 0)
        if op_type == "mload":
            return {"riscv_offset": offset}
        elif op_type == "mstore":
            return {
                "riscv_offset": offset,
                "value": memory_op.get("value")
            }
        elif op_type == "mcopy":
            return {
                "riscv_dest": memory_op.get("dest"),
                "riscv_src": memory_op.get("src"),
                "riscv_size": memory_op.get("size")
            }
        return {}

    def calculate_memory_gas_cost(self, old_size: int, new_size: int):
        """
        Calculate and track memory expansion gas cost.
        Args:
            old_size (int): Current memory size
            new_size (int): New required memory size
        """
        from .gas_costs import calculate_memory_expansion_cost  # Lazy import
        if new_size > old_size:
            gas_cost = calculate_memory_expansion_cost(new_size, self.context)
            self.context.gas_meter["total"] += gas_cost
            self.context.gas_meter.setdefault("breakdown", {})["memory"] = \
                self.context.gas_meter["breakdown"].get("memory", 0) + gas_cost
            logging.debug(f"Gas cost for memory expansion: {gas_cost}")

    def get_current_memory_size(self):
        """
        Return current allocated memory size in bytes.
        Returns:
            int: Current memory size
        """
        return self.context.memory.get("size", 0)

    def get_usage(self):
        """
        Get current memory usage for reporting/debugging purposes.
        Returns:
            int: Current memory size in bytes
        """
        return self.get_current_memory_size()