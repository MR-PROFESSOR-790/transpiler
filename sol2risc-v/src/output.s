
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
    ld a0, 0(sp)
    addi sp, sp, 8
    jal sload_impl
    addi sp, sp, -8
    sd a0, 0(sp)