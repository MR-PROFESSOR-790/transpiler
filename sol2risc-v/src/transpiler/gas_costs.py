# gas_costs.py - Gas cost calculation and tracking for EVM-to-RISC-V transpiler

from .context_manager import Context
from .riscv_emitter import emit_runtime_calls  # For inserting gas deduction calls
import logging


# Static gas costs from Ethereum Yellow Paper
STATIC_GAS_COSTS = {
    "STOP": 0,
    "ADD": 3,
    "MUL": 5,
    "SUB": 3,
    "DIV": 5,
    "SDIV": 5,
    "MOD": 5,
    "SMOD": 5,
    "ADDMOD": 8,
    "MULMOD": 8,
    "EXP": 10,
    "SIGNEXTEND": 3,

    "LT": 3,
    "GT": 3,
    "SLT": 3,
    "SGT": 3,
    "EQ": 3,
    "ISZERO": 3,

    "AND": 3,
    "OR": 3,
    "XOR": 3,
    "NOT": 3,
    "BYTE": 3,

    "CALLDATALOAD": 3,
    "CALLDATACOPY": 3,
    "CODECOPY": 3,

    "POP": 2,
    "MLOAD": 3,
    "MSTORE": 3,
    "MSTORE8": 3,
    "JUMP": 8,
    "JUMPI": 10,
    "PC": 2,
    "MSIZE": 2,
    "GAS": 2,

    "PUSH1": 3,
    "PUSH2": 3,
    "PUSH3": 3,
    "PUSH4": 3,
    "PUSH5": 3,
    "PUSH6": 3,
    "PUSH7": 3,
    "PUSH8": 3,
    "PUSH9": 3,
    "PUSH10": 3,
    "PUSH11": 3,
    "PUSH12": 3,
    "PUSH13": 3,
    "PUSH14": 3,
    "PUSH15": 3,
    "PUSH16": 3,
    "PUSH17": 3,
    "PUSH18": 3,
    "PUSH19": 3,
    "PUSH20": 3,
    "PUSH21": 3,
    "PUSH22": 3,
    "PUSH23": 3,
    "PUSH24": 3,
    "PUSH25": 3,
    "PUSH26": 3,
    "PUSH27": 3,
    "PUSH28": 3,
    "PUSH29": 3,
    "PUSH30": 3,
    "PUSH31": 3,
    "PUSH32": 3,

    "DUP1": 3,
    "DUP2": 3,
    "DUP3": 3,
    "DUP4": 3,
    "DUP5": 3,
    "DUP6": 3,
    "DUP7": 3,
    "DUP8": 3,
    "DUP9": 3,
    "DUP10": 3,
    "DUP11": 3,
    "DUP12": 3,
    "DUP13": 3,
    "DUP14": 3,
    "DUP15": 3,
    "DUP16": 3,

    "SWAP1": 3,
    "SWAP2": 3,
    "SWAP3": 3,
    "SWAP4": 3,
    "SWAP5": 3,
    "SWAP6": 3,
    "SWAP7": 3,
    "SWAP8": 3,
    "SWAP9": 3,
    "SWAP10": 3,
    "SWAP11": 3,
    "SWAP12": 3,
    "SWAP13": 3,
    "SWAP14": 3,
    "SWAP15": 3,
    "SWAP16": 3,

    "LOG0": 375,
    "LOG1": 750,
    "LOG2": 1125,
    "LOG3": 1500,
    "LOG4": 1875,

    "CREATE": 32000,
    "CALL": 700,
    "CALLCODE": 700,
    "DELEGATECALL": 700,
    "STATICCALL": 700,

    "RETURN": 0,
    "REVERT": 0,
    "SELFDESTRUCT": 5000,
    "INVALID": 0,
}


def gas_cost_lookup(opcode: str) -> int:
    """
    Return static gas cost for an opcode.
    
    Args:
        opcode (str): EVM instruction name
    Returns:
        int: Gas cost or 0 if unknown
    """
    return STATIC_GAS_COSTS.get(opcode, 0)


def calculate_gas_cost(opcode: str, context: Context):
    """
    Calculate total gas cost including memory expansion for this opcode.
    
    Args:
        opcode (str): EVM instruction name
        context (Context): Shared compilation state
    Returns:
        int: Total gas cost
    """
    base_cost = gas_cost_lookup(opcode)

    # Add dynamic memory cost if applicable
    mem_expansion_cost = 0
    if opcode in ["MLOAD", "MSTORE", "MSTORE8", "CALLDATACOPY", "CODECOPY"]:
        size = context.memory.get_current_size()  # Hypothetical method
        new_size = size + 32  # Example: assume 32-byte write
        mem_expansion_cost = calculate_memory_expansion_cost(new_size, context)

    total_cost = base_cost + mem_expansion_cost
    track_gas_usage({"opcode": opcode, "cost": total_cost}, context)
    return total_cost


def calculate_memory_expansion_cost(size: int, context: Context):
    """
    Memory expansion cost formula from EIP-150.
    
    Args:
        size (int): New required memory size (in bytes)
        context (Context): Shared compilation state
    Returns:
        int: Gas cost for expanding memory to this size
    """
    current_mem = context.memory.get_current_size()
    if size <= current_mem:
        return 0

    words = (size + 31) // 32
    word_cost = words * 3
    quadratic_cost = words * words // 512
    total_cost = word_cost + quadratic_cost

    if current_mem > 0:
        current_words = (current_mem + 31) // 32
        current_word_cost = current_words * 3
        current_quad_cost = current_words * current_words // 512
        current_total = current_word_cost + current_quad_cost
        total_cost -= current_total

    return max(total_cost, 0)


def calculate_storage_cost(operation: str, context: Context):
    """
    Calculate storage read/write cost based on operation type.
    
    Args:
        operation (str): 'read', 'write', 'reset', etc.
        context (Context): Compilation context
    Returns:
        int: Gas cost
    """
    costs = {
        "read": 100,
        "write": 20000,
        "reset": 5000,
        "delete": 15000
    }
    cost = costs.get(operation.lower(), 0)
    track_gas_usage({"opcode": f"storage_{operation}", "cost": cost}, context)
    return cost


def calculate_call_cost(context: Context):
    """
    Estimate gas cost for CALL-like operations.
    
    Args:
        context (Context): Compilation context
    Returns:
        int: Gas cost
    """
    base_cost = 700
    value_transfer = context.stack.peek(2)  # Assume value is at index 2
    if value_transfer != 0:
        base_cost += 9000  # Extra for value transfer
    track_gas_usage({"opcode": "CALL", "cost": base_cost}, context)
    return base_cost


def calculate_create_cost(context: Context):
    """
    Estimate gas cost for CREATE operations.
    
    Args:
        context (Context): Compilation context
    Returns:
        int: Gas cost
    """
    base_cost = 32000
    track_gas_usage({"opcode": "CREATE", "cost": base_cost}, context)
    return base_cost


def track_gas_usage(instruction: dict, context: Context):
    """
    Update context with cumulative gas usage.
    
    Args:
        instruction (dict): Instruction metadata
        context (Context): Shared compilation state
    """
    opcode = instruction.get("opcode", "unknown")
    cost = instruction.get("cost", 0)

    context.gas_meter["total"] = context.gas_meter.get("total", 0) + cost
    context.gas_meter.setdefault("breakdown", {})[opcode] = \
        context.gas_meter["breakdown"].get(opcode, 0) + cost

    logging.log(f"Gas used by {opcode}: {cost} | Total so far: {context.gas_meter['total']}")


def emit_gas_tracking_code(context: Context):
    """
    Generate RISC-V assembly instructions to dynamically track gas usage.
    
    Args:
        context (Context): Compilation context
    Returns:
        list[str]: Assembly lines for gas tracking
    """
    lines = []

    total_gas = context.gas_meter.get("total", 0)
    if total_gas > 0:
        lines.append(f"li a0, {total_gas}")
        lines.append("jal ra, deduct_gas")

    return lines