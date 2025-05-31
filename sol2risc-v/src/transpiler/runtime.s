# runtime.s - Core EVM Runtime Support in RISC-V Assembly
# Fully valid RISC-V 64-bit code for riscv64-unknown-elf-as

# Read-only data section
.section .rodata
.align 2
calldata_size:
  .word 0x00000000

# Uninitialized data section
.section .bss
.align 8
# Memory layout constants
MEM_BASE = 0x0020000
STACK_BASE = 0x0029000  # Adjusted to fit within DATA section (0x1a710 to 0x3a710)
CALLDATA_BASE = 0x0020400
STACK_SIZE = 512
MEM_CLEAR_SIZE = 512
EVM_MEMORY_SIZE = 16384

tohost:
  .dword 0
fromhost:
  .dword 0
evm_stack:
  .space 4096  # Space for EVM stack simulation

# Code section
.section .text
.align 2

# Global symbols
.globl _start
.globl _exit
.globl tohost
.globl fromhost
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
.globl evm_entry

# Register aliases
.set GAS_REGISTER, s1         # Track remaining gas
.set RETURN_DATA_OFFSET, s4   # Offset to return data buffer
.set RETURN_DATA_SIZE, s5     # Size of return data

# ---------------------------
# Entry Point
# ---------------------------

.section .text.start, "ax", @progbits
.global _start
_start:
    # Initialize stack pointer
    li sp, 0x0029000          # STACK_BASE
    li t0, 512                # STACK_SIZE
    add sp, sp, t0            # sp = 0x0029200
    andi sp, sp, -16          # Align to 16-byte boundary

    # Save registers (optional, but good practice)
    addi sp, sp, -64
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)

    # Initialize registers
    li s0, 0x0020000          # MEM_BASE
    li s1, 1000000            # Initial gas

    # Call clear_memory
    jal ra, clear_memory      # ra = address of next instruction

    # Call evm_entry (from output.o)
    jal ra, evm_entry         # Continue to EVM execution

    # Restore registers
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    addi sp, sp, 64

    # Exit cleanly
    j _exit                   # Use _exit to terminate

# Safety wrapper for evm_entry
safe_call_evm:
  addi sp, sp, -16
  sd ra, 8(sp)

  call evm_entry

  ld ra, 8(sp)
  addi sp, sp, 16
  ret

# ---------------------------
# Stack Helpers
# ---------------------------

stack_push_256:
  addi sp, sp, -32
  sd a0, 0(sp)
  sd a1, 8(sp)
  sd a2, 16(sp)
  sd a3, 24(sp)
  ret

stack_pop_256:
  ld a0, 0(sp)
  ld a1, 8(sp)
  ld a2, 16(sp)
  ld a3, 24(sp)
  addi sp, sp, 32
  ret

# ---------------------------
# Gas Metering
# ---------------------------

deduct_gas:
  addi sp, sp, -16
  sd ra, 8(sp)

  # Check if gas is zero or negative
  blez s1, .gas_already_zero

  # Subtract gas cost
  sub s1, s1, a0

  # Check for underflow
  bgez s1, .gas_ok

  # Gas underflow
  li s1, 0

.gas_ok:
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

.gas_already_zero:
  li s1, 0
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

# ---------------------------
# External Interactions
# ---------------------------

get_call_value:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ret

calldatasize:
  la t0, calldata_size
  lw a0, 0(t0)
  ret

calldataload:
  addi sp, sp, -16
  sd ra, 8(sp)

  # Pop offset
  jal ra, stack_pop_256

  # Bounds check
  la t0, calldata_size
  lw t1, 0(t0)
  bltu a0, t1, .valid_offset
  j calldataload_oob

.valid_offset:
  mv t0, a0
  li t1, CALLDATA_BASE
  add t0, t1, t0

  # Compute max address
  la t3, calldata_size
  lw t3, 0(t3)
  add t1, t1, t3

  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0

  addi t2, t0, 32
  bgtu t2, t1, calldataload_done
  ld a0, 0(t0)

  addi t2, t0, 16
  bgtu t2, t1, calldataload_done
  ld a1, 8(t0)

  addi t2, t0, 24
  bgtu t2, t1, calldataload_done
  ld a2, 16(t0)

  addi t2, t0, 32
  bgtu t2, t1, calldataload_done
  ld a3, 24(t0)

calldataload_done:
  jal ra, stack_push_256
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

calldataload_oob:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  jal ra, stack_push_256
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

calldataload_partial1:
  li a1, 0
calldataload_partial2:
  li a2, 0
calldataload_partial3:
  li a3, 0
  jal ra, stack_push_256
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

calldatacopy:
  addi sp, sp, -16
  sd ra, 8(sp)

  blez a2, calldatacopy_done
  add a0, s0, a0
  li t0, CALLDATA_BASE
  add a1, t0, a1
  call memcpy

calldatacopy_done:
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

# ---------------------------
# Memory Management
# ---------------------------

mload:
  addi sp, sp, -16
  sd ra, 8(sp)

  li t1, 0x8000
  bgeu a0, t1, mload_out_of_bounds
  add t0, s0, a0

  li t1, MEM_BASE
  li t2, 0x4000
  add t3, t1, t2
  bgeu t0, t3, mload_out_of_bounds

  ld a0, 0(t0)
  ld a1, 8(t0)
  ld a2, 16(t0)
  ld a3, 24(t0)

  ld ra, 8(sp)
  addi sp, sp, 16
  ret

mload_out_of_bounds:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

mstore:
  addi sp, sp, -16
  sd ra, 8(sp)

  li t1, 0x8000
  bgeu a0, t1, mstore_out_of_bounds
  add t0, s0, a0

  sd a1, 0(t0)
  sd a2, 8(t0)
  sd a3, 16(t0)
  sd a4, 24(t0)

  ld ra, 8(sp)
  addi sp, sp, 16
  ret

mstore_out_of_bounds:
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

mstore8:
  li t1, 0x4000
  bgeu a0, t1, mstore8_out_of_bounds
  add t0, s0, a0
  sb a1, 0(t0)
  ret

mstore8_out_of_bounds:
  ret

# ---------------------------
# Cryptographic Operations
# ---------------------------

keccak256:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ret

# ---------------------------
# Arithmetic Operations
# ---------------------------

add256:
  addi sp, sp, -8
  sd ra, 0(sp)
  li t0, 0

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
  ret

sub256:
  addi sp, sp, -8
  sd ra, 0(sp)
  li t0, 0

  sub a0, a0, a4
  sltu t0, a4, a0
  sub a1, a1, a5
  sub a1, a1, t0
  sltu t1, a5, a1
  or t0, t0, t1
  sub a2, a2, a6
  sub a2, a2, t0
  sltu t1, a6, a2
  or t0, t0, t1
  sub a3, a3, a7
  sub a3, a3, t0

  ld ra, 0(sp)
  addi sp, sp, 8
  ret

mul256:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ret

div256:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ret

mod256:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ret

addmod256:
  jal ra, add256
  jal ra, mod256
  ret

mulmod256:
  jal ra, mul256
  jal ra, mod256
  ret

exp256:
  li a0, 1
  li a1, 0
  li a2, 0
  li a3, 0
  ret

# ---------------------------
# Comparison Operations
# ---------------------------

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
  ret
gt256_true:
  li a0, 1
  ret
gt256_false:
  li a0, 0
  ret

eq256:
  bne a0, a4, eq256_false
  bne a1, a5, eq256_false
  bne a2, a6, eq256_false
  bne a3, a7, eq256_false
  li a0, 1
  ret
eq256_false:
  li a0, 0
  ret

iszero256:
  or t0, a0, a1
  or t0, t0, a2
  or t0, t0, a3
  seqz a0, t0
  ret

# ---------------------------
# Bitwise Operations
# ---------------------------

and256:
  and a0, a0, a4
  and a1, a1, a5
  and a2, a2, a6
  and a3, a3, a7
  ret

or256:
  or a0, a0, a4
  or a1, a1, a5
  or a2, a2, a6
  or a3, a3, a7
  ret

xor256:
  xor a0, a0, a4
  xor a1, a1, a5
  xor a2, a2, a6
  xor a3, a3, a7
  ret

not256:
  not a0, a0
  not a1, a1
  not a2, a2
  not a3, a3
  ret

shl256:
  addi sp, sp, -16
  sd ra, 8(sp)

  beqz a4, shl256_done
  li t1, 256
  bgeu a4, t1, shl256_zero

  li t2, 0
shl256_loop:
  beq t2, a4, shl256_done
  slli a0, a0, 1
  srli t3, a1, 63
  or a0, a0, t3
  slli a1, a1, 1
  srli t3, a2, 63
  or a1, a1, t3
  slli a2, a2, 1
  srli t3, a3, 63
  or a2, a2, t3
  slli a3, a3, 1
  addi t2, t2, 1
  j shl256_loop

shl256_done:
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

shl256_zero:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

shr256:
  addi sp, sp, -16
  sd ra, 8(sp)

  beqz a4, shr256_done
  li t1, 256
  bgeu a4, t1, shr256_zero

  li t2, 0
shr256_loop:
  beq t2, a4, shr256_done
  srli a3, a3, 1
  slli t3, a2, 63
  or a3, a3, t3
  srli a2, a2, 1
  slli t3, a1, 63
  or a2, a2, t3
  srli a1, a1, 1
  slli t3, a0, 63
  or a1, a1, t3
  srli a0, a0, 1
  addi t2, t2, 1
  j shr256_loop

shr256_done:
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

shr256_zero:
  li a0, 0
  li a1, 0
  li a2, 0
  li a3, 0
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

sar256:
  addi sp, sp, -16
  sd ra, 8(sp)

  beqz a4, sar256_done
  li t1, 256
  bgeu a4, t1, sar256_max

  li t2, 0
sar256_loop:
  beq t2, a4, sar256_done
  srli t4, a3, 63
  srai a3, a3, 1
  srli a2, a2, 1
  slli t3, a1, 63
  or a2, a2, t3
  srli a1, a1, 1
  slli t3, a0, 63
  or a1, a1, t3
  srli a0, a0, 1
  li t3, 1
  slli t3, t3, 63
  beqz t4, sar256_skip_sign
  or a0, a0, t3

sar256_skip_sign:
  addi t2, t2, 1
  j sar256_loop

sar256_done:
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

sar256_max:
  srli t0, a3, 63
  beqz t0, shr256_zero
  li a0, -1
  li a1, -1
  li a2, -1
  li a3, -1
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

# ---------------------------
# Exit & Error Handling
# ---------------------------

evm_revert:
  mv s4, a0
  mv s5, a1
  li a0, 0
  ret

evm_return:
  mv s4, a0
  mv s5, a1
  li a0, 1
  ret

_revert_out_of_gas:
  li a0, 0xFFFF
  j _exit

_invalid:
  li a0, 0xFFFE
  j _exit

_exit:
  addi sp, sp, -16
  sd ra, 0(sp)
  li a7, 93
  ecall
  ld ra, 0(sp)
  addi sp, sp, 16
  ret

# ---------------------------
# Helper Functions
# ---------------------------

memcpy:
  beqz a2, memcpy_done
  li t3, 0x8000
  bgt a2, t3, memcpy_done
  li t3, 0
memcpy_loop:
  bge t3, a2, memcpy_done
  lb t4, 0(a1)
  sb t4, 0(a0)
  addi a0, a0, 1
  addi a1, a1, 1
  addi t3, t3, 1
  j memcpy_loop
memcpy_done:
  ret

# ---------------------------
# Stub Functions
# ---------------------------

evm_codecopy:
  li a0, 0
  ret

# Stub implementation for evm_entry if it's not defined
.section .rodata
.align 3

.section .bss
.align 4
.section .text

clear_memory:
    li t0, 0x20000            # MEM_BASE
    li t1, 0                  # Value to store (0)
    li t2, 512                # MEM_CLEAR_SIZE
.clear_loop:
    beqz t2, .clear_done      # Exit loop when t2 == 0
    sb t1, 0(t0)              # Store 0 at address in t0
    addi t0, t0, 1            # Increment pointer
    addi t2, t2, -1           # Decrement counter
    j .clear_loop             # Repeat
.clear_done:
    ret                       # Return to address in ra
