import sys
import logging
import re
from .memory_model import MemoryModel
from .riscv_emitter import RISCVEmitter
from .register_allocator import RegisterAllocator
from .stack_emulator import StackEmulator
from .opcode_mapping import OpcodeMapping

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def parse_instruction(line):
    """Parse an EVM instruction line into (address, opcode, value)."""
    match = re.match(r'([0-9a-fA-F]+):\s+(\w+)(?:\s+([0-9a-fA-F]+))?', line)
    if match:
        addr = int(match.group(1), 16)
        opcode = match.group(2)
        value = match.group(3)
        if value:
            value = int(value, 16)
        return addr, opcode, value
    return None, None, None

def transpile_evm_to_riscv(input_file, output_file):
    """Transpile EVM bytecode to RISC-V assembly."""
    # Initialize components
    memory_model = MemoryModel()
    register_allocator = RegisterAllocator()
    stack_emulator = StackEmulator()
    opcode_mapping = OpcodeMapping()
    riscv_emitter = RISCVEmitter(register_allocator, memory_model)

    # Add additional EVM opcodes to the mapping
    opcode_mapping.add_mapping("CALLVALUE", "custom_callvalue", 0)
    opcode_mapping.add_mapping("CALLDATASIZE", "custom_calldatasize", 0)
    opcode_mapping.add_mapping("CALLDATALOAD", "custom_calldataload", 1)
    opcode_mapping.add_mapping("CODECOPY", "custom_codecopy", 3)
    opcode_mapping.add_mapping("PUSH0", "custom_push", 0)
    opcode_mapping.add_mapping("RETURN", "custom_return", 2)
    opcode_mapping.add_mapping("REVERT", "custom_revert", 2)
    opcode_mapping.add_mapping("SLOAD", "custom_sload", 1)
    opcode_mapping.add_mapping("SSTORE", "custom_sstore", 2)
    opcode_mapping.add_mapping("SHR", "srl", 2)
    opcode_mapping.add_mapping("LOG2", "custom_log2", 4)

    # Initialize RISC-V assembly with necessary sections and directives
    riscv_emitter.emit(".section .text")
    riscv_emitter.emit(".global _start")
    riscv_emitter.emit("")
    riscv_emitter.emit("_start:")

    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()

        # First pass: collect all jump destinations
        jump_destinations = set()
        for line in lines:
            addr, opcode, _ = parse_instruction(line.strip())
            if opcode == "JUMPDEST":
                jump_destinations.add(addr)

        # Second pass: generate RISC-V assembly
        for line in lines:
            line = line.strip()
            if not line:
                continue

            addr, opcode, value = parse_instruction(line)
            if not opcode:
                continue

            # Add a comment for the original EVM instruction
            riscv_emitter.emit_comment(f"0x{addr:04x}: {opcode} {value if value is not None else ''}")

            try:
                mapping = opcode_mapping.get_riscv_mapping(opcode)
                instr = mapping["instr"]

                # Handle each opcode type
                if opcode.startswith("PUSH"):
                    reg = register_allocator.allocate()
                    riscv_emitter.emit_load_immediate(reg, value)
                    stack_emulator.push(reg)

                elif opcode == "JUMPDEST":
                    riscv_emitter.emit_label(f"L_{addr:04x}")

                elif opcode == "JUMP":
                    addr_reg = stack_emulator.pop()
                    riscv_emitter.emit_jump(f"L_{addr:04x}")
                    register_allocator.free(addr_reg)

                elif opcode == "JUMPI":
                    addr_reg = stack_emulator.pop()
                    cond_reg = stack_emulator.pop()
                    riscv_emitter.emit_conditional_jump(cond_reg, f"L_{addr:04x}")
                    register_allocator.free(addr_reg)
                    register_allocator.free(cond_reg)

                elif opcode.startswith("DUP"):
                    depth = int(opcode[3:])
                    value_reg = stack_emulator.peek(depth - 1)
                    new_reg = register_allocator.allocate()
                    riscv_emitter.emit(f"mv {new_reg}, {value_reg}")
                    stack_emulator.push(new_reg)

                elif opcode == "SWAP1":
                    reg1 = stack_emulator.pop()
                    reg2 = stack_emulator.pop()
                    stack_emulator.push(reg1)
                    stack_emulator.push(reg2)

                elif opcode == "POP":
                    reg = stack_emulator.pop()
                    register_allocator.free(reg)

                elif opcode == "MSTORE":
                    value_reg = stack_emulator.pop()
                    addr_reg = stack_emulator.pop()
                    riscv_emitter.emit_store(value_reg, addr_reg)
                    register_allocator.free(value_reg)
                    register_allocator.free(addr_reg)

                elif opcode == "MLOAD":
                    addr_reg = stack_emulator.pop()
                    dest_reg = register_allocator.allocate()
                    riscv_emitter.emit_load(dest_reg, addr_reg)
                    stack_emulator.push(dest_reg)
                    register_allocator.free(addr_reg)

                elif opcode in ["ADD", "SUB", "MUL", "DIV", "AND", "OR", "XOR"]:
                    reg2 = stack_emulator.pop()
                    reg1 = stack_emulator.pop()
                    dest_reg = register_allocator.allocate()
                    riscv_emitter.emit_arithmetic(instr, dest_reg, reg1, reg2)
                    stack_emulator.push(dest_reg)
                    register_allocator.free(reg1)
                    register_allocator.free(reg2)

                elif opcode == "ISZERO":
                    reg = stack_emulator.pop()
                    dest_reg = register_allocator.allocate()
                    riscv_emitter.emit(f"seqz {dest_reg}, {reg}")
                    stack_emulator.push(dest_reg)
                    register_allocator.free(reg)

                else:
                    # Handle custom instructions
                    if instr.startswith("custom_"):
                        riscv_emitter.emit_comment(f"TODO: Implement {opcode}")
                    else:
                        riscv_emitter.emit(instr)

            except NotImplementedError as e:
                logger.warning(f"Skipping unimplemented opcode: {opcode}")
                continue

        # Write the final assembly
        with open(output_file, 'w') as f:
            f.write(riscv_emitter.emit_code())
            logger.info(f"RISC-V assembly written to {output_file}")

    except FileNotFoundError:
        logger.error(f"Input file not found: {input_file}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error during transpilation: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python main.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    transpile_evm_to_riscv(input_file, output_file)