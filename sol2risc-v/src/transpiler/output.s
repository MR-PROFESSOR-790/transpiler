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
# PUSH1 0a
li a0,  6
jal ra,  deduct_gas
# PUSH 0a
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000000a       # Limb 0(lowest 64 bits)
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
# SSTORE 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: SSTORE
addi s3,  s3,  -2 # Adjust stack for unimplemented opcode
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
# PUSH1 12
li a0,  6
jal ra,  deduct_gas
# PUSH 12
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000012       # Limb 0(lowest 64 bits)
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
# PUSH2 02e3
li a0,  9
jal ra,  deduct_gas
# PUSH 02e3
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000002e3       # Limb 0(lowest 64 bits)
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
# PUSH2 0020
li a0,  9
jal ra,  deduct_gas
# PUSH 0020
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
blt t1,  t2,  lt_true_0
bgt t1,  t2,  lt_false_0
ld t1,  48(t0)  # a limb2
ld t2,  16(t0) # b limb2
blt t1,  t2,  lt_true_0
bgt t1,  t2,  lt_false_0
ld t1,  40(t0)  # a limb1
ld t2,  8(t0) # b limb1
blt t1,  t2,  lt_true_0
bgt t1,  t2,  lt_false_0
ld t1,  32(t0)  # a limb0
ld t2,  0(t0) # b limb0
blt t1,  t2,  lt_true_0
bgt t1,  t2,  lt_false_0
li s0,  0
j lt_done_0
lt_true_0:
li s0,  1
j lt_done_0
lt_false_0:
li s0,  0
lt_done_0:
sd s0,  0(t0)
sd zero,  8(t0)
sd zero,  16(t0)
sd zero,  24(t0)
addi s3,  s3,  1
# PUSH2 004a
li a0,  9
jal ra,  deduct_gas
# PUSH 004a
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000004a       # Limb 0(lowest 64 bits)
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
sub a1,  t6,  t1
sll a2,  t4,  a1
or  s3,  s3,  a2
srl s2,  t4,  t1
sub a1,  t6,  t1
sll a2,  t3,  a1
or  s2,  s2,  a2
srl s1,  t3,  t1
sub a1,  t6,  t1
sll a2,  t2,  a1
or  s1,  s1,  a2
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
# PUSH4 131e2f18
li a0,  15
jal ra,  deduct_gas
# PUSH 131e2f18
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000131e2f18       # Limb 0(lowest 64 bits)
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
ld a0,  48(t0)
ld a1,  56(t0)
xor s0,  t1,  t5
xor s1,  t2,  t6
xor s2,  t3,  a0
xor s3,  t4,  a1
or  s0,  s0,  s1
or  s0,  s0,  s2
or  s0,  s0,  s3
seqz s0,  s0            # if all zero => equal
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
# PUSH2 004e
li a0,  9
jal ra,  deduct_gas
# PUSH 004e
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000004e       # Limb 0(lowest 64 bits)
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
# PUSH4 188b85b4
li a0,  15
jal ra,  deduct_gas
# PUSH 188b85b4
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000188b85b4       # Limb 0(lowest 64 bits)
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
ld a0,  48(t0)
ld a1,  56(t0)
xor s0,  t1,  t5
xor s1,  t2,  t6
xor s2,  t3,  a0
xor s3,  t4,  a1
or  s0,  s0,  s1
or  s0,  s0,  s2
or  s0,  s0,  s3
seqz s0,  s0            # if all zero => equal
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
# PUSH2 007e
li a0,  9
jal ra,  deduct_gas
# PUSH 007e
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000007e       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_3
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_3:
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
# PUSH4 27ee58a6
li a0,  15
jal ra,  deduct_gas
# PUSH 27ee58a6
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000027ee58a6       # Limb 0(lowest 64 bits)
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
ld a0,  48(t0)
ld a1,  56(t0)
xor s0,  t1,  t5
xor s1,  t2,  t6
xor s2,  t3,  a0
xor s3,  t4,  a1
or  s0,  s0,  s1
or  s0,  s0,  s2
or  s0,  s0,  s3
seqz s0,  s0            # if all zero => equal
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
# PUSH2 00ae
li a0,  9
jal ra,  deduct_gas
# PUSH 00ae
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000ae       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_4
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_4:
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
ld a0,  48(t0)
ld a1,  56(t0)
xor s0,  t1,  t5
xor s1,  t2,  t6
xor s2,  t3,  a0
xor s3,  t4,  a1
or  s0,  s0,  s1
or  s0,  s0,  s2
or  s0,  s0,  s3
seqz s0,  s0            # if all zero => equal
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
# PUSH2 00de
li a0,  9
jal ra,  deduct_gas
# PUSH 00de
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000de       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_5
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_5:
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
# PUSH2 0068
li a0,  9
jal ra,  deduct_gas
# PUSH 0068
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000068       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
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
# CALLDATASIZE 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3,  s3,  1 # Adjust stack for unimplemented opcode
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
addi s3,  s3,  1
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s10,  t3,  a0         # sum2 = b2 + a2
add s10,  s10,  s5         # sum2 += carry1
sltu s5,  s10,  t3        # carry2
add s11,  t4,  a1         # sum3 = b3 + a3
add s11,  s11,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s10,  16(t0)         # result limb2
sd s11,  24(t0)         # result limb3
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
# PUSH2 0063
li a0,  9
jal ra,  deduct_gas
# PUSH 0063
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000063       # Limb 0(lowest 64 bits)
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
# PUSH2 0186
li a0,  9
jal ra,  deduct_gas
# PUSH 0186
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000186       # Limb 0(lowest 64 bits)
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
# PUSH2 00fc
li a0,  9
jal ra,  deduct_gas
# PUSH 00fc
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000fc       # Limb 0(lowest 64 bits)
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
# PUSH2 0075
li a0,  9
jal ra,  deduct_gas
# PUSH 0075
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000075       # Limb 0(lowest 64 bits)
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
# PUSH2 01c0
li a0,  9
jal ra,  deduct_gas
# PUSH 01c0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001c0       # Limb 0(lowest 64 bits)
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
jumpdest_6:
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
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
jumpdest_7:
li a0,  3
jal ra,  deduct_gas
# PUSH2 0098
li a0,  9
jal ra,  deduct_gas
# PUSH 0098
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000098       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
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
# CALLDATASIZE 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3,  s3,  1 # Adjust stack for unimplemented opcode
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
addi s3,  s3,  1
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s10,  t3,  a0         # sum2 = b2 + a2
add s10,  s10,  s5         # sum2 += carry1
sltu s5,  s10,  t3        # carry2
add s11,  t4,  a1         # sum3 = b3 + a3
add s11,  s11,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s10,  16(t0)         # result limb2
sd s11,  24(t0)         # result limb3
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
# PUSH2 0093
li a0,  9
jal ra,  deduct_gas
# PUSH 0093
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000093       # Limb 0(lowest 64 bits)
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
# PUSH2 0186
li a0,  9
jal ra,  deduct_gas
# PUSH 0186
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000186       # Limb 0(lowest 64 bits)
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
jumpdest_8:
li a0,  3
jal ra,  deduct_gas
# PUSH2 0116
li a0,  9
jal ra,  deduct_gas
# PUSH 0116
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000116       # Limb 0(lowest 64 bits)
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
# PUSH2 00a5
li a0,  9
jal ra,  deduct_gas
# PUSH 00a5
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000a5       # Limb 0(lowest 64 bits)
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
# PUSH2 01c0
li a0,  9
jal ra,  deduct_gas
# PUSH 01c0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001c0       # Limb 0(lowest 64 bits)
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
jumpdest_10:
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
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
jumpdest_11:
li a0,  3
jal ra,  deduct_gas
# PUSH2 00c8
li a0,  9
jal ra,  deduct_gas
# PUSH 00c8
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000c8       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
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
# CALLDATASIZE 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3,  s3,  1 # Adjust stack for unimplemented opcode
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
addi s3,  s3,  1
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s10,  t3,  a0         # sum2 = b2 + a2
add s10,  s10,  s5         # sum2 += carry1
sltu s5,  s10,  t3        # carry2
add s11,  t4,  a1         # sum3 = b3 + a3
add s11,  s11,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s10,  16(t0)         # result limb2
sd s11,  24(t0)         # result limb3
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
# PUSH2 00c3
li a0,  9
jal ra,  deduct_gas
# PUSH 00c3
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000c3       # Limb 0(lowest 64 bits)
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
# PUSH2 0186
li a0,  9
jal ra,  deduct_gas
# PUSH 0186
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000186       # Limb 0(lowest 64 bits)
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
jumpdest_12:
li a0,  3
jal ra,  deduct_gas
# PUSH2 0130
li a0,  9
jal ra,  deduct_gas
# PUSH 0130
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000130       # Limb 0(lowest 64 bits)
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
jumpdest_13:
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
# PUSH2 00d5
li a0,  9
jal ra,  deduct_gas
# PUSH 00d5
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000d5       # Limb 0(lowest 64 bits)
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
# PUSH2 01c0
li a0,  9
jal ra,  deduct_gas
# PUSH 01c0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001c0       # Limb 0(lowest 64 bits)
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
jumpdest_14:
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
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
jumpdest_15:
li a0,  3
jal ra,  deduct_gas
# PUSH2 00e6
li a0,  9
jal ra,  deduct_gas
# PUSH 00e6
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000e6       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH2 014a
li a0,  9
jal ra,  deduct_gas
# PUSH 014a
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000014a       # Limb 0(lowest 64 bits)
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
jumpdest_16:
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
# PUSH2 00f3
li a0,  9
jal ra,  deduct_gas
# PUSH 00f3
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000000f3       # Limb 0(lowest 64 bits)
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
# PUSH2 01c0
li a0,  9
jal ra,  deduct_gas
# PUSH 01c0
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001c0       # Limb 0(lowest 64 bits)
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
jumpdest_17:
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
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
jumpdest_18:
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
# PUSH2 010b
li a0,  9
jal ra,  deduct_gas
# PUSH 010b
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000010b       # Limb 0(lowest 64 bits)
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
# PUSH2 0206
li a0,  9
jal ra,  deduct_gas
# PUSH 0206
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000206       # Limb 0(lowest 64 bits)
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
jumpdest_19:
li a0,  3
jal ra,  deduct_gas
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
jumpdest_20:
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
# PUSH2 0125
li a0,  9
jal ra,  deduct_gas
# PUSH 0125
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000125       # Limb 0(lowest 64 bits)
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
# PUSH2 0247
li a0,  9
jal ra,  deduct_gas
# PUSH 0247
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000247       # Limb 0(lowest 64 bits)
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
jumpdest_21:
li a0,  3
jal ra,  deduct_gas
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
jumpdest_22:
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
# PUSH2 013f
li a0,  9
jal ra,  deduct_gas
# PUSH 013f
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000013f       # Limb 0(lowest 64 bits)
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
# PUSH2 027a
li a0,  9
jal ra,  deduct_gas
# PUSH 027a
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000027a       # Limb 0(lowest 64 bits)
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
jumpdest_23:
li a0,  3
jal ra,  deduct_gas
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
jumpdest_24:
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
jumpdest_25:
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
jumpdest_26:
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
jumpdest_27:
li a0,  3
jal ra,  deduct_gas
# PUSH2 0165
li a0,  9
jal ra,  deduct_gas
# PUSH 0165
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000165       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_28:
li a0,  3
jal ra,  deduct_gas
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
ld a0,  48(t0)
ld a1,  56(t0)
xor s0,  t1,  t5
xor s1,  t2,  t6
xor s2,  t3,  a0
xor s3,  t4,  a1
or  s0,  s0,  s1
or  s0,  s0,  s2
or  s0,  s0,  s3
seqz s0,  s0            # if all zero => equal
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
# PUSH2 016f
li a0,  9
jal ra,  deduct_gas
# PUSH 016f
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000016f       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_6
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_6:
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
jumpdest_29:
li a0,  3
jal ra,  deduct_gas
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
jumpdest_30:
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
# CALLDATALOAD 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: CALLDATALOAD
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
# PUSH2 0180
li a0,  9
jal ra,  deduct_gas
# PUSH 0180
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000180       # Limb 0(lowest 64 bits)
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
# PUSH2 015c
li a0,  9
jal ra,  deduct_gas
# PUSH 015c
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000015c       # Limb 0(lowest 64 bits)
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
jumpdest_31:
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
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_32:
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
addi s3,  s3,  1
# SLT 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: SLT
addi s3,  s3,  -1 # Adjust stack for unimplemented opcode
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
# PUSH2 019b
li a0,  9
jal ra,  deduct_gas
# PUSH 019b
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000019b       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_7
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_7:
# PUSH2 019a
li a0,  9
jal ra,  deduct_gas
# PUSH 019a
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000019a       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH2 014f
li a0,  9
jal ra,  deduct_gas
# PUSH 014f
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000014f       # Limb 0(lowest 64 bits)
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
jumpdest_33:
li a0,  3
jal ra,  deduct_gas
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_34:
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
# PUSH2 01a8
li a0,  9
jal ra,  deduct_gas
# PUSH 01a8
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001a8       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
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
# DUP6 
li a0,  9
jal ra,  deduct_gas
# DUP6
addi t0,  s3,  -6       # Index to duplicate
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s10,  t3,  a0         # sum2 = b2 + a2
add s10,  s10,  s5         # sum2 += carry1
sltu s5,  s10,  t3        # carry2
add s11,  t4,  a1         # sum3 = b3 + a3
add s11,  s11,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s10,  16(t0)         # result limb2
sd s11,  24(t0)         # result limb3
addi s3,  s3,  1         # Push result
# PUSH2 0172
li a0,  9
jal ra,  deduct_gas
# PUSH 0172
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000172       # Limb 0(lowest 64 bits)
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
jumpdest_35:
li a0,  3
jal ra,  deduct_gas
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
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_36:
li a0,  3
jal ra,  deduct_gas
# PUSH2 01ba
li a0,  9
jal ra,  deduct_gas
# PUSH 01ba
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001ba       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_37:
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
jumpdest_38:
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s10,  t3,  a0         # sum2 = b2 + a2
add s10,  s10,  s5         # sum2 += carry1
sltu s5,  s10,  t3        # carry2
add s11,  t4,  a1         # sum3 = b3 + a3
add s11,  s11,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s10,  16(t0)         # result limb2
sd s11,  24(t0)         # result limb3
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
# PUSH2 01d3
li a0,  9
jal ra,  deduct_gas
# PUSH 01d3
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001d3       # Limb 0(lowest 64 bits)
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s10,  t3,  a0         # sum2 = b2 + a2
add s10,  s10,  s5         # sum2 += carry1
sltu s5,  s10,  t3        # carry2
add s11,  t4,  a1         # sum3 = b3 + a3
add s11,  s11,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s10,  16(t0)         # result limb2
sd s11,  24(t0)         # result limb3
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
# PUSH2 01b1
li a0,  9
jal ra,  deduct_gas
# PUSH 01b1
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001b1       # Limb 0(lowest 64 bits)
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
jumpdest_39:
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
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_40:
li a0,  3
jal ra,  deduct_gas
# DUP0 
li a0,  3
jal ra,  deduct_gas
# DUP0
addi t0,  s3,  -0       # Index to duplicate
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
# UNKNOWN_0X4E 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: UNKNOWN_0X4E
# BASEFEE 
li a0,  3
jal ra,  deduct_gas
# Unimplemented opcode: BASEFEE
addi s3,  s3,  1 # Adjust stack for unimplemented opcode
# PUSH28 71000000000000000000000000000000000000000000000000000000
li a0,  87
jal ra,  deduct_gas
# PUSH 71000000000000000000000000000000000000000000000000000000
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
li t0,  0x0000000071000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_41:
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
# PUSH2 0210
li a0,  9
jal ra,  deduct_gas
# PUSH 0210
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000210       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_42:
li a0,  3
jal ra,  deduct_gas
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# PUSH2 021b
li a0,  9
jal ra,  deduct_gas
# PUSH 021b
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000021b       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_43:
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
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
# MUL 
li a0,  5
jal ra,  deduct_gas
# 256-bit MUL (schoolbook 4x4 = 8 limbs, store lowest 4)
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  32(t0)     # A limb0
ld t2,  40(t0)     # A limb1
ld t3,  48(t0)     # A limb2
ld t4,  56(t0)     # A limb3
ld t5,  0(t0)      # B limb0
ld t6,  8(t0)      # B limb1
ld a0,  16(t0)     # B limb2
ld a1,  24(t0)     # B limb3
mul s0,  t1,  t5     # r0 = a0 * b0
mul s1,  t1,  t6     # r1 = a0 * b1
mul a2,  t2,  t5     # + a1 * b0
add s1,  s1,  a2
mul s2,  t1,  a0     # r2 = a0 * b2
mul a2,  t2,  t6     # + a1 * b1
add s2,  s2,  a2
mul a2,  t3,  t5     # + a2 * b0
add s2,  s2,  a2
mul s3,  t1,  a1     # r3 = a0 * b3
mul a2,  t2,  a0     # + a1 * b2
add s3,  s3,  a2
mul a2,  t3,  t6     # + a2 * b1
add s3,  s3,  a2
mul a2,  t4,  t5     # + a3 * b0
add s3,  s3,  a2
sd s0,  0(t0)
sd s1,  8(t0)
sd s2,  16(t0)
sd s3,  24(t0)
addi s3,  s3,  1
# PUSH2 0229
li a0,  9
jal ra,  deduct_gas
# PUSH 0229
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000229       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_44:
li a0,  3
jal ra,  deduct_gas
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
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
# DIV 
li a0,  5
jal ra,  deduct_gas
# Unimplemented opcode: DIV
addi s3,  s3,  -1 # Adjust stack for unimplemented opcode
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
ld a0,  48(t0)
ld a1,  56(t0)
xor s0,  t1,  t5
xor s1,  t2,  t6
xor s2,  t3,  a0
xor s3,  t4,  a1
or  s0,  s0,  s1
or  s0,  s0,  s2
or  s0,  s0,  s3
seqz s0,  s0            # if all zero => equal
sd   s0,  0(t0)
sd   zero,  8(t0)
sd   zero,  16(t0)
sd   zero,  24(t0)
addi s3,  s3,  1
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
# OR 
li a0,  3
jal ra,  deduct_gas
# OR - 256-bit bitwise OR
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  0(t0)
ld t2,  8(t0)
ld t3,  16(t0)
ld t4,  24(t0)
ld t5,  32(t0)
ld t6,  40(t0)
ld a0,  48(t0)
ld a1,  56(t0)
or s0,  t1,  t5
or s1,  t2,  t6
or s2,  t3,  a0
or s3,  t4,  a1
sd s0,  0(t0)
sd s1,  8(t0)
sd s2,  16(t0)
sd s3,  24(t0)
addi s3,  s3,  1
# PUSH2 0240
li a0,  9
jal ra,  deduct_gas
# PUSH 0240
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000240       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_8
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_8:
# PUSH2 023f
li a0,  9
jal ra,  deduct_gas
# PUSH 023f
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000023f       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH2 01d9
li a0,  9
jal ra,  deduct_gas
# PUSH 01d9
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001d9       # Limb 0(lowest 64 bits)
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
jumpdest_45:
li a0,  3
jal ra,  deduct_gas
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_46:
li a0,  3
jal ra,  deduct_gas
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
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
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_47:
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
# PUSH2 0251
li a0,  9
jal ra,  deduct_gas
# PUSH 0251
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000251       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_48:
li a0,  3
jal ra,  deduct_gas
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# PUSH2 025c
li a0,  9
jal ra,  deduct_gas
# PUSH 025c
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000025c       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_49:
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
add s4,  t1,  t5         # sum0
sltu s5,  s4,  t1        # carry0 = s4 < t1
add s6,  t2,  t6         # sum1 = b1 + a1
add s6,  s6,  s5         # sum1 += carry0
sltu s5,  s6,  t2        # carry1
add s10,  t3,  a0         # sum2 = b2 + a2
add s10,  s10,  s5         # sum2 += carry1
sltu s5,  s10,  t3        # carry2
add s11,  t4,  a1         # sum3 = b3 + a3
add s11,  s11,  s5         # sum3 += carry2
sd s4,  0(t0)          # result limb0
sd s6,  8(t0)          # result limb1
sd s10,  16(t0)         # result limb2
sd s11,  24(t0)         # result limb3
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
# GT 
li a0,  3
jal ra,  deduct_gas
# GT - unsigned 256-bit greater-than
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  24(t0)  # a limb3
ld t2,  56(t0)       # b limb3
blt t1,  t2,  gt_true_1
bgt t1,  t2,  gt_false_1
ld t1,  16(t0)  # a limb2
ld t2,  48(t0)       # b limb2
blt t1,  t2,  gt_true_1
bgt t1,  t2,  gt_false_1
ld t1,  8(t0)  # a limb1
ld t2,  40(t0)       # b limb1
blt t1,  t2,  gt_true_1
bgt t1,  t2,  gt_false_1
ld t1,  0(t0)  # a limb0
ld t2,  32(t0)       # b limb0
blt t1,  t2,  gt_true_1
bgt t1,  t2,  gt_false_1
li s0,  0
j gt_done_1
gt_true_1:
li s0,  1
j gt_done_1
gt_false_1:
li s0,  0
gt_done_1:
sd s0,  0(t0)
sd zero,  8(t0)
sd zero,  16(t0)
sd zero,  24(t0)
addi s3,  s3,  1
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
# PUSH2 0274
li a0,  9
jal ra,  deduct_gas
# PUSH 0274
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000274       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_9
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_9:
# PUSH2 0273
li a0,  9
jal ra,  deduct_gas
# PUSH 0273
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000273       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH2 01d9
li a0,  9
jal ra,  deduct_gas
# PUSH 01d9
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001d9       # Limb 0(lowest 64 bits)
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
jumpdest_50:
li a0,  3
jal ra,  deduct_gas
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_51:
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
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_52:
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
# PUSH2 0284
li a0,  9
jal ra,  deduct_gas
# PUSH 0284
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000284       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_53:
li a0,  3
jal ra,  deduct_gas
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
# PUSH2 028f
li a0,  9
jal ra,  deduct_gas
# PUSH 028f
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x000000000000028f       # Limb 0(lowest 64 bits)
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
# PUSH2 0153
li a0,  9
jal ra,  deduct_gas
# PUSH 0153
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x0000000000000153       # Limb 0(lowest 64 bits)
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
jumpdest_54:
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
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
ld a0,  48(t0)         # A limb2
ld a1,  56(t0)         # A limb3
sub s4,  t5,  t1         # res0 = a0 - b0
sltu s5,  t5,  t1        # borrow0 = a0 < b0
sub s6,  t6,  t2         # res1 = a1 - b1
sub s6,  s6,  s5         # res1 -= borrow0
sltu s5,  t6,  t2        # borrow1 = a1 < b1
sltu a2,  s6,  s5
or   s5,  s5,  a2
sub s10,  a0,  t3
sub s10,  s10,  s5
sltu s5,  a0,  t3
sltu a2,  s10,  s5
or   s5,  s5,  a2
sub s11,  a1,  t4
sub s11,  s11,  s5
sd s4,  0(t0)
sd s6,  8(t0)
sd s10,  16(t0)
sd s11,  24(t0)
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
# POP 
li a0,  2
jal ra,  deduct_gas
addi s3,  s3,  -1    # Decrement stack pointer
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
# GT 
li a0,  3
jal ra,  deduct_gas
# GT - unsigned 256-bit greater-than
addi s3,  s3,  -2
slli t0,  s3,  5
add  t0,  s2,  t0
ld t1,  24(t0)  # a limb3
ld t2,  56(t0)       # b limb3
blt t1,  t2,  gt_true_2
bgt t1,  t2,  gt_false_2
ld t1,  16(t0)  # a limb2
ld t2,  48(t0)       # b limb2
blt t1,  t2,  gt_true_2
bgt t1,  t2,  gt_false_2
ld t1,  8(t0)  # a limb1
ld t2,  40(t0)       # b limb1
blt t1,  t2,  gt_true_2
bgt t1,  t2,  gt_false_2
ld t1,  0(t0)  # a limb0
ld t2,  32(t0)       # b limb0
blt t1,  t2,  gt_true_2
bgt t1,  t2,  gt_false_2
li s0,  0
j gt_done_2
gt_true_2:
li s0,  1
j gt_done_2
gt_false_2:
li s0,  0
gt_done_2:
sd s0,  0(t0)
sd zero,  8(t0)
sd zero,  16(t0)
sd zero,  24(t0)
addi s3,  s3,  1
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
# PUSH2 02a7
li a0,  9
jal ra,  deduct_gas
# PUSH 02a7
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000002a7       # Limb 0(lowest 64 bits)
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
beqz t2,  jumpi_skip_10
slli t1,  t1,  2
la   t3,  jumpdest_table
add  t3,  t3,  t1
lw   t4,  0(t3)        # load label
jr   t4
jumpi_skip_10:
# PUSH2 02a6
li a0,  9
jal ra,  deduct_gas
# PUSH 02a6
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000002a6       # Limb 0(lowest 64 bits)
sd t0,  0(t1)
li t0,  0x0000000000000000       # Limb 1
sd t0,  8(t1)
li t0,  0x0000000000000000       # Limb 2
sd t0,  16(t1)
li t0,  0x0000000000000000       # Limb 3(highest bits)
sd t0,  24(t1)
addi s3,  s3,  1          # Increment stack pointer
# PUSH2 01d9
li a0,  9
jal ra,  deduct_gas
# PUSH 01d9
li a0,  6
jal ra,  deduct_gas
slli t1,  s3,  5          # Stack offset = s3 * 32
add  t1,  s2,  t1         # Address = stack base + offset
li t0,  0x00000000000001d9       # Limb 0(lowest 64 bits)
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
jumpdest_55:
li a0,  3
jal ra,  deduct_gas
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_56:
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
# JUMPDEST 
li a0,  3
jal ra,  deduct_gas
jumpdest_57:
li a0,  3
jal ra,  deduct_gas
# STOP 
# Unimplemented opcode: STOP
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
