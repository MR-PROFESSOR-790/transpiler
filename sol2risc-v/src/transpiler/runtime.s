# runtime.s - Core EVM Runtime Support in RISC-V Assembly

# Memory layout constants
MEM_BASE = 0x10000000       # Base of simulated EVM memory
STACK_BASE = 0x20000000     # Simulated stack base
GAS_REGISTER = s11          # Register used to track remaining gas
PC_REGISTER = s10           # Simulated program counter or return address
RETURN_DATA_SIZE = s9       # Size of return data after calls
RETURN_DATA_OFFSET = s8     # Offset to return data buffer

# ---------------------------
# Memory Management
# ---------------------------

# mload: Load word from EVM memory
# Stack input: offset
# Result stored in a0
mload:
    # Get offset
    lw t0, 0(sp)
    addi sp, sp, 4         # Pop offset

    # Compute address = MEM_BASE + offset
    li t1, MEM_BASE
    add t1, t1, t0

    # Load word into result register
    lw a0, 0(t1)
    jr ra

# mstore: Store word into EVM memory
# Stack inputs: offset, value
mstore:
    # Pop value
    lw t0, 0(sp)
    addi sp, sp, 4

    # Pop offset
    lw t1, 0(sp)
    addi sp, sp, 4

    # Compute address = MEM_BASE + offset
    li t2, MEM_BASE
    add t2, t2, t1

    # Store value
    sw t0, 0(t2)
    jr ra

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

# keccak256: Hashes memory range [offset, offset+size)
# Inputs:
#   a0 = offset
#   a1 = size
# Output:
#   a0 = hash pointer (simplified stub)
keccak256:
    # In real use, this would implement or call an optimized SHA3 function
    # For now, we'll simulate it as a no-op that returns a dummy hash
    li a0, 0xDEADBEEF
    jr ra

# ---------------------------
# Big Integer Arithmetic
# ---------------------------

# add256: Add two 256-bit unsigned integers
# Inputs:
#   a0 = ptr to first number (8 words)
#   a1 = ptr to second number (8 words)
# Output:
#   a2 = ptr to result (8 words)
add256:
    li t0, 0                # Carry
    li t1, 0                # index
.add256_loop:
    bge t1, 8, .add256_done

    lw t2, 0(a0)            # load word from a
    lw t3, 0(a1)            # load word from b
    add t4, t2, t3
    add t4, t4, t0          # add carry
    sw t4, 0(a2)            # store result

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

# sub256: Subtract two 256-bit unsigned integers
# Inputs:
#   a0 = ptr to minuend
#   a1 = ptr to subtrahend
# Output:
#   a2 = ptr to result
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

    sltu t0, t2, t3         # borrow = (minuend < subtrahend)
    sltu t5, t4, t3         # additional borrow if result < subtrahend
    or t0, t0, t5

    addi a0, a0, 4
    addi a1, a1, 4
    addi a2, a2, 4
    addi t1, t1, 1
    j .sub256_loop
.sub256_done:
    jr ra

# mul256: Multiply two 256-bit numbers (stub)
# Full implementation would be complex; this is a placeholder.
mul256:
    jal _not_implemented
    jr ra

# ---------------------------
# Error Handling
# ---------------------------

# revert: Revert execution with reason and data
# Inputs:
#   a0 = offset
#   a1 = size
_revert:
    # Save error info
    mv RETURN_DATA_OFFSET, a0
    mv RETURN_DATA_SIZE, a1
    # Fall through to general revert handler

_revert_out_of_gas:
    li a0, 0xFFFF          # Set error code
    j _exit

_invalid:
    li a0, 0xFFFE          # Invalid instruction error
    j _exit

# ---------------------------
# Exit Routine
# ---------------------------

_exit:
    # End execution
    ebreak
    jr ra

# ---------------------------
# Helpers
# ---------------------------

_not_implemented:
    ecall
    jr ra