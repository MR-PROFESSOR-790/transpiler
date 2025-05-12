.globl mload
.globl mstore
.globl deduct_gas
.globl keccak256
.globl add256
.globl sub256
.globl mul256
.globl evm_revert
.globl evm_return
.globl evm_codecopy
.globl memcpy

# ---------------------------
# Memory Management
# ---------------------------

# mload: Load word from EVM memory
# Stack input: offset
# Result stored in a0
mload:
    lw t0, 0(sp)
    addi sp, sp, 4         # Pop offset
    li t1, MEM_BASE
    add t1, t1, t0
    lw a0, 0(t1)
    jr ra

# mstore: Store word into EVM memory
# Stack inputs: offset, value
mstore:
    lw t0, 0(sp)
    addi sp, sp, 4
    lw t1, 0(sp)
    addi sp, sp, 4
    li t2, MEM_BASE
    add t2, t2, t1
    sw t0, 0(t2)
    jr ra

# codecopy: Copy bytes in memory
evm_codecopy:
    add t0, s0, a0     # MEM_BASE + dest
    add t1, s0, a1     # MEM_BASE + source
    call memcpy
    ret

# ---------------------------
# Gas Metering
# ---------------------------

# deduct_gas: Deduct a fixed amount of gas
# Input: a0 = gas cost
deduct_gas:
    sub GAS_REGISTER, GAS_REGISTER, a0
    bltz GAS_REGISTER, _revert_out_of_gas
    jr ra

# ---------------------------
# Cryptographic Operations
# ---------------------------

.globl keccak256
keccak256:
    li a0, 0xDEADBEEF
    jr ra

# ---------------------------
# Big Integer Arithmetic
# ---------------------------

.globl add256
add256:
    li t0, 0                # Carry
    li t1, 0                # index
.add256_loop:
    bge t1, 8, .add256_done
    lw t2, 0(a0)            # load word from a
    lw t3, 0(a1)            # load word from b
    add t4, t2, t3
    add t4, t4, t0          # add carry
    sw t4, 0(a2)           # store result
    sltu t0, t4, t2         # check carry
    sltu t5, t4, t3
    or t0, t0, t5
    addi a0, a0, 4
    addi a1, a1, 4
    addi a2, a2, 4
    addi t1, t1, 1
    j .add256_loop
.add256_done:
    jr ra

.globl sub256
sub256:
    li t0, 0                # Borrow
    li t1, 0
.sub256_loop:
    bge t1, 8, .sub256_done
    lw t2, 0(a0)
    lw t3, 0(a1)
    sub t4, t2, t3
    sub t4, t4, t0
    sw t4, 0(a2)
    sltu t0, t2, t3
    sltu t5, t4, t3
    or t0, t0, t5
    addi a0, a0, 4
    addi a1, a1, 4
    addi a2, a2, 4
    addi t1, t1, 1
    j .sub256_loop
.sub256_done:
    jr ra

.globl mul256
mul256:
    jal _not_implemented
    jr ra

# ---------------------------
# Error Handling
# ---------------------------

.globl evm_revert
evm_revert:
    mv RETURN_DATA_OFFSET, a0
    mv RETURN_DATA_SIZE, a1
    j _exit

.globl evm_return
evm_return:
    mv RETURN_DATA_OFFSET, a0
    mv RETURN_DATA_SIZE, a1
    j _exit

.globl _revert_out_of_gas
_revert_out_of_gas:
    li a0, 0xFFFF
    j _exit

.globl _invalid
_invalid:
    li a0, 0xFFFE
    j _exit

# ---------------------------
# Exit Routine
# ---------------------------

.globl _exit
_exit:
    ebreak
    jr ra

# ---------------------------
# Helpers
# ---------------------------

_not_implemented:
    ecall
    jr ra

# Standard library stubs
.globl memcpy
memcpy:
    # Simple byte copy (could be optimized)
    # a0 = dst, a1 = src, a2 = len
    beqz a2, memcpy_done
    lbu t0, 0(a1)
    sb t0, 0(a0)
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    j memcpy
memcpy_done:
    jr ra

.globl get_call_value
get_call_value:
    li a0, 0x0              # Simulated call value
    jr ra

.globl evm_return
evm_return:
    # a0 = offset, a1 = size
    # Return execution normally
    jr ra

.globl evm_revert
evm_revert:
    # a0 = offset, a1 = size
    # Revert execution
    li a0, 0xFFFF
    j _exit