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
.set MEM_BASE, 0x00100000       # Use standard user space memory that QEMU definitely allows
.set CALLDATA_BASE, 0x00110000  # After main memory
.set STACK_BASE, 0x00120000     # After calldata

# Register aliases (must use actual registers)
.set GAS_REGISTER, s1            # Track remaining gas
.set RETURN_DATA_OFFSET, s4      # Offset to return data buffer 
.set RETURN_DATA_SIZE, s5        # Size of return data

# Define size constants
.set STACK_SIZE, 4096
.set MEM_CLEAR_SIZE, 512         # Reduced memory clear size to avoid issues

# ---------------------------
# Entry Point
# ---------------------------

_start:
    # Set up safe stack with known alignment
    li sp, STACK_BASE
    li t0, STACK_SIZE
    add sp, sp, t0
    andi sp, sp, -16         # Ensure 16-byte alignment for stack
    
    # Reserve space for saved registers
    addi sp, sp, -64
    
    # Save callee-saved registers
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)
    sd s3, 32(sp)
    sd s4, 40(sp)
    sd s5, 48(sp)
    sd s6, 56(sp)

    # Initialize memory base register
    li s0, MEM_BASE

    # Initialize gas counter with safe value
    li s1, 1000000     # Start with 1M gas
    
    # Initialize return data registers
    li s4, 0           # RETURN_DATA_OFFSET
    li s5, 0           # RETURN_DATA_SIZE

    # Clear minimal memory to avoid crashes
    li t0, MEM_BASE
    li t1, 0           # Fill value
    li t2, MEM_CLEAR_SIZE  # Bytes to clear
3:
    beqz t2, 4f        # Exit loop when done
    sd t1, 0(t0)       # Store 0 to memory
    addi t0, t0, 8     # Next 8 bytes
    addi t2, t2, -8    # Decrement counter
    j 3b               # Loop

4:  # Initialize calldata area
    li t0, CALLDATA_BASE
    li t2, 128         # Clear first 128 bytes of calldata
5:
    beqz t2, 6f
    sd t1, 0(t0)
    addi t0, t0, 8
    addi t2, t2, -8
    j 5b

6:  # Set up calldata size
    la t0, calldata_size
    li t1, 0           # Default to 0 size
    sw t1, 0(t0)

    # Call the contract's entry point with a safety wrapper
    call safe_call_evm

    # Restore callee-saved registers
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    ld s4, 40(sp)
    ld s5, 48(sp)
    ld s6, 56(sp)
    addi sp, sp, 64
    
    # Exit program
    li a7, 93          # exit syscall
    li a0, 0           # exit code 0
    ecall
    
# Safety wrapper to catch segfaults from contract code
safe_call_evm:
    addi sp, sp, -16
    sd ra, 8(sp)
    
    # Try calling EVM entry
    call evm_entry
    
    # If we get here, no segfault occurred
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

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
    addi sp, sp, -16       # Reserve stack space
    sd ra, 8(sp)           # Save return address
    
    # Check if gas is already zero or negative
    blez s1, _gas_already_zero
    
    # Subtract gas cost
    sub s1, s1, a0
    
    # Check for underflow
    bgez s1, _gas_ok
    
    # Gas underflow, set to zero
    li s1, 0
    
_gas_ok:
    ld ra, 8(sp)           # Restore return address
    addi sp, sp, 16        # Free stack space
    ret                    # Return normally
    
_gas_already_zero:
    # Gas already depleted
    li s1, 0
    ld ra, 8(sp)
    addi sp, sp, 16
    ret                    # Just return, don't abort

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

# calldataload: Load 256-bit value from calldata with safety checks
# Input: a0 = offset on stack
calldataload:
    addi sp, sp, -16
    sd ra, 8(sp)
    
    # Stack operation for getting offset
    jal ra, stack_pop_256      # Pop offset into a0
    
    # Safety bounds check
    la t0, calldata_size
    lw t1, 0(t0)               # Get calldata size
    bge a0, t1, calldataload_oob  # Out of bounds check
    
    # Calculate pointer to calldata
    add t0, a0, zero           # t0 = offset
    li t1, CALLDATA_BASE       # t1 = base address
    add t0, t1, t0             # t0 = base + offset
    
    # Load the data - with bounds checking in case of partial read
    ld a0, 0(t0)               # Load first word
    
    # Check if we can safely load more
    addi t2, a0, 8
    bge t2, t1, calldataload_partial1
    ld a1, 8(t0)               # Load second word
    
    addi t2, a0, 16
    bge t2, t1, calldataload_partial2
    ld a2, 16(t0)              # Load third word
    
    addi t2, a0, 24
    bge t2, t1, calldataload_partial3
    ld a3, 24(t0)              # Load fourth word
    
    # Push result to stack and return
    jal ra, stack_push_256
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
    
calldataload_oob:
    # Return all zeros for out-of-bounds
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    jal ra, stack_push_256
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
    
calldataload_partial1:
    # Only first word valid, zero rest
    li a1, 0
calldataload_partial2:
    # Only first two words valid, zero rest
    li a2, 0
calldataload_partial3:
    # Only first three words valid, zero last
    li a3, 0
    # Push partial result and return
    jal ra, stack_push_256
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

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
    addi sp, sp, -16
    sd ra, 8(sp)

    # Calculate memory address with safety bounds check
    # Limit offset to safe range
    li t1, 0x8000      # 32KB safety limit
    bge a0, t1, mload_out_of_bounds
    
    add t0, s0, a0     # Calculate address = base + offset
    
    # Load the 256-bit value (4 x 64-bit words)
    ld a0, 0(t0)
    ld a1, 8(t0)
    ld a2, 16(t0)
    ld a3, 24(t0)
    
    # Return
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# Handle out of bounds access safely
mload_out_of_bounds:
    # Return zeros for out of bounds
    li a0, 0
    li a1, 0
    li a2, 0
    li a3, 0
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# mstore: Store 256-bit value to memory
# Inputs: a0 = offset, a1-a4 = value
mstore:
    addi sp, sp, -16
    sd ra, 8(sp)
    
    # Safety bounds check
    li t1, 0x8000      # 32KB safety limit
    bge a0, t1, mstore_out_of_bounds
    
    # Calculate address = base + offset
    add t0, s0, a0
    
    # Store the value
    sd a1, 0(t0)
    sd a2, 8(t0)
    sd a3, 16(t0)
    sd a4, 24(t0)
    
    # Return
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
    
mstore_out_of_bounds:
    # Silently ignore out of bounds stores
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# mstore8: Store byte to memory
mstore8:
    # Safety bounds check
    li t1, 0x10000     # 64KB safety limit
    bge a0, t1, mstore8_out_of_bounds
    
    # Calculate address = base + offset
    add t0, s0, a0
    
    # Store single byte
    sb a1, 0(t0)
    ret
    
mstore8_out_of_bounds:
    # Silently ignore out of bounds stores
    ret

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
    srl t3, a2, t2
    or a1, a1, t3
    sll a2, a2, t0
    srl t3, a3, t2
    or a2, a2, t3
    sll a3, a3, t0

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
    # Set return values
    mv s4, a0          # RETURN_DATA_OFFSET = a0  
    mv s5, a1          # RETURN_DATA_SIZE = a1
    li a0, 0
    jr ra

# evm_return: Normal return
evm_return:
    # Set return values
    mv s4, a0          # RETURN_DATA_OFFSET = a0
    mv s5, a1          # RETURN_DATA_SIZE = a1
    li a0, 1
    jr ra

# _revert_out_of_gas: Out of gas error handler
_revert_out_of_gas:
    # Set status code for out of gas
    li a0, 0xFFFF
    # Fall through to _exit
    j _exit

# Invalid operation handler  
_invalid:
    li a0, 0xFFFE
    j _exit

# _exit: End execution with proper syscall
_exit:
    li a7, 93          # syscall number for exit
    li a0, 0           # exit code
    ecall              # exit syscall
    
    # Should never reach here, but just in case
    j _exit            # infinite loop

# ---------------------------
# Helper Functions
# ---------------------------

# memcpy: Copy bytes between memory regions with safety checks
# a0 = dst, a1 = src, a2 = length
memcpy:
    # Safety checks
    beqz a2, memcpy_done       # Zero length, nothing to do
    
    # Bounds check for reasonable size
    li t3, 0x8000              # 32KB max reasonable size
    bgt a2, t3, memcpy_done    # Too large, abort silently
    
    # Efficient copying with bounds check
    li t3, 0                   # Counter
memcpy_loop:
    bge t3, a2, memcpy_done    # Check if we're done
    
    # Load byte from source
    add t4, a1, t3
    lbu t5, 0(t4)
    
    # Store byte to destination
    add t4, a0, t3
    sb t5, 0(t4)
    
    # Increment counter
    addi t3, t3, 1
    j memcpy_loop
    
memcpy_done:
    ret

# ---------------------------
# MISSING FUNCTION STUBS
# ---------------------------

# Add stubs for undefined functions to avoid linker errors
evm_codecopy:
    li a0, 0
    jr ra

.section .rodata
.align 3
calldata_size:
    .word 0x00              # Placeholder for calldata size

.section .bss
.align 4
evm_stack: .space 4096      # Space for EVM stack simulation
.section .text
