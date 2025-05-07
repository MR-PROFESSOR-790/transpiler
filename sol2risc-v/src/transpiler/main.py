import sys
import logging
import re
from .memory_model import MemoryModel
from .riscv_emitter import RISCVEmitter
from .register_allocator import RegisterAllocator
from .stack_manager import StackManager
from .opcode_mapping import OpcodeMapping

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def parse_instruction(line):
    """Parse an EVM instruction line into (address, opcode, value)."""
    # Handle UNKNOWN opcodes and hex values
    if "UNKNOWN" in line:
        match = re.match(r'([0-9a-fA-F]+):\s+UNKNOWN_0x([0-9a-fA-F]+)', line)
        if match:
            addr = int(match.group(1), 16)
            value = int(match.group(2), 16)
            return addr, "UNKNOWN", value
    
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
    stack_manager = StackManager(register_allocator)
    opcode_mapping = OpcodeMapping()
    riscv_emitter = RISCVEmitter(register_allocator, memory_model)

    # Add comprehensive EVM opcode mappings
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
    opcode_mapping.add_mapping("CREATE", "custom_create", 3)
    opcode_mapping.add_mapping("CREATE2", "custom_create2", 4)
    opcode_mapping.add_mapping("DELEGATECALL", "custom_delegatecall", 6)
    opcode_mapping.add_mapping("STATICCALL", "custom_staticcall", 6)
    opcode_mapping.add_mapping("CALL", "custom_call", 7)
    opcode_mapping.add_mapping("BALANCE", "custom_balance", 1)
    opcode_mapping.add_mapping("EXTCODEHASH", "custom_extcodehash", 1)
    opcode_mapping.add_mapping("BLOCKHASH", "custom_blockhash", 1)
    opcode_mapping.add_mapping("SHA3", "custom_sha3", 2)
    opcode_mapping.add_mapping("LOG0", "custom_log0", 2)
    opcode_mapping.add_mapping("LOG1", "custom_log1", 3)
    opcode_mapping.add_mapping("LOG2", "custom_log2", 4)
    opcode_mapping.add_mapping("LOG3", "custom_log3", 5)
    opcode_mapping.add_mapping("LOG4", "custom_log4", 6)

    # Add RISC-V specific memory layout
    riscv_emitter.emit("""
    .section .data
    .align 3
memory_area:    .space 65536  # 64KB EVM memory space
storage_area:   .space 65536  # 64KB storage space
calldata_area:  .space 4096   # 4KB calldata space
    
    .section .text
    .align 2
    .global _start

_start:
    # Setup runtime environment
    addi sp, sp, -1024        # Allocate stack frame
    sd ra, 1016(sp)           # Save return address
    sd s0, 1008(sp)           # Save frame pointer
    addi s0, sp, 1024         # Setup new frame pointer
    
    # Initialize memory pointers
    la s1, memory_area        # s1 = memory base
    la s2, storage_area       # s2 = storage base
    la s3, calldata_area      # s3 = calldata base
    li s11, 1000000          # Initial gas limit

# Common EVM operations
sload_impl:
    # Input: a0 = storage key
    # Output: a0 = value
    slli t0, a0, 3           # Multiply key by 8 (64-bit values)
    add t0, s2, t0           # Add storage base
    ld a0, 0(t0)            # Load value
    ret

sstore_impl:
    # Input: a0 = key, a1 = value
    slli t0, a0, 3
    add t0, s2, t0
    sd a1, 0(t0)
    ret

mload_impl:
    # Input: a0 = offset
    # Output: a0 = value
    add t0, s1, a0
    ld a0, 0(t0)
    ret

mstore_impl:
    # Input: a0 = offset, a1 = value
    add t0, s1, a0
    sd a1, 0(t0)
    ret

revert_impl:
    # Input: a0 = offset, a1 = size
    li a7, 93               # exit syscall
    li a0, 1               # Error status
    ecall

return_impl:
    # Input: a0 = offset, a1 = size
    li a7, 93              # exit syscall
    li a0, 0              # Success status
    ecall
    """)

    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()

        current_block = None
        
        for line in lines:
            addr, opcode, value = parse_instruction(line.strip())
            if not opcode:
                continue

            # Map EVM instructions to RISC-V
            if opcode == "PUSH1":
                riscv_emitter.emit(f"    li t0, {value}")
                riscv_emitter.emit("    addi sp, sp, -8")
                riscv_emitter.emit("    sd t0, 0(sp)")
            
            elif opcode == "SLOAD":
                riscv_emitter.emit("    ld a0, 0(sp)")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    jal sload_impl")
                riscv_emitter.emit("    addi sp, sp, -8")
                riscv_emitter.emit("    sd a0, 0(sp)")
            
            elif opcode == "SSTORE":
                riscv_emitter.emit("    ld a1, 0(sp)")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    ld a0, 0(sp)")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    jal sstore_impl")
            
            elif opcode == "MLOAD":
                riscv_emitter.emit("    ld a0, 0(sp)")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    jal mload_impl")
                riscv_emitter.emit("    addi sp, sp, -8")
                riscv_emitter.emit("    sd a0, 0(sp)")
            
            elif opcode == "MSTORE":
                riscv_emitter.emit("    ld a1, 0(sp)")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    ld a0, 0(sp)")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    jal mstore_impl")
            
            elif opcode == "REVERT":
                riscv_emitter.emit("    ld a1, 0(sp)  # size")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    ld a0, 0(sp)  # offset")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    j revert_impl")
            
            elif opcode == "RETURN":
                riscv_emitter.emit("    ld a1, 0(sp)  # size")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    ld a0, 0(sp)  # offset")
                riscv_emitter.emit("    addi sp, sp, 8")
                riscv_emitter.emit("    j return_impl")

        # Write the final assembly
        with open(output_file, 'w') as f:
            f.write(riscv_emitter.emit_code())
            logger.info(f"RISC-V assembly written to {output_file}")

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