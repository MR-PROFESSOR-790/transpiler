class EVMInstructionMapper:
    def __init__(self, emitter):
        self.emitter = emitter
        self.mappings = {
            'ADD': self._emit_arithmetic('add'),
            'SUB': self._emit_arithmetic('sub'),
            'MUL': self._emit_arithmetic('mul'),
            'DIV': self._emit_arithmetic('divu'),
            'SDIV': self._emit_arithmetic('div'),
            'AND': self._emit_arithmetic('and'),
            'OR': self._emit_arithmetic('or'),
            'XOR': self._emit_arithmetic('xor'),
            'SHL': self._emit_shift('sll'),
            'SHR': self._emit_shift('srl'),
            'SAR': self._emit_shift('sra'),
        }

    def _emit_arithmetic(self, op):
        """Generate RISC-V arithmetic operations"""
        return f"""
            ld a1, 0(sp)     # Load second operand
            addi sp, sp, 8
            ld a0, 0(sp)     # Load first operand
            addi sp, sp, 8
            {op} a0, a0, a1  # Perform operation
            addi sp, sp, -8
            sd a0, 0(sp)     # Push result
        """
