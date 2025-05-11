# riscv_emitter.py - Emits RISC-V assembly code based on parsed EVM instructions

import os
import logging
from typing import List, Dict, Any


class RiscvEmitter:
    """
    Class responsible for emitting RISC-V assembly from EVM IR.
    
    Handles:
    - Function prologue/epilogue
    - Instruction translation
    - Runtime calls
    - Gas metering
    - Stack emulation
    - Output formatting and file writing
    """

    def __init__(self):
        """Initialize emitter with optional context."""
        self.context = None

    def set_context(self, context):
        """Set compilation context."""
        self.context = context
        self._init_dependencies()

    def _init_dependencies(self):
        """Initialize emitter dependencies."""
        if self.context is None:
            return
            
        from .register_allocator import RegisterAllocator
        from .gas_costs import GasCostCalculator
        
        # Create instances of dependencies
        self.register_allocator = RegisterAllocator()
        self.register_allocator.set_context(self.context)
        
        self.gas_calculator = GasCostCalculator()
        self.gas_calculator.set_context(self.context)
        
        # Bind methods
        self.allocate_registers_for_instruction = self.register_allocator.allocate_registers_for_instruction
        self.calculate_gas_cost = self.gas_calculator.calculate_gas_cost
        self.deduct_gas = self.gas_calculator.deduct_gas
        
        # Initialize runtime signatures
        self.runtime_signatures = self._parse_runtime_signature()
        
        logging.debug("Emitter dependencies initialized")

    # --- Public Methods ---

    def emit_riscv_assembly(self, ir_representation: list, output_file: str = None):
        """
        Main function to emit RISC-V assembly from IR.
        
        Args:
            ir_representation (list): List of instruction dictionaries
            output_file (str): Optional file to write output to
        Returns:
            str: Final formatted RISC-V assembly
        """
        try:
            logging.debug("Starting RISC-V emission...")

            if not ir_representation:
                raise ValueError("Empty IR representation provided")

            prologue = self.emit_function_prologue(self.context.function_info)
            epilogue = self.emit_function_epilogue(self.context.function_info)

            body_code = []
            for instr in ir_representation:
                lines = self.emit_instruction_sequence([instr])
                body_code.extend(lines)

            full_assembly = prologue + body_code + epilogue
            formatted = self.format_assembly_output(full_assembly)

            if output_file:
                self.write_output_file(formatted, output_file)
                logging.debug(f"Successfully wrote assembly to {output_file}")

            return formatted

        except Exception as e:
            logging.error(f"Error during RISC-V assembly emission: {str(e)}")
            raise

    def emit_function_prologue(self, function_info):
        """
        Emit function prologue boilerplate.
        
        Args:
            function_info (dict): Metadata about function entry
        Returns:
            list[str]: Prologue assembly lines
        """
        logging.log(f"Emitting prologue for {function_info['name']}")
        return [
            f".globl {function_info['name']}",
            f"{function_info['name']}:",

            "addi sp, sp, -16",      # Reserve stack space
            "sw   ra, 12(sp)",       # Save return address
            "sw   s0, 8(sp)",        # Save saved registers
            "li   s0, 0x10000000",   # MEM_BASE base address
        ]

    def emit_function_epilogue(self, function_info):
        """
        Emit function epilogue boilerplate.
        
        Args:
            function_info (dict): Metadata about function exit
        Returns:
            list[str]: Epilogue assembly lines
        """
        logging.log(f"Emitting epilogue for {function_info['name']}")
        return [
            "lw   ra, 12(sp)",       # Restore return address
            "lw   s0, 8(sp)",        # Restore saved registers
            "addi sp, sp, 16",       # Deallocate stack
            "jr   ra",               # Return
        ]

    def emit_instruction_sequence(self, instructions: list):
        """
        Translate a sequence of EVM instructions into RISC-V instructions.
        Uses register allocator and runtime call helpers internally.
        
        Args:
            instructions (list): List of EVM instructions
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        riscv_lines = []

        for instr in instructions:
            opcode = instr["opcode"]

            # Register allocation per instruction
            reg_alloc = self.allocate_registers_for_instruction(instr, self.context)

            # Gas cost emission
            gas_line = self.emit_gas_cost(opcode)
            if gas_line:
                riscv_lines.append(gas_line)

            # Handle special runtime functions
            if opcode in ["KECCAK256", "CALLDATACOPY", "CODECOPY"]:
                args = {"size": reg_alloc.get("size"), "offset": reg_alloc.get("offset")}
                riscv_lines.extend(self.emit_runtime_calls(opcode.lower(), args))
                continue

            # Basic arithmetic opcodes
            if opcode == "ADD":
                rd = reg_alloc["dest"]
                rs1 = reg_alloc["a"]
                rs2 = reg_alloc["b"]
                riscv_lines.append(f"add {rd}, {rs1}, {rs2}")
            elif opcode == "MUL":
                rd = reg_alloc["dest"]
                rs1 = reg_alloc["a"]
                rs2 = reg_alloc["b"]
                riscv_lines.append(f"mul {rd}, {rs1}, {rs2}")

            # Stack ops
            elif opcode.startswith("PUSH"):
                val = instr["value"]
                riscv_lines.append(f"li t0, {val}")
                riscv_lines.append("sw t0, 0(sp)")
                riscv_lines.append("addi sp, sp, -4")

            elif opcode.startswith("POP"):
                riscv_lines.append("addi sp, sp, 4")

            else:
                riscv_lines.append(f"# Unimplemented opcode: {opcode}")

        return riscv_lines

    def emit_gas_cost(self, opcode: str) -> str:
        """
        Emit gas deduction line for given opcode.
        
        Args:
            opcode (str): EVM instruction name
        Returns:
            str: RISC-V gas deduction line or empty string
        """
        cost = self.calculate_gas_cost(opcode, self.context)
        if cost > 0:
            return f"li a0, {cost}\njal ra, deduct_gas"
        return ""

    def emit_error_handling_code(self, error_type: str):
        """
        Generate assembly for handling known error types.
        
        Args:
            error_type (str): Type of error (e.g., 'revert', 'invalid')
        Returns:
            list[str]: Assembly lines for error handling
        """
        handlers = {
            "revert": ["jal ra, _revert"],
            "invalid": ["jal ra, _invalid"],
            "out_of_gas": ["jal ra, _revert_out_of_gas"]
        }

        return handlers.get(error_type.lower(), ["ebreak"])

    def _parse_runtime_signature(self, runtime_file="runtime.s"):
        """
        Parse runtime.s to extract function signatures and their argument patterns.
        
        Returns:
            dict: Mapping of runtime functions to their argument specs
        """
        runtime_signatures = {}
        runtime_path = os.path.join(os.path.dirname(__file__), runtime_file)

        try:
            with open(runtime_path, 'r') as f:
                current_func = None
                for line in f:
                    line = line.strip()
                    if line.startswith('.globl'):
                        current_func = line.split()[-1]
                        runtime_signatures[current_func] = {
                            'args': [],
                            'registers': ['a0', 'a1', 'a2', 'a3', 'a4', 'a5']
                        }
        except FileNotFoundError:
            logging.error(f"Runtime file {runtime_file} not found")
            return {}

        return runtime_signatures

    def emit_runtime_calls(self, runtime_function: str, args: dict):
        """
        Dynamically emits RISC-V code for runtime function calls.
        
        Args:
            runtime_function (str): Name of the runtime function to call
            args (dict): Arguments (registers or values) to prepare
        Returns:
            list[str]: RISC-V assembly lines calling the function
        """
        lines = []

        if runtime_function not in self.runtime_signatures:
            logging.warning(f"Unknown runtime function: {runtime_function}")
            return [f"# Unknown runtime function: {runtime_function}"]

        # Map arguments to registers
        signature = self.runtime_signatures[runtime_function]
        for i, (arg_name, arg_value) in enumerate(args.items()):
            if i < len(signature['registers']):
                reg = signature['registers'][i]
                if isinstance(arg_value, str) and arg_value.startswith('$'):
                    lines.append(f"mv {reg}, {arg_value[1:]}")
                else:
                    lines.append(f"li {reg}, {arg_value}")

        # Call the runtime function
        lines.append(f"jal ra, {runtime_function}")
        return lines

    def format_assembly_output(self, assembly_code: list):
        """
        Format raw assembly lines into clean sectioned output.
        
        Args:
            assembly_code (list): Raw RISC-V assembly lines
        Returns:
            str: Cleanly formatted assembly string
        """
        return "\n".join([".section .text", ""] + assembly_code)

    def write_output_file(self, assembly_code: str, output_file: str):
        """
        Write final RISC-V assembly to disk.
        
        Args:
            assembly_code (str): Formatted assembly string
            output_file (str): Path to output file
        """
        try:
            output_dir = os.path.dirname(output_file)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir)

            with open(output_file, "w") as f:
                f.write(assembly_code)

        except IOError as e:
            logging.error(f"Failed to write output file {output_file}: {str(e)}")
            raise