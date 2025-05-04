import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RISCVEmitter:
    def __init__(self, register_allocator=None, memory_model=None):
        self.instructions = []
        self.label_counter = 0
        self.register_allocator = register_allocator
        self.memory_model = memory_model

    def emit(self, instr):
        self.instructions.append(instr)
        logger.debug(f"Emitted: {instr}")

    def emit_comment(self, comment):
        self.instructions.append(f"# {comment}")
        logger.debug(f"Comment: {comment}")

    def emit_label(self, label=None):
        if label is None:
            label = f"L{self.label_counter}"
            self.label_counter += 1
        self.instructions.append(f"{label}:")
        logger.debug(f"Label: {label}")
        return label

    def emit_load_immediate(self, dest_reg, value):
        self.emit(f"li {dest_reg}, {value}")
        logger.debug(f"Load Immediate: {dest_reg} = {value}")

    def emit_load(self, dest_reg, addr_reg, offset=0):
        self.emit(f"lw {dest_reg}, {offset}({addr_reg})")
        logger.debug(f"Load: {dest_reg} = MEM[{addr_reg} + {offset}]")

    def emit_store(self, src_reg, addr_reg, offset=0):
        self.emit(f"sw {src_reg}, {offset}({addr_reg})")
        logger.debug(f"Store: MEM[{addr_reg} + {offset}] = {src_reg}")

    def emit_add(self, dest, src1, src2):
        self.emit(f"add {dest}, {src1}, {src2}")
        logger.debug(f"Add: {dest} = {src1} + {src2}")

    def emit_sub(self, dest, src1, src2):
        self.emit(f"sub {dest}, {src1}, {src2}")
        logger.debug(f"Sub: {dest} = {src1} - {src2}")

    def emit_mul(self, dest, src1, src2):
        self.emit(f"mul {dest}, {src1}, {src2}")
        logger.debug(f"Mul: {dest} = {src1} * {src2}")

    def emit_div(self, dest, src1, src2):
        self.emit(f"div {dest}, {src1}, {src2}")
        logger.debug(f"Div: {dest} = {src1} / {src2}")

    def emit_rem(self, dest, src1, src2):
        self.emit(f"rem {dest}, {src1}, {src2}")
        logger.debug(f"Rem: {dest} = {src1} % {src2}")

    def emit_arithmetic(self, op, dest, src1, src2):
        self.emit(f"{op} {dest}, {src1}, {src2}")
        logger.debug(f"Arithmetic: {op} {dest}, {src1}, {src2}")

    def emit_jump(self, label):
        self.emit(f"j {label}")
        logger.debug(f"Jump to: {label}")

    def emit_conditional_jump(self, condition_reg, label):
        self.emit(f"beq {condition_reg}, zero, {label}")
        logger.debug(f"Conditional Jump: if {condition_reg} == 0 -> {label}")

    def emit_branch_eq(self, reg1, reg2, label):
        self.emit(f"beq {reg1}, {reg2}, {label}")
        logger.debug(f"Branch EQ: if {reg1} == {reg2} -> {label}")

    def emit_branch_ne(self, reg1, reg2, label):
        self.emit(f"bne {reg1}, {reg2}, {label}")
        logger.debug(f"Branch NE: if {reg1} != {reg2} -> {label}")

    def emit_branch_lt(self, reg1, reg2, label):
        self.emit(f"blt {reg1}, {reg2}, {label}")
        logger.debug(f"Branch LT: if {reg1} < {reg2} -> {label}")

    def emit_branch_le(self, reg1, reg2, label):
        self.emit(f"ble {reg1}, {reg2}, {label}")
        logger.debug(f"Branch LE: if {reg1} <= {reg2} -> {label}")

    def emit_branch_gt(self, reg1, reg2, label):
        self.emit(f"bgt {reg1}, {reg2}, {label}")
        logger.debug(f"Branch GT: if {reg1} > {reg2} -> {label}")

    def emit_branch_ge(self, reg1, reg2, label):
        self.emit(f"bge {reg1}, {reg2}, {label}")
        logger.debug(f"Branch GE: if {reg1} >= {reg2} -> {label}")

    def emit_syscall(self):
        self.emit("ecall")
        logger.debug("Syscall (ecall) emitted")

    def emit_return(self):
        self.emit("ret")
        logger.debug("Return (ret) emitted")

    def emit_code(self):
        return "\n".join(self.instructions)

    def get_code(self):
        return self.emit_code()

    def reset(self):
        self.instructions = []
        self.label_counter = 0
        logger.info("Emitter state reset")
