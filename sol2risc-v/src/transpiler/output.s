.section .rodata

# Jump destination table
.align 4
jumpdest_table:

.section .text

.globl evm_entry
evm_entry:
addi sp,  sp,  -64
sd   ra,  56(sp)
sd   s0,  48(sp)
sd   s1,  40(sp)
sd   s2,  32(sp)
sd   s3,  24(sp)
sd   s4,  16(sp)
sd   s5,  8(sp)
sd   s6,  0(sp)
li   s0,  0x10000000
li   s1,  100000
la   s2,  evm_stack
li   s3,  0
# PUSH1 80
li a0,  6
jal ra,  deduct_gas
# PUSH 80
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000080       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH1 40
li a0,  6
jal ra,  deduct_gas
# PUSH 40
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000040       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# MSTORE 
li a0,  3
jal ra,  deduct_gas
# MSTORE - store 256-bit word to memory
addi s3,  s3,  -2              # Pop offset and value
slli t0,  s3,  5               # Stack offset = s3 * 32
add  t0,  s2,  t0              # Address of value and offset
ld   t1,  0(t0)              # offset
ld   t2,  8(t0)              # val limb0
ld   t3,  16(t0)             # val limb1
ld   t4,  24(t0)             # val limb2
ld   t5,  32(t0)             # val limb3
add  t1,  t1,  s0              # effective addr = offset + MEM_BASE
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
# CALLVALUE 
li a0,  3
jal ra,  deduct_gas
# CALLVALUE - get call value (256-bit, low only)
li a0,  3
jal ra,  deduct_gas
jal ra,  get_call_value     # Assume it returns value in a0
slli t1,  s3,  5             # s3 * 32
add  t1,  s2,  t1
sd   a0,  0(t1)            # store in limb0
sd   zero,  8(t1)
sd   zero,  16(t1)
sd   zero,  24(t1)
addi s3,  s3,  1             # Push 256-bit result
# DUP1 
li a0,  4
jal ra,  deduct_gas
# DUP1
addi t0,  s3,  -1       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# ISZERO 
li a0,  3
jal ra,  deduct_gas
# ISZERO - 256-bit check if value == 0
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  0(t0)
ld t2,  8(t0)
ld t3,  16(t0)
ld t4,  24(t0)
or  s0,  t1,  t2
or  s0,  s0,  t3
or  s0,  s0,  t4
seqz s0,  s0
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
# PUSH1 0e
li a0,  6
jal ra,  deduct_gas
# PUSH 0e
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000000e       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# JUMPI 
li a0,  10
jal ra,  deduct_gas
# JUMPI - conditional jump if cond ≠ 0
li a0,  10
jal ra,  deduct_gas
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
ld   t2,  8(t0)        # condition
beqz t2,  jumpi_skip_0
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_0:
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# DUP1 
li a0,  4
jal ra,  deduct_gas
# DUP1
addi t0,  s3,  -1       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# REVERT 
# REVERT - undo state and return error slice
li a0,  0x0A
jal ra,  deduct_gas
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld   a0,  0(t0)        # offset
ld   a1,  8(t0)        # length
add  a0,  a0,  s0        # offset += MEM_BASE
jal  ra,  evm_revert    # call runtime revert function
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_0:
li a0,  3
jal ra,  deduct_gas
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# PUSH1 ac
li a0,  6
jal ra,  deduct_gas
# PUSH ac
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000ac       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# DUP1 
li a0,  4
jal ra,  deduct_gas
# DUP1
addi t0,  s3,  -1       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# PUSH1 1a
li a0,  6
jal ra,  deduct_gas
# PUSH 1a
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000001a       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# CODECOPY 
li a0,  3
jal ra,  deduct_gas
# Unknown runtime function: codecopy
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# RETURN 
# RETURN - exit and return memory slice
li a0,  0x0A
jal ra,  deduct_gas
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld   a0,  0(t0)        # offset
ld   a1,  8(t0)        # length
add  a0,  a0,  s0        # offset += MEM_BASE
jal  ra,  evm_return    # call runtime return function
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_1:
li a0,  3
jal ra,  deduct_gas
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# PUSH1 04
li a0,  6
jal ra,  deduct_gas
# PUSH 04
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000004       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# CALLDATASIZE 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3,  s3,  1 # Adjust stack for unimplemented opcode
# LT 
li a0,  3
jal ra,  deduct_gas
# LT - unsigned 256-bit less-than
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  56(t0)  # a limb3
ld t2,  24(t0) # b limb3
blt t1,  t2,  lt_true
bgt t1,  t2,  lt_false
ld t1,  48(t0)  # a limb2
ld t2,  16(t0) # b limb2
blt t1,  t2,  lt_true
bgt t1,  t2,  lt_false
ld t1,  40(t0)  # a limb1
ld t2,  8(t0) # b limb1
blt t1,  t2,  lt_true
bgt t1,  t2,  lt_false
ld t1,  32(t0)  # a limb0
ld t2,  0(t0) # b limb0
blt t1,  t2,  lt_true
bgt t1,  t2,  lt_false
li s0,  0
j lt_done
lt_true:
li s0,  1
j lt_done
lt_false:
li s0,  0
lt_done:
sd s0,  0(t0)
sd zero,  8(t0)
sd zero,  16(t0)
sd zero,  24(t0)
addi s3,  s3,  1
# PUSH1 26
li a0,  6
jal ra,  deduct_gas
# PUSH 26
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000026       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# JUMPI 
li a0,  10
jal ra,  deduct_gas
# JUMPI - conditional jump if cond ≠ 0
li a0,  10
jal ra,  deduct_gas
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
ld   t2,  8(t0)        # condition
beqz t2,  jumpi_skip_1
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_1:
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# CALLDATALOAD 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: CALLDATALOAD
# PUSH1 e0
li a0,  6
jal ra,  deduct_gas
# PUSH e0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000e0       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# SHR 
li a0,  3
jal ra,  deduct_gas
# SHR - 256-bit logical right shift (simplified for ≤64)
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  0(t0)      # shift amount
ld t2,  8(t0)
ld t3,  16(t0)
ld t4,  24(t0)
ld t5,  32(t0)
li t6,  64
bge t1,  t6,  shr_zero
srl s3,  t5,  t1
sub a9,  t6,  t1
sll s4,  t4,  a0
or  s3,  s3,  s4
srl s2,  t4,  t1
sub a0,  t6,  t1
sll s4,  t3,  a0
or  s2,  s2,  s4
srl s1,  t3,  t1
sub a0,  t6,  t1
sll s4,  t2,  a0
or  s1,  s1,  s4
srl s0,  t2,  t1
sd s0,  0(t0)
sd s1,  8(t0)
sd s2,  16(t0)
sd s3,  24(t0)
addi s3,  s3,  1
j shr_done
shr_zero:
sd zero,  0(t0)
sd zero,  8(t0)
sd zero,  16(t0)
sd zero,  24(t0)
addi s3,  s3,  1
shr_done:
# DUP1 
li a0,  4
jal ra,  deduct_gas
# DUP1
addi t0,  s3,  -1       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# PUSH4 67e919b6
li a0,  15
jal ra,  deduct_gas
# PUSH 67e919b6
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000067e919b6       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# EQ 
li a0,  3
jal ra,  deduct_gas
# EQ - 256-bit equality check
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  0(t0)
ld t2,  8(t0)
ld t3,  16(t0)
ld t4,  24(t0)
ld t5,  32(t0)
ld t6,  40(t0)
ld t7,  48(t0)
ld t8,  56(t0)
xor s0,  t1,  t5
xor s1,  t2,  t6
xor s2,  t3,  t7
xor s3,  t4,  t8
or  s0,  s0,  s1
or  s0,  s0,  s2
or  s0,  s0,  s3
seqz s0,  s0            # if all zero => equal
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
# PUSH1 2a
li a0,  6
jal ra,  deduct_gas
# PUSH 2a
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000002a       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# JUMPI 
li a0,  10
jal ra,  deduct_gas
# JUMPI - conditional jump if cond ≠ 0
li a0,  10
jal ra,  deduct_gas
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
ld   t2,  8(t0)        # condition
beqz t2,  jumpi_skip_2
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_2:
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_2:
li a0,  3
jal ra,  deduct_gas
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# DUP1 
li a0,  4
jal ra,  deduct_gas
# DUP1
addi t0,  s3,  -1       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# REVERT 
# REVERT - undo state and return error slice
li a0,  0x0A
jal ra,  deduct_gas
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld   a0,  0(t0)        # offset
ld   a1,  8(t0)        # length
add  a0,  a0,  s0        # offset += MEM_BASE
jal  ra,  evm_revert    # call runtime revert function
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_3:
li a0,  3
jal ra,  deduct_gas
# PUSH1 30
li a0,  6
jal ra,  deduct_gas
# PUSH 30
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000030       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH1 44
li a0,  6
jal ra,  deduct_gas
# PUSH 44
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000044       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_4:
li a0,  3
jal ra,  deduct_gas
# PUSH1 40
li a0,  6
jal ra,  deduct_gas
# PUSH 40
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000040       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# MLOAD 
li a0,  3
jal ra,  deduct_gas
# MLOAD - load 256-bit word from memory
addi s3,  s3,  -1              # Pop offset
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)              # offset
add  t1,  t1,  s0              # addr = offset + MEM_BASE
ld   t2,  0(t1)
ld   t3,  8(t1)
ld   t4,  16(t1)
ld   t5,  24(t1)
sd   t2,  0(t0)              # store back to stack
sd   t3,  8(t0)
sd   t4,  16(t0)
sd   t5,  24(t0)
addi s3,  s3,  1
# PUSH1 3b
li a0,  6
jal ra,  deduct_gas
# PUSH 3b
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000003b       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# SWAP2 
li a0,  5
jal ra,  deduct_gas
# SWAP2
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -3     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# SWAP1 
li a0,  4
jal ra,  deduct_gas
# SWAP1
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -2     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# PUSH1 5f
li a0,  6
jal ra,  deduct_gas
# PUSH 5f
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000005f       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_5:
li a0,  3
jal ra,  deduct_gas
# PUSH1 40
li a0,  6
jal ra,  deduct_gas
# PUSH 40
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000040       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# MLOAD 
li a0,  3
jal ra,  deduct_gas
# MLOAD - load 256-bit word from memory
addi s3,  s3,  -1              # Pop offset
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)              # offset
add  t1,  t1,  s0              # addr = offset + MEM_BASE
ld   t2,  0(t1)
ld   t3,  8(t1)
ld   t4,  16(t1)
ld   t5,  24(t1)
sd   t2,  0(t0)              # store back to stack
sd   t3,  8(t0)
sd   t4,  16(t0)
sd   t5,  24(t0)
addi s3,  s3,  1
# DUP1 
li a0,  4
jal ra,  deduct_gas
# DUP1
addi t0,  s3,  -1       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# SWAP2 
li a0,  5
jal ra,  deduct_gas
# SWAP2
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -3     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# SUB 
li a0,  3
jal ra,  deduct_gas
# 256-bit SUB (4 limbs)
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  0(t0)          # B limb0
ld t2,  8(t0)          # B limb1
ld t3,  16(t0)         # B limb2
ld t4,  24(t0)         # B limb3
ld t5,  32(t0)         # A limb0
ld t6,  40(t0)         # A limb1
ld t7,  48(t0)         # A limb2
ld t8,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a0,  s6,  s5
or   s5,  s5,  a0
sub s7,  t7,  t3
sub s7,  s7,  s5
sltu s5,  t7,  t3
sltu a0,  s7,  s5
or   s5,  s5,  a0
sub s8,  t8,  t4
sub s8,  s8,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s7,  16(t0)
sd s8,  24(t0)
addi s3,  s3,  1
# SWAP1 
li a0,  4
jal ra,  deduct_gas
# SWAP1
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -2     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# RETURN 
# RETURN - exit and return memory slice
li a0,  0x0A
jal ra,  deduct_gas
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld   a0,  0(t0)        # offset
ld   a1,  8(t0)        # length
add  a0,  a0,  s0        # offset += MEM_BASE
jal  ra,  evm_return    # call runtime return function
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_6:
li a0,  3
jal ra,  deduct_gas
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# SLOAD 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0,  5
jal ra,  deduct_gas
# DUP2
addi t0,  s3,  -2       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_7:
li a0,  3
jal ra,  deduct_gas
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# DUP2 
li a0,  5
jal ra,  deduct_gas
# DUP2
addi t0,  s3,  -2       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# SWAP1 
li a0,  4
jal ra,  deduct_gas
# SWAP1
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -2     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# SWAP2 
li a0,  5
jal ra,  deduct_gas
# SWAP2
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -3     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# SWAP1 
li a0,  4
jal ra,  deduct_gas
# SWAP1
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -2     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_8:
li a0,  3
jal ra,  deduct_gas
# PUSH1 59
li a0,  6
jal ra,  deduct_gas
# PUSH 59
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000059       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# DUP2 
li a0,  5
jal ra,  deduct_gas
# DUP2
addi t0,  s3,  -2       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# PUSH1 49
li a0,  6
jal ra,  deduct_gas
# PUSH 49
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000049       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_9:
li a0,  3
jal ra,  deduct_gas
# DUP3 
li a0,  6
jal ra,  deduct_gas
# DUP3
addi t0,  s3,  -3       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# MSTORE 
li a0,  3
jal ra,  deduct_gas
# MSTORE - store 256-bit word to memory
addi s3,  s3,  -2              # Pop offset and value
slli t0,  s3,  5               # Stack offset = s3 * 32
add  t0,  s2,  t0              # Address of value and offset
ld   t1,  0(t0)              # offset
ld   t2,  8(t0)              # val limb0
ld   t3,  16(t0)             # val limb1
ld   t4,  24(t0)             # val limb2
ld   t5,  32(t0)             # val limb3
add  t1,  t1,  s0              # effective addr = offset + MEM_BASE
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
# SWAP1 
li a0,  4
jal ra,  deduct_gas
# SWAP1
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -2     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_10:
li a0,  3
jal ra,  deduct_gas
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH1 20
li a0,  6
jal ra,  deduct_gas
# PUSH 20
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000020       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# DUP3 
li a0,  6
jal ra,  deduct_gas
# DUP3
addi t0,  s3,  -3       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# ADD 
li a0,  3
jal ra,  deduct_gas
# 256-bit ADD (4 limbs)
addi s3,  s3,  -2        # Pop two 256-bit values
slli t0,  s3,  5         # Offset = s3 * 32
add  t0,  s2,  t0        # Stack address for operand A and B
ld t1,  0(t0)          # B limb0
ld t2,  8(t0)          # B limb1
ld t3,  16(t0)         # B limb2
ld t4,  24(t0)         # B limb3
ld t5,  32(t0)         # A limb0
ld t6,  40(t0)         # A limb1
ld t7,  48(t0)         # A limb2
ld t8,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s7,  t3,  t7         # sum2 = b2 + a2
add s7,  s7,  s5         # sum2 += carry1
sltu s5,  s7,  t3        # carry2
add s8,  t4,  t8         # sum3 = b3 + a3
add s8,  s8,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s7,  16(t0)         # result limb2
sd s8,  24(t0)         # result limb3
addi s3,  s3,  1         # Push result
# SWAP1 
li a0,  4
jal ra,  deduct_gas
# SWAP1
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -2     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# PUSH1 70
li a0,  6
jal ra,  deduct_gas
# PUSH 70
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000070       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH0 
li a0,  3
jal ra,  deduct_gas
# PUSH 0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000000       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# DUP4 
li a0,  7
jal ra,  deduct_gas
# DUP4
addi t0,  s3,  -4       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# ADD 
li a0,  3
jal ra,  deduct_gas
# 256-bit ADD (4 limbs)
addi s3,  s3,  -2        # Pop two 256-bit values
slli t0,  s3,  5         # Offset = s3 * 32
add  t0,  s2,  t0        # Stack address for operand A and B
ld t1,  0(t0)          # B limb0
ld t2,  8(t0)          # B limb1
ld t3,  16(t0)         # B limb2
ld t4,  24(t0)         # B limb3
ld t5,  32(t0)         # A limb0
ld t6,  40(t0)         # A limb1
ld t7,  48(t0)         # A limb2
ld t8,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s7,  t3,  t7         # sum2 = b2 + a2
add s7,  s7,  s5         # sum2 += carry1
sltu s5,  s7,  t3        # carry2
add s8,  t4,  t8         # sum3 = b3 + a3
add s8,  s8,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s7,  16(t0)         # result limb2
sd s8,  24(t0)         # result limb3
addi s3,  s3,  1         # Push result
# DUP5 
li a0,  8
jal ra,  deduct_gas
# DUP5
addi t0,  s3,  -5       # Index to duplicate
slli t0,  t0,  5          # Offset = t0 * 32
add  t0,  s2,  t0         # Src address
slli t1,  s3,  5          # Dest offset = s3 * 32
add  t1,  s2,  t1         # Dest address
ld   t2,  0(t0)         # limb0
ld   t3,  8(t0)         # limb1
ld   t4,  16(t0)        # limb2
ld   t5,  24(t0)        # limb3
sd   t2,  0(t1)
sd   t3,  8(t1)
sd   t4,  16(t1)
sd   t5,  24(t1)
addi s3,  s3,  1          # Push duplicate
# PUSH1 52
li a0,  6
jal ra,  deduct_gas
# PUSH 52
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000052       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_11:
li a0,  3
jal ra,  deduct_gas
# SWAP3 
li a0,  6
jal ra,  deduct_gas
# SWAP3
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -4     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# SWAP2 
li a0,  5
jal ra,  deduct_gas
# SWAP2
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -3     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# SWAP1 
li a0,  4
jal ra,  deduct_gas
# SWAP1
li a0,  3
jal ra,  deduct_gas
addi t0,  s3,  -1         # Top index
addi t1,  s3,  -2     # Swap index
slli t0,  t0,  5
slli t1,  t1,  5
add  t0,  s2,  t0         # Addr1
add  t1,  s2,  t1         # Addr2
ld t2,  0(t0)
ld t3,  0(t1)
sd t3,  0(t0)
sd t2,  0(t1)
ld t2,  8(t0)
ld t3,  8(t1)
sd t3,  8(t0)
sd t2,  8(t1)
ld t2,  16(t0)
ld t3,  16(t1)
sd t3,  16(t0)
sd t2,  16(t1)
ld t2,  24(t0)
ld t3,  24(t1)
sd t3,  24(t0)
sd t2,  24(t1)
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# JUMP 
li a0,  8
jal ra,  deduct_gas
# JUMP - unconditional jump to JUMPDEST
addi s3,  s3,  -1
slli t0,  s3,  5
add  t0,  s2,  t0
ld   t1,  0(t0)        # jump target
slli t1,  t1,  2         # index * 4
la   t2,  jumpdest_table
add  t2,  t2,  t1
lw   t3,  0(t2)        # actual label address
jr   t3                # jump
# INVALID 
# Unimplemented opcode: INVALID
ld   ra,  56(sp)
ld   s0,  48(sp)
ld   s1,  40(sp)
ld   s2,  32(sp)
ld   s3,  24(sp)
ld   s4,  16(sp)
ld   s5,  8(sp)
ld   s6,  0(sp)
addi sp,  sp,  64
li   s1,  100000
li   s3,  0
jr   ra

.section .bss
.align 5
evm_stack: .space 4096
.section .text
