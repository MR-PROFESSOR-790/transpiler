# memory_model.py - Simulates EVM memory and maps it to RISC-V memory

from .types import Context
from .gas_costs import calculate_memory_expansion_cost
import logging


def initialize_memory_model(context: Context):
    """
    Initialize the memory subsystem within the compilation context.
    
    Args:
        context (Context): Shared compilation state
    """
    if not hasattr(context, "memory"):
        context.memory = {
            "base": "MEM_BASE",  # Symbolic constant defined in runtime.s
            "size": 0,
            "allocated": {},     # Map offset -> value (for testing/debugging)
            "last_used": 0
        }
    logging.log("Memory model initialized")


def mload_operation(offset: int, context: Context):
    """
    Emulate EVM MLOAD instruction by reading from memory.
    
    Args:
        offset (int): Offset in bytes
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log(f"Emulating MLOAD at offset {offset}")
    allocate_memory(offset + 32, context)  # Ensure space exists

    base_reg = "s0"  # MEM_BASE loaded into s0 by prologue
    dest_reg = "a0"

    return [
        f"li t0, {offset}",
        f"add t1, {base_reg}, t0",
        f"lw {dest_reg}, 0(t1)",
        "sw a0, 0(sp)",
        "addi sp, sp, -4"
    ]


def mstore_operation(offset: int, value: int, context: Context):
    """
    Emulate EVM MSTORE instruction by writing 32 bytes to memory.
    
    Args:
        offset (int): Offset in bytes
        value (int): Value to store
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log(f"Emulating MSTORE at offset {offset}, value {value}")
    allocate_memory(offset + 32, context)

    base_reg = "s0"
    src_reg = "t2"

    return [
        f"li {src_reg}, {value}",
        f"li t0, {offset}",
        f"add t1, {base_reg}, t0",
        f"sw {src_reg}, 0(t1)"
    ]


def mstore8_operation(offset: int, value: int, context: Context):
    """
    Emulate EVM MSTORE8 instruction by writing 1 byte to memory.
    
    Args:
        offset (int): Offset in bytes
        value (int): Byte value to store
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log(f"Emulating MSTORE8 at offset {offset}, value {value}")
    allocate_memory(offset + 1, context)

    base_reg = "s0"
    src_reg = "t2"

    return [
        f"li {src_reg}, {value}",
        f"li t0, {offset}",
        f"add t1, {base_reg}, t0",
        f"sb {src_reg}, 0(t1)"
    ]


def mcopy_operation(dest: int, src: int, size: int, context: Context):
    """
    Emulate EVM MCOPY / CALLDATACOPY / CODECOPY operation.
    
    Args:
        dest (int): Destination offset
        src (int): Source offset
        size (int): Number of bytes to copy
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log(f"Emulating MCOPY from {src} to {dest}, size {size}")
    allocate_memory(dest + size, context)

    base_reg = "s0"

    return [
        f"li a0, {dest}",
        f"li a1, {src}",
        f"li a2, {size}",
        "jal ra, mcopy"
    ]


def allocate_memory(size: int, context: Context):
    """
    Allocate memory if needed and update usage tracking.
    
    Args:
        size (int): Required memory size in bytes
        context (Context): Shared compilation state
    """
    mem = context.memory
    if size > mem["size"]:
        old_size = mem["size"]
        mem["size"] = ((size + 31) // 32) * 32  # Round up to 32-byte boundary
        logging.log(f"Memory expanded from {old_size} to {mem['size']} bytes")

        # Track memory expansion cost
        calculate_memory_expansion_cost(old_size, mem["size"], context)


def map_evm_memory_to_riscv(memory_op: dict, context: Context):
    """
    Translate EVM memory access to RISC-V memory layout.
    
    Args:
        memory_op (dict): Memory operation metadata
        context (Context): Shared compilation state
    Returns:
        dict: Updated memory_op with RISC-V-specific info
    """
    op_type = memory_op.get("type")
    offset = memory_op.get("offset", 0)

    if op_type == "mload":
        return {"riscv_offset": offset}
    elif op_type == "mstore":
        return {"riscv_offset": offset, "value": memory_op.get("value")}
    elif op_type == "mcopy":
        return {
            "riscv_dest": memory_op.get("dest"),
            "riscv_src": memory_op.get("src"),
            "riscv_size": memory_op.get("size")
        }

    return {}


def calculate_memory_gas_cost(old_size: int, new_size: int, context: Context):
    """
    Calculate and track memory expansion gas cost.
    
    Args:
        old_size (int): Current memory size
        new_size (int): New required memory size
        context (Context): Shared compilation state
    """
    if new_size > old_size:
        gas_cost = calculate_memory_expansion_cost(new_size, context)
        context.gas_meter["total"] += gas_cost
        context.gas_meter.setdefault("breakdown", {})["memory"] = \
            context.gas_meter["breakdown"].get("memory", 0) + gas_cost
        logging.log(f"Gas cost for memory expansion: {gas_cost}")


def get_current_memory_size(context: Context):
    """
    Return current allocated memory size in bytes.
    
    Args:
        context (Context): Shared compilation state
    Returns:
        int: Current memory size
    """
    return context.memory.get("size", 0)