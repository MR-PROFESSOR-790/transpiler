# Generated RISC-V Assembly from EVM bytecode
# This file was transpiled automatically

.section .data
evm_memory:     .space 65536   # 64KB EVM memory
evm_storage_keys:   .space 1024   # Storage keys
evm_storage_values: .space 1024   # Storage values

.section .rodata
__contract_code:
    .byte 0x60, 0x80, 0x60, 0x40, 0x52, 0x33, 0x60, 0x0e
    .byte 0x14, 0x60, 0x00, 0x14, 0x60, 0x00, 0xfd, 0x60
    .byte 0x00, 0x40, 0x51, 0x60, 0x3e, 0x60, 0x1a, 0x60
    .byte 0x00, 0x37, 0x60, 0x00, 0xf3, 0xfe, 0x60, 0x80
    .byte 0x60, 0x40, 0x52, 0x60, 0x00, 0x60, 0x00, 0xfd

.section .text
.global _start         # Changed from .globl main

_start:               # Changed from main:
    # Initialize stack pointer and frame
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    addi s0, sp, 16

    # Initialize gas counter if metering is enabled
    li a4, 0         # Gas used = 0

    # EVM: 0000: PUSH1 80
evm_addr_0000:
    li a0, 0x80
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 0002: PUSH1 40
evm_addr_0002:
    li a0, 0x40
    addi a5, a5, 1
    sd a0, -16(sp)

    # EVM: 0004: MSTORE
evm_addr_0004:
    ld a0, -16(sp)
    addi a5, a5, -1
    ld a1, -8(sp)
    addi a5, a5, -1

    lui t0, %hi(evm_memory)
    addi t0, t0, %lo(evm_memory)
    slli a0, a0, 5
    add t0, t0, a0
    sd a1, 0(t0)

    # EVM: 0005: CALLVALUE
evm_addr_0005:
    li a0, 0
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 0006: DUP1
evm_addr_0006:
    ld a0, -8(sp)
    addi a5, a5, 1
    sd a0, -16(sp)

    # EVM: 0007: ISZERO
evm_addr_0007:
    ld a0, -16(sp)
    addi a5, a5, -1
    seqz a0, a0
    sd a0, -8(sp)

    # EVM: 0008: PUSH1 0e
evm_addr_0008:
    li a0, 0x0e
    addi a5, a5, 1
    sd a0, -16(sp)

    # EVM: 000a: JUMPI
evm_addr_000a:
    ld a1, -16(sp)
    addi a5, a5, -1
    ld a0, -8(sp)
    addi a5, a5, -1
    bnez a0, evm_addr_000e

    # EVM: 000b: PUSH0
evm_addr_000b:
    li a0, 0
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 000c: DUP1
evm_addr_000c:
    ld a0, -8(sp)
    addi a5, a5, 1
    sd a0, -16(sp)

    # EVM: 000d: REVERT
evm_addr_000d:
    j exit

    # EVM: 000e: JUMPDEST
evm_addr_000e:
    ld a0, -8(sp)
    addi a5, a5, -1

    # EVM: 000f: POP
evm_addr_000f:
    addi a5, a5, -1

    # EVM: 0010: PUSH1 3e
evm_addr_0010:
    li a0, 0x3e
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 0012: DUP1
evm_addr_0012:
    ld a0, -8(sp)
    addi a5, a5, 1
    sd a0, -16(sp)

    # EVM: 0013: PUSH1 1a
evm_addr_0013:
    li a0, 0x1a
    addi a5, a5, 1
    sd a0, -24(sp)

    # EVM: 0015: PUSH0
evm_addr_0015:
    li a0, 0
    addi a5, a5, 1
    sd a0, -32(sp)

    # EVM: 0016: CODECOPY
evm_addr_0016:
    ld a2, -32(sp)
    addi a5, a5, -1
    ld a1, -24(sp)
    addi a5, a5, -1
    ld a0, -16(sp)
    addi a5, a5, -1

    la t0, __contract_code
    add a0, t0, a0
    la t1, evm_memory
    add a1, t1, a1
    sd a2, 0(a1)

    # EVM: 0017: PUSH0
evm_addr_0017:
    li a0, 0
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 0018: RETURN
evm_addr_0018:
    j exit

    # EVM: 0019: INVALID
evm_addr_0019:
    li a0, 0
    j exit

    # EVM: 001a: PUSH1 80
evm_addr_001a:
    li a0, 0x80
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 001c: PUSH1 40
evm_addr_001c:
    li a0, 0x40
    addi a5, a5, 1
    sd a0, -16(sp)

    # EVM: 001e: MSTORE
evm_addr_001e:
    ld a0, -16(sp)
    addi a5, a5, -1
    ld a1, -8(sp)
    addi a5, a5, -1

    lui t0, %hi(evm_memory)
    addi t0, t0, %lo(evm_memory)
    slli a0, a0, 5
    add t0, t0, a0
    sd a1, 0(t0)

    # EVM: 001f: PUSH0
evm_addr_001f:
    li a0, 0
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 0020: DUP1
evm_addr_0020:
    ld a0, -8(sp)
    addi a5, a5, 1
    sd a0, -16(sp)

    # EVM: 0021: REVERT
evm_addr_0021:
    j exit

    # EVM: 0022: INVALID
evm_addr_0022:
    li a0, 0
    j exit

    # EVM: 0023: LOG2
evm_addr_0023:
    # Not implemented yet
    j exit

    # EVM: 0024: PUSH5 6970667358
evm_addr_0024:
    # Fix large immediate value using multiple operations
    li t0, 0x6970
    slli t0, t0, 16
    li t1, 0x6673
    or t0, t0, t1
    slli t0, t0, 8
    li t1, 0x58
    or a0, t0, t1
    addi a5, a5, 1
    sd a0, -8(sp)

    # EVM: 002a: UNKNOWN_0x22
evm_addr_002a:
    # Unknown opcode
    j exit

    # EVM: 002b: SLT
evm_addr_002b:
    ld a1, -8(sp)
    addi a5, a5, -1
    ld a0, -16(sp)
    addi a5, a5, -1
    slt a0, a0, a1
    sd a0, -8(sp)

    # EVM: 002c: SHA3
evm_addr_002c:
    # Call internal SHA3 implementation instead of external
    ld a1, -8(sp)     # size
    ld a0, -16(sp)    # offset
    call evm_sha3     # Changed from __evm_sha3
    sd a0, -8(sp)

    # EVM: 002d: TIMESTAMP
evm_addr_002d:
    li a0, 0
    sd a0, -8(sp)

    # EVM: 0030: JUMPDEST
evm_addr_0030:
    # Jump destination marker

    # EVM: 0032: JUMPDEST
evm_addr_0032:
    # Jump destination marker

    # EVM: 0034: POP
evm_addr_0034:
    addi a5, a5, -1

    # EVM: 0037: NOT
evm_addr_0037:
    ld a0, -8(sp)
    addi a5, a5, -1
    not a0, a0
    sd a0, -8(sp)

    # EVM: 003b: MSIZE
evm_addr_003b:
    li a0, 0
    sd a0, -8(sp)

    # EVM: 003e: CALL
evm_addr_003e:
    # Placeholder for CALL instruction
    li a0, 0
    sd a0, -8(sp)

    # EVM: 0040: UNKNOWN_0xd8
evm_addr_0040:
    # Unknown opcode
    j exit

    # EVM: 0041: CREATE
evm_addr_0041:
    # Placeholder for CREATE instruction
    li a0, 0
    sd a0, -8(sp)

    # EVM: 0042: MSIZE
evm_addr_0042:
    li a0, 0
    sd a0, -8(sp)

    # EVM: 0043: SWAP7
evm_addr_0043:
    ld a0, -8(sp)
    addi a5, a5, -1
    ld a1, -64(sp)
    sd a1, -8(sp)
    sd a0, -64(sp)

    # EVM: 0045: PUSH25 e15bdbd97a4c7d64736f6c634300081a003300000000000000
evm_addr_0045:
    # Load large constant in multiple steps
    li t0, 0xe15b
    slli t0, t0, 16
    li t1, 0xdbd9
    or t0, t0, t1
    slli t0, t0, 16
    li t1, 0x7a4c
    or t0, t0, t1
    
    li t1, 0x7d64
    slli t1, t1, 16
    li t2, 0x736f
    or t1, t1, t2
    
    li t2, 0x6c63
    slli t2, t2, 16
    li t3, 0x4300
    or t2, t2, t3
    
    li t3, 0x081a
    slli t3, t3, 16
    li t4, 0x0033
    or t3, t3, t4
    
    # Store the values
    sd t0, -8(sp)
    sd t1, -16(sp)
    sd t2, -24(sp)
    sd t3, -32(sp)
    addi a5, a5, 1

exit:
    # Exit program using proper syscall
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    li a7, 93         # exit syscall number
    li a0, 0          # exit code
    ecall             # make syscall

# Helper functions for EVM operations

# Memory Operations
evm_mstore:
    # a0 = offset, a1 = value
    lui t0, %hi(evm_memory)
    addi t0, t0, %lo(evm_memory)
    add t0, t0, a0
    sd a1, 0(t0)
    ret

evm_mload:
    # a0 = offset
    lui t0, %hi(evm_memory)
    addi t0, t0, %lo(evm_memory)
    add t0, t0, a0
    ld a0, 0(t0)
    ret

# SHA3 Hash Function (Simple implementation)
evm_sha3:
    # Simple hash implementation for testing
    # a0 = offset, a1 = size
    mv t0, a0         # save offset
    mv t1, a1         # save size
    li a0, 0         # initialize hash
    
.L_sha3_loop:
    beqz t1, .L_sha3_done
    lb t2, 0(t0)     # load byte
    add a0, a0, t2   # add to hash
    slli a0, a0, 3   # shift left
    xor a0, a0, t2   # xor with byte
    addi t0, t0, 1   # increment pointer
    addi t1, t1, -1  # decrement count
    j .L_sha3_loop

.L_sha3_done:
    ret

# Arithmetic Helpers
evm_add:
    add a0, a0, a1
    ret

evm_mul:
    mul a0, a0, a1
    ret

evm_div:
    div a0, a0, a1
    ret

evm_mod:
    rem a0, a0, a1
    ret

evm_lt:
    slt a0, a0, a1
    ret

evm_gt:
    sgt a0, a0, a1
    ret

evm_eq:
    xor a0, a0, a1
    seqz a0, a0
    ret

evm_not:
    not a0, a0
    ret

evm_slt:
    slt a0, a0, a1
    ret

evm_sgt:
    sgt a0, a0, a1
    ret

.end