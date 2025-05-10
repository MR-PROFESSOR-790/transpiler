
"""
arithmetic.py - EVM arithmetic operations handler for EVM to RISC-V transpiler
Handles translation of EVM arithmetic instructions to RISC-V assembly
"""

from .riscv_emitter import RISCVEmitter


class ArithmeticHandler:
    """Manages the translation of EVM arithmetic and bitwise operations to RISC-V"""
    
    def __init__(self, emitter):
        """
        Initialize with a RISC-V emitter
        
        Args:
            emitter (RISCVEmitter): The RISC-V code emitter
        """
        self.emitter = emitter
    
    def handle_add(self):
        """
        Handles EVM ADD operation (0x01)
        Pop two values, add them, and push the result
        """
        self.emitter.comment("ADD operation")
        # Pop two values from stack to registers
        self.emitter.pop_to_register("a0")  # First operand
        self.emitter.pop_to_register("a1")  # Second operand
        # Perform addition
        self.emitter.emit("add a0, a0, a1")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_mul(self):
        """
        Handles EVM MUL operation (0x02)
        Pop two values, multiply them, and push the result
        """
        self.emitter.comment("MUL operation")
        # Pop two values from stack to registers
        self.emitter.pop_to_register("a0")  # First operand
        self.emitter.pop_to_register("a1")  # Second operand
        # Perform multiplication
        self.emitter.emit("mul a0, a0, a1")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_sub(self):
        """
        Handles EVM SUB operation (0x03)
        Pop two values, subtract second from first, and push the result
        """
        self.emitter.comment("SUB operation")
        # Note: Order matters for SUB
        self.emitter.pop_to_register("a1")  # Second operand (subtrahend)
        self.emitter.pop_to_register("a0")  # First operand (minuend)
        # Perform subtraction
        self.emitter.emit("sub a0, a0, a1")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_div(self):
        """
        Handles EVM DIV operation (0x04)
        Pop two values, unsigned integer division, and push the result
        """
        self.emitter.comment("DIV operation")
        # Note: Order matters for DIV
        self.emitter.pop_to_register("a1")  # Second operand (divisor)
        self.emitter.pop_to_register("a0")  # First operand (dividend)
        
        # Check for division by zero
        self.emitter.emit("beqz a1, div_by_zero")
        
        # Perform unsigned division
        self.emitter.emit("divu a0, a0, a1")
        self.emitter.emit("j div_end")
        
        # Handle division by zero (result should be 0 in EVM)
        self.emitter.label("div_by_zero")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("div_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_sdiv(self):
        """
        Handles EVM SDIV operation (0x05)
        Pop two values, signed integer division, and push the result
        """
        self.emitter.comment("SDIV operation")
        # Note: Order matters for SDIV
        self.emitter.pop_to_register("a1")  # Second operand (divisor)
        self.emitter.pop_to_register("a0")  # First operand (dividend)
        
        # Check for division by zero
        self.emitter.emit("beqz a1, sdiv_by_zero")
        
        # Handle special case for signed division: -2^255 / -1 = -2^255 (overflow)
        self.emitter.emit("li t0, -1")
        self.emitter.emit("bne a1, t0, sdiv_normal")
        
        # Load the most negative 256-bit value to check
        self.emitter.emit("li t1, 1")
        self.emitter.emit("slli t1, t1, 255")  # t1 = 2^255
        self.emitter.emit("bne a0, t1, sdiv_normal")
        
        # If we get here, it's the overflow case, return the same value
        self.emitter.emit("j sdiv_end")
        
        # Normal signed division
        self.emitter.label("sdiv_normal")
        self.emitter.emit("div a0, a0, a1")
        self.emitter.emit("j sdiv_end")
        
        # Handle division by zero (result should be 0 in EVM)
        self.emitter.label("sdiv_by_zero")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("sdiv_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_mod(self):
        """
        Handles EVM MOD operation (0x06)
        Pop two values, unsigned modulo, and push the result
        """
        self.emitter.comment("MOD operation")
        self.emitter.pop_to_register("a1")  # Second operand (modulus)
        self.emitter.pop_to_register("a0")  # First operand
        
        # Check for modulo by zero
        self.emitter.emit("beqz a1, mod_by_zero")
        
        # Perform unsigned modulo
        self.emitter.emit("remu a0, a0, a1")
        self.emitter.emit("j mod_end")
        
        # Handle modulo by zero (result should be 0 in EVM)
        self.emitter.label("mod_by_zero")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("mod_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_smod(self):
        """
        Handles EVM SMOD operation (0x07)
        Pop two values, signed modulo, and push the result
        """
        self.emitter.comment("SMOD operation")
        self.emitter.pop_to_register("a1")  # Second operand (modulus)
        self.emitter.pop_to_register("a0")  # First operand
        
        # Check for modulo by zero
        self.emitter.emit("beqz a1, smod_by_zero")
        
        # Perform signed modulo
        self.emitter.emit("rem a0, a0, a1")
        self.emitter.emit("j smod_end")
        
        # Handle modulo by zero (result should be 0 in EVM)
        self.emitter.label("smod_by_zero")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("smod_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_addmod(self):
        """
        Handles EVM ADDMOD operation (0x08)
        Pop three values, (a + b) % N, and push the result
        """
        self.emitter.comment("ADDMOD operation")
        self.emitter.pop_to_register("a2")  # Third operand (modulus)
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Check for modulo by zero
        self.emitter.emit("beqz a2, addmod_by_zero")
        
        # We need wide registers for this calculation to avoid overflow
        self.emitter.emit("add a3, a0, a1")  # a3 = a0 + a1
        self.emitter.emit("remu a0, a3, a2")  # a0 = a3 % a2
        self.emitter.emit("j addmod_end")
        
        # Handle modulo by zero (result should be 0 in EVM)
        self.emitter.label("addmod_by_zero")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("addmod_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_mulmod(self):
        """
        Handles EVM MULMOD operation (0x09)
        Pop three values, (a * b) % N, and push the result
        """
        self.emitter.comment("MULMOD operation")
        self.emitter.pop_to_register("a2")  # Third operand (modulus)
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Check for modulo by zero
        self.emitter.emit("beqz a2, mulmod_by_zero")
        
        # We need wide registers for this calculation to avoid overflow
        self.emitter.emit("mul a3, a0, a1")  # a3 = a0 * a1
        self.emitter.emit("remu a0, a3, a2")  # a0 = a3 % a2
        self.emitter.emit("j mulmod_end")
        
        # Handle modulo by zero (result should be 0 in EVM)
        self.emitter.label("mulmod_by_zero")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("mulmod_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_exp(self):
        """
        Handles EVM EXP operation (0x0A)
        Pop two values, a^b, and push the result
        """
        self.emitter.comment("EXP operation")
        self.emitter.pop_to_register("a1")  # Second operand (exponent)
        self.emitter.pop_to_register("a0")  # First operand (base)
        
        # Call a function to handle exponentiation (too complex for inline)
        self.emitter.emit("call evm_exp")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_signextend(self):
        """
        Handles EVM SIGNEXTEND operation (0x0B)
        Sign extends b from (a*8+7)th bit
        """
        self.emitter.comment("SIGNEXTEND operation")
        self.emitter.pop_to_register("a1")  # Value to extend
        self.emitter.pop_to_register("a0")  # Byte number
        
        # Check if a0 >= 32 (out of range)
        self.emitter.emit("li t0, 32")
        self.emitter.emit("bgeu a0, t0, signextend_out_of_range")
        
        # Calculate bit position: t1 = a0 * 8 + 7
        self.emitter.emit("slli t1, a0, 3")  # t1 = a0 * 8
        self.emitter.emit("addi t1, t1, 7")  # t1 = t1 + 7
        
        # Create mask: t2 = (1 << t1) - 1
        self.emitter.emit("li t2, 1")
        self.emitter.emit("sll t2, t2, t1")
        self.emitter.emit("addi t2, t2, -1")  # t2 = (1 << t1) - 1
        
        # Check sign bit
        self.emitter.emit("srl t3, a1, t1")  # Get sign bit
        self.emitter.emit("andi t3, t3, 1")  # Isolate sign bit
        self.emitter.emit("beqz t3, signextend_positive")
        
        # If negative, invert bits above sign bit
        self.emitter.emit("not t2, t2")  # Invert mask
        self.emitter.emit("or a0, a1, t2")  # Set all bits above sign bit
        self.emitter.emit("j signextend_end")
        
        # If positive, keep bits above sign bit as 0
        self.emitter.label("signextend_positive")
        self.emitter.emit("and a0, a1, t2")  # Clear all bits above sign bit
        self.emitter.emit("j signextend_end")
        
        # Handle out of range case (return value unchanged)
        self.emitter.label("signextend_out_of_range")
        self.emitter.emit("mv a0, a1")
        
        self.emitter.label("signextend_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")

    # Bitwise operations
    
    def handle_lt(self):
        """
        Handles EVM LT operation (0x10)
        Less than comparison (unsigned)
        """
        self.emitter.comment("LT operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform unsigned comparison
        self.emitter.emit("sltu a0, a0, a1")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_gt(self):
        """
        Handles EVM GT operation (0x11)
        Greater than comparison (unsigned)
        """
        self.emitter.comment("GT operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform unsigned comparison
        self.emitter.emit("sltu a0, a1, a0")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_slt(self):
        """
        Handles EVM SLT operation (0x12)
        Less than comparison (signed)
        """
        self.emitter.comment("SLT operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform signed comparison
        self.emitter.emit("slt a0, a0, a1")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_sgt(self):
        """
        Handles EVM SGT operation (0x13)
        Greater than comparison (signed)
        """
        self.emitter.comment("SGT operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform signed comparison
        self.emitter.emit("slt a0, a1, a0")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_eq(self):
        """
        Handles EVM EQ operation (0x14)
        Equality comparison
        """
        self.emitter.comment("EQ operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform equality comparison
        self.emitter.emit("xor a0, a0, a1")     # a0 = a0 XOR a1
        self.emitter.emit("seqz a0, a0")        # a0 = (a0 == 0) ? 1 : 0
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_iszero(self):
        """
        Handles EVM ISZERO operation (0x15)
        Check if value is zero
        """
        self.emitter.comment("ISZERO operation")
        self.emitter.pop_to_register("a0")  # Operand
        
        # Check if zero
        self.emitter.emit("seqz a0, a0")  # a0 = (a0 == 0) ? 1 : 0
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_and(self):
        """
        Handles EVM AND operation (0x16)
        Bitwise AND
        """
        self.emitter.comment("AND operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform bitwise AND
        self.emitter.emit("and a0, a0, a1")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_or(self):
        """
        Handles EVM OR operation (0x17)
        Bitwise OR
        """
        self.emitter.comment("OR operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform bitwise OR
        self.emitter.emit("or a0, a0, a1")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_xor(self):
        """
        Handles EVM XOR operation (0x18)
        Bitwise XOR
        """
        self.emitter.comment("XOR operation")
        self.emitter.pop_to_register("a1")  # Second operand
        self.emitter.pop_to_register("a0")  # First operand
        
        # Perform bitwise XOR
        self.emitter.emit("xor a0, a0, a1")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_not(self):
        """
        Handles EVM NOT operation (0x19)
        Bitwise NOT
        """
        self.emitter.comment("NOT operation")
        self.emitter.pop_to_register("a0")  # Operand
        
        # Perform bitwise NOT
        self.emitter.emit("not a0, a0")
        
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_byte(self):
        """
        Handles EVM BYTE operation (0x1A)
        Extract a byte from a word
        """
        self.emitter.comment("BYTE operation")
        self.emitter.pop_to_register("a1")  # Second operand (word)
        self.emitter.pop_to_register("a0")  # First operand (byte index)
        
        # Check if byte index is >= 32 (out of range)
        self.emitter.emit("li t0, 32")
        self.emitter.emit("bgeu a0, t0, byte_out_of_range")
        
        # Calculate shift amount: t1 = (31 - a0) * 8
        self.emitter.emit("li t1, 31")
        self.emitter.emit("sub t1, t1, a0")  # t1 = 31 - a0
        self.emitter.emit("slli t1, t1, 3")  # t1 = t1 * 8
        
        # Shift and mask to get the byte
        self.emitter.emit("srl a0, a1, t1")  # a0 = a1 >> t1
        self.emitter.emit("andi a0, a0, 0xFF")  # a0 = a0 & 0xFF
        self.emitter.emit("j byte_end")
        
        # Handle out of range case (return 0)
        self.emitter.label("byte_out_of_range")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("byte_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_shl(self):
        """
        Handles EVM SHL operation (0x1B)
        Shift left
        """
        self.emitter.comment("SHL operation")
        self.emitter.pop_to_register("a1")  # Second operand (value)
        self.emitter.pop_to_register("a0")  # First operand (shift amount)
        
        # Check if shift amount >= 256 (result should be 0)
        self.emitter.emit("li t0, 256")
        self.emitter.emit("bgeu a0, t0, shl_large_shift")
        
        # Perform shift left
        self.emitter.emit("sll a0, a1, a0")
        self.emitter.emit("j shl_end")
        
        # Handle large shift case (return 0)
        self.emitter.label("shl_large_shift")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("shl_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_shr(self):
        """
        Handles EVM SHR operation (0x1C)
        Logical shift right (unsigned)
        """
        self.emitter.comment("SHR operation")
        self.emitter.pop_to_register("a1")  # Second operand (value)
        self.emitter.pop_to_register("a0")  # First operand (shift amount)
        
        # Check if shift amount >= 256 (result should be 0)
        self.emitter.emit("li t0, 256")
        self.emitter.emit("bgeu a0, t0, shr_large_shift")
        
        # Perform logical shift right
        self.emitter.emit("srl a0, a1, a0")
        self.emitter.emit("j shr_end")
        
        # Handle large shift case (return 0)
        self.emitter.label("shr_large_shift")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("shr_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")
    
    def handle_sar(self):
        """
        Handles EVM SAR operation (0x1D)
        Arithmetic shift right (signed)
        """
        self.emitter.comment("SAR operation")
        self.emitter.pop_to_register("a1")  # Second operand (value)
        self.emitter.pop_to_register("a0")  # First operand (shift amount)
        
        # Check if shift amount >= 256
        self.emitter.emit("li t0, 256")
        self.emitter.emit("bgeu a0, t0, sar_large_shift")
        
        # Perform arithmetic shift right
        self.emitter.emit("sra a0, a1, a0")
        self.emitter.emit("j sar_end")
        
        # Handle large shift case (if negative, return -1, else 0)
        self.emitter.label("sar_large_shift")
        self.emitter.emit("srai a0, a1, 31")  # Get sign bit (all 1s if negative, 0 if positive)
        
        self.emitter.label("sar_end")
        # Push result back to stack
        self.emitter.push_from_register("a0")

    # Helper functions for instruction dispatch
    
    def get_handler_for_opcode(self, opcode):
        """
        Get the appropriate handler function for a given EVM opcode
        
        Args:
            opcode (int): The EVM opcode
            
        Returns:
            function: The handler function or None if not supported
        """
        opcode_handlers = {
            0x01: self.handle_add,      # ADD
            0x02: self.handle_mul,      # MUL
            0x03: self.handle_sub,      # SUB
            0x04: self.handle_div,      # DIV
            0x05: self.handle_sdiv,     # SDIV
            0x06: self.handle_mod,      # MOD
            0x07: self.handle_smod,     # SMOD
            0x08: self.handle_addmod,   # ADDMOD
            0x09: self.handle_mulmod,   # MULMOD
            0x0A: self.handle_exp,      # EXP
            0x0B: self.handle_signextend, # SIGNEXTEND
            
            # Comparison and bitwise operations
            0x10: self.handle_lt,       # LT
            0x11: self.handle_gt,       # GT
            0x12: self.handle_slt,      # SLT
            0x13: self.handle_sgt,      # SGT
            0x14: self.handle_eq,       # EQ
            0x15: self.handle_iszero,   # ISZERO
            0x16: self.handle_and,      # AND
            0x17: self.handle_or,       # OR
            0x18: self.handle_xor,      # XOR
            0x19: self.handle_not,      # NOT
            0x1A: self.handle_byte,     # BYTE
            0x1B: self.handle_shl,      # SHL
            0x1C: self.handle_shr,      # SHR
            0x1D: self.handle_sar,      # SAR
        }
        
        return opcode_handlers.get(opcode)
    
    def generate_exp_helper_function(self):
        """
        Generate a helper function for EVM EXP operation
        This is too complex to inline
        """
        self.emitter.comment("EVM exponentiation helper function")
        self.emitter.label("evm_exp")
        
        # Function prologue
        self.emitter.emit("addi sp, sp, -16")
        self.emitter.emit("sw ra, 12(sp)")
        self.emitter.emit("sw s0, 8(sp)")
        self.emitter.emit("sw s1, 4(sp)")
        self.emitter.emit("sw s2, 0(sp)")
        
        # s0 = base, s1 = exponent, s2 = result
        self.emitter.emit("mv s0, a0")    # Save base
        self.emitter.emit("mv s1, a1")    # Save exponent
        self.emitter.emit("li s2, 1")     # Initialize result to 1
        
        # Start of exponentiation loop
        self.emitter.label("exp_loop")
        self.emitter.emit("beqz s1, exp_end")  # If exponent is 0, we're done
        
        # Check if least significant bit of exponent is 1
        self.emitter.emit("andi t0, s1, 1")    # t0 = s1 & 1
        self.emitter.emit("beqz t0, exp_skip_multiply")  # Skip multiply if bit is 0
        
        # Multiply result by base
        self.emitter.emit("mul s2, s2, s0")    # s2 = s2 * s0
        
        self.emitter.label("exp_skip_multiply")
        # Square the base and divide exponent by 2
        self.emitter.emit("mul s0, s0, s0")    # s0 = s0 * s0 (square the base)
        self.emitter.emit("srli s1, s1, 1")    # s1 = s1 >> 1 (divide exponent by 2)
        self.emitter.emit("j exp_loop")        # Repeat
        
        # End of exponentiation function
        self.emitter.label("exp_end")
        self.emitter.emit("mv a0, s2")         # Set return value
        
        # Function epilogue
        self.emitter.emit("lw ra, 12(sp)")
        self.emitter.emit("lw s0, 8(sp)")
        self.emitter.emit("lw s1, 4(sp)")
        self.emitter.emit("lw s2, 0(sp)")
        self.emitter.emit("addi sp, sp, 16")
        self.emitter.emit("ret")