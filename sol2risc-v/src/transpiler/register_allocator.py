# register_allocator.py - Register allocation for EVM-to-RISC-V transpiler

import logging


# Available general-purpose registers in RISC-V calling convention
RISCV_CALLER_SAVED_REGS = ["t0", "t1", "t2", "t3", "t4", "t5", "t6"]
RISCV_CALLEE_SAVED_REGS = ["s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11"]
AVAILABLE_PHYSICAL_REGS = RISCV_CALLER_SAVED_REGS + RISCV_CALLEE_SAVED_REGS


class RegisterAllocator:
    """
    Class responsible for allocating physical RISC-V registers from EVM stack variables.
    
    Implements:
    - Variable lifetime analysis
    - Interference graph building
    - Graph coloring algorithm
    - Spill handling
    - Register assignment
    - Optimization pass
    """

    def __init__(self):
        self.context = None

    def set_context(self, context):
        """Set compilation context."""
        self.context = context

    @staticmethod
    def allocate_registers_for_instruction(instruction, context=None):
        """Allocate registers for an instruction."""
        return {
            "dest": "t0",
            "a": "t1",
            "b": "t2",
            "size": "a0",
            "offset": "a1"
        }

    # --- Public Methods ---

    def get_available_registers(self):
        """
        Return list of available physical registers based on ABI and context.
        
        Returns:
            list[str]: List of available register names
        """
        return AVAILABLE_PHYSICAL_REGS.copy()

    def calculate_variable_lifetimes(self, instructions):
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

    def build_interference_graph(self, instructions, lifetimes):
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

    def color_register_graph(self, interference_graph):
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

    def assign_physical_registers(self, virtual_registers, coloring):
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

    def handle_register_spilling(self, coloring):
        """
        Handle spilled variables by allocating space on the stack.
        
        Args:
            coloring (dict): Register coloring output
        Returns:
            dict: Mapping of spilled variables to offsets on the stack
        """
        spilled = {var for var, color in coloring.items() if color == -1}
        offset = 0
        spill_map = {}

        for var in spilled:
            spill_map[var] = offset
            offset += 4  # Assume 32-bit values

        self.context.stack.spill_offsets.update(spill_map)
        return spill_map

    def optimize_register_assignment(self, assignment, instructions):
        """
        Post-process register assignment to reduce register pressure.
        
        Args:
            assignment (dict): Initial register assignment
            instructions (list[dict]): Instruction sequence
        Returns:
            dict: Optimized register assignment
        """
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

    def allocate_registers(self, instructions):
        """
        Main function to perform full register allocation.
        
        Args:
            instructions (list[dict]): EVM instruction stream
        Returns:
            dict: Final register assignment map { var: reg_name or offset }
        """
        logging.debug("Starting register allocation...")

        lifetimes = self.calculate_variable_lifetimes(instructions)
        interference = self.build_interference_graph(instructions, lifetimes)
        coloring = self.color_register_graph(interference)
        spilled = self.handle_register_spilling(coloring)

        virtual_regs = list(lifetimes.keys())
        assignment = self.assign_physical_registers(virtual_regs, coloring)
        optimized = self.optimize_register_assignment(assignment, instructions)

        logging.log(f"Register allocation complete. Spilled: {list(spilled)}")
        return optimized

    # ---------------------------
    # Helper Functions
    # ---------------------------

def apply_constant_folding(range_tuple, context):
    """Replace two PUSHes and an ADD/MUL with a single PUSH."""
    start, end = range_tuple
    instrs = context.ir[start:end]
    val1 = int(instrs[0]["value"], 16)
    val2 = int(instrs[1]["value"], 16)
    op = instrs[2]["opcode"]
    result = val1 + val2 if op == "ADD" else val1 * val2
    return [{"opcode": "PUSH1", "value": hex(result)}]

def remove_instructions(range_tuple):
    """Remove a block of instructions."""
    start, end = range_tuple
    return []

def coalesce_operations(range_tuple, context):
    """Replace two similar operations with a combined one."""
    return [{"opcode": "ADDMOD"}]

def optimize_memory_access(range_tuple, context):
    """Replace memory copy pattern with optimized version."""

    logging.info("Optimizing memory access pattern...")
    optimized = []
    for i in range_tuple:
        instr = context.ir[i]
        if instr["opcode"] == "MLOAD":
            optimized.append({"opcode": "LW", "args": instr["args"]})
        elif instr["opcode"] == "MSTORE":
            optimized.append({"opcode": "SW", "args": instr["args"]})
        else:
            optimized.append(instr)
    return optimized