.section .text

# Jump destination table
.align 4
jumpdest_table:

.globl evm_entry
evm_entry:
addi sp, sp, -64
sd   ra, 56(sp)
sd   s0, 48(sp)
sd   s1, 40(sp)
sd   s2, 32(sp)
sd   s3, 24(sp)
sd   s4, 16(sp)
sd   s5, 8(sp)
sd   s6, 0(sp)
li   s0, 0x10000000
li   s1, 100000
la   s2, evm_stack
li   s3, 0
# PUSH1 80
li a0, 6
jal ra, deduct_gas
# PUSH 80
li a0, 6
jal ra, deduct_gas
li t0, 80            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
# PUSH 40
li a0, 6
jal ra, deduct_gas
li t0, 40            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# MSTORE 
li a0, 3
jal ra, deduct_gas
# MSTORE - store 256-bit word to memory
addi s3, s3, -2              # Pop offset and value
slli t0, s3, 5               # Stack offset = s3 * 32
add  t0, s2, t0              # Address of value and offset
ld   t1, 0(t0)               # offset
ld   t2, 8(t0)               # val limb0
ld   t3, 16(t0)              # val limb1
ld   t4, 24(t0)              # val limb2
ld   t5, 32(t0)              # val limb3
add  t1, t1, s0              # effective addr = offset + MEM_BASE
sd   t2, 0(t1)
sd   t3, 8(t1)
sd   t4, 16(t1)
sd   t5, 24(t1)
# CALLVALUE 
li a0, 3
jal ra, deduct_gas
# CALLVALUE - get call value (256-bit, low only)
jal ra, get_call_value     # Assume it returns value in a0
slli t1, s3, 5             # s3 * 32
add  t1, s2, t1
sd   a0, 0(t1)             # store in limb0
sd   zero, 8(t1)
sd   zero, 16(t1)
sd   zero, 24(t1)
addi s3, s3, 1             # Push 256-bit result
# DUP1 
li a0, 4
jal ra, deduct_gas
# DUP1
addi t0, s3, -1       # Index to duplicate
slli t0, t0, 5          # Offset = t0 * 32
add  t0, s2, t0         # Src address
slli t1, s3, 5          # Dest offset = s3 * 32
add  t1, s2, t1         # Dest address
ld   t2, 0(t0)          # limb0
ld   t3, 8(t0)          # limb1
ld   t4, 16(t0)         # limb2
ld   t5, 24(t0)         # limb3
sd   t2, 0(t1)
sd   t3, 8(t1)
sd   t4, 16(t1)
sd   t5, 24(t1)
addi s3, s3, 1          # Push duplicate
# ISZERO 
li a0, 3
jal ra, deduct_gas
# ISZERO - 256-bit check if value == 0
addi s3, s3, -1
slli t0, s3, 5
add  t0, s2, t0
ld t1, 0(t0)
ld t2, 8(t0)
ld t3, 16(t0)
ld t4, 24(t0)
or  s0, t1, t2
or  s0, s0, t3
or  s0, s0, t4
seqz s0, s0
sd   s0, 0(t0)
sd   zero, 8(t0)
sd   zero, 16(t0)
sd   zero, 24(t0)
addi s3, s3, 1
# PUSH1 0e
li a0, 6
jal ra, deduct_gas
# PUSH 0e
li a0, 6
jal ra, deduct_gas
li t0, 0e            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# JUMPI 
li a0, 10
jal ra, deduct_gas
# JUMPI - conditional jump if cond ≠ 0
addi s3, s3, -2
slli t0, s3, 5
add  t0, s2, t0
ld   t1, 0(t0)         # jump target
ld   t2, 8(t0)         # condition
beqz t2, jumpi_skip_0
slli t1, t1, 2
la   t3, jumpdest_table
add  t3, t3, t1
lw   t4, 0(t3)         # load label
jr   t4
jumpi_skip_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
# PUSH 0
li a0, 6
jal ra, deduct_gas
li t0, 0            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# DUP1 
li a0, 4
jal ra, deduct_gas
# DUP1
addi t0, s3, -1       # Index to duplicate
slli t0, t0, 5          # Offset = t0 * 32
add  t0, s2, t0         # Src address
slli t1, s3, 5          # Dest offset = s3 * 32
add  t1, s2, t1         # Dest address
ld   t2, 0(t0)          # limb0
ld   t3, 8(t0)          # limb1
ld   t4, 16(t0)         # limb2
ld   t5, 24(t0)         # limb3
sd   t2, 0(t1)
sd   t3, 8(t1)
sd   t4, 16(t1)
sd   t5, 24(t1)
addi s3, s3, 1          # Push duplicate
# REVERT 
# REVERT - undo state and return error slice
addi s3, s3, -2
slli t0, s3, 5
add  t0, s2, t0
ld   a0, 0(t0)         # offset
ld   a1, 8(t0)         # length
add  a0, a0, s0        # offset += MEM_BASE
jal  ra, evm_revert    # call runtime revert function
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 3e
li a0, 6
jal ra, deduct_gas
# PUSH 3e
li a0, 6
jal ra, deduct_gas
li t0, 3e            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# DUP1 
li a0, 4
jal ra, deduct_gas
# DUP1
addi t0, s3, -1       # Index to duplicate
slli t0, t0, 5          # Offset = t0 * 32
add  t0, s2, t0         # Src address
slli t1, s3, 5          # Dest offset = s3 * 32
add  t1, s2, t1         # Dest address
ld   t2, 0(t0)          # limb0
ld   t3, 8(t0)          # limb1
ld   t4, 16(t0)         # limb2
ld   t5, 24(t0)         # limb3
sd   t2, 0(t1)
sd   t3, 8(t1)
sd   t4, 16(t1)
sd   t5, 24(t1)
addi s3, s3, 1          # Push duplicate
# PUSH1 1a
li a0, 6
jal ra, deduct_gas
# PUSH 1a
li a0, 6
jal ra, deduct_gas
li t0, 1a            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
# PUSH 0
li a0, 6
jal ra, deduct_gas
li t0, 0            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# CODECOPY 
li a0, 3
jal ra, deduct_gas
# Unknown runtime function: codecopy
# PUSH0 
li a0, 3
jal ra, deduct_gas
# PUSH 0
li a0, 6
jal ra, deduct_gas
li t0, 0            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
# RETURN 
# RETURN - exit and return memory slice
addi s3, s3, -2
slli t0, s3, 5
add  t0, s2, t0
ld   a0, 0(t0)         # offset
ld   a1, 8(t0)         # length
add  a0, a0, s0        # offset += MEM_BASE
jal  ra, evm_return    # call runtime return function
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# UNKNOWN_0XDF 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XDF
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# UNKNOWN_0XC5 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XC5
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# UNKNOWN_0X2B 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X2B
# UNKNOWN_0XD2 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XD2
# NOT 
li a0, 3
jal ra, deduct_gas
# NOT - 256-bit bitwise negation
addi s3, s3, -1
slli t0, s3, 5
add  t0, s2, t0
ld t1, 0(t0)
ld t2, 8(t0)
ld t3, 16(t0)
ld t4, 24(t0)
not t1, t1
not t2, t2
not t3, t3
not t4, t4
sd t1, 0(t0)
sd t2, 8(t0)
sd t3, 16(t0)
sd t4, 24(t0)
addi s3, s3, 1
# UNKNOWN_0XAB 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XAB
# UNKNOWN_0X0C 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X0C
# UNKNOWN_0X2A 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X2A
# MSIZE 
li a0, 2
jal ra, deduct_gas
# Unimplemented opcode: MSIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# UNKNOWN_0XF7 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XF7
# UNKNOWN_0XED 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XED
# CALL 
li a0, 700
jal ra, deduct_gas
# Unimplemented opcode: CALL
addi s3, s3, -7 # Adjust stack for unimplemented opcode
# DUP9 
li a0, 12
jal ra, deduct_gas
# DUP9
addi t0, s3, -9       # Index to duplicate
slli t0, t0, 5          # Offset = t0 * 32
add  t0, s2, t0         # Src address
slli t1, s3, 5          # Dest offset = s3 * 32
add  t1, s2, t1         # Dest address
ld   t2, 0(t0)          # limb0
ld   t3, 8(t0)          # limb1
ld   t4, 16(t0)         # limb2
ld   t5, 24(t0)         # limb3
sd   t2, 0(t1)
sd   t3, 8(t1)
sd   t4, 16(t1)
sd   t5, 24(t1)
addi s3, s3, 1          # Push duplicate
# UNKNOWN_0XD8 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XD8
# CREATE 
li a0, 32000
jal ra, deduct_gas
# Unimplemented opcode: CREATE
addi s3, s3, -3 # Adjust stack for unimplemented opcode
# MSIZE 
li a0, 2
jal ra, deduct_gas
# Unimplemented opcode: MSIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# SWAP7 
li a0, 10
jal ra, deduct_gas
# SWAP7
addi t0, s3, -1         # Top index
addi t1, s3, -8     # Swap index
slli t0, t0, 5
slli t1, t1, 5
add  t0, s2, t0         # Addr1
add  t1, s2, t1         # Addr2
ld t2, 0(t0)
ld t3, 0(t1)
sd t3, 0(t0)
sd t2, 0(t1)
ld t2, 8(t0)
ld t3, 8(t1)
sd t3, 8(t0)
sd t2, 8(t1)
ld t2, 16(t0)
ld t3, 16(t1)
sd t3, 16(t0)
sd t2, 16(t1)
ld t2, 24(t0)
ld t3, 24(t1)
sd t3, 24(t0)
sd t2, 24(t1)
# UNKNOWN_0XA9 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XA9
# PUSH25 e15bdbd97a4c7d64736f6c634300081a003300000000000000
li a0, 78
jal ra, deduct_gas
# PUSH e15bdbd97a4c7d64736f6c634300081a003300000000000000
li a0, 6
jal ra, deduct_gas
li t0, e15bdbd97a4c7d64736f6c634300081a003300000000000000            # Load value
slli t1, s3, 5          # Stack offset = s3 * 32
add  t1, s2, t1         # Address = stack base + offset
sd   t0, 0(t1)          # Store limb0
sd   zero, 8(t1)        # limb1 = 0
sd   zero, 16(t1)       # limb2 = 0
sd   zero, 24(t1)       # limb3 = 0
addi s3, s3, 1          # Increment stack pointer
ld   ra, 56(sp)
ld   s0, 48(sp)
ld   s1, 40(sp)
ld   s2, 32(sp)
ld   s3, 24(sp)
ld   s4, 16(sp)
ld   s5, 8(sp)
ld   s6, 0(sp)
addi sp, sp, 64
jr   ra

.section .bss
.align 5
evm_stack: .space 4096
.section .text