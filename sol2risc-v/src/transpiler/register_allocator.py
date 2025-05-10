# register_allocator.py - Register allocation for EVM-to-RISC-V transpiler

from .context_manager import Context
from .stack_emulator import StackModel
import logging


# Available general-purpose registers in RISC-V calling convention
RISCV_CALLER_SAVED_REGS = ["t0", "t1", "t2", "t3", "t4", "t5", "t6"]
RISCV_CALLEE_SAVED_REGS = ["s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11"]
AVAILABLE_PHYSICAL_REGS = RISCV_CALLER_SAVED_REGS + RISCV_CALLEE_SAVED_REGS


def get_available_registers(context: Context):
    """
    Return list of available physical registers based on ABI and context.
    
    Args:
        context (Context): Shared compilation context
    Returns:
        list[str]: List of available register names
    """
    return AVAILABLE_PHYSICAL_REGS.copy()


def calculate_variable_lifetimes(instructions):
    """
    Calculate live ranges (start and end indices) of each variable (stack item).
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        dict: { var_id: {'start': int, 'end': int} }
    """
    lifetimes = {}
    stack = []
    for idx, instr in enumerate(instructions):
        opcode = instr.get("opcode", "")

        if opcode.startswith("PUSH"):
            var_id = f"stack_{len(stack)}"
            lifetimes[var_id] = {"start": idx, "end": None}
            stack.append(var_id)

        elif opcode == "POP":
            if stack:
                var_id = stack.pop()
                lifetimes[var_id]["end"] = idx

        elif opcode in ["ADD", "MUL", "SUB"]:
            if len(stack) >= 2:
                b = stack.pop()
                a = stack.pop()
                result = f"stack_{len(stack)}"
                lifetimes[result] = {"start": idx, "end": None}
                stack.append(result)

    # Finalize remaining variables
    for var in stack:
        if lifetimes[var].get("end") is None:
            lifetimes[var]["end"] = len(instructions) - 1

    return lifetimes


def build_interference_graph(instructions, lifetimes):
    """
    Build interference graph from variable lifetimes.
    
    Args:
        instructions (list[dict]): List of EVM instructions
        lifetimes (dict): Output of calculate_variable_lifetimes
    Returns:
        dict: { var: set(interfering_vars) }
    """
    interference = {}

    for v1 in lifetimes:
        interference[v1] = set()
        for v2 in lifetimes:
            if v1 == v2:
                continue
            l1 = lifetimes[v1]
            l2 = lifetimes[v2]
            if not (l1["end"] < l2["start"] or l2["end"] < l1["start"]):
                interference[v1].add(v2)

    return interference


def color_register_graph(interference_graph):
    """
    Perform greedy graph coloring to assign colors (registers) to nodes (variables).
    
    Args:
        interference_graph (dict): From build_interference_graph
    Returns:
        dict: { var: color_index }
    """
    colors = {}
    available_colors = list(range(len(AVAILABLE_PHYSICAL_REGS)))

    # Sort by degree heuristic (greedy coloring)
    sorted_vars = sorted(
        interference_graph.keys(),
        key=lambda x: len(interference_graph[x]),
        reverse=True
    )

    for var in sorted_vars:
        used_colors = {
            colors[neighbor]
            for neighbor in interference_graph[var]
            if neighbor in colors
        }
        for color in available_colors:
            if color not in used_colors:
                colors[var] = color
                break
        else:
            colors[var] = -1  # Mark as spilled

    return colors


def assign_physical_registers(virtual_registers, coloring):
    """
    Map virtual registers (colors) to actual RISC-V registers.
    
    Args:
        virtual_registers (list): List of variable IDs
        coloring (dict): Output of color_register_graph
    Returns:
        dict: { var: reg_name }
    """
    mapping = {}
    for var in virtual_registers:
        color = coloring.get(var, -1)
        if color >= 0:
            reg_idx = color % len(AVAILABLE_PHYSICAL_REGS)
            mapping[var] = AVAILABLE_PHYSICAL_REGS[reg_idx]
        else:
            mapping[var] = "spilled"
    return mapping


def handle_register_spilling(coloring, context: Context):
    """
    Handle spilled variables by allocating space on the stack.
    
    Args:
        coloring (dict): Register coloring output
        context (Context): Compilation context
    Returns:
        dict: Mapping of spilled variables to offsets on the stack
    """
    spilled = {var for var, color in coloring.items() if color == -1}
    offset = 0
    spill_map = {}

    for var in spilled:
        spill_map[var] = offset
        offset += 4  # Assume 32-bit values

    context.stack.spill_offsets.update(spill_map)
    return spill_map


def optimize_register_assignment(assignment, instructions):
    """
    Post-process register assignment to reduce register pressure.
    
    Args:
        assignment (dict): Initial register assignment
        instructions (list[dict]): Instruction sequence
    Returns:
        dict: Optimized register assignment
    """
    # Basic optimization: reuse same register if possible
    new_assign = assignment.copy()

    for instr in instructions:
        opcode = instr.get("opcode")
        if opcode in ["ADD", "MUL"]:
            try:
                a = [k for k, v in assignment.items() if v == assignment.get("a")][0]
                b = [k for k, v in assignment.items() if v == assignment.get("b")][0]
                result = f"result_{instr['id']}"
                new_assign[result] = assignment[a]  # Reuse register
            except Exception:
                pass

    return new_assign


def allocate_registers(instructions, context: Context):
    """
    Main function to perform full register allocation.
    
    Args:
        instructions (list[dict]): EVM instruction stream
        context (Context): Shared compilation state
    Returns:
        dict: Final register assignment map { var: reg_name or offset }
    """
    logging.log("Starting register allocation...")

    lifetimes = calculate_variable_lifetimes(instructions)
    interference = build_interference_graph(instructions, lifetimes)
    coloring = color_register_graph(interference)
    spilled = handle_register_spilling(coloring, context)

    virtual_regs = list(lifetimes.keys())
    assignment = assign_physical_registers(virtual_regs, coloring)
    optimized = optimize_register_assignment(assignment, instructions)

    logging.log(f"Register allocation complete. Spilled: {list(spilled)}")
    return optimized