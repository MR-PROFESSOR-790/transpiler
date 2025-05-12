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
# PUSH7 2386f26fc10000
li a0, 24
jal ra, deduct_gas
li t0, 2386f26fc10000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 03
li a0, 6
jal ra, deduct_gas
li t0, 03     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
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
# PUSH2 001a
li a0, 9
jal ra, deduct_gas
li t0, 001a     # Push value onto stack
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
# CALLER 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLER
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 008c
li a0, 9
jal ra, deduct_gas
li t0, 008c     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X1E 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X1E
# UNKNOWN_0X4F 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X4F
# UNKNOWN_0XBD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XBD
# UNKNOWN_0XF7 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XF7
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH2 009b
li a0, 9
jal ra, deduct_gas
li t0, 009b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 00a8
li a0, 9
jal ra, deduct_gas
li t0, 00a8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SHL 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHL
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SHR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
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
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 01c1
li a0, 9
jal ra, deduct_gas
li t0, 01c1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
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
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# OR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: OR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP12 
li a0, 15
jal ra, deduct_gas
addi t0, s3, -12  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0XE0 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XE0
# SMOD 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: SMOD
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP13 
li a0, 16
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -14 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# MSTORE8 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: MSTORE8
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MSIZE 
li a0, 2
jal ra, deduct_gas
# Unimplemented opcode: MSIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SGT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SGT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DIFFICULTY 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: DIFFICULTY
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# UNKNOWN_0XCD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XCD
# UNKNOWN_0X1F 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X1F
# UNKNOWN_0XD0 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XD0
# LOG4 
li a0, 3375
jal ra, deduct_gas
# Unimplemented opcode: LOG4
addi s3, s3, -6 # Adjust stack for unimplemented opcode
# CALLCODE 
li a0, 700
jal ra, deduct_gas
# Unimplemented opcode: CALLCODE
addi s3, s3, -7 # Adjust stack for unimplemented opcode
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# UNKNOWN_0X49 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X49
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP8 
li a0, 11
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -9 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# UNKNOWN_0X22 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X22
# LOG3 
li a0, 2625
jal ra, deduct_gas
# Unimplemented opcode: LOG3
addi s3, s3, -5 # Adjust stack for unimplemented opcode
# UNKNOWN_0XDA 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XDA
# UNKNOWN_0XAF 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XAF
# UNKNOWN_0XE3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XE3
# UNKNOWN_0XB4 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XB4
# XOR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: XOR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0192
li a0, 9
jal ra, deduct_gas
li t0, 0192     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0169
li a0, 9
jal ra, deduct_gas
li t0, 0169     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 01a2
li a0, 9
jal ra, deduct_gas
li t0, 01a2     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0188
li a0, 9
jal ra, deduct_gas
li t0, 0188     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 01bb
li a0, 9
jal ra, deduct_gas
li t0, 01bb     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0199
li a0, 9
jal ra, deduct_gas
li t0, 0199     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 15f0
li a0, 9
jal ra, deduct_gas
li t0, 15f0     # Push value onto stack
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
# PUSH2 01ce
li a0, 9
jal ra, deduct_gas
li t0, 01ce     # Push value onto stack
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
# PUSH4 204206e1
li a0, 15
jal ra, deduct_gas
li t0, 204206e1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0092
li a0, 9
jal ra, deduct_gas
li t0, 0092     # Push value onto stack
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
# PUSH4 24600fc3
li a0, 15
jal ra, deduct_gas
li t0, 24600fc3     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 00ae
li a0, 9
jal ra, deduct_gas
li t0, 00ae     # Push value onto stack
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
# PUSH4 715018a6
li a0, 15
jal ra, deduct_gas
li t0, 715018a6     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 00c4
li a0, 9
jal ra, deduct_gas
li t0, 00c4     # Push value onto stack
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
# PUSH4 7e57fe59
li a0, 15
jal ra, deduct_gas
li t0, 7e57fe59     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 00da
li a0, 9
jal ra, deduct_gas
li t0, 00da     # Push value onto stack
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
# PUSH2 0090
li a0, 9
jal ra, deduct_gas
li t0, 0090     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# CALLDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH2 0090
li a0, 9
jal ra, deduct_gas
li t0, 0090     # Push value onto stack
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
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 00ac
li a0, 9
jal ra, deduct_gas
li t0, 00ac     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 04
li a0, 6
jal ra, deduct_gas
li t0, 04     # Push value onto stack
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
# CALLDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 00a7
li a0, 9
jal ra, deduct_gas
li t0, 00a7     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0b54
li a0, 9
jal ra, deduct_gas
li t0, 0b54     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 01d2
li a0, 9
jal ra, deduct_gas
li t0, 01d2     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH2 00b9
li a0, 9
jal ra, deduct_gas
li t0, 00b9     # Push value onto stack
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
# PUSH2 00c2
li a0, 9
jal ra, deduct_gas
li t0, 00c2     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0420
li a0, 9
jal ra, deduct_gas
li t0, 0420     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH2 00cf
li a0, 9
jal ra, deduct_gas
li t0, 00cf     # Push value onto stack
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
# PUSH2 00d8
li a0, 9
jal ra, deduct_gas
li t0, 00d8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0531
li a0, 9
jal ra, deduct_gas
li t0, 0531     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH2 00e5
li a0, 9
jal ra, deduct_gas
li t0, 00e5     # Push value onto stack
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
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 04
li a0, 6
jal ra, deduct_gas
li t0, 04     # Push value onto stack
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
# CALLDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 00fb
li a0, 9
jal ra, deduct_gas
li t0, 00fb     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0bfd
li a0, 9
jal ra, deduct_gas
li t0, 0bfd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0544
li a0, 9
jal ra, deduct_gas
li t0, 0544     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH2 010d
li a0, 9
jal ra, deduct_gas
li t0, 010d     # Push value onto stack
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
# PUSH2 0116
li a0, 9
jal ra, deduct_gas
li t0, 0116     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 05cf
li a0, 9
jal ra, deduct_gas
li t0, 05cf     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0123
li a0, 9
jal ra, deduct_gas
li t0, 0123     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0df8
li a0, 9
jal ra, deduct_gas
li t0, 0df8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH2 0137
li a0, 9
jal ra, deduct_gas
li t0, 0137     # Push value onto stack
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
# PUSH2 0140
li a0, 9
jal ra, deduct_gas
li t0, 0140     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 07a9
li a0, 9
jal ra, deduct_gas
li t0, 07a9     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 014d
li a0, 9
jal ra, deduct_gas
li t0, 014d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0e27
li a0, 9
jal ra, deduct_gas
li t0, 0e27     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH2 0161
li a0, 9
jal ra, deduct_gas
li t0, 0161     # Push value onto stack
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
# PUSH2 016a
li a0, 9
jal ra, deduct_gas
li t0, 016a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 07af
li a0, 9
jal ra, deduct_gas
li t0, 07af     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0177
li a0, 9
jal ra, deduct_gas
li t0, 0177     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0e4f
li a0, 9
jal ra, deduct_gas
li t0, 0e4f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH2 018b
li a0, 9
jal ra, deduct_gas
li t0, 018b     # Push value onto stack
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
# PUSH2 0194
li a0, 9
jal ra, deduct_gas
li t0, 0194     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 07d6
li a0, 9
jal ra, deduct_gas
li t0, 07d6     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 01a1
li a0, 9
jal ra, deduct_gas
li t0, 01a1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0e27
li a0, 9
jal ra, deduct_gas
li t0, 0e27     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH2 01b5
li a0, 9
jal ra, deduct_gas
li t0, 01b5     # Push value onto stack
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
# PUSH2 01d0
li a0, 9
jal ra, deduct_gas
li t0, 01d0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 04
li a0, 6
jal ra, deduct_gas
li t0, 04     # Push value onto stack
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
# CALLDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 01cb
li a0, 9
jal ra, deduct_gas
li t0, 01cb     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0e92
li a0, 9
jal ra, deduct_gas
li t0, 0e92     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 07dc
li a0, 9
jal ra, deduct_gas
li t0, 07dc     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 01da
li a0, 9
jal ra, deduct_gas
li t0, 01da     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0860
li a0, 9
jal ra, deduct_gas
li t0, 0860     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 03
li a0, 6
jal ra, deduct_gas
li t0, 03     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# CALLVALUE 
li a0, 3
jal ra, deduct_gas
jal  ra, get_call_value # Get call value from runtime
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
sw   a0, 0(t0)     # Store call value on stack
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 021f
li a0, 9
jal ra, deduct_gas
li t0, 021f     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADDMOD 
li a0, 8
jal ra, deduct_gas
# Unimplemented opcode: ADDMOD
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# UNKNOWN_0XC3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XC3
# PUSH26 a000000000000000000000000000000000000000000000000000
li a0, 81
jal ra, deduct_gas
li t0, a000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
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
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# PUSH1 80
li a0, 6
jal ra, deduct_gas
li t0, 80     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# TIMESTAMP 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: TIMESTAMP
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# CALLER 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLER
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
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
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 04
li a0, 6
jal ra, deduct_gas
li t0, 04     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0291
li a0, 9
jal ra, deduct_gas
li t0, 0291     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 1155
li a0, 9
jal ra, deduct_gas
li t0, 1155     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 02a7
li a0, 9
jal ra, deduct_gas
li t0, 02a7     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 1155
li a0, 9
jal ra, deduct_gas
li t0, 1155     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# PUSH1 60
li a0, 6
jal ra, deduct_gas
li t0, 60     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 03
li a0, 6
jal ra, deduct_gas
li t0, 03     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# OR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: OR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# CALLVALUE 
li a0, 3
jal ra, deduct_gas
jal  ra, get_call_value # Get call value from runtime
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
sw   a0, 0(t0)     # Store call value on stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 04
li a0, 6
jal ra, deduct_gas
li t0, 04     # Push value onto stack
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
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# PUSH2 030b
li a0, 9
jal ra, deduct_gas
li t0, 030b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 1251
li a0, 9
jal ra, deduct_gas
li t0, 1251     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 031b
li a0, 9
jal ra, deduct_gas
li t0, 031b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 07af
li a0, 9
jal ra, deduct_gas
li t0, 07af     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# CALLVALUE 
li a0, 3
jal ra, deduct_gas
jal  ra, get_call_value # Get call value from runtime
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
sw   a0, 0(t0)     # Store call value on stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 033e
li a0, 9
jal ra, deduct_gas
li t0, 033e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 12b1
li a0, 9
jal ra, deduct_gas
li t0, 12b1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP8 
li a0, 11
jal ra, deduct_gas
addi t0, s3, -8  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GAS 
li a0, 2
jal ra, deduct_gas
# Unimplemented opcode: GAS
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# CALL 
li a0, 700
jal ra, deduct_gas
# Unimplemented opcode: CALL
addi s3, s3, -7 # Adjust stack for unimplemented opcode
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0378
li a0, 9
jal ra, deduct_gas
li t0, 0378     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# PUSH1 3f
li a0, 6
jal ra, deduct_gas
li t0, 3f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# RETURNDATACOPY 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATACOPY
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# PUSH2 037d
li a0, 9
jal ra, deduct_gas
li t0, 037d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 60
li a0, 6
jal ra, deduct_gas
li t0, 60     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
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
# PUSH2 03c1
li a0, 9
jal ra, deduct_gas
li t0, 03c1     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADDMOD 
li a0, 8
jal ra, deduct_gas
# Unimplemented opcode: ADDMOD
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# UNKNOWN_0XC3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XC3
# PUSH26 a000000000000000000000000000000000000000000000000000
li a0, 81
jal ra, deduct_gas
li t0, a000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# CALLER 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLER
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# RETURNDATACOPY 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATACOPY
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0XCE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XCE
# UNKNOWN_0XFC 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XFC
# LOG1 
li a0, 1125
jal ra, deduct_gas
# Unimplemented opcode: LOG1
addi s3, s3, -3 # Adjust stack for unimplemented opcode
# PUSH18 d6a759367a345daff60147419fddaf081f29
li a0, 57
jal ra, deduct_gas
li t0, d6a759367a345daff60147419fddaf081f29     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH26 7bcbf9314484844260405161040b9392919061138b565b604051
li a0, 81
jal ra, deduct_gas
li t0, 7bcbf9314484844260405161040b9392919061138b565b604051     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# LOG2 
li a0, 1875
jal ra, deduct_gas
# Unimplemented opcode: LOG2
addi s3, s3, -4 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 041c
li a0, 9
jal ra, deduct_gas
li t0, 041c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 08af
li a0, 9
jal ra, deduct_gas
li t0, 08af     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0428
li a0, 9
jal ra, deduct_gas
li t0, 0428     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 08b8
li a0, 9
jal ra, deduct_gas
li t0, 08b8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0430
li a0, 9
jal ra, deduct_gas
li t0, 0430     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0860
li a0, 9
jal ra, deduct_gas
li t0, 0860     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SELFBALANCE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SELFBALANCE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 0476
li a0, 9
jal ra, deduct_gas
li t0, 0476     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADDMOD 
li a0, 8
jal ra, deduct_gas
# Unimplemented opcode: ADDMOD
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# UNKNOWN_0XC3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XC3
# PUSH26 a000000000000000000000000000000000000000000000000000
li a0, 81
jal ra, deduct_gas
li t0, a000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 047f
li a0, 9
jal ra, deduct_gas
li t0, 047f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 07af
li a0, 9
jal ra, deduct_gas
li t0, 07af     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 04a2
li a0, 9
jal ra, deduct_gas
li t0, 04a2     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 12b1
li a0, 9
jal ra, deduct_gas
li t0, 12b1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP8 
li a0, 11
jal ra, deduct_gas
addi t0, s3, -8  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GAS 
li a0, 2
jal ra, deduct_gas
# Unimplemented opcode: GAS
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# CALL 
li a0, 700
jal ra, deduct_gas
# Unimplemented opcode: CALL
addi s3, s3, -7 # Adjust stack for unimplemented opcode
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 04dc
li a0, 9
jal ra, deduct_gas
li t0, 04dc     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# PUSH1 3f
li a0, 6
jal ra, deduct_gas
li t0, 3f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# RETURNDATASIZE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATASIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# RETURNDATACOPY 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATACOPY
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# PUSH2 04e1
li a0, 9
jal ra, deduct_gas
li t0, 04e1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 60
li a0, 6
jal ra, deduct_gas
li t0, 60     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
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
# PUSH2 0525
li a0, 9
jal ra, deduct_gas
li t0, 0525     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADDMOD 
li a0, 8
jal ra, deduct_gas
# Unimplemented opcode: ADDMOD
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# UNKNOWN_0XC3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XC3
# PUSH26 a000000000000000000000000000000000000000000000000000
li a0, 81
jal ra, deduct_gas
li t0, a000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 052f
li a0, 9
jal ra, deduct_gas
li t0, 052f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 08af
li a0, 9
jal ra, deduct_gas
li t0, 08af     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0539
li a0, 9
jal ra, deduct_gas
li t0, 0539     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 08b8
li a0, 9
jal ra, deduct_gas
li t0, 08b8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0542
li a0, 9
jal ra, deduct_gas
li t0, 0542     # Push value onto stack
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
# PUSH2 093f
li a0, 9
jal ra, deduct_gas
li t0, 093f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 054c
li a0, 9
jal ra, deduct_gas
li t0, 054c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 08b8
li a0, 9
jal ra, deduct_gas
li t0, 08b8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 058e
li a0, 9
jal ra, deduct_gas
li t0, 058e     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADDMOD 
li a0, 8
jal ra, deduct_gas
# Unimplemented opcode: ADDMOD
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# UNKNOWN_0XC3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XC3
# PUSH26 a000000000000000000000000000000000000000000000000000
li a0, 81
jal ra, deduct_gas
li t0, a000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH1 03
li a0, 6
jal ra, deduct_gas
li t0, 03     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# RETURNDATACOPY 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: RETURNDATACOPY
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# UNKNOWN_0X26 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X26
# UNKNOWN_0X23 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X23
# PUSH10 4efe135193106e707cb9
li a0, 33
jal ra, deduct_gas
li t0, 4efe135193106e707cb9     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# ADDMOD 
li a0, 8
jal ra, deduct_gas
# Unimplemented opcode: ADDMOD
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# PUSH18 bd82b3667d6e4eaf7c2d2888009d81816040
li a0, 57
jal ra, deduct_gas
li t0, bd82b3667d6e4eaf7c2d2888009d81816040     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 05c4
li a0, 9
jal ra, deduct_gas
li t0, 05c4     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0e27
li a0, 9
jal ra, deduct_gas
li t0, 0e27     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# LOG1 
li a0, 1125
jal ra, deduct_gas
# Unimplemented opcode: LOG1
addi s3, s3, -3 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 60
li a0, 6
jal ra, deduct_gas
li t0, 60     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
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
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 07a0
li a0, 9
jal ra, deduct_gas
li t0, 07a0     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
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
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 04
li a0, 6
jal ra, deduct_gas
li t0, 04     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# PUSH1 80
li a0, 6
jal ra, deduct_gas
li t0, 80     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# PUSH2 0622
li a0, 9
jal ra, deduct_gas
li t0, 0622     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0f88
li a0, 9
jal ra, deduct_gas
li t0, 0f88     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# PUSH2 064e
li a0, 9
jal ra, deduct_gas
li t0, 064e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0f88
li a0, 9
jal ra, deduct_gas
li t0, 0f88     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH2 0699
li a0, 9
jal ra, deduct_gas
li t0, 0699     # Push value onto stack
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
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 0670
li a0, 9
jal ra, deduct_gas
li t0, 0670     # Push value onto stack
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
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0699
li a0, 9
jal ra, deduct_gas
li t0, 0699     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
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
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 067c
li a0, 9
jal ra, deduct_gas
li t0, 067c     # Push value onto stack
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
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# PUSH2 06b2
li a0, 9
jal ra, deduct_gas
li t0, 06b2     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0f88
li a0, 9
jal ra, deduct_gas
li t0, 0f88     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# PUSH2 06de
li a0, 9
jal ra, deduct_gas
li t0, 06de     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0f88
li a0, 9
jal ra, deduct_gas
li t0, 0f88     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH2 0729
li a0, 9
jal ra, deduct_gas
li t0, 0729     # Push value onto stack
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
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 0700
li a0, 9
jal ra, deduct_gas
li t0, 0700     # Push value onto stack
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
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0729
li a0, 9
jal ra, deduct_gas
li t0, 0729     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
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
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 070c
li a0, 9
jal ra, deduct_gas
li t0, 070c     # Push value onto stack
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
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 03
li a0, 6
jal ra, deduct_gas
li t0, 03     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 05f2
li a0, 9
jal ra, deduct_gas
li t0, 05f2     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 03
li a0, 6
jal ra, deduct_gas
li t0, 03     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 04
li a0, 6
jal ra, deduct_gas
li t0, 04     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 07e4
li a0, 9
jal ra, deduct_gas
li t0, 07e4     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 08b8
li a0, 9
jal ra, deduct_gas
li t0, 08b8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0854
li a0, 9
jal ra, deduct_gas
li t0, 0854     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X1E 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X1E
# UNKNOWN_0X4F 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X4F
# UNKNOWN_0XBD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XBD
# UNKNOWN_0XF7 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XF7
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH2 085d
li a0, 9
jal ra, deduct_gas
li t0, 085d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 093f
li a0, 9
jal ra, deduct_gas
li t0, 093f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 08a5
li a0, 9
jal ra, deduct_gas
li t0, 08a5     # Push value onto stack
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADDMOD 
li a0, 8
jal ra, deduct_gas
# Unimplemented opcode: ADDMOD
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# UNKNOWN_0XC3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XC3
# PUSH26 a000000000000000000000000000000000000000000000000000
li a0, 81
jal ra, deduct_gas
li t0, a000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
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
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 08c0
li a0, 9
jal ra, deduct_gas
li t0, 08c0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a00
li a0, 9
jal ra, deduct_gas
li t0, 0a00     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 08de
li a0, 9
jal ra, deduct_gas
li t0, 08de     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 07af
li a0, 9
jal ra, deduct_gas
li t0, 07af     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 093d
li a0, 9
jal ra, deduct_gas
li t0, 093d     # Push value onto stack
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
# PUSH2 0901
li a0, 9
jal ra, deduct_gas
li t0, 0901     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a00
li a0, 9
jal ra, deduct_gas
li t0, 0a00     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP13 
li a0, 16
jal ra, deduct_gas
addi t0, s3, -13  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0XDA 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XDA
# UNKNOWN_0XA7 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XA7
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
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
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
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
# PUSH2 0100
li a0, 9
jal ra, deduct_gas
li t0, 0100     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# EXP 
li a0, 10
jal ra, deduct_gas
# Unimplemented opcode: EXP
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# OR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: OR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP12 
li a0, 15
jal ra, deduct_gas
addi t0, s3, -12  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0XE0 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XE0
# SMOD 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: SMOD
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP13 
li a0, 16
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -14 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# MSTORE8 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: MSTORE8
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# MSIZE 
li a0, 2
jal ra, deduct_gas
# Unimplemented opcode: MSIZE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SGT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SGT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DIFFICULTY 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: DIFFICULTY
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# UNKNOWN_0XCD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XCD
# UNKNOWN_0X1F 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X1F
# UNKNOWN_0XD0 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XD0
# LOG4 
li a0, 3375
jal ra, deduct_gas
# Unimplemented opcode: LOG4
addi s3, s3, -6 # Adjust stack for unimplemented opcode
# CALLCODE 
li a0, 700
jal ra, deduct_gas
# Unimplemented opcode: CALLCODE
addi s3, s3, -7 # Adjust stack for unimplemented opcode
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# UNKNOWN_0X49 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X49
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP8 
li a0, 11
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -9 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# UNKNOWN_0X22 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X22
# LOG3 
li a0, 2625
jal ra, deduct_gas
# Unimplemented opcode: LOG3
addi s3, s3, -5 # Adjust stack for unimplemented opcode
# UNKNOWN_0XDA 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XDA
# UNKNOWN_0XAF 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XAF
# UNKNOWN_0XE3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XE3
# UNKNOWN_0XB4 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0XB4
# XOR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: XOR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# CALLER 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLER
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X4E 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X4E
# BASEFEE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: BASEFEE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH28 71000000000000000000000000000000000000000000000000000000
li a0, 87
jal ra, deduct_gas
li t0, 71000000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0a66
li a0, 9
jal ra, deduct_gas
li t0, 0a66     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a20
li a0, 9
jal ra, deduct_gas
li t0, 0a20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH8 ffffffffffffffff
li a0, 27
jal ra, deduct_gas
li t0, ffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# OR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: OR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0a85
li a0, 9
jal ra, deduct_gas
li t0, 0a85     # Push value onto stack
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
# PUSH2 0a84
li a0, 9
jal ra, deduct_gas
li t0, 0a84     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a30
li a0, 9
jal ra, deduct_gas
li t0, 0a30     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a97
li a0, 9
jal ra, deduct_gas
li t0, 0a97     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a07
li a0, 9
jal ra, deduct_gas
li t0, 0a07     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0aa3
li a0, 9
jal ra, deduct_gas
li t0, 0aa3     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a5d
li a0, 9
jal ra, deduct_gas
li t0, 0a5d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH8 ffffffffffffffff
li a0, 27
jal ra, deduct_gas
li t0, ffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0ac2
li a0, 9
jal ra, deduct_gas
li t0, 0ac2     # Push value onto stack
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
# PUSH2 0ac1
li a0, 9
jal ra, deduct_gas
li t0, 0ac1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a30
li a0, 9
jal ra, deduct_gas
li t0, 0a30     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0acb
li a0, 9
jal ra, deduct_gas
li t0, 0acb     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a20
li a0, 9
jal ra, deduct_gas
li t0, 0a20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# CALLDATACOPY 
li a0, 3
jal ra, deduct_gas
# Unknown runtime function: calldatacopy
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0af8
li a0, 9
jal ra, deduct_gas
li t0, 0af8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0af3
li a0, 9
jal ra, deduct_gas
li t0, 0af3     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0aa8
li a0, 9
jal ra, deduct_gas
li t0, 0aa8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0a8e
li a0, 9
jal ra, deduct_gas
li t0, 0a8e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0b14
li a0, 9
jal ra, deduct_gas
li t0, 0b14     # Push value onto stack
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
# PUSH2 0b13
li a0, 9
jal ra, deduct_gas
li t0, 0b13     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a1c
li a0, 9
jal ra, deduct_gas
li t0, 0a1c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0b1f
li a0, 9
jal ra, deduct_gas
li t0, 0b1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ad8
li a0, 9
jal ra, deduct_gas
li t0, 0ad8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -5 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SLT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 0b3b
li a0, 9
jal ra, deduct_gas
li t0, 0b3b     # Push value onto stack
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
# PUSH2 0b3a
li a0, 9
jal ra, deduct_gas
li t0, 0b3a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a18
li a0, 9
jal ra, deduct_gas
li t0, 0a18     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# CALLDATALOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATALOAD
# PUSH2 0b4b
li a0, 9
jal ra, deduct_gas
li t0, 0b4b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0ae6
li a0, 9
jal ra, deduct_gas
li t0, 0ae6     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SLT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0b6a
li a0, 9
jal ra, deduct_gas
li t0, 0b6a     # Push value onto stack
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
# PUSH2 0b69
li a0, 9
jal ra, deduct_gas
li t0, 0b69     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a10
li a0, 9
jal ra, deduct_gas
li t0, 0a10     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# CALLDATALOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATALOAD
# PUSH8 ffffffffffffffff
li a0, 27
jal ra, deduct_gas
li t0, ffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0b87
li a0, 9
jal ra, deduct_gas
li t0, 0b87     # Push value onto stack
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
# PUSH2 0b86
li a0, 9
jal ra, deduct_gas
li t0, 0b86     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a14
li a0, 9
jal ra, deduct_gas
li t0, 0a14     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0b93
li a0, 9
jal ra, deduct_gas
li t0, 0b93     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0b27
li a0, 9
jal ra, deduct_gas
li t0, 0b27     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# CALLDATALOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATALOAD
# PUSH8 ffffffffffffffff
li a0, 27
jal ra, deduct_gas
li t0, ffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0bb4
li a0, 9
jal ra, deduct_gas
li t0, 0bb4     # Push value onto stack
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
# PUSH2 0bb3
li a0, 9
jal ra, deduct_gas
li t0, 0bb3     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a14
li a0, 9
jal ra, deduct_gas
li t0, 0a14     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0bc0
li a0, 9
jal ra, deduct_gas
li t0, 0bc0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0b27
li a0, 9
jal ra, deduct_gas
li t0, 0b27     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0bdc
li a0, 9
jal ra, deduct_gas
li t0, 0bdc     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0bca
li a0, 9
jal ra, deduct_gas
li t0, 0bca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0be6
li a0, 9
jal ra, deduct_gas
li t0, 0be6     # Push value onto stack
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
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# CALLDATALOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATALOAD
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0bf7
li a0, 9
jal ra, deduct_gas
li t0, 0bf7     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0bd3
li a0, 9
jal ra, deduct_gas
li t0, 0bd3     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SLT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0c12
li a0, 9
jal ra, deduct_gas
li t0, 0c12     # Push value onto stack
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
# PUSH2 0c11
li a0, 9
jal ra, deduct_gas
li t0, 0c11     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a10
li a0, 9
jal ra, deduct_gas
li t0, 0a10     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c1f
li a0, 9
jal ra, deduct_gas
li t0, 0c1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0be9
li a0, 9
jal ra, deduct_gas
li t0, 0be9     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X5E 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X5E
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c83
li a0, 9
jal ra, deduct_gas
li t0, 0c83     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c51
li a0, 9
jal ra, deduct_gas
li t0, 0c51     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0c8d
li a0, 9
jal ra, deduct_gas
li t0, 0c8d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c5b
li a0, 9
jal ra, deduct_gas
li t0, 0c5b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -5 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0c9d
li a0, 9
jal ra, deduct_gas
li t0, 0c9d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0c6b
li a0, 9
jal ra, deduct_gas
li t0, 0c6b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0ca6
li a0, 9
jal ra, deduct_gas
li t0, 0ca6     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a20
li a0, 9
jal ra, deduct_gas
li t0, 0a20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0cba
li a0, 9
jal ra, deduct_gas
li t0, 0cba     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0bca
li a0, 9
jal ra, deduct_gas
li t0, 0bca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH20 ffffffffffffffffffffffffffffffffffffffff
li a0, 63
jal ra, deduct_gas
li t0, ffffffffffffffffffffffffffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ce9
li a0, 9
jal ra, deduct_gas
li t0, 0ce9     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0cc0
li a0, 9
jal ra, deduct_gas
li t0, 0cc0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0cf9
li a0, 9
jal ra, deduct_gas
li t0, 0cf9     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0cdf
li a0, 9
jal ra, deduct_gas
li t0, 0cdf     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 80
li a0, 6
jal ra, deduct_gas
li t0, 80     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 0d19
li a0, 9
jal ra, deduct_gas
li t0, 0d19     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c79
li a0, 9
jal ra, deduct_gas
li t0, 0c79     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 0d33
li a0, 9
jal ra, deduct_gas
li t0, 0d33     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c79
li a0, 9
jal ra, deduct_gas
li t0, 0c79     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0d48
li a0, 9
jal ra, deduct_gas
li t0, 0d48     # Push value onto stack
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
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0cb1
li a0, 9
jal ra, deduct_gas
li t0, 0cb1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 60
li a0, 6
jal ra, deduct_gas
li t0, 60     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0d5b
li a0, 9
jal ra, deduct_gas
li t0, 0d5b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 60
li a0, 6
jal ra, deduct_gas
li t0, 60     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0cf0
li a0, 9
jal ra, deduct_gas
li t0, 0cf0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
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
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0d71
li a0, 9
jal ra, deduct_gas
li t0, 0d71     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0cff
li a0, 9
jal ra, deduct_gas
li t0, 0cff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0d8f
li a0, 9
jal ra, deduct_gas
li t0, 0d8f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c28
li a0, 9
jal ra, deduct_gas
li t0, 0c28     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0d99
li a0, 9
jal ra, deduct_gas
li t0, 0d99     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c32
li a0, 9
jal ra, deduct_gas
li t0, 0c32     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -5 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0dab
li a0, 9
jal ra, deduct_gas
li t0, 0dab     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c42
li a0, 9
jal ra, deduct_gas
li t0, 0c42     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
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
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0de6
li a0, 9
jal ra, deduct_gas
li t0, 0de6     # Push value onto stack
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
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# DUP10 
li a0, 13
jal ra, deduct_gas
addi t0, s3, -10  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0dc7
li a0, 9
jal ra, deduct_gas
li t0, 0dc7     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0d66
li a0, 9
jal ra, deduct_gas
li t0, 0d66     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -6 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0dd2
li a0, 9
jal ra, deduct_gas
li t0, 0dd2     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0d79
li a0, 9
jal ra, deduct_gas
li t0, 0d79     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP11 
li a0, 14
jal ra, deduct_gas
addi t0, s3, -11  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP10 
li a0, 13
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -11 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0dae
li a0, 9
jal ra, deduct_gas
li t0, 0dae     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP8 
li a0, 11
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -9 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP8 
li a0, 11
jal ra, deduct_gas
addi t0, s3, -8  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -7 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 0e10
li a0, 9
jal ra, deduct_gas
li t0, 0e10     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0d85
li a0, 9
jal ra, deduct_gas
li t0, 0d85     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0e21
li a0, 9
jal ra, deduct_gas
li t0, 0e21     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0bca
li a0, 9
jal ra, deduct_gas
li t0, 0bca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0e3a
li a0, 9
jal ra, deduct_gas
li t0, 0e3a     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0e18
li a0, 9
jal ra, deduct_gas
li t0, 0e18     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0e49
li a0, 9
jal ra, deduct_gas
li t0, 0e49     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0cdf
li a0, 9
jal ra, deduct_gas
li t0, 0cdf     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0e62
li a0, 9
jal ra, deduct_gas
li t0, 0e62     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0e40
li a0, 9
jal ra, deduct_gas
li t0, 0e40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0e71
li a0, 9
jal ra, deduct_gas
li t0, 0e71     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0cdf
li a0, 9
jal ra, deduct_gas
li t0, 0cdf     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0e7b
li a0, 9
jal ra, deduct_gas
li t0, 0e7b     # Push value onto stack
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
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# CALLDATALOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CALLDATALOAD
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0e8c
li a0, 9
jal ra, deduct_gas
li t0, 0e8c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0e68
li a0, 9
jal ra, deduct_gas
li t0, 0e68     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# SLT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0ea7
li a0, 9
jal ra, deduct_gas
li t0, 0ea7     # Push value onto stack
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
# PUSH2 0ea6
li a0, 9
jal ra, deduct_gas
li t0, 0ea6     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a10
li a0, 9
jal ra, deduct_gas
li t0, 0a10     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0eb4
li a0, 9
jal ra, deduct_gas
li t0, 0eb4     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0e7e
li a0, 9
jal ra, deduct_gas
li t0, 0e7e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DIFFICULTY 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: DIFFICULTY
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH16 6e6174696f6e20616d6f756e74206973
li a0, 51
jal ra, deduct_gas
li t0, 6e6174696f6e20616d6f756e74206973     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH13 657373207468616e207468655f
li a0, 42
jal ra, deduct_gas
li t0, 657373207468616e207468655f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH14 696e696d756d2072657175697265
li a0, 45
jal ra, deduct_gas
li t0, 696e696d756d2072657175697265     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH5 0000000000
li a0, 18
jal ra, deduct_gas
li t0, 0000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0f27
li a0, 9
jal ra, deduct_gas
li t0, 0f27     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 31
li a0, 6
jal ra, deduct_gas
li t0, 31     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ebd
li a0, 9
jal ra, deduct_gas
li t0, 0ebd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 0f32
li a0, 9
jal ra, deduct_gas
li t0, 0f32     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ecd
li a0, 9
jal ra, deduct_gas
li t0, 0ecd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 0f54
li a0, 9
jal ra, deduct_gas
li t0, 0f54     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0f1b
li a0, 9
jal ra, deduct_gas
li t0, 0f1b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X4E 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X4E
# BASEFEE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: BASEFEE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH28 71000000000000000000000000000000000000000000000000000000
li a0, 87
jal ra, deduct_gas
li t0, 71000000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 0f9f
li a0, 9
jal ra, deduct_gas
li t0, 0f9f     # Push value onto stack
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
# PUSH1 7f
li a0, 6
jal ra, deduct_gas
li t0, 7f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0fb2
li a0, 9
jal ra, deduct_gas
li t0, 0fb2     # Push value onto stack
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
# PUSH2 0fb1
li a0, 9
jal ra, deduct_gas
li t0, 0fb1     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0f5b
li a0, 9
jal ra, deduct_gas
li t0, 0f5b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
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
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
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
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DIV 
li a0, 5
jal ra, deduct_gas
# Unimplemented opcode: DIV
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SHL 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHL
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 08
li a0, 6
jal ra, deduct_gas
li t0, 08     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 1014
li a0, 9
jal ra, deduct_gas
li t0, 1014     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SELFDESTRUCT 
li a0, 5000
jal ra, deduct_gas
# Unimplemented opcode: SELFDESTRUCT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0fd9
li a0, 9
jal ra, deduct_gas
li t0, 0fd9     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 101e
li a0, 9
jal ra, deduct_gas
li t0, 101e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0fd9
li a0, 9
jal ra, deduct_gas
li t0, 0fd9     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -7 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
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
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -5 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
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
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# OR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: OR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -5 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1059
li a0, 9
jal ra, deduct_gas
li t0, 1059     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1054
li a0, 9
jal ra, deduct_gas
li t0, 1054     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 104f
li a0, 9
jal ra, deduct_gas
li t0, 104f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0bca
li a0, 9
jal ra, deduct_gas
li t0, 0bca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 1036
li a0, 9
jal ra, deduct_gas
li t0, 1036     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 0bca
li a0, 9
jal ra, deduct_gas
li t0, 0bca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 1072
li a0, 9
jal ra, deduct_gas
li t0, 1072     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 103f
li a0, 9
jal ra, deduct_gas
li t0, 103f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 1086
li a0, 9
jal ra, deduct_gas
li t0, 1086     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 107e
li a0, 9
jal ra, deduct_gas
li t0, 107e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1060
li a0, 9
jal ra, deduct_gas
li t0, 1060     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# PUSH2 0fe5
li a0, 9
jal ra, deduct_gas
li t0, 0fe5     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 109a
li a0, 9
jal ra, deduct_gas
li t0, 109a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 108e
li a0, 9
jal ra, deduct_gas
li t0, 108e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 10a5
li a0, 9
jal ra, deduct_gas
li t0, 10a5     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1069
li a0, 9
jal ra, deduct_gas
li t0, 1069     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 10c8
li a0, 9
jal ra, deduct_gas
li t0, 10c8     # Push value onto stack
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
# PUSH2 10bd
li a0, 9
jal ra, deduct_gas
li t0, 10bd     # Push value onto stack
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
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1092
li a0, 9
jal ra, deduct_gas
li t0, 1092     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 10ab
li a0, 9
jal ra, deduct_gas
li t0, 10ab     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 110d
li a0, 9
jal ra, deduct_gas
li t0, 110d     # Push value onto stack
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
# PUSH2 10de
li a0, 9
jal ra, deduct_gas
li t0, 10de     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0fb8
li a0, 9
jal ra, deduct_gas
li t0, 0fb8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 10e7
li a0, 9
jal ra, deduct_gas
li t0, 10e7     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0fca
li a0, 9
jal ra, deduct_gas
li t0, 0fca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 10f6
li a0, 9
jal ra, deduct_gas
li t0, 10f6     # Push value onto stack
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
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 110a
li a0, 9
jal ra, deduct_gas
li t0, 110a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1102
li a0, 9
jal ra, deduct_gas
li t0, 1102     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0fca
li a0, 9
jal ra, deduct_gas
li t0, 0fca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 10aa
li a0, 9
jal ra, deduct_gas
li t0, 10aa     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SHR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 112d
li a0, 9
jal ra, deduct_gas
li t0, 112d     # Push value onto stack
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
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 08
li a0, 6
jal ra, deduct_gas
li t0, 08     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 1112
li a0, 9
jal ra, deduct_gas
li t0, 1112     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1145
li a0, 9
jal ra, deduct_gas
li t0, 1145     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 111e
li a0, 9
jal ra, deduct_gas
li t0, 111e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# OR 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: OR
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 115e
li a0, 9
jal ra, deduct_gas
li t0, 115e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c51
li a0, 9
jal ra, deduct_gas
li t0, 0c51     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH8 ffffffffffffffff
li a0, 27
jal ra, deduct_gas
li t0, ffffffffffffffff     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 1177
li a0, 9
jal ra, deduct_gas
li t0, 1177     # Push value onto stack
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
# PUSH2 1176
li a0, 9
jal ra, deduct_gas
li t0, 1176     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a30
li a0, 9
jal ra, deduct_gas
li t0, 0a30     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 1181
li a0, 9
jal ra, deduct_gas
li t0, 1181     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SLOAD 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SLOAD
# PUSH2 0f88
li a0, 9
jal ra, deduct_gas
li t0, 0f88     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 118c
li a0, 9
jal ra, deduct_gas
li t0, 118c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 10cc
li a0, 9
jal ra, deduct_gas
li t0, 10cc     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# EQ 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
xor  t3, t1, t2    # XOR values
seqz t3, t3        # Set t3 to 1 if equal
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH2 11bd
li a0, 9
jal ra, deduct_gas
li t0, 11bd     # Push value onto stack
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
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
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
# PUSH2 11ab
li a0, 9
jal ra, deduct_gas
li t0, 11ab     # Push value onto stack
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
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP8 
li a0, 11
jal ra, deduct_gas
addi t0, s3, -8  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 11b5
li a0, 9
jal ra, deduct_gas
li t0, 11b5     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 113a
li a0, 9
jal ra, deduct_gas
li t0, 113a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 121c
li a0, 9
jal ra, deduct_gas
li t0, 121c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# NOT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: NOT
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH2 11cb
li a0, 9
jal ra, deduct_gas
li t0, 11cb     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0fb8
li a0, 9
jal ra, deduct_gas
li t0, 0fb8     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 11f2
li a0, 9
jal ra, deduct_gas
li t0, 11f2     # Push value onto stack
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
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP10 
li a0, 13
jal ra, deduct_gas
addi t0, s3, -10  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -6 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 11cd
li a0, 9
jal ra, deduct_gas
li t0, 11cd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# LT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: LT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 120f
li a0, 9
jal ra, deduct_gas
li t0, 120f     # Push value onto stack
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
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP10 
li a0, 13
jal ra, deduct_gas
addi t0, s3, -10  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# MLOAD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -1    # Pop memory offset
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load memory offset
add  t1, s0, t1    # Add memory base
lw   t2, 0(t1)     # Load value from memory
sw   t2, 0(t0)     # Push value onto stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 120b
li a0, 9
jal ra, deduct_gas
li t0, 120b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP10 
li a0, 13
jal ra, deduct_gas
addi t0, s3, -10  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# AND 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: AND
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 111e
li a0, 9
jal ra, deduct_gas
li t0, 111e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 01
li a0, 6
jal ra, deduct_gas
li t0, 01     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 02
li a0, 6
jal ra, deduct_gas
li t0, 02     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
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
# MUL 
li a0, 5
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
mul  t3, t1, t2    # Multiply values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# SSTORE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SSTORE
addi s3, s3, -2 # Adjust stack for unimplemented opcode
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X4E 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X4E
# BASEFEE 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: BASEFEE
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH28 71000000000000000000000000000000000000000000000000000000
li a0, 87
jal ra, deduct_gas
li t0, 71000000000000000000000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 125b
li a0, 9
jal ra, deduct_gas
li t0, 125b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0bca
li a0, 9
jal ra, deduct_gas
li t0, 0bca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 1266
li a0, 9
jal ra, deduct_gas
li t0, 1266     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0bca
li a0, 9
jal ra, deduct_gas
li t0, 0bca     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
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
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# GT 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: GT
addi s3, s3, -1 # Adjust stack for unimplemented opcode
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
# PUSH2 127e
li a0, 9
jal ra, deduct_gas
li t0, 127e     # Push value onto stack
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
# PUSH2 127d
li a0, 9
jal ra, deduct_gas
li t0, 127d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1224
li a0, 9
jal ra, deduct_gas
li t0, 1224     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 129c
li a0, 9
jal ra, deduct_gas
li t0, 129c     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1284
li a0, 9
jal ra, deduct_gas
li t0, 1284     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 12a7
li a0, 9
jal ra, deduct_gas
li t0, 12a7     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 128e
li a0, 9
jal ra, deduct_gas
li t0, 128e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 12bb
li a0, 9
jal ra, deduct_gas
li t0, 12bb     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1291
li a0, 9
jal ra, deduct_gas
li t0, 1291     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# CHAINID 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: CHAINID
addi s3, s3, 1 # Adjust stack for unimplemented opcode
# PUSH2 696c
li a0, 9
jal ra, deduct_gas
li t0, 696c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH6 6420746f2073
li a0, 21
jal ra, deduct_gas
li t0, 6420746f2073     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH6 6e6420457468
li a0, 21
jal ra, deduct_gas
li t0, 6e6420457468     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH6 7220746f2074
li a0, 21
jal ra, deduct_gas
li t0, 7220746f2074     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH9 65206f776e655f8201
li a0, 30
jal ra, deduct_gas
li t0, 65206f776e655f8201     # Push value onto stack
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
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH19 00000000000000000000000000000000000000
li a0, 60
jal ra, deduct_gas
li t0, 00000000000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 131f
li a0, 9
jal ra, deduct_gas
li t0, 131f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 21
li a0, 6
jal ra, deduct_gas
li t0, 21     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ebd
li a0, 9
jal ra, deduct_gas
li t0, 0ebd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 132a
li a0, 9
jal ra, deduct_gas
li t0, 132a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 12c5
li a0, 9
jal ra, deduct_gas
li t0, 12c5     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 134c
li a0, 9
jal ra, deduct_gas
li t0, 134c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1313
li a0, 9
jal ra, deduct_gas
li t0, 1313     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 135d
li a0, 9
jal ra, deduct_gas
li t0, 135d     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0c51
li a0, 9
jal ra, deduct_gas
li t0, 0c51     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 1367
li a0, 9
jal ra, deduct_gas
li t0, 1367     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ebd
li a0, 9
jal ra, deduct_gas
li t0, 0ebd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -5 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 1377
li a0, 9
jal ra, deduct_gas
li t0, 1377     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# PUSH2 0c6b
li a0, 9
jal ra, deduct_gas
li t0, 0c6b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH2 1380
li a0, 9
jal ra, deduct_gas
li t0, 1380     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0a20
li a0, 9
jal ra, deduct_gas
li t0, 0a20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -4 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 60
li a0, 6
jal ra, deduct_gas
li t0, 60     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 13a3
li a0, 9
jal ra, deduct_gas
li t0, 13a3     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP7 
li a0, 10
jal ra, deduct_gas
addi t0, s3, -7  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1353
li a0, 9
jal ra, deduct_gas
li t0, 1353     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 13b7
li a0, 9
jal ra, deduct_gas
li t0, 13b7     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP6 
li a0, 9
jal ra, deduct_gas
addi t0, s3, -6  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1353
li a0, 9
jal ra, deduct_gas
li t0, 1353     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 13c6
li a0, 9
jal ra, deduct_gas
li t0, 13c6     # Push value onto stack
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
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# DUP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -5  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0e18
li a0, 9
jal ra, deduct_gas
li t0, 0e18     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP5 
li a0, 8
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -6 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -5 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X4E 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X4E
# PUSH16 2066756e647320617661696c61626c65
li a0, 51
jal ra, deduct_gas
li t0, 2066756e647320617661696c61626c65     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# SHA3 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: SHA3
addi s3, s3, -1 # Adjust stack for unimplemented opcode
# PUSH7 6f722077697468
li a0, 24
jal ra, deduct_gas
li t0, 6f722077697468     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH5 726177615f
li a0, 18
jal ra, deduct_gas
li t0, 726177615f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH13 00000000000000000000000000
li a0, 42
jal ra, deduct_gas
li t0, 00000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1428
li a0, 9
jal ra, deduct_gas
li t0, 1428     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 21
li a0, 6
jal ra, deduct_gas
li t0, 21     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ebd
li a0, 9
jal ra, deduct_gas
li t0, 0ebd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 1433
li a0, 9
jal ra, deduct_gas
li t0, 1433     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 13ce
li a0, 9
jal ra, deduct_gas
li t0, 13ce     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 1455
li a0, 9
jal ra, deduct_gas
li t0, 1455     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 141c
li a0, 9
jal ra, deduct_gas
li t0, 141c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH10 746864726177616c2066
li a0, 33
jal ra, deduct_gas
li t0, 746864726177616c2066     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 696c
li a0, 9
jal ra, deduct_gas
li t0, 696c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH6 640000000000
li a0, 21
jal ra, deduct_gas
li t0, 640000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1490
li a0, 9
jal ra, deduct_gas
li t0, 1490     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 11
li a0, 6
jal ra, deduct_gas
li t0, 11     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ebd
li a0, 9
jal ra, deduct_gas
li t0, 0ebd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 149b
li a0, 9
jal ra, deduct_gas
li t0, 149b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 145c
li a0, 9
jal ra, deduct_gas
li t0, 145c     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 14bd
li a0, 9
jal ra, deduct_gas
li t0, 14bd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1484
li a0, 9
jal ra, deduct_gas
li t0, 1484     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# UNKNOWN_0X4D 
li a0, 3
jal ra, deduct_gas
# Unimplemented opcode: UNKNOWN_0X4D
# PUSH10 6e696d756d2070726963
li a0, 33
jal ra, deduct_gas
li t0, 6e696d756d2070726963     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH6 206d75737420
li a0, 21
jal ra, deduct_gas
li t0, 206d75737420     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH3 652067
li a0, 12
jal ra, deduct_gas
li t0, 652067     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH19 65617465722074685f8201527f616e207a6572
li a0, 60
jal ra, deduct_gas
li t0, 65617465722074685f8201527f616e207a6572     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH16 00000000000000000000000000000000
li a0, 51
jal ra, deduct_gas
li t0, 00000000000000000000000000000000     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# STOP 
# Unimplemented opcode: STOP
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 151e
li a0, 9
jal ra, deduct_gas
li t0, 151e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 27
li a0, 6
jal ra, deduct_gas
li t0, 27     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ebd
li a0, 9
jal ra, deduct_gas
li t0, 0ebd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 1529
li a0, 9
jal ra, deduct_gas
li t0, 1529     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 14c4
li a0, 9
jal ra, deduct_gas
li t0, 14c4     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 40
li a0, 6
jal ra, deduct_gas
li t0, 40     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 154b
li a0, 9
jal ra, deduct_gas
li t0, 154b     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1512
li a0, 9
jal ra, deduct_gas
li t0, 1512     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# DUP0 
li a0, 3
jal ra, deduct_gas
addi t0, s3, -0  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
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
# PUSH6 656e7472616e
li a0, 21
jal ra, deduct_gas
li t0, 656e7472616e     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH4 79477561
li a0, 15
jal ra, deduct_gas
li t0, 79477561     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH19 643a207265656e7472616e742063616c6c005f
li a0, 60
jal ra, deduct_gas
li t0, 643a207265656e7472616e742063616c6c005f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1586
li a0, 9
jal ra, deduct_gas
li t0, 1586     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 1f
li a0, 6
jal ra, deduct_gas
li t0, 1f     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 0ebd
li a0, 9
jal ra, deduct_gas
li t0, 0ebd     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# PUSH2 1591
li a0, 9
jal ra, deduct_gas
li t0, 1591     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 1552
li a0, 9
jal ra, deduct_gas
li t0, 1552     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# PUSH1 20
li a0, 6
jal ra, deduct_gas
li t0, 20     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP3 
li a0, 6
jal ra, deduct_gas
addi t0, s3, -3  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# SUB 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
sub  t3, t1, t2    # Subtract values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Increment stack pointer
# PUSH0 
li a0, 3
jal ra, deduct_gas
li t0, 0     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP4 
li a0, 7
jal ra, deduct_gas
addi t0, s3, -4  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# ADD 
li a0, 3
jal ra, deduct_gas
addi s3, s3, -2    # Pop two values
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load first value
lw   t2, 4(t0)     # Load second value
add  t3, t1, t2    # Add values
sw   t3, 0(t0)     # Store result
addi s3, s3, 1     # Adjust stack pointer
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
# PUSH2 15b3
li a0, 9
jal ra, deduct_gas
li t0, 15b3     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# DUP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -2  # Calculate dup index
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t0, s2, t0    # Get stack address
lw   t1, 0(t0)     # Load value from stack
slli t0, s3, 2     # Calculate current stack pointer
add  t0, s2, t0    # Get current stack address
sw   t1, 0(t0)     # Store duplicated value
addi s3, s3, 1     # Increment stack pointer
# PUSH2 157a
li a0, 9
jal ra, deduct_gas
li t0, 157a     # Push value onto stack
slli t1, s3, 2     # Calculate stack offset
add  t1, s2, t1    # Get stack address
sw   t0, 0(t1)     # Store value to stack
addi s3, s3, 1     # Increment stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# JUMPDEST 
li a0, 3
jal ra, deduct_gas
jumpdest_0:
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# SWAP2 
li a0, 5
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -3 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# SWAP1 
li a0, 4
jal ra, deduct_gas
addi t0, s3, -1    # Top of stack
addi t1, s3, -2 # Swap target
slli t0, t0, 2     # Multiply by 4
slli t1, t1, 2     # Multiply by 4
add  t0, s2, t0    # Get top address
add  t1, s2, t1    # Get target address
lw   t2, 0(t0)     # Load top value
lw   t3, 0(t1)     # Load target value
sw   t3, 0(t0)     # Store target at top
sw   t2, 0(t1)     # Store top at target
# POP 
li a0, 2
jal ra, deduct_gas
addi s3, s3, -1    # Decrement stack pointer
# JUMP 
li a0, 8
jal ra, deduct_gas
addi s3, s3, -1    # Pop jump target
slli t0, s3, 2     # Calculate stack offset
add  t0, s2, t0    # Get stack address
lw   t0, 0(t0)     # Load jump target
la   t1, jumpdest_table # Load jump table
slli t0, t0, 2     # Multiply by 4 for word alignment
add  t1, t1, t0    # Calculate jump address
lw   t1, 0(t1)     # Load actual address
jr   t1            # Jump to target
# INVALID 
# Unimplemented opcode: INVALID
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