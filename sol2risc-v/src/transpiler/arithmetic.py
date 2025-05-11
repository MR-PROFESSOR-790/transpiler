# arithmetic.py - Arithmetic operation translation layer for EVM-to-RISC-V

import logging


class ArithmeticTranslator:
    """
    Main class to translate EVM arithmetic instructions to RISC-V.
    
    All functions are preserved as-is, but encapsulated in a class.
    Other modules like register_allocator and riscv_emitter are initialized on demand.
    """

    def __init__(self, context):
        """
        Initialize translator with shared compilation context.

        Args:
            context (CompilationContext): Shared state object
        """
        self.context = context
        self._init_dependencies()

    def _init_dependencies(self):
        """
        Lazy-load dependencies to avoid circular import issues.
        These are set as instance attributes after import.
        """
        from .register_allocator import RegisterAllocator
        from .riscv_emitter import emit_runtime_calls

        self.register_allocator = RegisterAllocator(self.context)
        self.emit_runtime_call = emit_runtime_calls

    # --- Public Methods ---

    def handle_add_operation(self):
        """
        Emits RISC-V code for EVM ADD operation.

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling ADD")
        return self._emit_binary_op("add")

    def handle_mul_operation(self):
        """
        Emits RISC-V code for EVM MUL operation.

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling MUL")
        return self._emit_binary_op("mul")

    def handle_sub_operation(self):
        """
        Emits RISC-V code for EVM SUB operation.

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling SUB")
        return self._emit_binary_op("sub")

    def handle_div_operation(self):
        """
        Emits RISC-V code for EVM DIV (unsigned division).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling DIV")
        return self._emit_binary_op("divu")

    def handle_sdiv_operation(self):
        """
        Emits RISC-V code for EVM SDIV (signed division).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling SDIV")
        return self._emit_binary_op("div")

    def handle_mod_operation(self):
        """
        Emits RISC-V code for EVM MOD (unsigned modulo).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling MOD")
        return self._emit_binary_op("remu")

    def handle_smod_operation(self):
        """
        Emits RISC-V code for EVM SMOD (signed modulo).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling SMOD")
        return self._emit_binary_op("rem")

    def handle_addmod_operation(self):
        """
        Emits RISC-V code for EVM ADDMOD (addition modulo).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling ADDMOD")
        args = {}
        return self.emit_runtime_call("addmod", args)

    def handle_mulmod_operation(self):
        """
        Emits RISC-V code for EVM MULMOD (multiplication modulo).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling MULMOD")
        args = {}
        return self.emit_runtime_call("mulmod", args)

    def handle_exp_operation(self):
        """
        Emits RISC-V code for EVM EXP (exponentiation).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling EXP")
        args = {}
        return self.emit_runtime_call("exp", args)

    def handle_signextend_operation(self):
        """
        Emits RISC-V code for EVM SIGNEXTEND (sign extension).

        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log("Handling SIGNEXTEND")
        return [
            "lw t0, 8(sp)",
            "lw t1, 4(sp)",
            "slli t2, t1, 3",
            "srai t0, t0, t2",
            "sll t0, t0, t2",
            "sw t0, 4(sp)",
            "addi sp, sp, 4"
        ]

    def implement_256bit_arithmetic(self, operation: str, args: dict):
        """
        Implements arithmetic on 256-bit values using multiple registers or memory.

        Args:
            operation (str): Operation type ('add', 'mul', etc.)
            args (dict): Arguments like operand pointers
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        logging.log(f"Implementing 256-bit {operation}")
        if operation == "add":
            return self.emit_runtime_call("add256", args)
        elif operation == "sub":
            return self.emit_runtime_call("sub256", args)
        elif operation == "mul":
            return self.emit_runtime_call("mul256", args)
        else:
            logging.warn(f"Unsupported 256-bit op: {operation}")
            return ["ebreak"]

    def optimize_arithmetic_sequence(self, operations: list):
        """
        Optimize a sequence of arithmetic instructions (e.g., constant folding).

        Args:
            operations (list): List of arithmetic instructions
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

    # --- Internal Helpers ---

    def _emit_binary_op(self, op_name: str):
        """
        Helper to emit binary arithmetic operations.
        Pops two operands from stack, performs operation, pushes result.

        Args:
            op_name (str): RISC-V instruction name
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        reg_map = self.register_allocator.allocate_registers_for_instruction({"opcode": op_name.upper()})

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