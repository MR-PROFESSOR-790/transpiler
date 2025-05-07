
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
    ld t1, 0(t0)            # Load old value
    beq t1, a1, skip_store  # Skip if unchanged
    li a0, GAS_SSTORE_NEW
    jal check_gas
    sd a1, 0(t0)
skip_store:
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

sha3_impl:
    # Input: a0 = offset, a1 = size
    jal check_memory_bounds
    # ... SHA3 implementation ...
    ret

log_impl:
    # Input: a0 = offset, a1 = size, a2 = topics
    jal check_memory_bounds
    # ... Log implementation ...
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

check_gas:
    # Input: a0 = required gas
    addi t0, s11, 0          # Current gas
    sub t0, t0, a0           # Subtract required
    bltz t0, out_of_gas      # Branch if negative
    addi s11, t0, 0          # Update gas counter
    ret

out_of_gas:
    li a0, 2                 # Out of gas error code
    j revert_impl

check_memory_bounds:
    # Input: a0 = offset, a1 = size
    add t0, a0, a1           # End address
    li t1, 65536            # Memory limit
    bgeu t0, t1, memory_error
    ret

memory_error:
    li a0, 3                # Memory access error
    j revert_impl
    
    li t0, 128
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 3
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li a0, 1875
    jal check_gas
    li a2, 4
    jal log_impl
    li a0, 1500
    jal check_gas
    li a2, 3
    jal log_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j return_impl
    li t0, 128
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 224
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j return_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j return_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j return_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j return_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 3
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 128
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 96
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 3
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 63
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 96
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li a0, 750
    jal check_gas
    li a2, 1
    jal log_impl
    li a0, 1125
    jal check_gas
    li a2, 2
    jal log_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 63
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 96
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 3
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 750
    jal check_gas
    li a2, 1
    jal log_impl
    li t0, 96
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 128
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 3
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 3
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li a0, 1875
    jal check_gas
    li a2, 4
    jal log_impl
    li a0, 1500
    jal check_gas
    li a2, 3
    jal log_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 65
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 36
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 128
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 96
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 96
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 49
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 34
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 36
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 127
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 8
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 8
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    li t0, 1
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 2
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 20000
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 17
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 4
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 36
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)  # size
    addi sp, sp, 8
    ld a0, 0(sp)  # offset
    addi sp, sp, 8
    j revert_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 33
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 96
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 33
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 17
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 39
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 64
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li t0, 31
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    li t0, 32
    addi sp, sp, -8
    sd t0, 0(sp)
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal mstore_impl
    li a0, 1125
    jal check_gas
    li a2, 2
    jal log_impl
    li a0, 30
    jal check_gas
    ld a1, 0(sp)
    addi sp, sp, 8
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sha3_impl
    li a0, 32000
    jal check_gas
    jal create_impl
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)
    li a0, 32000
    jal check_gas
    jal create_impl