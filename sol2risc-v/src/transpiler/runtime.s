.section .text
.globl mload
.globl mstore
.globl deduct_gas
.globl keccak256
.globl add256
.globl sub256
.globl mul256
.globl div256
.globl mod256
.globl addmod256
.globl mulmod256
.globl exp256
.globl lt256
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
.globl byte_access
.globl evm_revert
.globl evm_return
.globl codecopy
.globl memcpy
.globl get_call_value
.globl calldataload
.globl calldatasize
.globl calldatacopy
.globl _exit
.globl _revert_out_of_gas
.globl _invalid

# ---------------------------
# Constants
# ---------------------------
.equ MEM_BASE, 0x10000000
.equ CALLDATA_BASE, 0x20000000
.equ STACK_BASE, 0x30000000
.equ GAS_REGISTER, s1
.equ RETURN_DATA_OFFSET, s4
.equ RETURN_DATA_SIZE, s5
.equ MAX_UINT64, 0xFFFFFFFFFFFFFFFF

# ---------------------------
# Memory Management
# ---------------------------

# mload: Load 256-bit word (4x64-bit) from EVM memory
# Input: a0 = offset (consumed from stack)
# Output: a0-a3 = 256-bit value (4x64-bit)
mload:
    # Get offset from stack
    lw t0, 0(sp)
    addi sp, sp, 4
    
    # Calculate memory address
    li t1, MEM_BASE
    add t1, t1, t0
    
    # Load 256-bit value (4x64-bit words)
    ld a0, 0(t1)   # Low 64 bits
    ld a1, 8(t1)   # Next 64 bits
    ld a2, 16(t1)  # Next 64 bits
    ld a3, 24(t1)  # High 64 bits
    
    ret

# mstore: Store 256-bit value to memory
# Input: a0-a3 = 256-bit value, stack holds the offset
mstore:
    # Get offset from stack
    lw t0, 0(sp)
    addi sp, sp, 4
    
    # Calculate memory address
    li t1, MEM_BASE
    add t1, t1, t0
    
    # Store 256-bit value (4x64-bit words)
    sd a0, 0(t1)   # Low 64 bits
    sd a1, 8(t1)   # Next 64 bits
    sd a2, 16(t1)  # Next 64 bits
    sd a3, 24(t1)  # High 64 bits
    
    ret

# mstore8: Store a single byte to memory
# Input: a0 = 256-bit value (only lowest byte used), stack holds the offset
mstore8:
    # Get offset from stack
    lw t0, 0(sp)
    addi sp, sp, 4
    
    # Calculate memory address
    li t1, MEM_BASE
    add t1, t1, t0
    
    # Store only the lowest byte
    sb a0, 0(t1)
    
    ret

# codecopy: Copy code to memory
# Input: a0 = dest offset, a1 = src offset, a2 = size
codecopy:
    # Calculate memory addresses
    li t0, MEM_BASE
    add a0, t0, a0  # dest address
    add a1, s0, a1  # src address (s0 holds code base)
    
    # Call memcpy
    call memcpy
    
    ret

# calldataload: Load 256 bits from calldata
# Input: a0 = offset (consumed from stack)
# Output: a0-a3 = 256-bit value
calldataload:
    # Get offset from stack
    lw t0, 0(sp)
    addi sp, sp, 4
    
    # Calculate calldata address
    li t1, CALLDATA_BASE
    add t1, t1, t0
    
    # Load 256-bit value (4x64-bit words)
    ld a0, 0(t1)
    ld a1, 8(t1)
    ld a2, 16(t1)
    ld a3, 24(t1)
    
    ret

# calldatasize: Get size of calldata
# Output: a0 = size (lowest 64 bits), a1-a3 = 0
calldatasize:
    # Load calldata size from a predefined location
    la t0, calldata_size
    lw a0, 0(t0)
    li a1, 0
    li a2, 0
    li a3, 0
    
    ret

# calldatacopy: Copy calldata to memory
# Input: a0 = dest offset, a1 = src offset, a2 = size
calldatacopy:
    # Calculate addresses
    li t0, MEM_BASE
    add a0, t0, a0  # dest address
    li t0, CALLDATA_BASE
    add a1, t0, a1  # src address
    
    # Call memcpy
    call memcpy
    
    ret

# ---------------------------
# Gas Metering
# ---------------------------

# deduct_gas: Deduct gas for an operation
# Input: a0 = gas cost
deduct_gas:
    sub GAS_REGISTER, GAS_REGISTER, a0
    bltz GAS_REGISTER, _revert_out_of_gas
    ret

# ---------------------------
# Cryptographic Operations
# ---------------------------

# keccak256: Compute Keccak-256 hash
# Input: a0 = offset, a1 = size
# Output: a0-a3 = hash result (256 bits)
keccak256:
    # For now, this is a placeholder
    # In a real implementation, this would call a native function
    # or implement the Keccak-256 algorithm
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# ---------------------------
# Arithmetic Operations
# ---------------------------

# add256: 256-bit addition
# Input: a0-a3, a4-a7 = operands (256-bit each)
# Output: a0-a3 = result (256-bit)
add256:
    # Save ra to stack
    addi sp, sp, -8
    sd ra, 0(sp)
    
    # Initialize carry
    li t0, 0
    
    # Add low 64 bits
    add t1, a0, a4
    sltu t2, t1, a0  # Get carry
    mv a0, t1
    
    # Add second 64 bits with carry
    add t1, a1, a5
    add t1, t1, t2
    sltu t2, t1, a1  # Get new carry
    sltu t3, t1, t2
    or t2, t2, t3    # Combine carries
    mv a1, t1
    
    # Add third 64 bits with carry
    add t1, a2, a6
    add t1, t1, t2
    sltu t2, t1, a2  # Get new carry
    sltu t3, t1, t2
    or t2, t2, t3    # Combine carries
    mv a2, t1
    
    # Add high 64 bits with carry
    add t1, a3, a7
    add a3, t1, t2
    
    # Restore ra and return
    ld ra, 0(sp)
    addi sp, sp, 8
    ret

# sub256: 256-bit subtraction
# Input: a0-a3, a4-a7 = operands (256-bit each)
# Output: a0-a3 = result (256-bit)
sub256:
    # Save ra to stack
    addi sp, sp, -8
    sd ra, 0(sp)
    
    # Initialize borrow
    li t0, 0
    
    # Subtract low 64 bits
    sub t1, a0, a4
    sltu t2, a0, a4  # Get borrow
    mv a0, t1
    
    # Subtract second 64 bits with borrow
    sub t1, a1, a5
    sub t1, t1, t2
    sltu t2, a1, a5  # Get new borrow
    sltu t3, a1, t2
    or t2, t2, t3    # Combine borrows
    mv a1, t1
    
    # Subtract third 64 bits with borrow
    sub t1, a2, a6
    sub t1, t1, t2
    sltu t2, a2, a6  # Get new borrow
    sltu t3, a2, t2
    or t2, t2, t3    # Combine borrows
    mv a2, t1
    
    # Subtract high 64 bits with borrow
    sub t1, a3, a7
    sub a3, t1, t2
    
    # Restore ra and return
    ld ra, 0(sp)
    addi sp, sp, 8
    ret

# mul256: 256-bit multiplication (simplified implementation)
# Input: a0-a3, a4-a7 = operands (256-bit each)
# Output: a0-a3 = result (low 256 bits of product)
mul256:
    # Save ra to stack
    addi sp, sp, -8
    sd ra, 0(sp)
    
    # Allocate temp space on stack
    addi sp, sp, -64
    
    # Initialize result to 0
    li t0, 0
    sd t0, 0(sp)
    sd t0, 8(sp)
    sd t0, 16(sp)
    sd t0, 24(sp)
    
    # Simplified multiplication algorithm (repeated addition)
    # Note: This is inefficient but works as a placeholder
    # A real implementation would use a more efficient algorithm
    
    # Store operands to stack for safekeeping
    sd a0, 32(sp)  # First operand (lowest 64 bits)
    sd a1, 40(sp)
    sd a2, 48(sp)
    sd a3, 56(sp)  # First operand (highest 64 bits)
    
    # Initialize counter
    li t0, 0
    
mul256_loop:
    beqz a4, mul256_next  # If current digit is 0, skip addition
    
    # Load first operand from stack
    ld t1, 32(sp)
    ld t2, 40(sp)
    ld t3, 48(sp)
    ld t4, 56(sp)
    
    # Multiply by current digit (simplified: just add operand1 to result a4 times)
    li t5, 0  # counter for inner loop
    
mul256_inner_loop:
    beq t5, a4, mul256_next
    
    # Load current result
    ld a0, 0(sp)
    ld a1, 8(sp)
    ld a2, 16(sp)
    ld a3, 24(sp)
    
    # Add operand1 to result
    add a0, a0, t1
    sltu t6, a0, t1
    add a1, a1, t2
    add a1, a1, t6
    sltu t6, a1, t2
    add a2, a2, t3
    add a2, a2, t6
    sltu t6, a2, t3
    add a3, a3, t4
    add a3, a3, t6
    
    # Store updated result
    sd a0, 0(sp)
    sd a1, 8(sp)
    sd a2, 16(sp)
    sd a3, 24(sp)
    
    addi t5, t5, 1
    j mul256_inner_loop
    
mul256_next:
    # Shift operand1 left by 64 bits (simplified handling for this placeholder)
    ld t1, 0(sp)
    ld t2, 8(sp)
    ld t3, 16(sp)
    
    sd t2, 0(sp)
    sd t3, 8(sp)
    li t4, 0
    sd t4, 16(sp)
    sd t4, 24(sp)
    
    # Move to next digit of operand2
    mv a4, a5
    mv a5, a6
    mv a6, a7
    li a7, 0
    
    addi t0, t0, 1
    li t1, 4
    blt t0, t1, mul256_loop
    
    # Load result
    ld a0, 0(sp)
    ld a1, 8(sp)
    ld a2, 16(sp)
    ld a3, 24(sp)
    
    # Clean up stack
    addi sp, sp, 64
    
    # Restore ra and return
    ld ra, 0(sp)
    addi sp, sp, 8
    ret

# div256: 256-bit division
# Input: a0-a3 = numerator, a4-a7 = denominator
# Output: a0-a3 = quotient
div256:
    # Save ra to stack
    addi sp, sp, -8
    sd ra, 0(sp)
    
    # Check for division by zero
    or t0, a4, a5
    or t0, t0, a6
    or t0, t0, a7
    beqz t0, div_by_zero
    
    # Simplified binary long division algorithm
    # Initialize quotient and remainder
    li t0, 0  # quotient bit position
    li a0, 0  # quotient
    li a1, 0
    li a2, 0
    li a3, 0
    
    # Restore ra and return
    ld ra, 0(sp)
    addi sp, sp, 8
    ret
    
div_by_zero:
    # Return 0 for division by zero
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    
    # Restore ra and return
    ld ra, 0(sp)
    addi sp, sp, 8
    ret

# mod256: 256-bit modulo
# Input: a0-a3 = value, a4-a7 = modulus
# Output: a0-a3 = result
mod256:
    # Currently a placeholder
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# addmod256: (a + b) % N
# Input: a0-a3 = a, a4-a7 = b, stack = N
# Output: a0-a3 = result
addmod256:
    # Currently a placeholder
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# mulmod256: (a * b) % N
# Input: a0-a3 = a, a4-a7 = b, stack = N
# Output: a0-a3 = result
mulmod256:
    # Currently a placeholder
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# exp256: a^b
# Input: a0-a3 = base, a4-a7 = exponent
# Output: a0-a3 = result
exp256:
    # Currently a placeholder
    li a0, 1
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# ---------------------------
# Comparison Operations
# ---------------------------

# lt256: Less than comparison (a < b)
# Input: a0-a3 = a, a4-a7 = b
# Output: a0 = result (1 if true, 0 if false), a1-a3 = 0
lt256:
    # Compare highest word first (most significant)
    blt a3, a7, lt256_true
    bne a3, a7, lt256_false
    
    # Compare next word
    blt a2, a6, lt256_true
    bne a2, a6, lt256_false
    
    # Compare next word
    blt a1, a5, lt256_true
    bne a1, a5, lt256_false
    
    # Compare lowest word
    blt a0, a4, lt256_true
    
lt256_false:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret
    
lt256_true:
    li a0, 1
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# gt256: Greater than comparison (a > b)
# Input: a0-a3 = a, a4-a7 = b
# Output: a0 = result (1 if true, 0 if false), a1-a3 = 0
gt256:
    # Compare highest word first (most significant)
    bgt a3, a7, gt256_true
    bne a3, a7, gt256_false
    
    # Compare next word
    bgt a2, a6, gt256_true
    bne a2, a6, gt256_false
    
    # Compare next word
    bgt a1, a5, gt256_true
    bne a1, a5, gt256_false
    
    # Compare lowest word
    bgt a0, a4, gt256_true
    
gt256_false:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret
    
gt256_true:
    li a0, 1
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# eq256: Equal comparison (a == b)
# Input: a0-a3 = a, a4-a7 = b
# Output: a0 = result (1 if true, 0 if false), a1-a3 = 0
eq256:
    # Compare all words
    bne a0, a4, eq256_false
    bne a1, a5, eq256_false
    bne a2, a6, eq256_false
    bne a3, a7, eq256_false
    
    # All equal
    li a0, 1
    li a1, 0
    li a2, 0
    li a3, 0
    ret
    
eq256_false:
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# iszero256: Check if value is zero
# Input: a0-a3 = value
# Output: a0 = result (1 if zero, 0 if non-zero), a1-a3 = 0
iszero256:
    or t0, a0, a1
    or t0, t0, a2
    or t0, t0, a3
    
    snez t0, t0     # t0 = 1 if any bit is set
    xori a0, t0, 1  # Invert to get 1 if zero
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# ---------------------------
# Bitwise Operations
# ---------------------------

# and256: Bitwise AND
# Input: a0-a3 = a, a4-a7 = b
# Output: a0-a3 = result
and256:
    and a0, a0, a4
    and a1, a1, a5
    and a2, a2, a6
    and a3, a3, a7
    ret

# or256: Bitwise OR
# Input: a0-a3 = a, a4-a7 = b
# Output: a0-a3 = result
or256:
    or a0, a0, a4
    or a1, a1, a5
    or a2, a2, a6
    or a3, a3, a7
    ret

# xor256: Bitwise XOR
# Input: a0-a3 = a, a4-a7 = b
# Output: a0-a3 = result
xor256:
    xor a0, a0, a4
    xor a1, a1, a5
    xor a2, a2, a6
    xor a3, a3, a7
    ret

# not256: Bitwise NOT
# Input: a0-a3 = value
# Output: a0-a3 = result
not256:
    not a0, a0
    not a1, a1
    not a2, a2
    not a3, a3
    ret

# shl256: Shift left
# Input: a0-a3 = value, a4 = shift amount (low 8 bits)
# Output: a0-a3 = result
shl256:
    # Handle shifts >= 256 bits
    li t0, 256
    bgeu a4, t0, shl256_zero
    
    # Handle word-aligned shifts (multiples of 64)
    li t0, 64
    div t1, a4, t0  # t1 = whole words to shift
    rem t2, a4, t0  # t2 = remaining bits
    
    # Shift whole words
    beqz t1, shl256_bits  # Skip if no whole words to shift
    li t3, 0
    
    beq t1, 1, shl256_shift_words_1
    beq t1, 2, shl256_shift_words_2
    beq t1, 3, shl256_shift_words_3
    j shl256_zero  # If t1 >= 4, result is 0
    
shl256_shift_words_1:
    # Shift by 1 word (64 bits)
    mv a3, a2
    mv a2, a1
    mv a1, a0
    li a0, 0
    j shl256_bits
    
shl256_shift_words_2:
    # Shift by 2 words (128 bits)
    mv a3, a1
    mv a2, a0
    li a1, 0
    li a0, 0
    j shl256_bits
    
shl256_shift_words_3:
    # Shift by 3 words (192 bits)
    mv a3, a0
    li a2, 0
    li a1, 0
    li a0, 0
    j shl256_bits
    
shl256_zero:
    # Result is 0 for shift >= 256
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret
    
shl256_bits:
    # Now handle the remaining bits (less than 64)
    beqz t2, shl256_done  # If no bits to shift, we're done
    
    # Compute 64 - shift for the right shifts
    li t3, 64
    sub t3, t3, t2
    
    # Save original values
    mv t4, a0
    mv t5, a1
    mv t6, a2
    
    # Shift each word and combine with bits from lower word
    sll a0, a0, t2
    
    sll a1, a1, t2
    srl t0, t4, t3
    or a1, a1, t0
    
    sll a2, a2, t2
    srl t0, t5, t3
    or a2, a2, t0
    
    sll a3, a3, t2
    srl t0, t6, t3
    or a3, a3, t0
    
shl256_done:
    ret

# shr256: Logical shift right
# Input: a0-a3 = value, a4 = shift amount (low 8 bits)
# Output: a0-a3 = result
shr256:
    # Handle shifts >= 256 bits
    li t0, 256
    bgeu a4, t0, shr256_zero
    
    # Handle word-aligned shifts (multiples of 64)
    li t0, 64
    div t1, a4, t0  # t1 = whole words to shift
    rem t2, a4, t0  # t2 = remaining bits
    
    # Shift whole words
    beqz t1, shr256_bits  # Skip if no whole words to shift
    
    beq t1, 1, shr256_shift_words_1
    beq t1, 2, shr256_shift_words_2
    beq t1, 3, shr256_shift_words_3
    j shr256_zero  # If t1 >= 4, result is 0
    
shr256_shift_words_1:
    # Shift by 1 word (64 bits)
    mv a0, a1
    mv a1, a2
    mv a2, a3
    li a3, 0
    j shr256_bits
    
shr256_shift_words_2:
    # Shift by 2 words (128 bits)
    mv a0, a2
    mv a1, a3
    li a2, 0
    li a3, 0
    j shr256_bits
    
shr256_shift_words_3:
    # Shift by 3 words (192 bits)
    mv a0, a3
    li a1, 0
    li a2, 0
    li a3, 0
    j shr256_bits
    
shr256_zero:
    # Result is 0 for shift >= 256
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret
    
shr256_bits:
    # Now handle the remaining bits (less than 64)
    beqz t2, shr256_done  # If no bits to shift, we're done
    
    # Compute 64 - shift for the left shifts
    li t3, 64
    sub t3, t3, t2
    
    # Save original values
    mv t4, a1
    mv t5, a2
    mv t6, a3
    
    # Shift each word and combine with bits from higher word
    sra a0, a0, t2  # Arithmetic shift for lowest word
    sll t0, t4, t3
    or a0, a0, t0
    
    srl a1, a1, t2  # Logical shift for middle words
    sll t0, t5, t3
    or a1, a1, t0
    
    srl a2, a2, t2  # Logical shift for middle words
    sll t0, t6, t3
    or a2, a2, t0
    
    sra a3, a3, t2  # Arithmetic shift for highest word (sign extension)
    
sar256_done:
    ret

# byte_access: Get a single byte from a 256-bit word
# Input: a0-a3 = value, a4 = byte index (0-31)
# Output: a0 = byte value (0-255), a1-a3 = 0
byte_access:
    # Check if index is within range
    li t0, 32
    bgeu a4, t0, byte_access_zero
    
    # Determine which word the byte is in
    li t0, 8
    div t1, a4, t0  # t1 = word index (0-3)
    rem t2, a4, t0  # t2 = byte index within word (0-7)
    
    # Select the correct word
    beqz t1, byte_access_word0
    li t0, 1
    beq t1, t0, byte_access_word1
    li t0, 2
    beq t1, t0, byte_access_word2
    j byte_access_word3
    
byte_access_word0:
    mv t3, a0
    j byte_access_extract
    
byte_access_word1:
    mv t3, a1
    j byte_access_extract
    
byte_access_word2:
    mv t3, a2
    j byte_access_extract
    
byte_access_word3:
    mv t3, a3
    
byte_access_extract:
    # Shift right to position byte at bottom
    li t0, 8
    mul t0, t0, t2  # t0 = bits to shift right
    srl t3, t3, t0
    
    # Mask off all but lowest byte
    li t0, 0xFF
    and a0, t3, t0
    
    # Zero out other registers
    li a1, 0
    li a2, 0
    li a3, 0
    ret
    
byte_access_zero:
    # Return 0 for out-of-range index
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# ---------------------------
# Control Flow
# ---------------------------

# evm_revert: Revert execution
# Input: a0 = memory offset, a1 = size
evm_revert:
    mv RETURN_DATA_OFFSET, a0
    mv RETURN_DATA_SIZE, a1
    li a0, 0xFFFF
    j _exit

# evm_return: Return from execution
# Input: a0 = memory offset, a1 = size
evm_return:
    mv RETURN_DATA_OFFSET, a0
    mv RETURN_DATA_SIZE, a1
    li a0, 0  # Success code
    j _exit

# ---------------------------
# Error Handling
# ---------------------------

_revert_out_of_gas:
    li a0, 0xFFFF  # Error code for out of gas
    j _exit

_invalid:
    li a0, 0xFFFE  # Error code for invalid operation
    j _exit

# ---------------------------
# Exit Routine
# ---------------------------

_exit:
    ebreak  # Break execution
    ret

# ---------------------------
# Helpers
# ---------------------------

# memcpy: Copy memory
# Input: a0 = destination, a1 = source, a2 = length
memcpy:
    beqz a2, memcpy_done
    
    # Load byte from source
    lbu t0, 0(a1)
    
    # Store byte to destination
    sb t0, 0(a0)
    
    # Update pointers and counter
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    
    # Continue loop
    j memcpy
    
memcpy_done:
    ret

# get_call_value: Get the value sent with the call
# Output: a0-a3 = value (256-bit)
get_call_value:
    # For now, this is a placeholder
    # In a real implementation, this would access the call value
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ret

# Data section (if needed)
.section .data
calldata_size:
    .word 0  # Placeholder for calldata size

    mv t6, a3
    
    # Shift each word and combine with bits from higher word
    srl a0, a0, t2
    sll t0, t4, t3
    or a0, a0, t0
    
    srl a1, a1, t2
    sll t0, t5, t3
    or a1, a1, t0
    
    srl a2, a2, t2
    sll t0, t6, t3
    or a2, a2, t0
    
    srl a3, a3, t2
    
shr256_done:
    ret

# sar256: Arithmetic shift right
# Input: a0-a3 = value, a4 = shift amount (low 8 bits)
# Output: a0-a3 = result
sar256:
    # Check if value is negative (highest bit set)
    li t0, 0x8000000000000000
    and t1, a3, t0
    beqz t1, shr256  # If not negative, same as logical shift
    
    # Similar to shr256 but fill with 1s for negative numbers
    # Handle shifts >= 256 bits
    li t0, 256
    bgeu a4, t0, sar256_all_ones
    
    # Handle word-aligned shifts (multiples of 64)
    li t0, 64
    div t1, a4, t0  # t1 = whole words to shift
    rem t2, a4, t0  # t2 = remaining bits
    
    # Shift whole words
    beqz t1, sar256_bits  # Skip if no whole words to shift
    
    beq t1, 1, sar256_shift_words_1
    beq t1, 2, sar256_shift_words_2
    beq t1, 3, sar256_shift_words_3
    j sar256_all_ones  # If t1 >= 4, result is all 1s
    
sar256_shift_words_1:
    # Shift by 1 word (64 bits)
    mv a0, a1
    mv a1, a2
    mv a2, a3
    li t0, -1  # All 1s for sign extension
    mv a3, t0
    j sar256_bits
    
sar256_shift_words_2:
    # Shift by 2 words (128 bits)
    mv a0, a2
    mv a1, a3
    li t0, -1  # All 1s for sign extension
    mv a2, t0
    mv a3, t0
    j sar256_bits
    
sar256_shift_words_3:
    # Shift by 3 words (192 bits)
    mv a0, a3
    li t0, -1  # All 1s for sign extension
    mv a1, t0
    mv a2, t0
    mv a3, t0
    j sar256_bits
    
sar256_all_ones:
    # Result is all 1s for large shifts on negative numbers
    li a0, -1
    li a1, -1
    li a2, -1
    li a3, -1
    ret
    
sar256_bits:
    # Now handle the remaining bits (less than 64)
    beqz t2, sar256_done  # If no bits to shift, we're done
    
    # Compute 64 - shift for the left shifts
    li t3, 64
    sub t3, t3, t2
    
    # Save original values
    mv t4, a1
    mv t5, a2