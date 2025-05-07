import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RISCVEmitter:
    def __init__(self, register_allocator=None, memory_model=None):
        """
        Initializes the RISCVEmitter.
        Args:
            register_allocator: Optional register allocator for managing registers.
            memory_model: Optional memory model for memory interactions.
        """
        self.instructions = []
        self.label_counter = 0
        self.register_allocator = register_allocator
        self.memory_model = memory_model

    def emit(self, instr):
        """Appends an instruction to the instruction list."""
        self.instructions.append(instr)
        logger.debug(f"Emitted: {instr}")

    def emit_comment(self, comment):
        """Adds a comment to the instruction list."""
        self.instructions.append(f"# {comment}")
        logger.debug(f"Comment: {comment}")

    def emit_label(self, label=None):
        """Emits a unique or given label."""
        if label is None:
            label = f"L{self.label_counter}"
            self.label_counter += 1
        self.instructions.append(f"{label}:")
        logger.debug(f"Label: {label}")
        return label

    def emit_load_immediate(self, dest_reg, value):
        """Emits an instruction to load an immediate value into a register."""
        self.emit(f"li {dest_reg}, {value}")
        logger.debug(f"Load Immediate: {dest_reg} = {value}")

    def emit_load(self, dest_reg, addr_reg, offset=0):
        """Emits a load word instruction."""
        self.emit(f"lw {dest_reg}, {offset}({addr_reg})")
        logger.debug(f"Load: {dest_reg} = MEM[{addr_reg} + {offset}]")

    def emit_store(self, src_reg, addr_reg, offset=0):
        """Emits a store word instruction."""
        self.emit(f"sw {src_reg}, {offset}({addr_reg})")
        logger.debug(f"Store: MEM[{addr_reg} + {offset}] = {src_reg}")

    def emit_add(self, dest, src1, src2):
        """Emits an add instruction."""
        self.emit(f"add {dest}, {src1}, {src2}")
        logger.debug(f"Add: {dest} = {src1} + {src2}")

    def emit_sub(self, dest, src1, src2):
        """Emits a subtract instruction."""
        self.emit(f"sub {dest}, {src1}, {src2}")
        logger.debug(f"Sub: {dest} = {src1} - {src2}")

    def emit_mul(self, dest, src1, src2):
        """Emits a multiply instruction."""
        self.emit(f"mul {dest}, {src1}, {src2}")
        logger.debug(f"Mul: {dest} = {src1} * {src2}")

    def emit_div(self, dest, src1, src2):
        """Emits a divide instruction."""
        self.emit(f"div {dest}, {src1}, {src2}")
        logger.debug(f"Div: {dest} = {src1} / {src2}")

    def emit_rem(self, dest, src1, src2):
        """Emits a remainder instruction."""
        self.emit(f"rem {dest}, {src1}, {src2}")
        logger.debug(f"Rem: {dest} = {src1} % {src2}")

    def emit_arithmetic(self, op, dest, src1, src2):
        """Emits a generic arithmetic operation."""
        self.emit(f"{op} {dest}, {src1}, {src2}")
        logger.debug(f"Arithmetic: {op} {dest}, {src1}, {src2}")

    def emit_jump(self, label):
        """Emits an unconditional jump."""
        self.emit(f"j {label}")
        logger.debug(f"Jump to: {label}")

    def emit_conditional_jump(self, condition_reg, label):
        """Emits a conditional jump if condition_reg is zero."""
        self.emit(f"beq {condition_reg}, zero, {label}")
        logger.debug(f"Conditional Jump: if {condition_reg} == 0 -> {label}")

    def emit_branch_eq(self, reg1, reg2, label):
        """Emits a branch if reg1 == reg2."""
        self.emit(f"beq {reg1}, {reg2}, {label}")
        logger.debug(f"Branch EQ: if {reg1} == {reg2} -> {label}")

    def emit_branch_ne(self, reg1, reg2, label):
        """Emits a branch if reg1 != reg2."""
        self.emit(f"bne {reg1}, {reg2}, {label}")
        logger.debug(f"Branch NE: if {reg1} != {reg2} -> {label}")

    def emit_branch_lt(self, reg1, reg2, label):
        """Emits a branch if reg1 < reg2."""
        self.emit(f"blt {reg1}, {reg2}, {label}")
        logger.debug(f"Branch LT: if {reg1} < {reg2} -> {label}")

    def emit_branch_le(self, reg1, reg2, label):
        """Emits a branch if reg1 <= reg2."""
        self.emit(f"ble {reg1}, {reg2}, {label}")
        logger.debug(f"Branch LE: if {reg1} <= {reg2} -> {label}")

    def emit_branch_gt(self, reg1, reg2, label):
        """Emits a branch if reg1 > reg2."""
        self.emit(f"bgt {reg1}, {reg2}, {label}")
        logger.debug(f"Branch GT: if {reg1} > {reg2} -> {label}")

    def emit_branch_ge(self, reg1, reg2, label):
        """Emits a branch if reg1 >= reg2."""
        self.emit(f"bge {reg1}, {reg2}, {label}")
        logger.debug(f"Branch GE: if {reg1} >= {reg2} -> {label}")

    def emit_syscall(self):
        """Emits a system call."""
        self.emit("ecall")
        logger.debug("Syscall (ecall) emitted")

    def emit_return(self):
        """Emits a return from function."""
        self.emit("ret")
        logger.debug("Return (ret) emitted")

    def emit_code(self):
        """Returns the full emitted code as a string."""
        return "\n".join(self.instructions)

    def get_code(self):
        """Alias for emit_code()."""
        return self.emit_code()

    def reset(self):
        """Resets the emitter's state."""
        self.instructions = []
        self.label_counter = 0
        logger.info("Emitter state reset")

    def emit_storage_load(self, dest_reg, key_reg):
        """Emulate SLOAD operation"""
        self.emit(f"# SLOAD implementation")
        self.emit(f"mv a0, {key_reg}")
        self.emit(f"call storage_load")
        self.emit(f"mv {dest_reg}, a0")

    def emit_storage_store(self, value_reg, key_reg):
        """Emulate SSTORE operation"""
        self.emit(f"# SSTORE implementation")
        self.emit(f"mv a0, {key_reg}")
        self.emit(f"mv a1, {value_reg}")
        self.emit(f"call storage_store")

    def emit_call_data_load(self, dest_reg, offset_reg):
        """Emulate CALLDATALOAD operation"""
        self.emit(f"# CALLDATALOAD implementation")
        self.emit(f"mv a0, {offset_reg}")
        self.emit(f"call read_call_data")
        self.emit(f"mv {dest_reg}, a0")

    def emit_code_copy(self, dest_reg, offset_reg, size_reg):
        """Emulate CODECOPY operation"""
        self.emit(f"# CODECOPY implementation")
        self.emit(f"mv a0, {dest_reg}")
        self.emit(f"mv a1, {offset_reg}")
        self.emit(f"mv a2, {size_reg}")
        self.emit(f"call code_copy")

    def emit_return(self, offset_reg, size_reg):
        """Emulate RETURN operation"""
        self.emit(f"# RETURN implementation")
        self.emit(f"mv a0, {offset_reg}")
        self.emit(f"mv a1, {size_reg}")
        self.emit(f"call return_data")
