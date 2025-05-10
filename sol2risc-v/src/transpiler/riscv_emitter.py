# riscv_emitter.py - Emits RISC-V assembly code based on parsed EVM instructions

from .context_manager import Context
from .gas_costs import deduct_gas, calculate_gas_cost
from .register_allocator import allocate_registers_for_instruction
import logging
import os

def emit_riscv_assembly(ir_representation: list, context: Context, output_file: str = None):
    """
    Main function to emit RISC-V assembly from IR.
    
    Args:
        ir_representation (list): List of instruction dictionaries
        context (Context): Shared compilation context
        output_file (str): Optional file to write output to
    Returns:
        str: Final formatted RISC-V assembly
    """
    try:
        logging.debug("Starting RISC-V assembly emission...")
        
        if not ir_representation:
            raise ValueError("Empty IR representation provided")
        
        prologue = emit_function_prologue(context.function_info)
        epilogue = emit_function_epilogue(context.function_info)
        
        body_code = []
        for instr in ir_representation:
            lines = emit_instruction_sequence([instr], context)
            body_code.extend(lines)

        full_assembly = prologue + body_code + epilogue
        formatted = format_assembly_output(full_assembly)

        if output_file:
            write_output_file(formatted, output_file)
            logging.debug(f"Successfully wrote assembly to {output_file}")

        return formatted
        
    except Exception as e:
        logging.error(f"Error during RISC-V assembly emission: {str(e)}")
        raise


def emit_function_prologue(function_info):
    """
    Emit function prologue for RISC-V function
    
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


def emit_function_epilogue(function_info):
    """
    Emit function epilogue for RISC-V function
    
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


def emit_instruction_sequence(instructions: list, context: Context):
    """
    Translate a sequence of EVM instructions into RISC-V instructions.
    Uses register allocator and runtime call helpers internally.
    
    Args:
        instructions (list): List of EVM instructions
        context (Context): Compilation context
    Returns:
        list[str]: Generated RISC-V assembly lines
    """
    riscv_lines = []

    for instr in instructions:
        opcode = instr["opcode"]

        # Register allocation per instruction
        reg_alloc = allocate_registers_for_instruction(instr, context)

        # Gas cost emission
        gas_line = emit_gas_cost(opcode, context)
        if gas_line:
            riscv_lines.append(gas_line)

        # Handle special runtime functions
        if opcode in ["KECCAK256", "CALLDATACOPY", "CODECOPY"]:
            args = {"size": reg_alloc.get("size"), "offset": reg_alloc.get("offset")}
            riscv_lines.extend(emit_runtime_calls(opcode.lower(), args))
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


def emit_gas_cost(opcode: str, context: Context = None) -> str:
    """Emit gas deduction code"""
    cost = calculate_gas_cost(opcode, context)
    if cost > 0:
        return f"li a0, {cost}\njal ra, deduct_gas"
    return ""


def emit_error_handling_code(error_type: str):
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


def _parse_runtime_signature(runtime_file="runtime.s"):
    """
    Parse runtime.s to extract function signatures and their argument patterns.
    
    Returns:
        dict: Mapping of runtime functions to their argument specifications
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


def emit_runtime_calls(runtime_function: str, args: dict):
    """
    Dynamically emits RISC-V code for runtime function calls.
    
    Args:
        runtime_function (str): Name of the runtime function to call
        args (dict): Arguments (registers or values) to prepare
    Returns:
        list[str]: RISC-V assembly lines calling the function
    """
    lines = []
    runtime_signatures = _parse_runtime_signature()
    
    if runtime_function not in runtime_signatures:
        logging.warning(f"Unknown runtime function: {runtime_function}")
        return [f"# Unknown runtime function: {runtime_function}"]
    
    # Map arguments to registers based on runtime signature
    signature = runtime_signatures[runtime_function]
    for i, (arg_name, arg_value) in enumerate(args.items()):
        if i < len(signature['registers']):
            reg = signature['registers'][i]
            if isinstance(arg_value, str) and arg_value.startswith('$'):
                # If arg_value is already a register reference
                lines.append(f"mv {reg}, {arg_value[1:]}")
            else:
                # Otherwise load immediate value
                lines.append(f"li {reg}, {arg_value}")
    
    # Call the runtime function
    lines.append(f"jal ra, {runtime_function}")
    
    return lines


def format_assembly_output(assembly_code: list):
    """
    Format raw assembly lines into a clean string with section headers.
    
    Args:
        assembly_code (list): Raw RISC-V assembly lines
    Returns:
        str: Cleanly formatted assembly string
    """
    formatted = [".section .text\n"]
    formatted.extend(assembly_code)
    return "\n".join(formatted)


def write_output_file(assembly_code: str, output_file: str):
    """
    Write final RISC-V assembly to disk with error handling.
    
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