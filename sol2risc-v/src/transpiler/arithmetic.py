class EVMArithmetic:
    @staticmethod
    def emit_arithmetic_ops(emitter):
        emitter.emit("""
        addmod_impl:
            # Input: a0, a1 = operands, a2 = modulus
            add t0, a0, a1
            rem a0, t0, a2
            ret

        mulmod_impl:
            # Input: a0, a1 = operands, a2 = modulus
            mul t0, a0, a1
            rem a0, t0, a2
            ret

        exp_impl:
            # Input: a0 = base, a1 = exponent
            li t0, 1          # result
            beqz a1, exp_end
        exp_loop:
            mul t0, t0, a0
            addi a1, a1, -1
            bnez a1, exp_loop
        exp_end:
            mv a0, t0
            ret
        """)
