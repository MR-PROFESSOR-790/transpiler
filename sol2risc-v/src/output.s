
        .section .data
            .align 3
        memory_area:     .space 65536    # EVM memory
        storage_area:    .space 65536    # Storage
        calldata_area:   .space 4096     # Calldata
        returndata:      .space 4096     # Return data
        event_buffer:    .space 8192     # Event logs
        
        .section .text
            .align 2
            .global _start
            
        _start:
            # Runtime setup
            addi sp, sp, -1024
            sd ra, 1016(sp)
            sd s0, 1008(sp)
            addi s0, sp, 1024
            
            # Initialize pointers and counters
            la s1, memory_area      # s1 = memory base
            la s2, storage_area     # s2 = storage base
            la s3, calldata_area    # s3 = calldata base
            la s4, returndata       # s4 = return data
            la s5, event_buffer     # s5 = event buffer
            li s11, 1000000        # Initial gas limit
            
        # Error handlers and common operations
        

        # Memory operations
        mstore_impl:
            add t0, s1, a0        # memory base + offset
            sd a1, 0(t0)          # store value
            ret
            
        mload_impl:
            add t0, s1, a0        # memory base + offset
            ld a0, 0(t0)          # load value
            ret
            
        # Storage operations
        sstore_impl:
            slli t0, a0, 3        # multiply key by 8
            add t0, s2, t0        # storage base + offset
            ld t1, 0(t0)          # load old value
            beq t1, a1, skip_store # skip if unchanged
            sd a1, 0(t0)          # store new value
        skip_store:
            ret
            
        sload_impl:
            slli t0, a0, 3        # multiply key by 8
            add t0, s2, t0        # storage base + offset
            ld a0, 0(t0)          # load value
            ret
            
        # Gas checking
        check_gas:
            sub t0, s11, a0       # subtract required gas
            bltz t0, out_of_gas   # branch if negative
            mv s11, t0            # update gas counter
            ret
            
        # Error handlers
        out_of_gas:
            li a0, 2              # out of gas error code
            j revert_handler
            
        revert_handler:
            li a7, 93             # exit syscall
            ecall
        

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 128        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 64        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # value
                addi sp, sp, 8
                ld a0, 0(sp)          # offset
                addi sp, sp, 8
                jal mstore_impl
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_callvalue t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_dup1 t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_iszero t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 14        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                # Conditional jump
                ld t1, 0(sp)          # condition
                addi sp, sp, 8
                ld t0, 0(sp)          # destination
                addi sp, sp, 8
                beqz t1, skip_a   # if condition is 0, skip jump
                j L_a           # jump to destination
            skip_a:
            

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, None        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_dup1 t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_revert t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            
L_e:

            li a0, 3         # gas cost
            jal check_gas
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_pop t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 62        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_dup1 t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 26        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, None        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_codecopy t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, None        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_return t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                invalid t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 128        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 64        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # value
                addi sp, sp, 8
                ld a0, 0(sp)          # offset
                addi sp, sp, 8
                jal mstore_impl
            

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, None        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_dup1 t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_revert t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                invalid t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

            # LOG2 operation
            mv a2, 2       # number of topics
            ld a1, 0(sp)         # size
            addi sp, sp, 8
            ld a0, 0(sp)         # offset
            addi sp, sp, 8
            jal log_impl         # call log implementation
        

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 452857328472        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 2a: UNKNOWN_0x22

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                slt t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

            ld a1, 0(sp)          # size
            addi sp, sp, 8
            ld a0, 0(sp)          # offset
            addi sp, sp, 8
            jal ra, sha3_impl     # call SHA3 implementation
            addi sp, sp, -8
            sd a0, 0(sp)          # push result
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_timestamp t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 2e: UNKNOWN_0xc2

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 2f: UNKNOWN_0x4d
L_30:

            li a0, 3         # gas cost
            jal check_gas
        

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 31: UNKNOWN_0xdf
L_32:

            li a0, 3         # gas cost
            jal check_gas
        

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 33: UNKNOWN_0xc5

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_pop t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 35: UNKNOWN_0x2b

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 36: UNKNOWN_0xd2

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_not t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 38: UNKNOWN_0xab

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 39: UNKNOWN_0x0c

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 3a: UNKNOWN_0x2a

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                msize t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 3c: UNKNOWN_0xf7

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 3d: UNKNOWN_0xed

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_call t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_dup9 t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 40: UNKNOWN_0xd8

            li a0, 3         # gas cost
            jal check_gas
        

            # CREATE operation
            ld a2, 0(sp)         # value
            addi sp, sp, 8
            ld a1, 0(sp)         # offset
            addi sp, sp, 8
            ld a0, 0(sp)         # size
            addi sp, sp, 8
            jal create_impl      # call create implementation
            addi sp, sp, -8
            sd a0, 0(sp)        # push created address
        

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                msize t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        

                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                custom_swap7 t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            

            li a0, 3         # gas cost
            jal check_gas
        
    # Unknown opcode at 44: UNKNOWN_0xa9

            li a0, 3         # gas cost
            jal check_gas
        

            li t0, 1414600261370298344297501822032665984025284281532778639523840        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        