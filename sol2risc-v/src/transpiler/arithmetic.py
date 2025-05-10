# arithmetic.py - Arithmetic operation translation layer for EVM-to-RISC-V

from .context_manager import Context
from .register_allocator import allocate_registers_for_instruction
from .riscv_emitter import emit_runtime_calls
import logging


def handle_add_operation(context: Context):
    """
    Emits RISC-V code for EVM ADD operation.
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling ADD")
    return _emit_binary_op("add", context)


def handle_mul_operation(context: Context):
    """
    Emits RISC-V code for EVM MUL operation.
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling MUL")
    return _emit_binary_op("mul", context)


def handle_sub_operation(context: Context):
    """
    Emits RISC-V code for EVM SUB operation.
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling SUB")
    return _emit_binary_op("sub", context)


def handle_div_operation(context: Context):
    """
    Emits RISC-V code for EVM DIV (unsigned division).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling DIV")
    return _emit_binary_op("divu", context)


def handle_sdiv_operation(context: Context):
    """
    Emits RISC-V code for EVM SDIV (signed division).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling SDIV")
    return _emit_binary_op("div", context)


def handle_mod_operation(context: Context):
    """
    Emits RISC-V code for EVM MOD (unsigned modulo).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling MOD")
    return _emit_binary_op("remu", context)


def handle_smod_operation(context: Context):
    """
    Emits RISC-V code for EVM SMOD (signed modulo).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling SMOD")
    return _emit_binary_op("rem", context)


def handle_addmod_operation(context: Context):
    """
    Emits RISC-V code for EVM ADDMOD (addition modulo).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling ADDMOD")
    # This requires a helper function in runtime.s
    return emit_runtime_calls("addmod", {})


def handle_mulmod_operation(context: Context):
    """
    Emits RISC-V code for EVM MULMOD (multiplication modulo).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling MULMOD")
    return emit_runtime_calls("mulmod", {})


def handle_exp_operation(context: Context):
    """
    Emits RISC-V code for EVM EXP (exponentiation).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling EXP")
    return emit_runtime_calls("exp", {})


def handle_signextend_operation(context: Context):
    """
    Emits RISC-V code for EVM SIGNEXTEND (sign extension).
    
    Args:
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log("Handling SIGNEXTEND")
    # Simulate sign extension manually
    return [
        "lw t0, 8(sp)",
        "lw t1, 4(sp)",
        "slli t2, t1, 3",
        "srai t0, t0, t2",
        "sll t0, t0, t2",
        "sw t0, 4(sp)",
        "addi sp, sp, 4"
    ]


def implement_256bit_arithmetic(operation: str, args: dict, context: Context):
    """
    Implements arithmetic on 256-bit values using multiple registers or memory.
    
    Args:
        operation (str): Operation type ('add', 'mul', etc.)
        args (dict): Arguments like operand pointers
        context (Context): Compilation context
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    logging.log(f"Implementing 256-bit {operation}")
    if operation == "add":
        return emit_runtime_calls("add256", args)
    elif operation == "sub":
        return emit_runtime_calls("sub256", args)
    elif operation == "mul":
        return emit_runtime_calls("mul256", args)
    else:
        logging.warn(f"Unsupported 256-bit op: {operation}")
        return ["ebreak"]


def optimize_arithmetic_sequence(operations: list, context: Context):
    """
    Optimize a sequence of arithmetic instructions (e.g., constant folding).
    
    Args:
        operations (list): List of arithmetic instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction stream
    """
    optimized = []

    for op in operations:
        opcode = op.get("opcode")
        if opcode in ["PUSH1", "PUSH2"]:
            optimized.append(op)
        elif opcode == "ADD":
            if len(optimized) >= 2:
                b = optimized.pop()
                a = optimized.pop()
                if a["opcode"].startswith("PUSH") and b["opcode"].startswith("PUSH"):
                    result = int(a["value"], 16) + int(b["value"], 16)
                    optimized.append({"opcode": "PUSH1", "value": hex(result)})
                else:
                    optimized.append(a)
                    optimized.append(b)
                    optimized.append(op)
            else:
                optimized.append(op)
        else:
            optimized.append(op)

    logging.log(f"Optimized arithmetic sequence size: {len(operations)} → {len(optimized)}")
    return optimized


# ---------------------------
# Internal Helpers
# ---------------------------

def _emit_binary_op(op_name: str, context: Context):
    """
    Helper to emit binary arithmetic operations.
    Pops two operands from stack, performs operation, pushes result.
    
    Args:
        op_name (str): RISC-V instruction name
        context (Context): Shared compilation state
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    reg_map = allocate_registers_for_instruction({"opcode": op_name.upper()}, context)

    rs1 = reg_map.get("a", "t0")
    rs2 = reg_map.get("b", "t1")
    rd = reg_map.get("dest", "t0")

    return [
        f"lw {rs1}, 4(sp)",
        f"lw {rs2}, 0(sp)",
        f"{op_name} {rd}, {rs1}, {rs2}",
        f"sw {rd}, 0(sp)",
        "addi sp, sp, 4"
    ]