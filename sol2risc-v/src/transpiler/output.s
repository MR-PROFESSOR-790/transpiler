.section .text

# Jump destination table
.align 4
jumpdest_table:

.globl evm_entry
evm_entry:
addi sp, sp, -32
sw   ra, 28(sp)
sw   s0, 24(sp)
sw   s1, 20(sp)
sw   s2, 16(sp)
sw   s3, 12(sp)
sw   s4, 8(sp)
sw   s5, 4(sp)
sw   s6, 0(sp)
li   s0, 0x10000000
li   s1, 0
la   s2, evm_stack
li   s3, 0
# PUSH1 80
li a0, 6
jal ra, deduct_gas
li t0, 80     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MSTORE 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop memory offset and value
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
lw   t2, 4(t0)     # Load value
add  t1, s0, t1    # Add memory base
sw   t2, 0(t1)     # Store value to memory
# CALLVALUE 
li a0, 3
jal ra, deduct_gas
jal  ra, get_call_value # Get call value from runtime
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
sw   a0, 0(t0)     # Store call value on stack
addi s3, s3, 1     # Increment stack pointer
# DUP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ISZERO 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop value
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value
seqz t1, t1        # Set t1 to 1 if t1 == 0, otherwise 0
sw   t1, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH1 0e
li a0, 6
jal ra, deduct_gas
li t0, 0e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMPI 
li a0, 10
jal ra, deduct_gas
addi s3, s3, -2    # Pop jump target and condition
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
lw   t1, 4(t0)     # Load condition
beqz t1, jumpi_skip_0 # Skip if false
la   t2, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t2, t2, t0    # Calculate jump address
lw   t2, 0(t2)     # Load actual address
jr   t2             # Jump to target
jumpi_skip_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# REVERT 
addi s3, s3, -2    # Pop offset and length
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   a0, 0(t0)     # Load offset
lw   a1, 4(t0)     # Load length
add  a0, s0, a0    # Add memory base to offset
jal  ra, evm_revert # Call revert function
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
li t0, 3e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1a
li a0, 6
jal ra, deduct_gas
li t0, 1a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# CODECOPY 
li a0, 3
jal ra, deduct_gas
# Unknown runtime function: codecopy
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# RETURN 
addi s3, s3, -2    # Pop offset and length
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   a0, 0(t0)     # Load offset
lw   a1, 4(t0)     # Load length
add  a0, s0, a0    # Add memory base to offset
jal  ra, evm_return # Call return function
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
# Unimplemented opcode: NOT
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
addi t0, s3, -9  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
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
addi t0, s3, -1    # Top of stack
addi t1, s3, -8 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# UNKNOWN_0XA9 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XA9
# PUSH25 e15bdbd97a4c7d64736f6c634300081a003300000000000000
li a0, 78
jal ra, deduct_gas
li t0, e15bdbd97a4c7d64736f6c634300081a003300000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
lw   ra, 28(sp)
lw   s0, 24(sp)
lw   s1, 20(sp)
lw   s2, 16(sp)
lw   s3, 12(sp)
lw   s4, 8(sp)
lw   s5, 4(sp)
lw   s6, 0(sp)
addi sp, sp, 32
jr   ra

.section .bss
.align 4
evm_stack: .space 4096
.section .text