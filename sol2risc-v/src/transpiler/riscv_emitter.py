# riscv_emitter.py - Emits RISC-V assembly code based on parsed EVM instructions
import os
import logging
from typing import List, Dict, Any


class RiscvEmitter:
    """
    Class responsible for emitting RISC-V assembly from EVM IR.
    Handles:
    - Function prologue/epilogue
    - Instruction translation
    - Runtime calls
    - Gas metering
    - Stack emulation
    - Output formatting and file writing
    """

    def __init__(self):
        """Initialize emitter with optional context."""
        self.context = None
        self.output_lines = []
        self.current_function = None
        self.unknown_opcodes = set()
        self.invalid_opcodes = set()
        self.warnings = []
        self.errors = []
        self.runtime_signatures = {}

    def set_context(self, context):
        """Set compilation context."""
        self.context = context
        self._init_dependencies()

    def _init_dependencies(self):
        """Initialize emitter dependencies."""
        if self.context is None:
            return

        try:
            from .register_allocator import RegisterAllocator
            from .gas_costs import GasCostCalculator

            # Create instances of dependencies
            self.register_allocator = RegisterAllocator()
            self.register_allocator.set_context(self.context)
            self.gas_calculator = GasCostCalculator()
            self.gas_calculator.set_context(self.context)

            # Bind methods
            self.allocate_registers_for_instruction = self.register_allocator.allocate_registers_for_instruction
            self.calculate_gas_cost = self.gas_calculator.calculate_gas_cost
            self.deduct_gas = self.gas_calculator.deduct_gas

            # Initialize runtime signatures
            self.runtime_signatures = self._parse_runtime_signature()

            logging.debug("Emitter dependencies initialized")
        except Exception as e:
            logging.warning(f"Failed to load emitter dependencies: {str(e)}")

    def emit_riscv_assembly(self, ir_representation: list, output_file: str = None):
        """
        Main function to emit RISC-V assembly from IR.
        
        Args:
            ir_representation (list): List of instruction dictionaries
            output_file (str): Optional file to write output to
            
        Returns:
            str: Final formatted RISC-V assembly
        """
        try:
            logging.debug("Starting RISC-V emission...")
            if not ir_representation:
                raise ValueError("Empty IR representation provided")

            prologue = self.emit_function_prologue(self.context.function_info)
            epilogue = self.emit_function_epilogue(self.context.function_info)
            body_code = []

            for instr in ir_representation:
                lines = self.emit_instruction_sequence([instr])
                body_code.extend(lines)

            full_assembly = prologue + body_code + epilogue
            formatted = self.format_assembly_output(full_assembly)

            if output_file:
                self.write_output_file(formatted, output_file)
                logging.debug(f"Successfully wrote assembly to {output_file}")

            return formatted
        except Exception as e:
            logging.error(f"Error during RISC-V assembly emission: {str(e)}", exc_info=True)
            raise

    def emit_function_prologue(self, function_info):
        """
        Emit function prologue boilerplate.
        
        Args:
            function_info (dict): Metadata about function entry
            
        Returns:
            list[str]: Prologue assembly lines
        """
        logging.info(f"Emitting prologue for {function_info['name']}")
        return [
            f".globl {function_info['name']}",
            f"{function_info['name']}:",
            "addi sp, sp, -32",      # Reserve stack space
            "sw   ra, 28(sp)",       # Save return address
            "sw   s0, 24(sp)",       # Save saved registers
            "sw   s1, 20(sp)",
            "sw   s2, 16(sp)",
            "sw   s3, 12(sp)",
            "sw   s4, 8(sp)",
            "sw   s5, 4(sp)",
            "sw   s6, 0(sp)",
            "li   s0, 0x10000000",   # MEM_BASE base address
            "li   s1, 0",            # Initialize gas counter
            "la   s2, evm_stack",    # EVM stack base
            "li   s3, 0",            # EVM stack pointer
        ]

    def emit_function_epilogue(self, function_info):
        """
        Emit function epilogue boilerplate.
        
        Args:
            function_info (dict): Metadata about function exit
            
        Returns:
            list[str]: Epilogue assembly lines
        """
        logging.info(f"Emitting epilogue for {function_info['name']}")
        return [
            "lw   ra, 28(sp)",       # Restore return address
            "lw   s0, 24(sp)",       # Restore saved registers
            "lw   s1, 20(sp)",
            "lw   s2, 16(sp)",
            "lw   s3, 12(sp)",
            "lw   s4, 8(sp)",
            "lw   s5, 4(sp)",
            "lw   s6, 0(sp)",
            "addi sp, sp, 32",       # Deallocate stack
            "jr   ra",               # Return
            "",                       # Extra line for section switch
            ".section .bss",
            ".align 4",
            "evm_stack: .space 4096", # Reserve 1KB for EVM stack
            ".section .text"          # Return to text section
        ]

    def emit_instruction_sequence(self, instructions: list) -> List[str]:
        """
        Translate a sequence of EVM instructions into RISC-V instructions.
        
        Args:
            instructions (list): List of EVM instructions
            
        Returns:
            list[str]: Generated RISC-V assembly lines
        """
        riscv_lines = []

        for instr in instructions:
            opcode = instr["opcode"]
            offset = instr.get("offset", "")

            # Add offset label if present
            if offset:
                riscv_lines.append(f"{offset:04x}:")

            # Add comment showing original instruction
            args = ' '.join(instr.get('args', []))
            riscv_lines.append(f"# {opcode} {args}")

            # Deduct gas cost if available
            gas_line = self.emit_gas_cost(opcode)
            if gas_line:
                riscv_lines.append(gas_line)

            # Handle JUMPDEST
            if opcode == "JUMPDEST":
                label = f"jumpdest_{instr.get('index', 0)}"
                riscv_lines.append(f"{label}:")
                continue

            # Handle special runtime functions
            if opcode in ["KECCAK256", "CALLDATACOPY", "CODECOPY"]:
                reg_alloc = self.allocate_registers_for_instruction(instr, self.context)
                args = {
                    "size": reg_alloc.get("size"),
                    "offset": reg_alloc.get("offset")
                }
                riscv_lines.extend(self.emit_runtime_calls(opcode.lower(), args))
                continue

            # Stack operations
            if opcode.startswith("PUSH"):
                val = instr.get("value", "0")
                riscv_lines.append(f"# PUSH {val}")
                riscv_lines.append(f"li t0, {val}            # Load value")
                riscv_lines.append(f"slli t1, s3, 5          # Stack offset = s3 * 32")
                riscv_lines.append(f"add  t1, s2, t1         # Address = stack base + offset")
                riscv_lines.append(f"sd   t0, 0(t1)          # Store limb0")
                riscv_lines.append(f"sd   zero, 8(t1)        # limb1 = 0")
                riscv_lines.append(f"sd   zero, 16(t1)       # limb2 = 0")
                riscv_lines.append(f"sd   zero, 24(t1)       # limb3 = 0")
                riscv_lines.append(f"addi s3, s3, 1          # Increment stack pointer")
                continue

            elif opcode == "POP":
                riscv_lines.append(f"addi s3, s3, -1    # Decrement stack pointer")
                continue

            elif opcode.startswith("DUP"):
                n = int(opcode[3:])
                riscv_lines.append(f"# DUP{n}")
                riscv_lines.append(f"addi t0, s3, -{n}       # Index to duplicate")
                riscv_lines.append(f"slli t0, t0, 5          # Offset = t0 * 32")
                riscv_lines.append(f"add  t0, s2, t0         # Src address")
                riscv_lines.append(f"slli t1, s3, 5          # Dest offset = s3 * 32")
                riscv_lines.append(f"add  t1, s2, t1         # Dest address")
                riscv_lines.append(f"ld   t2, 0(t0)          # limb0")
                riscv_lines.append(f"ld   t3, 8(t0)          # limb1")
                riscv_lines.append(f"ld   t4, 16(t0)         # limb2")
                riscv_lines.append(f"ld   t5, 24(t0)         # limb3")
                riscv_lines.append(f"sd   t2, 0(t1)")
                riscv_lines.append(f"sd   t3, 8(t1)")
                riscv_lines.append(f"sd   t4, 16(t1)")
                riscv_lines.append(f"sd   t5, 24(t1)")
                riscv_lines.append(f"addi s3, s3, 1          # Push duplicate")
                continue

            elif opcode == "ADD":
                riscv_lines.append("# 256-bit ADD (4 limbs)")
                riscv_lines.append("addi s3, s3, -2        # Pop two 256-bit values")
                riscv_lines.append("slli t0, s3, 5         # Offset = s3 * 32")
                riscv_lines.append("add  t0, s2, t0        # Stack address for operand A and B")

                # Load limbs
                riscv_lines.append("ld t1, 0(t0)           # B limb0")
                riscv_lines.append("ld t2, 8(t0)           # B limb1")
                riscv_lines.append("ld t3, 16(t0)          # B limb2")
                riscv_lines.append("ld t4, 24(t0)          # B limb3")
                riscv_lines.append("ld t5, 32(t0)          # A limb0")
                riscv_lines.append("ld t6, 40(t0)          # A limb1")
                riscv_lines.append("ld t7, 48(t0)          # A limb2")
                riscv_lines.append("ld t8, 56(t0)          # A limb3")

                # Perform limb-wise ADD with carry
                riscv_lines.append("add s4, t1, t5         # sum0")
                riscv_lines.append("sltu s5, s4, t1        # carry0 = s4 < t1")

                riscv_lines.append("add s6, t2, t6         # sum1 = b1 + a1")
                riscv_lines.append("add s6, s6, s5         # sum1 += carry0")
                riscv_lines.append("sltu s5, s6, t2        # carry1")

                riscv_lines.append("add s7, t3, t7         # sum2 = b2 + a2")
                riscv_lines.append("add s7, s7, s5         # sum2 += carry1")
                riscv_lines.append("sltu s5, s7, t3        # carry2")

                riscv_lines.append("add s8, t4, t8         # sum3 = b3 + a3")
                riscv_lines.append("add s8, s8, s5         # sum3 += carry2")

                # Store result back to stack
                riscv_lines.append("sd s4, 0(t0)           # result limb0")
                riscv_lines.append("sd s6, 8(t0)           # result limb1")
                riscv_lines.append("sd s7, 16(t0)          # result limb2")
                riscv_lines.append("sd s8, 24(t0)          # result limb3")

                riscv_lines.append("addi s3, s3, 1         # Push result")
                continue
            

            elif opcode == "MUL":
                riscv_lines.append("# 256-bit MUL (schoolbook 4x4 = 8 limbs, store lowest 4)")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")

                # Load operands (A: t1-t4, B: t5-t8)
                riscv_lines.append("ld t1, 32(t0)      # A limb0")
                riscv_lines.append("ld t2, 40(t0)      # A limb1")
                riscv_lines.append("ld t3, 48(t0)      # A limb2")
                riscv_lines.append("ld t4, 56(t0)      # A limb3")

                riscv_lines.append("ld t5, 0(t0)       # B limb0")
                riscv_lines.append("ld t6, 8(t0)       # B limb1")
                riscv_lines.append("ld t7, 16(t0)      # B limb2")
                riscv_lines.append("ld t8, 24(t0)      # B limb3")

                # Compute: result = A * B, keep only lowest 4 limbs (128-bit)
                # Use intermediate result registers s0–s3
                riscv_lines.append("mul s0, t1, t5     # r0 = a0 * b0")
                riscv_lines.append("mul s1, t1, t6     # r1 = a0 * b1")
                riscv_lines.append("mul t9, t2, t5     # + a1 * b0")
                riscv_lines.append("add s1, s1, t9")

                riscv_lines.append("mul s2, t1, t7     # r2 = a0 * b2")
                riscv_lines.append("mul t9, t2, t6     # + a1 * b1")
                riscv_lines.append("add s2, s2, t9")
                riscv_lines.append("mul t9, t3, t5     # + a2 * b0")
                riscv_lines.append("add s2, s2, t9")

                riscv_lines.append("mul s3, t1, t8     # r3 = a0 * b3")
                riscv_lines.append("mul t9, t2, t7")
                riscv_lines.append("add s3, s3, t9")
                riscv_lines.append("mul t9, t3, t6")
                riscv_lines.append("add s3, s3, t9")
                riscv_lines.append("mul t9, t4, t5")
                riscv_lines.append("add s3, s3, t9")

                # Store back to stack (overwrite original location)
                riscv_lines.append("sd s0, 0(t0)")
                riscv_lines.append("sd s1, 8(t0)")
                riscv_lines.append("sd s2, 16(t0)")
                riscv_lines.append("sd s3, 24(t0)")

                riscv_lines.append("addi s3, s3, 1")
                continue

            elif opcode == "SUB":
                riscv_lines.append("# 256-bit SUB (4 limbs)")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")

                riscv_lines.append("ld t1, 0(t0)           # B limb0")
                riscv_lines.append("ld t2, 8(t0)           # B limb1")
                riscv_lines.append("ld t3, 16(t0)          # B limb2")
                riscv_lines.append("ld t4, 24(t0)          # B limb3")
                riscv_lines.append("ld t5, 32(t0)          # A limb0")
                riscv_lines.append("ld t6, 40(t0)          # A limb1")
                riscv_lines.append("ld t7, 48(t0)          # A limb2")
                riscv_lines.append("ld t8, 56(t0)          # A limb3")

                riscv_lines.append("sub s4, t5, t1         # res0 = a0 - b0")
                riscv_lines.append("sltu s5, t5, t1        # borrow0 = a0 < b0")

                riscv_lines.append("sub s6, t6, t2         # res1 = a1 - b1")
                riscv_lines.append("sub s6, s6, s5         # res1 -= borrow0")
                riscv_lines.append("sltu s5, t6, t2        # borrow1 = a1 < b1")
                riscv_lines.append("sltu a0, s6, s5")
                riscv_lines.append("or   s5, s5, a0")

                riscv_lines.append("sub s7, t7, t3")
                riscv_lines.append("sub s7, s7, s5")
                riscv_lines.append("sltu s5, t7, t3")
                riscv_lines.append("sltu a0, s7, s5")
                riscv_lines.append("or   s5, s5, a0")

                riscv_lines.append("sub s8, t8, t4")
                riscv_lines.append("sub s8, s8, s5")

                riscv_lines.append("sd s4, 0(t0)")
                riscv_lines.append("sd s6, 8(t0)")
                riscv_lines.append("sd s7, 16(t0)")
                riscv_lines.append("sd s8, 24(t0)")

                riscv_lines.append("addi s3, s3, 1")
                continue

            # Control flow
            elif opcode == "JUMP":
                riscv_lines.append("# JUMP - unconditional jump to JUMPDEST")
                riscv_lines.append("addi s3, s3, -1")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")
                riscv_lines.append("ld   t1, 0(t0)         # jump target")
                riscv_lines.append("slli t1, t1, 2         # index * 4")
                riscv_lines.append("la   t2, jumpdest_table")
                riscv_lines.append("add  t2, t2, t1")
                riscv_lines.append("lw   t3, 0(t2)         # actual label address")
                riscv_lines.append("jr   t3                # jump")
                continue

            elif opcode == "JUMPI":
                index = instr.get('index', 0)
                riscv_lines.append(f"# JUMPI - conditional jump if cond ≠ 0")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")
                riscv_lines.append("ld   t1, 0(t0)         # jump target")
                riscv_lines.append("ld   t2, 8(t0)         # condition")
                riscv_lines.append(f"beqz t2, jumpi_skip_{index}")
                riscv_lines.append("slli t1, t1, 2")
                riscv_lines.append("la   t3, jumpdest_table")
                riscv_lines.append("add  t3, t3, t1")
                riscv_lines.append("lw   t4, 0(t3)         # load label")
                riscv_lines.append("jr   t4")
                riscv_lines.append(f"jumpi_skip_{index}:")
                continue

            # Memory operations
            elif opcode == "MSTORE":
                riscv_lines.append("# MSTORE - store 256-bit word to memory")
                riscv_lines.append("addi s3, s3, -2              # Pop offset and value")
                riscv_lines.append("slli t0, s3, 5               # Stack offset = s3 * 32")
                riscv_lines.append("add  t0, s2, t0              # Address of value and offset")
                riscv_lines.append("ld   t1, 0(t0)               # offset")
                riscv_lines.append("ld   t2, 8(t0)               # val limb0")
                riscv_lines.append("ld   t3, 16(t0)              # val limb1")
                riscv_lines.append("ld   t4, 24(t0)              # val limb2")
                riscv_lines.append("ld   t5, 32(t0)              # val limb3")
                riscv_lines.append("add  t1, t1, s0              # effective addr = offset + MEM_BASE")
                riscv_lines.append("sd   t2, 0(t1)")
                riscv_lines.append("sd   t3, 8(t1)")
                riscv_lines.append("sd   t4, 16(t1)")
                riscv_lines.append("sd   t5, 24(t1)")
                continue
            
            elif opcode == "MSTORE8":
                riscv_lines.append("# MSTORE8 - store least significant byte to memory")
                riscv_lines.append("addi s3, s3, -2              # Pop offset and value")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")
                riscv_lines.append("ld   t1, 0(t0)               # offset")
                riscv_lines.append("ld   t2, 8(t0)               # value (only lowest byte matters)")
                riscv_lines.append("add  t1, t1, s0              # addr = offset + MEM_BASE")
                riscv_lines.append("andi t2, t2, 0xff            # Mask to 1 byte")
                riscv_lines.append("sb   t2, 0(t1)")
                continue

            elif opcode == "MLOAD":
                riscv_lines.append("# MLOAD - load 256-bit word from memory")
                riscv_lines.append("addi s3, s3, -1              # Pop offset")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")
                riscv_lines.append("ld   t1, 0(t0)               # offset")
                riscv_lines.append("add  t1, t1, s0              # addr = offset + MEM_BASE")
                riscv_lines.append("ld   t2, 0(t1)")
                riscv_lines.append("ld   t3, 8(t1)")
                riscv_lines.append("ld   t4, 16(t1)")
                riscv_lines.append("ld   t5, 24(t1)")
                riscv_lines.append("sd   t2, 0(t0)               # store back to stack")
                riscv_lines.append("sd   t3, 8(t0)")
                riscv_lines.append("sd   t4, 16(t0)")
                riscv_lines.append("sd   t5, 24(t0)")
                riscv_lines.append("addi s3, s3, 1")
                continue

            # Comparison operations
            elif opcode == "ISZERO":
                riscv_lines.append("# ISZERO - 256-bit check if value == 0")
                riscv_lines.append("addi s3, s3, -1")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")

                riscv_lines.append("ld t1, 0(t0)")
                riscv_lines.append("ld t2, 8(t0)")
                riscv_lines.append("ld t3, 16(t0)")
                riscv_lines.append("ld t4, 24(t0)")

                riscv_lines.append("or  s0, t1, t2")
                riscv_lines.append("or  s0, s0, t3")
                riscv_lines.append("or  s0, s0, t4")
                riscv_lines.append("seqz s0, s0")

                riscv_lines.append("sd   s0, 0(t0)")
                riscv_lines.append("sd   zero, 8(t0)")
                riscv_lines.append("sd   zero, 16(t0)")
                riscv_lines.append("sd   zero, 24(t0)")
                riscv_lines.append("addi s3, s3, 1")
                continue

            elif opcode == "EQ":
                riscv_lines.append("# EQ - 256-bit equality check")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")

                riscv_lines.append("ld t1, 0(t0)")
                riscv_lines.append("ld t2, 8(t0)")
                riscv_lines.append("ld t3, 16(t0)")
                riscv_lines.append("ld t4, 24(t0)")

                riscv_lines.append("ld t5, 32(t0)")
                riscv_lines.append("ld t6, 40(t0)")
                riscv_lines.append("ld t7, 48(t0)")
                riscv_lines.append("ld t8, 56(t0)")

                # XOR each limb and OR the results
                riscv_lines.append("xor s0, t1, t5")
                riscv_lines.append("xor s1, t2, t6")
                riscv_lines.append("xor s2, t3, t7")
                riscv_lines.append("xor s3, t4, t8")
                riscv_lines.append("or  s0, s0, s1")
                riscv_lines.append("or  s0, s0, s2")
                riscv_lines.append("or  s0, s0, s3")

                riscv_lines.append("seqz s0, s0            # if all zero => equal")
                riscv_lines.append("sd   s0, 0(t0)")
                riscv_lines.append("sd   zero, 8(t0)")
                riscv_lines.append("sd   zero, 16(t0)")
                riscv_lines.append("sd   zero, 24(t0)")
                riscv_lines.append("addi s3, s3, 1")
                continue
            
            elif opcode == "LT":
                riscv_lines.append("# LT - unsigned 256-bit less-than")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")

                # Compare from MSB to LSB
                for i, offset in enumerate([56, 48, 40, 32]):
                    riscv_lines.append(f"ld t1, {offset}(t0)   # a limb{3 - i}")
                    riscv_lines.append(f"ld t2, {offset - 32}(t0)  # b limb{3 - i}")
                    riscv_lines.append("blt t1, t2, lt_true")
                    riscv_lines.append("bgt t1, t2, lt_false")
                riscv_lines.append("li s0, 0")
                riscv_lines.append("j lt_done")
                riscv_lines.append("lt_true:")
                riscv_lines.append("li s0, 1")
                riscv_lines.append("j lt_done")
                riscv_lines.append("lt_false:")
                riscv_lines.append("li s0, 0")
                riscv_lines.append("lt_done:")
                riscv_lines.append("sd s0, 0(t0)")
                riscv_lines.append("sd zero, 8(t0)")
                riscv_lines.append("sd zero, 16(t0)")
                riscv_lines.append("sd zero, 24(t0)")
                riscv_lines.append("addi s3, s3, 1")
                continue
            
            elif opcode == "GT":
                riscv_lines.append("# GT - unsigned 256-bit greater-than")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")

                for i, offset in enumerate([56, 48, 40, 32]):
                    riscv_lines.append(f"ld t1, {offset - 32}(t0)   # a limb{3 - i}")
                    riscv_lines.append(f"ld t2, {offset}(t0)        # b limb{3 - i}")
                    riscv_lines.append("blt t1, t2, gt_true")
                    riscv_lines.append("bgt t1, t2, gt_false")
                riscv_lines.append("li s0, 0")
                riscv_lines.append("j gt_done")
                riscv_lines.append("gt_true:")
                riscv_lines.append("li s0, 1")
                riscv_lines.append("j gt_done")
                riscv_lines.append("gt_false:")
                riscv_lines.append("li s0, 0")
                riscv_lines.append("gt_done:")
                riscv_lines.append("sd s0, 0(t0)")
                riscv_lines.append("sd zero, 8(t0)")
                riscv_lines.append("sd zero, 16(t0)")
                riscv_lines.append("sd zero, 24(t0)")
                riscv_lines.append("addi s3, s3, 1")
                continue

            # External interactions
            elif opcode == "CALLVALUE":
                riscv_lines.append("# CALLVALUE - get call value (256-bit, low only)")
                riscv_lines.append("jal ra, get_call_value     # Assume it returns value in a0")
                riscv_lines.append("slli t1, s3, 5             # s3 * 32")
                riscv_lines.append("add  t1, s2, t1")
                riscv_lines.append("sd   a0, 0(t1)             # store in limb0")
                riscv_lines.append("sd   zero, 8(t1)")
                riscv_lines.append("sd   zero, 16(t1)")
                riscv_lines.append("sd   zero, 24(t1)")
                riscv_lines.append("addi s3, s3, 1             # Push 256-bit result")
                continue

            elif opcode == "RETURN":
                riscv_lines.append("# RETURN - exit and return memory slice")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")
                riscv_lines.append("ld   a0, 0(t0)         # offset")
                riscv_lines.append("ld   a1, 8(t0)         # length")
                riscv_lines.append("add  a0, a0, s0        # offset += MEM_BASE")
                riscv_lines.append("jal  ra, evm_return    # call runtime return function")
                continue

            elif opcode == "REVERT":
                riscv_lines.append("# REVERT - undo state and return error slice")
                riscv_lines.append("addi s3, s3, -2")
                riscv_lines.append("slli t0, s3, 5")
                riscv_lines.append("add  t0, s2, t0")
                riscv_lines.append("ld   a0, 0(t0)         # offset")
                riscv_lines.append("ld   a1, 8(t0)         # length")
                riscv_lines.append("add  a0, a0, s0        # offset += MEM_BASE")
                riscv_lines.append("jal  ra, evm_revert    # call runtime revert function")
                continue

            elif opcode == "CODECOPY":
                riscv_lines.append(f"addi s3, s3, -3    # Pop dest, source, size")
                riscv_lines.append(f"slli t0, s3, 2     # Calculate stack offset")
                riscv_lines.append(f"add  t0, s2, t0    # Get stack address")
                riscv_lines.append(f"lw   a0, 0(t0)     # Load dest offset")
                riscv_lines.append(f"lw   a1, 4(t0)     # Load src offset")
                riscv_lines.append(f"lw   a2, 8(t0)     # Load size")
                riscv_lines.append(f"add  a0, s0, a0    # Add memory base to dest")
                riscv_lines.append(f"jal  ra, evm_codecopy # Call codecopy function")
                riscv_lines.append(f"addi s3, s3, 3")
                continue
            
            elif opcode.startswith("SWAP"):
                n = int(opcode[4:])
                riscv_lines.append(f"# SWAP{n}")
                riscv_lines.append(f"addi t0, s3, -1         # Top index")
                riscv_lines.append(f"addi t1, s3, -{n+1}     # Swap index")
                riscv_lines.append(f"slli t0, t0, 5")
                riscv_lines.append(f"slli t1, t1, 5")
                riscv_lines.append(f"add  t0, s2, t0         # Addr1")
                riscv_lines.append(f"add  t1, s2, t1         # Addr2")
                for i in [0, 8, 16, 24]:
                    riscv_lines.append(f"ld t2, {i}(t0)")
                    riscv_lines.append(f"ld t3, {i}(t1)")
                    riscv_lines.append(f"sd t3, {i}(t0)")
                    riscv_lines.append(f"sd t2, {i}(t1)")
                continue

            else:
                # Unknown opcode
                riscv_lines.append(f"# Unimplemented opcode: {opcode}")
                stack_effect = instr.get("stack_effect", 0)
                if stack_effect != 0:
                    riscv_lines.append(f"addi s3, s3, {stack_effect} # Adjust stack for unimplemented opcode")

        return riscv_lines

    def emit_gas_cost(self, opcode: str) -> str:
        """
        Emit gas deduction line for given opcode.
        
        Args:
            opcode (str): EVM instruction name
            
        Returns:
            str: RISC-V gas deduction line or empty string
        """
        cost = self.calculate_gas_cost(opcode, self.context)
        if cost > 0:
            return f"li a0, {cost}\njal ra, deduct_gas"
        return ""

    def _parse_runtime_signature(self, runtime_file="runtime.s"):
        """
        Parse runtime.s to extract function signatures.
        
        Args:
            runtime_file (str): Path to runtime file
            
        Returns:
            dict: Mapping of runtime functions to their argument specs
        """
        runtime_signatures = {}
        runtime_path = os.path.join(os.path.dirname(__file__), runtime_file)
        try:
            with open(runtime_path, 'r') as f:
                func_name = None
                for line in f:
                    line = line.strip()
                    if line.startswith('.globl'):
                        func_name = line.split()[-1]
                        runtime_signatures[func_name] = {'registers': ['a0', 'a1', 'a2', 'a3', 'a4', 'a5']}
        except FileNotFoundError:
            logging.warning(f"Runtime file {runtime_file} not found")
            return {}
        return runtime_signatures

    def emit_runtime_calls(self, runtime_function: str, args: dict):
        """
        Dynamically emits RISC-V code for runtime function calls.
        
        Args:
            runtime_function (str): Name of the runtime function to call
            args (dict): Arguments (registers or values) to prepare
            
        Returns:
            list[str]: RISC-V assembly lines calling the function
        """
        lines = []

        if runtime_function not in self.runtime_signatures:
            logging.warning(f"Unknown runtime function: {runtime_function}")
            return [f"# Unknown runtime function: {runtime_function}"]

        signature = self.runtime_signatures[runtime_function]

        for i, (arg_name, arg_value) in enumerate(args.items()):
            if i < len(signature['registers']):
                reg = signature['registers'][i]
                if isinstance(arg_value, str) and arg_value.startswith('$'):
                    lines.append(f"mv {reg}, {arg_value[1:]}")
                else:
                    lines.append(f"li {reg}, {arg_value}")

        lines.append(f"jal ra, {runtime_function}")
        return lines

    def format_assembly_output(self, assembly_code: list) -> str:
        """
        Format raw assembly lines into clean sectioned output.
        
        Args:
            assembly_code (list): Raw RISC-V assembly lines
            
        Returns:
            str: Cleanly formatted assembly string
        """
        output = [
            ".section .text",
            "",
            "# Jump destination table",
            ".align 4",
            "jumpdest_table:"
        ]

        if hasattr(self.context, 'jumpdests'):
            for idx in sorted(self.context.jumpdests):
                output.append(f"    .word jumpdest_{idx}")

        output.append("")
        output.extend(assembly_code)
        return "\n".join(output)

    def write_output_file(self, assembly_code: str, output_file: str):
        """
        Write final RISC-V assembly to disk.
        
        Args:
            assembly_code (str): Formatted assembly string
            output_file (str): Path to output file
        """
        try:
            output_dir = os.path.dirname(output_file)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir)
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(assembly_code)
        except IOError as e:
            logging.error(f"Failed to write output file {output_file}: {str(e)}")
            raise

    def emit_error_handling_code(self, error_type: str):
        """
        Generate assembly for handling known error types.
        
        Args:
            error_type (str): Type of error (e.g., 'revert', 'invalid')
            
        Returns:
            list[str]: Assembly lines for error handling
        """
        handlers = {
            "revert": ["jal ra, evm_revert"],
            "invalid": ["jal ra, evm_invalid"],
            "out_of_gas": ["jal ra, evm_out_of_gas"]
        }
        return handlers.get(error_type.lower(), ["ebreak"])

    def get_unknown_opcodes(self):
        """Get set of unknown opcodes encountered."""
        return self.unknown_opcodes

    def get_invalid_opcodes(self):
        """Get set of invalid opcodes encountered."""
        return self.invalid_opcodes

    def get_warnings(self):
        """Get list of warnings generated."""
        return self.warnings

    def get_errors(self):
        """Get list of errors generated."""
        return self.errors