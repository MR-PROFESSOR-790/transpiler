# memory_model.py - Simulates EVM memory and maps it to RISC-V memory

import logging


class MemoryModel:
    """
    Class responsible for simulating EVM memory and translating it to RISC-V.
    
    Handles memory allocation, MLOAD/MSTORE operations, and gas cost calculation.
    """

    def __init__(self, context):
        """
        Initialize memory model with shared compilation context.

        Args:
            context (Context): Shared state object
        """
        self.context = context
        self.initialize_memory_model()

    def initialize_memory_model(self):
        """
        Initialize the memory subsystem within the compilation context.
        """
        if not hasattr(self.context, "memory"):
            self.context.memory = {
                "base": "MEM_BASE",  # Symbolic constant defined in runtime.s
                "size": 0,
                "allocated": {},     # Map offset -> value (for testing/debugging)
                "last_used": 0
            }
        logging.debug("Memory model initialized")

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