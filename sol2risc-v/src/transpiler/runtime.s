.section .text

.globl mload
.globl mstore
.globl deduct_gas
.globl keccak256
.globl add256
.globl sub256
.globl mul256
.globl evm_revert
.globl evm_return
.globl codecopy
.globl memcpy
.globl get_call_value
.globl _exit
.globl _revert_out_of_gas
.globl _invalid

# ---------------------------
# Constants
# ---------------------------
.equ MEM_BASE, 0x10000000
.equ GAS_REGISTER, s1
.equ RETURN_DATA_OFFSET, s4
.equ RETURN_DATA_SIZE, s5

# ---------------------------
# Memory Management
# ---------------------------

# mload: Load 256-bit word (4x64-bit) from EVM memory
# a0 = offset, result in a0-a3
mload:
    lw t0, 0(sp)
    addi sp, sp, 4
    li t1, MEM_BASE
    add t1, t1, t0
    ld a0, 0(t1)
    ld a1, 8(t1)
    ld a2, 16(t1)
    ld a3, 24(t1)
    jr ra

# mstore: Store 256-bit value from a0-a3 into memory at offset in stack
mstore:
    lw t0, 0(sp)
    addi sp, sp, 4
    li t1, MEM_BASE
    add t1, t1, t0
    sd a0, 0(t1)
    sd a1, 8(t1)
    sd a2, 16(t1)
    sd a3, 24(t1)
    jr ra

# codecopy: a0 = dest, a1 = src, a2 = size
codecopy:
    add t0, s0, a0
    add t1, s0, a1
    call memcpy
    ret

# ---------------------------
# Gas Metering
# ---------------------------

# deduct_gas: a0 = gas cost
deduct_gas:
    sub GAS_REGISTER, GAS_REGISTER, a0
    bltz GAS_REGISTER, _revert_out_of_gas
    jr ra

# ---------------------------
# Cryptographic Operations
# ---------------------------

keccak256:
    li a0, 0xDEADBEEF
    jr ra

# ---------------------------
# Big Integer Arithmetic
# ---------------------------

# a0: ptr to A, a1: ptr to B, a2: ptr to OUT
add256:
    li t0, 0
    li t1, 0
.add256_loop:
    bge t1, 4, .add256_done
    ld t2, 0(a0)
    ld t3, 0(a1)
    add t4, t2, t3
    add t4, t4, t0
    sd t4, 0(a2)
    sltu t0, t4, t2
    addi a0, a0, 8
    addi a1, a1, 8
    addi a2, a2, 8
    addi t1, t1, 1
    j .add256_loop
.add256_done:
    jr ra

# a0: ptr to A, a1: ptr to B, a2: ptr to OUT
sub256:
    li t0, 0
    li t1, 0
.sub256_loop:
    bge t1, 4, .sub256_done
    ld t2, 0(a0)
    ld t3, 0(a1)
    sub t4, t2, t3
    sub t4, t4, t0
    sd t4, 0(a2)
    sltu t0, t2, t3
    addi a0, a0, 8
    addi a1, a1, 8
    addi a2, a2, 8
    addi t1, t1, 1
    j .sub256_loop
.sub256_done:
    jr ra

# mul256: full 256-bit multiplication
# Not yet implemented
mul256:
    j _not_implemented

# ---------------------------
# Error Handling
# ---------------------------

evm_revert:
    mv RETURN_DATA_OFFSET, a0
    mv RETURN_DATA_SIZE, a1
    li a0, 0xFFFF
    j _exit

evm_return:
    mv RETURN_DATA_OFFSET, a0
    mv RETURN_DATA_SIZE, a1
    j _exit

_revert_out_of_gas:
    li a0, 0xFFFF
    j _exit

_invalid:
    li a0, 0xFFFE
    j _exit

# ---------------------------
# Exit Routine
# ---------------------------

_exit:
    ebreak
    jr ra

# ---------------------------
# Helpers
# ---------------------------

_not_implemented:
    ecall
    jr ra

# memcpy: a0 = dst, a1 = src, a2 = len
memcpy:
    beqz a2, memcpy_done
    lbu t0, 0(a1)
    sb  t0, 0(a0)
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    j memcpy
memcpy_done:
    jr ra

get_call_value:
    li a0, 0x00
    jr ra
