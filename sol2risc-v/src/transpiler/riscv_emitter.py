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
        self.output_lines = []
        self.current_function = None
        self.unknown_opcodes = set()
        self.invalid_opcodes = set()
        self.warnings = []
        self.errors = []

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
        logging.info(f"Emitting prologue for {function_info['name']}")
        return [
            f".globl {function_info['name']}",
            f"{function_info['name']}:",

            "addi sp, sp, -32",      # Reserve stack space
            "sw   ra, 28(sp)",       # Save return address
            "sw   s0, 24(sp)",       # Save saved registers
            "sw   s1, 20(sp)",
            "sw   s2, 16(sp)",
            "sw   s3, 12(sp)",
            "sw   s4, 8(sp)",
            "sw   s5, 4(sp)",
            "sw   s6, 0(sp)",
            "li   s0, 0x10000000",   # MEM_BASE base address
            "li   s1, 0",            # Initialize gas counter
            "la   s2, evm_stack",    # EVM stack base
            "li   s3, 0",            # EVM stack pointer
        ]

    def emit_function_epilogue(self, function_info):
        """
        Emit function epilogue boilerplate.
        
        Args:
            function_info (dict): Metadata about function exit
        Returns:
            list[str]: Epilogue assembly lines
        """
        logging.info(f"Emitting epilogue for {function_info['name']}")
        return [
            "lw   ra, 28(sp)",       # Restore return address
            "lw   s0, 24(sp)",       # Restore saved registers
            "lw   s1, 20(sp)",
            "lw   s2, 16(sp)",
            "lw   s3, 12(sp)",
            "lw   s4, 8(sp)",
            "lw   s5, 4(sp)",
            "lw   s6, 0(sp)",
            "addi sp, sp, 32",       # Deallocate stack
            "jr   ra",               # Return
            "",                      # Extra line for .section
            ".section .bss",
            ".align 4",
            "evm_stack: .space 4096", # Reserve 1KB for EVM stack
            ".section .text"         # Return to text section
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
            offset = instr.get("offset", "")
            
            # Add a label for each instruction address
            if offset:
                riscv_lines.append(f"{offset:04x}:")
            
            # Add comment with original EVM instruction
            riscv_lines.append(f"# {opcode} {' '.join(instr.get('args', []))}")

            # Register allocation per instruction
            reg_alloc = self.allocate_registers_for_instruction(instr, self.context)

            # Gas cost emission
            gas_line = self.emit_gas_cost(opcode)
            if gas_line:
                riscv_lines.append(gas_line)

            # Handle special labels for JUMPDEST
            if opcode == "JUMPDEST":
                label = f"jumpdest_{instr.get('index', 0)}"
                riscv_lines.append(f"{label}:")
                continue
                
            # Handle special runtime functions
            if opcode in ["KECCAK256", "CALLDATACOPY", "CODECOPY"]:
                args = {"size": reg_alloc.get("size"), "offset": reg_alloc.get("offset")}
                riscv_lines.extend(self.emit_runtime_calls(opcode.lower(), args))
                continue

            # Extended instruction mapping - includes all EVM instructions
            # Stack operations
            if opcode.startswith("PUSH"):
                val = instr["value"]
                riscv_lines.append(f"li   t0, {val}     # Push value onto stack")
                riscv_lines.append(f"slli t1, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t1, s2, t1    # Get stack address")
                riscv_lines.append(f"sw   t0, 0(t1)     # Store value to stack")
                riscv_lines.append(f"addi s3, s3, 1     # Increment stack pointer")
            
            elif opcode == "POP":
                riscv_lines.append(f"addi s3, s3, -1    # Decrement stack pointer")
                
            elif opcode.startswith("DUP"):
                n = int(opcode[3:])
                riscv_lines.append(f"addi t0, s3, -{n}  # Calculate dup index")
                riscv_lines.append(f"slli t0, t0, 2     # Multiply by 4 for word alignment")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load value from stack")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate current stack pointer")
                riscv_lines.append(f"add  t0, s2, t0    # Get current stack address")
                riscv_lines.append(f"sw   t1, 0(t0)     # Store duplicated value")
                riscv_lines.append(f"addi s3, s3, 1     # Increment stack pointer")
                
            elif opcode.startswith("SWAP"):
                n = int(opcode[4:])
                riscv_lines.append(f"addi t0, s3, -1    # Top of stack")
                riscv_lines.append(f"addi t1, s3, -{n+1} # Swap target")
                riscv_lines.append(f"slli t0, t0, 2     # Multiply by 4")
                riscv_lines.append(f"slli t1, t1, 2     # Multiply by 4")
                riscv_lines.append(f"add  t0, s2, t0    # Get top address")
                riscv_lines.append(f"add  t1, s2, t1    # Get target address")
                riscv_lines.append(f"lw   t2, 0(t0)     # Load top value")
                riscv_lines.append(f"lw   t3, 0(t1)     # Load target value")
                riscv_lines.append(f"sw   t3, 0(t0)     # Store target at top")
                riscv_lines.append(f"sw   t2, 0(t1)     # Store top at target")
                
            # Arithmetic operations
            elif opcode == "ADD":
                riscv_lines.append(f"addi s3, s3, -2    # Pop two values")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load first value")
                riscv_lines.append(f"lw   t2, 4(t0)     # Load second value")
                riscv_lines.append(f"add  t3, t1, t2    # Add values")
                riscv_lines.append(f"sw   t3, 0(t0)     # Store result")
                riscv_lines.append(f"addi s3, s3, 1     # Adjust stack pointer")
                
            elif opcode == "MUL":
                riscv_lines.append(f"addi s3, s3, -2    # Pop two values")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load first value")
                riscv_lines.append(f"lw   t2, 4(t0)     # Load second value")
                riscv_lines.append(f"mul  t3, t1, t2    # Multiply values")
                riscv_lines.append(f"sw   t3, 0(t0)     # Store result")
                riscv_lines.append(f"addi s3, s3, 1     # Adjust stack pointer")
                
            elif opcode == "SUB":
                riscv_lines.append(f"addi s3, s3, -2    # Pop two values")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load first value")
                riscv_lines.append(f"lw   t2, 4(t0)     # Load second value")
                riscv_lines.append(f"sub  t3, t1, t2    # Subtract values")
                riscv_lines.append(f"sw   t3, 0(t0)     # Store result")
                riscv_lines.append(f"addi s3, s3, 1     # Adjust stack pointer")
                
            # Control flow
            elif opcode == "JUMP":
                riscv_lines.append(f"addi s3, s3, -1    # Pop jump target")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t0, 0(t0)     # Load jump target")
                riscv_lines.append(f"la   t1, jumpdest_table # Load jump table")
                riscv_lines.append(f"slli t0, t0, 2     # Multiply by 4 for word alignment")
                riscv_lines.append(f"add  t1, t1, t0    # Calculate jump address")
                riscv_lines.append(f"lw   t1, 0(t1)     # Load actual address")
                riscv_lines.append(f"jr   t1            # Jump to target")
                
            elif opcode == "JUMPI":
                riscv_lines.append(f"addi s3, s3, -2    # Pop jump target and condition")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t0, 0(t0)     # Load jump target")
                riscv_lines.append(f"lw   t1, 4(t0)     # Load condition")
                riscv_lines.append(f"beqz t1, jumpi_skip_{instr.get('index', 0)} # Skip if condition is false")
                riscv_lines.append(f"la   t2, jumpdest_table # Load jump table")
                riscv_lines.append(f"slli t0, t0, 2     # Multiply by 4 for word alignment")
                riscv_lines.append(f"add  t2, t2, t0    # Calculate jump address")
                riscv_lines.append(f"lw   t2, 0(t2)     # Load actual address")
                riscv_lines.append(f"jr   t2            # Jump to target")
                riscv_lines.append(f"jumpi_skip_{instr.get('index', 0)}:")
                
            # Memory operations
            elif opcode == "MSTORE":
                riscv_lines.append(f"addi s3, s3, -2    # Pop address and value")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load memory offset")
                riscv_lines.append(f"lw   t2, 4(t0)     # Load value to store")
                riscv_lines.append(f"add  t1, s0, t1    # Add memory base")
                riscv_lines.append(f"sw   t2, 0(t1)     # Store value to memory")
                
            elif opcode == "MLOAD":
                riscv_lines.append(f"addi s3, s3, -1    # Pop address")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load memory offset")
                riscv_lines.append(f"add  t1, s0, t1    # Add memory base")
                riscv_lines.append(f"lw   t2, 0(t1)     # Load value from memory")
                riscv_lines.append(f"sw   t2, 0(t0)     # Push value onto stack")
                riscv_lines.append(f"addi s3, s3, 1     # Increment stack pointer")
                
            # Comparison operations
            elif opcode == "ISZERO":
                riscv_lines.append(f"addi s3, s3, -1    # Pop value")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load value")
                riscv_lines.append(f"seqz t1, t1        # Set t1 to 1 if t1 == 0, otherwise 0")
                riscv_lines.append(f"sw   t1, 0(t0)     # Store result")
                riscv_lines.append(f"addi s3, s3, 1     # Increment stack pointer")
                
            elif opcode == "EQ":
                riscv_lines.append(f"addi s3, s3, -2    # Pop two values")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   t1, 0(t0)     # Load first value")
                riscv_lines.append(f"lw   t2, 4(t0)     # Load second value")
                riscv_lines.append(f"xor  t3, t1, t2    # XOR values")
                riscv_lines.append(f"seqz t3, t3        # Set t3 to 1 if t1 == t2, otherwise 0")
                riscv_lines.append(f"sw   t3, 0(t0)     # Store result")
                riscv_lines.append(f"addi s3, s3, 1     # Increment stack pointer")
                
            # External interactions
            elif opcode == "CALLVALUE":
                riscv_lines.append(f"jal  ra, get_call_value # Get call value from runtime")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"sw   a0, 0(t0)     # Store call value on stack")
                riscv_lines.append(f"addi s3, s3, 1     # Increment stack pointer")
                
            elif opcode == "RETURN":
                riscv_lines.append(f"addi s3, s3, -2    # Pop offset and length")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   a0, 0(t0)     # Load offset")
                riscv_lines.append(f"lw   a1, 4(t0)     # Load length")
                riscv_lines.append(f"add  a0, s0, a0    # Add memory base to offset")
                riscv_lines.append(f"jal  ra, evm_return # Call return function")
                
            elif opcode == "REVERT":
                riscv_lines.append(f"addi s3, s3, -2    # Pop offset and length")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   a0, 0(t0)     # Load offset")
                riscv_lines.append(f"lw   a1, 4(t0)     # Load length")
                riscv_lines.append(f"add  a0, s0, a0    # Add memory base to offset")
                riscv_lines.append(f"jal  ra, evm_revert # Call revert function")
                
            # Misc operations
            elif opcode == "CODECOPY":
                riscv_lines.append(f"addi s3, s3, -3    # Pop dest offset, source offset, length")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   a0, 0(t0)     # Load dest offset")
                riscv_lines.append(f"lw   a1, 4(t0)     # Load source offset")
                riscv_lines.append(f"lw   a2, 8(t0)     # Load length")
                riscv_lines.append(f"add  a0, s0, a0    # Add memory base to dest offset")
                riscv_lines.append(f"jal  ra, evm_codecopy # Call codecopy function")
                
            else:
                riscv_lines.append(f"# Unimplemented opcode: {opcode}")
                # If we encounter an unimplemented opcode, we should at least
                # adjust the stack to maintain the correct semantics
                stack_effect = instr.get("stack_effect", 0)
                if stack_effect != 0:
                    riscv_lines.append(f"addi s3, s3, {stack_effect} # Adjust stack for unimplemented opcode")

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
            "revert": ["jal ra, evm_revert"],
            "invalid": ["jal ra, evm_invalid"],
            "out_of_gas": ["jal ra, evm_out_of_gas"]
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
        output = [
            ".section .text",
            "",
            "# Jump destination table",
            ".align 4",
            "jumpdest_table:"
        ]
        
        # Generate jump table entries
        if hasattr(self, 'context') and hasattr(self.context, 'jumpdests'):
            for jumpdest in self.context.jumpdests:
                output.append(f".word jumpdest_{jumpdest}")
                
        output.append("")
        output.extend(assembly_code)
        
        return "\n".join(output)

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

    def emit(self, line):
        """Emit a RISC-V assembly line."""
        if line.startswith("#"):
            self.output_lines.append(line)
        else:
            # Add proper indentation for assembly instructions
            self.output_lines.append("    " + line)

    def get_unknown_opcodes(self):
        """Get set of unknown opcodes encountered."""
        return self.unknown_opcodes

    def get_invalid_opcodes(self):
        """Get set of invalid opcodes encountered."""
        return self.invalid_opcodes

    def get_warnings(self):
        """Get list of warnings generated."""
        return self.warnings

    def get_errors(self):
        """Get list of errors generated."""
        return self.errors