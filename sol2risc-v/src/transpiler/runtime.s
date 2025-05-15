# runtime.s - Core EVM Runtime Support in RISC-V Assembly
# Fully valid RISC-V 64-bit code that can be assembled with riscv64-unknown-elf-as

.section .text
.align 2

.globl _start
.globl evm_entry
.globl deduct_gas
.globl get_call_value
.globl evm_revert
.globl evm_return
.globl evm_codecopy
.globl memcpy
.globl keccak256
.globl add256
.globl sub256
.globl mul256
.globl exp256
.globl mod256
.globl addmod256
.globl mulmod256
.globl gt256
.globl eq256
.globl iszero256
.globl and256
.globl or256
.globl xor256
.globl not256
.globl shl256
.globl shr256
.globl sar256
.globl calldataload
.globl calldatasize
.globl calldatacopy
.globl mload
.globl mstore
.globl mstore8

# Memory layout constants (use real registers instead of macros)
.set MEM_BASE, 0x10000000       # Base of simulated EVM memory
.set CALLDATA_BASE, 0x20000000   # Base of calldata
.set STACK_BASE, 0x30000000      # Simulated stack base

# Register aliases (must use actual registers)
.set GAS_REGISTER, s1            # Track remaining gas
.set RETURN_DATA_OFFSET, s4      # Offset to return data buffer
.set RETURN_DATA_SIZE, s5        # Size of return data

# ---------------------------
# Entry Point
# ---------------------------

_start:
    jal ra, evm_entry
    j _exit

# ---------------------------
# Stack Helpers
# ---------------------------

# Push 256-bit value onto stack (a0-a3)
stack_push_256:
    addi sp, sp, -32
    sd a0, 0(sp)
    sd a1, 8(sp)
    sd a2, 16(sp)
    sd a3, 24(sp)
    jr ra

# Pop 256-bit value from stack into a0-a3
stack_pop_256:
    ld a0, 0(sp)
    ld a1, 8(sp)
    ld a2, 16(sp)
    ld a3, 24(sp)
    addi sp, sp, 32
    jr ra

# ---------------------------
# Gas Metering
# ---------------------------

# deduct_gas: Deduct a fixed amount of gas
# Input: a0 = gas cost
deduct_gas:
    sub s1, s1, a0
    bltz s1, _revert_out_of_gas
    jr ra

# ---------------------------
# External Interactions
# ---------------------------

# get_call_value: Simulate msg.value
get_call_value:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    jr ra

# calldatasize: Return size of input data
calldatasize:
    la t0, calldata_size
    lw a0, 0(t0)
    jr ra

# calldataload: Load 256-bit value from calldata
# Input: a0 = offset on stack
calldataload:
    jal ra, stack_pop_256         # Pop offset
    slli t0, a0, 3              # Convert bytes to bits
    srli t0, t0, 6              # Convert bits to words (64-bit words)
    add t1, t0, t0              # x2
    add t1, t1, t0             # x3 -> word index
    slli t1, t1, 3             # *8 bytes per word
    add t1, t1, t0             # Final offset
    li t0, CALLDATA_BASE
    add t0, t0, t1              # Final address
    ld a0, 0(t0)
    ld a1, 8(t0)
    ld a2, 16(t0)
    ld a3, 24(t0)
    jal ra, stack_push_256
    jr ra

# calldatacopy: Copy calldata to memory
# Inputs: a0 = dest offset, a1 = src offset, a2 = length
calldatacopy:
    add a0, s0, a0
    li t0, CALLDATA_BASE
    add a1, t0, a1
    call memcpy
    jr ra

# ---------------------------
# Memory Management
# ---------------------------

# mload: Load 256-bit word from memory
# Input: a0 = offset
# Output: a0-a3 = value
mload:
    addi sp, sp, -8
    sd ra, 0(sp)

    slli t0, a0, 0
    li t1, MEM_BASE
    add t0, t0, t1

    ld a0, 0(t0)
    ld a1, 8(t0)
    ld a2, 16(t0)
    ld a3, 24(t0)

    ld ra, 0(sp)
    addi sp, sp, 8
    jr ra

# mstore: Store 256-bit value to memory
# Inputs: a0 = offset, a1-a4 = value
mstore:
    addi sp, sp, -8
    sd ra, 0(sp)
    addi sp, sp, -8
    sd a0, 0(sp)  # Save offset
    sd a1, 8(sp)  # Save value parts

    slli t0, a0, 0
    li t1, MEM_BASE
    add t0, t0, t1

    sd a1, 0(t0)
    sd a2, 8(t0)
    sd a3, 16(t0)
    sd a4, 24(t0)

    ld a0, 0(sp)
    ld a1, 8(sp)
    addi sp, sp, 16
    ld ra, 0(sp)
    addi sp, sp, 8
    jr ra

# mstore8: Store byte to memory
mstore8:
    li t0, MEM_BASE
    add t0, t0, a0
    sb a1, 0(t0)
    jr ra

# ---------------------------
# Cryptographic Operations
# ---------------------------

# keccak256: Compute Keccak-256 hash (stub)
keccak256:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    jr ra

# ---------------------------
# Arithmetic Operations
# ---------------------------

# add256: Add two 256-bit numbers
add256:
    addi sp, sp, -8
    sd ra, 0(sp)
    li t0, 0  # carry

    add a0, a0, a4
    sltu t0, a0, a4
    add a1, a1, a5
    add a1, a1, t0
    sltu t1, a1, t0
    mv t0, t1
    add a2, a2, a6
    add a2, a2, t0
    sltu t1, a2, t0
    mv t0, t1
    add a3, a3, a7
    add a3, a3, t0

    ld ra, 0(sp)
    addi sp, sp, 8
    jr ra

# sub256: Subtract two 256-bit numbers
sub256:
    addi sp, sp, -8
    sd ra, 0(sp)
    li t0, 0  # borrow

    sub a0, a0, a4
    bgez a0, 1f
    addi t0, t0, 1
1:
    sub a1, a1, a5
    addi sp, sp, 8
    jr ra

# mul256: Multiply two 256-bit numbers (placeholder)
mul256:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    jr ra

# div256: 256-bit division (placeholder)
div256:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    jr ra

# mod256: 256-bit modulo operation (placeholder)
mod256:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    jr ra

# addmod256: (a + b) % N
addmod256:
    jal ra, add256
    jal ra, mod256
    jr ra

# mulmod256: (a * b) % N
mulmod256:
    jal ra, mul256
    jal ra, mod256
    jr ra

# exp256: a^b
exp256:
    li a0, 1
    li a1, 0
    li a2, 0
    li a3, 0
    jr ra

# ---------------------------
# Comparison Operations
# ---------------------------

# gt256: Compare 256-bit values
gt256:
    bgtu a3, a7, gt256_true
    bne a3, a7, gt256_false
    bgtu a2, a6, gt256_true
    bne a2, a6, gt256_false
    bgtu a1, a5, gt256_true
    bne a1, a5, gt256_false
    bgtu a0, a4, gt256_true
    bne a0, a4, gt256_false
    li a0, 0
    jr ra
gt256_true:
    li a0, 1
    jr ra
gt256_false:
    li a0, 0
    jr ra

# eq256: Check if two 256-bit values are equal
eq256:
    bne a0, a4, eq256_false
    bne a1, a5, eq256_false
    bne a2, a6, eq256_false
    bne a3, a7, eq256_false
    li a0, 1
    jr ra
eq256_false:
    li a0, 0
    jr ra

# iszero256: Check if 256-bit value is zero
iszero256:
    or t0, a0, a1
    or t0, t0, a2
    or t0, t0, a3
    seqz a0, t0
    jr ra

# ---------------------------
# Bitwise Operations
# ---------------------------

# and256: Bitwise AND
and256:
    and a0, a0, a4
    and a1, a1, a5
    and a2, a2, a6
    and a3, a3, a7
    jr ra

# or256: Bitwise OR
or256:
    or a0, a0, a4
    or a1, a1, a5
    or a2, a2, a6
    or a3, a3, a7
    jr ra

# xor256: Bitwise XOR
xor256:
    xor a0, a0, a4
    xor a1, a1, a5
    xor a2, a2, a6
    xor a3, a3, a7
    jr ra

# not256: Bitwise NOT
not256:
    not a0, a0
    not a1, a1
    not a2, a2
    not a3, a3
    jr ra

# shl256: Shift left 256-bit number
shl256:
    slli t0, a4, 3           # shift_amount * 8
    li t1, 64               # 64 bits per word
    beqz t0, shl256_word_aligned

    li t3, 0                # Temp for overflow
    li t4, 0

    # Handle shifts >= 256 bits
   li t1, 256
   bge t0, t1, shl256_zero

    # Word-aligned shifts
shl256_word_aligned:
    beqz t0, shl256_done
    li t1, 1
    beq t0, t1, shl256_shift_1
    li t1, 2
    beq t0, t1, shl256_shift_2
    li t1, 3
    beq t0, t1, shl256_shift_3
    j shl256_bit_shift

shl256_shift_1:
    mv a3, a2
    mv a2, a1
    mv a1, a0
    li a0, 0
    j shl256_bit_shift

shl256_shift_2:
    mv a3, a1
    mv a2, a0
    li a1, 0
    li a0, 0
    j shl256_bit_shift

shl256_shift_3:
    mv a3, a0
    li a0, 0
    li a1, 0
    li a2, 0
    j shl256_bit_shift

shl256_bit_shift:
    rem t0, a4, t1          # Remaining bits after word shifts
    beqz t0, shl256_done

    li t2, 64
    sub t2, t2, t0          # 64-shift_amount for right shift
    srl t3, a0, t2
    sll a0, a0, t0
    srl t4, a1, t2
    or a0, a0, t3
    sll a1, a1, t0
    or a1, a1, t4
    sll a2, a2, t0
    or a2, a2, t4
    sll a3, a3, t0
    or a3, a3, t4

shl256_done:
    jr ra

shl256_zero:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    jr ra

# shr256: Logical right shift
shr256:
    srl a0, a0, a4
    srl a1, a1, a4
    srl a2, a2, a4
    srl a3, a3, a4
    jr ra

# sar256: Arithmetic right shift
sar256:
    sra a0, a0, a4
    sra a1, a1, a4
    sra a2, a2, a4
    sra a3, a3, a4
    jr ra

# ---------------------------
# Exit & Error Handling
# ---------------------------

# evm_revert: Revert execution
evm_revert:
    ebreak
    jr ra

# evm_return: Normal return
evm_return:
    jr ra

# _revert_out_of_gas: Out of gas error
_revert_out_of_gas:
    li a0, 0xFFFF
    j _exit

_invalid:
    li a0, 0xFFFE
    j _exit

# _exit: End execution
_exit:
    ebreak
    jr ra

# ---------------------------
# Helper Functions
# ---------------------------

# memcpy: Copy bytes between memory regions
# a0 = dst, a1 = src, a2 = length
memcpy:
    beqz a2, memcpy_done
    lbu t0, 0(a1)
    sb t0, 0(a0)
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    j memcpy
memcpy_done:
    jr ra

# ---------------------------
# Data Sections
# ---------------------------

.section .rodata
.align 3
calldata_size:
    .word 0x00              # Placeholder for calldata size

.section .bss
.align 4
evm_stack: .space 4096      # Space for EVM stack simulation
.section .text
