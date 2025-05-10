#!/usr/bin/env python3
"""
RISC-V Emitter for EVM Transpiler

This module transpiles EVM assembly to RISC-V assembly, handling the conversion
from EVM's stack-based architecture to RISC-V's register-based architecture.
"""

import re
import os
import sys
from typing import Dict, List, Tuple, Set, Optional


class RISCVEmitter:
    """
    Emits RISC-V assembly code from EVM assembly instructions.
    
    The emitter handles:
    1. Stack-to-register mapping
    2. EVM opcode translation
    3. Memory management
    4. Gas metering (optional)
    5. Special EVM operations (storage, logs, etc.)
    """
    
    # RISC-V register mappings
    # a0-a7: argument registers (a0-a1 are also return value)
    # t0-t6: temporary registers
    # s0-s11: saved registers
    # sp: stack pointer
    # ra: return address
    
    # We'll use s1-s11 for the most active stack elements
    # and manage the rest in memory
    
    def __init__(self, input_asm_file: str, output_riscv_file: str, 
                 gas_metering: bool = False, stack_size: int = 1024):
        self.input_file = input_asm_file
        self.output_file = output_riscv_file
        self.gas_metering = gas_metering
        self.stack_size = stack_size
        
        # EVM assembly code
        self.evm_asm = []
        
        # RISC-V assembly code to be generated
        self.riscv_asm = []
        
        # Mapping of EVM labels to RISC-V labels
        self.label_map = {}
        
        # Current stack depth (for stack management)
        self.stack_depth = 0
        
        # Track used registers for register allocation
        self.used_registers = set()
        
        # Maximum stack depth encountered
        self.max_stack_depth = 0
        
        # Function signatures for common EVM operations
        self.function_signatures = {}
        
        # Stack registers (s1-s11 are our primary stack registers)
        self.stack_registers = [f"s{i}" for i in range(1, 12)]
        
        # Temporary registers for operations
        self.temp_registers = [f"t{i}" for i in range(0, 7)]
        
        # Section handling
        self.current_section = ".text"  # Default section
        self.code = []
        self.sections = {".text": [], ".data": []}
    
    def section(self, section_name: str) -> None:
        """Change current section for code generation."""
        if section_name not in self.sections:
            self.sections[section_name] = []
        self.current_section = section_name
        self.code.append(f"\n\t.section {section_name}")

    def align(self, alignment: int) -> None:
        """Add alignment directive."""
        self.code.append(f"\t.align {alignment}")
        self.sections[self.current_section].append(f"\t.align {alignment}")

    def global_(self, symbol: str) -> None:
        """Declare a global symbol."""
        self.code.append(f"\t.global {symbol}")
        self.sections[self.current_section].append(f"\t.global {symbol}")

    def label(self, name: str) -> None:
        """Create a label."""
        self.code.append(f"{name}:")
        self.sections[self.current_section].append(f"{name}:")

    def space(self, size: int) -> None:
        """Reserve space in the current section."""
        self.code.append(f"\t.space {size}")
        self.sections[self.current_section].append(f"\t.space {size}")

    def emit(self, instruction: str) -> None:
        """Emit an instruction to the current section."""
        self.sections[self.current_section].append(instruction)
        self.code.append(instruction)

    def load_evm_asm(self) -> None:
        """Load the EVM assembly file."""
        try:
            with open(self.input_file, 'r') as f:
                self.evm_asm = f.readlines()
        except FileNotFoundError:
            print(f"Error: Input file {self.input_file} not found.")
            sys.exit(1)
    
    def parse_evm_asm(self) -> List[Tuple[str, Optional[str], Optional[str]]]:
        """
        Parse EVM assembly into a structured format.
        
        Returns:
            A list of tuples: (opcode, operand, comment)
        """
        parsed_instructions = []
        
        for line in self.evm_asm:
            # Strip comments and whitespace
            line = line.strip()
            comment = None
            
            # Extract comments
            if ';' in line:
                line, comment = line.split(';', 1)
                line = line.strip()
                comment = comment.strip()
            
            # Skip empty lines
            if not line:
                continue
                
            # Handle labels
            if line.endswith(':'):
                parsed_instructions.append((line[:-1], None, comment))
                continue
                
            # Parse opcode and operand
            parts = line.split(maxsplit=1)
            opcode = parts[0].upper()
            operand = parts[1] if len(parts) > 1 else None
            
            parsed_instructions.append((opcode, operand, comment))
            
        return parsed_instructions
    
    def emit_header(self) -> None:
        """Emit the RISC-V assembly header."""
        header = [
            "# Generated RISC-V Assembly from EVM bytecode",
            "# This file was transpiled automatically",
            "",
            ".section .text",
            ".globl main",
            "",
            "# EVM stack is implemented using registers and memory",
            ".equ STACK_SIZE, {}".format(self.stack_size),
            ".equ MAX_MEM, 0x10000    # 64KB addressable memory",
            "",
            "# Memory layout:",
            "# 0x0000 - 0x????: Code and data",
            "# 0x???? - 0x????: EVM Stack (grows downward)",
            "# 0x???? - 0x????: EVM Memory (grows upward)",
            "# 0x???? - 0x????: EVM Storage (emulated)",
            "",
            ".section .data",
            "evm_memory: .space MAX_MEM",
            "evm_storage_keys:   .space 1024",
            "evm_storage_values: .space 1024",
            "",
            ".section .text",
            "main:",
            "    # Initialize stack pointer and frame",
            "    addi sp, sp, -16",
            "    sd ra, 8(sp)     # Save return address",
            "    sd s0, 0(sp)     # Save frame pointer",
            "    addi s0, sp, 16  # Set up frame pointer",
            "",
            "    # Initialize memory pointers",
            "    lui t0, %hi(evm_memory)",
            "    addi t0, t0, %lo(evm_memory)",
            "    li t1, MAX_MEM",
            "    add t1, t1, t0   # End of memory",
            "",
            "    # Initialize stack depth counter",
            "    li a5, 0         # Stack depth = 0",
            "",
            "    # Initialize gas counter if metering is enabled",
        ]
        
        if self.gas_metering:
            header.extend([
                "    li a4, 0         # Gas used = 0",
                "",
            ])
            
        header.append("")
        self.riscv_asm.extend(header)
    
    def emit_footer(self) -> None:
        """Emit the RISC-V assembly footer."""
        footer = [
            "",
            "exit:",
            "    # Clean up and exit",
            "    ld s0, 0(sp)     # Restore frame pointer",
            "    ld ra, 8(sp)     # Restore return address",
            "    addi sp, sp, 16  # Restore stack pointer",
            "    li a0, 0         # Return 0",
            "    ret",
            "",
            "# Helper functions for EVM operations",
            self._generate_helper_functions(),
            ""
        ]
        self.riscv_asm.extend(footer)
    
    def _generate_helper_functions(self) -> str:
        """Generate helper functions for complex EVM operations."""
        helpers = [
            "# --- EVM Helper Functions ---",
            "",
            "# Memory Operations",
            "evm_mstore:",
            "    # a0 = offset, a1 = value",
            "    lui t0, %hi(evm_memory)",
            "    addi t0, t0, %lo(evm_memory)",
            "    add t0, t0, a0   # Address = base + offset",
            "    sd a1, 0(t0)     # Store value to memory",
            "    ret",
            "",
            "evm_mload:",
            "    # a0 = offset, returns value in a0",
            "    lui t0, %hi(evm_memory)",
            "    addi t0, t0, %lo(evm_memory)",
            "    add t0, t0, a0   # Address = base + offset",
            "    ld a0, 0(t0)     # Load value from memory",
            "    ret",
            "",
            "# Storage Operations",
            "evm_sstore:",
            "    # a0 = key, a1 = value",
            "    # Simplified implementation - in real life would use a hash map",
            "    lui t0, %hi(evm_storage_keys)",
            "    addi t0, t0, %lo(evm_storage_keys)",
            "    lui t1, %hi(evm_storage_values)",
            "    addi t1, t1, %lo(evm_storage_values)",
            "",
            "    # Find the key or an empty slot",
            "    li t2, 0    # Index",
            "sstore_loop:",
            "    ld t3, 0(t0)  # Load key at current index",
            "    beqz t3, sstore_empty  # Found empty slot",
            "    beq t3, a0, sstore_found # Found matching key",
            "    addi t0, t0, 8  # Next key",
            "    addi t1, t1, 8  # Next value",
            "    addi t2, t2, 1  # Increment index",
            "    li t4, 128",
            "    blt t2, t4, sstore_loop  # Continue if index < 128",
            "    # If we get here, storage is full - just use the first slot",
            "    lui t0, %hi(evm_storage_keys)",
            "    addi t0, t0, %lo(evm_storage_keys)",
            "    lui t1, %hi(evm_storage_values)",
            "    addi t1, t1, %lo(evm_storage_values)",
            "",
            "sstore_empty:",
            "    # Store the key",
            "    sd a0, 0(t0)",
            "sstore_found:",
            "    # Store the value",
            "    sd a1, 0(t1)",
            "    ret",
            "",
            "evm_sload:",
            "    # a0 = key, returns value in a0",
            "    lui t0, %hi(evm_storage_keys)",
            "    addi t0, t0, %lo(evm_storage_keys)",
            "    lui t1, %hi(evm_storage_values)",
            "    addi t1, t1, %lo(evm_storage_values)",
            "",
            "    # Find the key",
            "    li t2, 0    # Index",
            "sload_loop:",
            "    ld t3, 0(t0)  # Load key at current index",
            "    beqz t3, sload_not_found  # End of entries",
            "    beq t3, a0, sload_found # Found matching key",
            "    addi t0, t0, 8  # Next key",
            "    addi t1, t1, 8  # Next value",
            "    addi t2, t2, 1  # Increment index",
            "    li t4, 128",
            "    blt t2, t4, sload_loop  # Continue if index < 128",
            "",
            "sload_not_found:",
            "    # Key not found, return 0",
            "    li a0, 0",
            "    ret",
            "",
            "sload_found:",
            "    # Return the value",
            "    ld a0, 0(t1)",
            "    ret",
            "",
            "# Arithmetic Operations",
            "evm_add:",
            "    # a0, a1 = operands, result in a0",
            "    add a0, a0, a1",
            "    ret",
            "",
            "evm_mul:",
            "    # a0, a1 = operands, result in a0",
            "    mul a0, a0, a1",
            "    ret",
            "",
            "evm_div:",
            "    # a0, a1 = operands, result in a0",
            "    beqz a1, div_by_zero",
            "    div a0, a0, a1",
            "    ret",
            "div_by_zero:",
            "    li a0, 0",
            "    ret",
            "",
            "evm_mod:",
            "    # a0, a1 = operands, result in a0",
            "    beqz a1, mod_by_zero",
            "    rem a0, a0, a1",
            "    ret",
            "mod_by_zero:",
            "    li a0, 0",
            "    ret",
            "",
            "# Comparison Operations",
            "evm_lt:",
            "    # a0, a1 = operands, result in a0",
            "    slt a0, a0, a1",
            "    ret",
            "",
            "evm_gt:",
            "    # a0, a1 = operands, result in a0",
            "    slt a0, a1, a0",
            "    ret",
            "",
            "evm_eq:",
            "    # a0, a1 = operands, result in a0",
            "    xor a0, a0, a1",
            "    seqz a0, a0",
            "    ret",
            "",
            "# Keccak256 Hash Function (simplified)",
            "evm_keccak256:",
            "    # Simplified implementation - returns a pseudo-hash",
            "    # a0 = memory offset, a1 = length",
            "    # In real implementation, this would compute the actual hash",
            "    add a0, a0, a1   # Just a placeholder calculation",
            "    not a0, a0       # Invert bits as a very simple 'hash'",
            "    ret",
            ""
        ]
        
        return '\n'.join(helpers)
    
    def stack_push(self, value: str) -> None:
        """
        Emit code to push a value onto the EVM stack.
        
        Args:
            value: The value to push, as a register or immediate
        """
        # Increment stack depth
        self.stack_depth += 1
        self.max_stack_depth = max(self.max_stack_depth, self.stack_depth)
        
        # Generate code to update stack depth
        self.riscv_asm.append(f"    # Push value {value} to stack")
        
        if self.stack_depth <= len(self.stack_registers):
            # If we have registers available, use them
            reg = self.stack_registers[self.stack_depth - 1]
            if value.startswith('s') or value.startswith('t') or value.startswith('a'):
                # Value is a register
                self.riscv_asm.append(f"    mv {reg}, {value}")
            else:
                # Value is an immediate
                self.riscv_asm.append(f"    li {reg}, {value}")
        else:
            # Otherwise push to memory stack
            offset = (self.stack_depth - len(self.stack_registers)) * 8
            if value.startswith('s') or value.startswith('t') or value.startswith('a'):
                # Value is a register
                self.riscv_asm.append(f"    sd {value}, -{offset}(sp)")
            else:
                # Value is an immediate
                self.riscv_asm.append(f"    li t0, {value}")
                self.riscv_asm.append(f"    sd t0, -{offset}(sp)")
        
        self.riscv_asm.append(f"    addi a5, a5, 1  # Stack depth = {self.stack_depth}")
        
    def stack_pop(self, target_reg: str = "a0") -> None:
        """
        Emit code to pop a value from the EVM stack.
        
        Args:
            target_reg: The register to pop the value into
        """
        if self.stack_depth <= 0:
            raise ValueError("Stack underflow")
        
        self.riscv_asm.append(f"    # Pop value from stack to {target_reg}")
        
        if self.stack_depth <= len(self.stack_registers):
            # If value is in a register
            reg = self.stack_registers[self.stack_depth - 1]
            self.riscv_asm.append(f"    mv {target_reg}, {reg}")
        else:
            # If value is in memory
            offset = (self.stack_depth - len(self.stack_registers)) * 8
            self.riscv_asm.append(f"    ld {target_reg}, -{offset}(sp)")
        
        # Decrement stack depth
        self.stack_depth -= 1
        self.riscv_asm.append(f"    addi a5, a5, -1  # Stack depth = {self.stack_depth}")
    
    def stack_peek(self, depth: int, target_reg: str = "a0") -> None:
        """
        Emit code to peek at a value on the EVM stack without popping.
        
        Args:
            depth: How deep in the stack to peek (0 = top of stack)
            target_reg: The register to load the value into
        """
        if depth >= self.stack_depth:
            raise ValueError(f"Stack peek beyond depth: {depth} >= {self.stack_depth}")
        
        peek_position = self.stack_depth - depth - 1
        
        self.riscv_asm.append(f"    # Peek at stack position {peek_position} to {target_reg}")
        
        if peek_position < len(self.stack_registers):
            # If value is in a register
            reg = self.stack_registers[peek_position]
            self.riscv_asm.append(f"    mv {target_reg}, {reg}")
        else:
            # If value is in memory
            offset = (peek_position - len(self.stack_registers) + 1) * 8
            self.riscv_asm.append(f"    ld {target_reg}, -{offset}(sp)")
    
    def stack_replace(self, depth: int, value: str) -> None:
        """
        Emit code to replace a value on the EVM stack.
        
        Args:
            depth: How deep in the stack to replace (0 = top of stack)
            value: The value or register to set
        """
        if depth >= self.stack_depth:
            raise ValueError(f"Stack replace beyond depth: {depth} >= {self.stack_depth}")
        
        replace_position = self.stack_depth - depth - 1
        
        self.riscv_asm.append(f"    # Replace stack position {replace_position} with {value}")
        
        if replace_position < len(self.stack_registers):
            # If value is in a register
            reg = self.stack_registers[replace_position]
            if value.startswith('s') or value.startswith('t') or value.startswith('a'):
                # Value is a register
                self.riscv_asm.append(f"    mv {reg}, {value}")
            else:
                # Value is an immediate
                self.riscv_asm.append(f"    li {reg}, {value}")
        else:
            # If value is in memory
            offset = (replace_position - len(self.stack_registers) + 1) * 8
            if value.startswith('s') or value.startswith('t') or value.startswith('a'):
                # Value is a register
                self.riscv_asm.append(f"    sd {value}, -{offset}(sp)")
            else:
                # Value is an immediate
                self.riscv_asm.append(f"    li t0, {value}")
                self.riscv_asm.append(f"    sd t0, -{offset}(sp)")
    
    def translate_evm_instruction(self, opcode: str, operand: Optional[str], comment: Optional[str]) -> List[str]:
        """
        Translate a single EVM instruction to RISC-V assembly.
        
        Args:
            opcode: The EVM opcode
            operand: The operand (if any)
            comment: Any comment on the line
            
        Returns:
            List of RISC-V assembly instructions
        """
        instructions = []
        
        # Add original instruction as a comment
        original = f"{opcode}" + (f" {operand}" if operand else "")
        instructions.append(f"    # EVM: {original}" + (f" ; {comment}" if comment else ""))
        
        # Handle label
        if opcode.endswith(':'):
            instructions.append(f"{self.evm_to_riscv_label(opcode)}:")
            return instructions
        
        # Handle different opcodes
        if opcode.startswith('PUSH'):
            # PUSH1, PUSH2, etc.
            value = operand.strip()
            # Check if it's a hex value
            if value.startswith('0x'):
                instructions.append(f"    # Push {value}")
                instructions.append(f"    li a0, {value}")
            else:
                instructions.append(f"    # Push {value}")
                instructions.append(f"    li a0, {value}")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: PUSH")
                
            # Push to stack
            self.stack_push("a0")
            
        elif opcode == 'POP':
            # Pop a value from the stack
            self.stack_pop("t0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: POP")
        
        elif opcode == 'ADD':
            # Pop two values, add them, push result
            self.stack_pop("a0")
            self.stack_pop("a1")
            instructions.append(f"    call evm_add")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: ADD")
        
        elif opcode == 'MUL':
            # Pop two values, multiply them, push result
            self.stack_pop("a0")
            self.stack_pop("a1")
            instructions.append(f"    call evm_mul")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 5  # Gas: MUL")
        
        elif opcode == 'SUB':
            # Pop two values, subtract them, push result
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    sub a0, a0, a1")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: SUB")
        
        elif opcode == 'DIV':
            # Pop two values, divide them, push result
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    call evm_div")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 5  # Gas: DIV")
        
        elif opcode == 'MOD':
            # Pop two values, compute modulo, push result
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    call evm_mod")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 5  # Gas: MOD")
        
        elif opcode == 'ADDMOD':
            # (a + b) % N
            self.stack_pop("a2")  # N
            self.stack_pop("a1")  # b
            self.stack_pop("a0")  # a
            instructions.append(f"    add a0, a0, a1")
            instructions.append(f"    mv a1, a2")
            instructions.append(f"    call evm_mod")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 8  # Gas: ADDMOD")
        
        elif opcode == 'MULMOD':
            # (a * b) % N
            self.stack_pop("a2")  # N
            self.stack_pop("a1")  # b
            self.stack_pop("a0")  # a
            instructions.append(f"    mul a0, a0, a1")
            instructions.append(f"    mv a1, a2")
            instructions.append(f"    call evm_mod")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 8  # Gas: MULMOD")
        
        elif opcode == 'EXP':
            # a^b
            self.stack_pop("a1")  # b
            self.stack_pop("a0")  # a
            instructions.append(f"    # Implement exponentiation in a loop")
            instructions.append(f"    mv t0, a0   # Base")
            instructions.append(f"    mv t1, a1   # Exponent")
            instructions.append(f"    li a0, 1    # Result")
            instructions.append(f"exp_loop:")
            instructions.append(f"    beqz t1, exp_done")
            instructions.append(f"    andi t2, t1, 1")
            instructions.append(f"    beqz t2, exp_skip")
            instructions.append(f"    mul a0, a0, t0")
            instructions.append(f"exp_skip:")
            instructions.append(f"    mul t0, t0, t0")
            instructions.append(f"    srli t1, t1, 1")
            instructions.append(f"    j exp_loop")
            instructions.append(f"exp_done:")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 10  # Gas: EXP (simplified)")
                
        elif opcode == 'LT':
            # Less than
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    call evm_lt")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: LT")
        
        elif opcode == 'GT':
            # Greater than
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    call evm_gt")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: GT")
        
        elif opcode == 'SLT':
            # Signed less than
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    slt a0, a0, a1")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: SLT")
        
        elif opcode == 'SGT':
            # Signed greater than
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    slt a0, a1, a0")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: SGT")
        
        elif opcode == 'EQ':
            # Equal
            self.stack_pop("a1")  # Second operand
            self.stack_pop("a0")  # First operand
            instructions.append(f"    call evm_eq")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: EQ")
        
        elif opcode == 'ISZERO':
            # Is zero
            self.stack_pop("a0")
            instructions.append(f"    seqz a0, a0")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: ISZERO")
        
        elif opcode == 'AND':
            # Bitwise AND
            self.stack_pop("a1")
            self.stack_pop("a0")
            instructions.append(f"    and a0, a0, a1")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: AND")
        
        elif opcode == 'OR':
            # Bitwise OR
            self.stack_pop("a1")
            self.stack_pop("a0")
            instructions.append(f"    or a0, a0, a1")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: OR")
        
        elif opcode == 'XOR':
            # Bitwise XOR
            self.stack_pop("a1")
            self.stack_pop("a0")
            instructions.append(f"    xor a0, a0, a1")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: XOR")
        
        elif opcode == 'NOT':
            # Bitwise NOT
            self.stack_pop("a0")
            instructions.append(f"    not a0, a0")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: NOT")
        
        elif opcode == 'BYTE':
            # Get byte from word
            self.stack_pop("a1")  # Byte index (0-31)
            self.stack_pop("a0")  # Word
            instructions.append(f"    # Get byte at index")
            instructions.append(f"    li t0, 31")
            instructions.append(f"    bgt a1, t0, byte_out_of_range")
            instructions.append(f"    li t0, 8")
            instructions.append(f"    mul t0, a1, t0")
            instructions.append(f"    srl a0, a0, t0")
            instructions.append(f"    andi a0, a0, 0xFF")
            instructions.append(f"    j byte_done")
            instructions.append(f"byte_out_of_range:")
            instructions.append(f"    li a0, 0")
            instructions.append(f"byte_done:")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: BYTE")
        
        elif opcode in ['SHL', 'SHR']:
            # Shift left or right
            self.stack_pop("a1")  # Shift amount
            self.stack_pop("a0")  # Value
            if opcode == 'SHL':
                instructions.append(f"    sll a0, a0, a1")
            else:  # SHR
                instructions.append(f"    srl a0, a0, a1")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: {opcode}")
        
        elif opcode == 'SAR':
            # Arithmetic shift right
            self.stack_pop("a1")  # Shift amount
            self.stack_pop("a0")  # Value
            instructions.append(f"    sra a0, a0, a1")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: SAR")
        
        elif opcode == 'SHA3':
            # Keccak256 hash
            self.stack_pop("a1")  # Length
            self.stack_pop("a0")  # Offset
            instructions.append(f"    call evm_keccak256")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 30  # Gas: SHA3 (base)")
                instructions.append(f"    srli t0, a1, 5   # t0 = length / 32")
                instructions.append(f"    addi t0, t0, 1   # t0 = (length / 32) + 1")
                instructions.append(f"    addi a4, a4, t0  # Gas: SHA3 words")
                
        elif opcode == 'ADDRESS':
            # Get address of current executing account
            instructions.append(f"    li a0, 0xADDRESS  # Placeholder for contract address")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: ADDRESS")
                
        elif opcode == 'BALANCE':
            # Get balance of account
            self.stack_pop("a0")  # Address
            instructions.append(f"    li a0, 0  # Placeholder for balance")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 20  # Gas: BALANCE")
                
        elif opcode == 'ORIGIN':
            # Get execution origination address
            instructions.append(f"    li a0, 0xORIGIN  # Placeholder for tx origin")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: ORIGIN")
                
        elif opcode == 'CALLER':
            # Get caller address
            instructions.append(f"    li a0, 0xCALLER  # Placeholder for caller")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: CALLER")
                
        elif opcode == 'CALLVALUE':
            # Get deposited value
            instructions.append(f"    li a0, 0  # Placeholder for call value")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: CALLVALUE")
                
        elif opcode == 'CALLDATALOAD':
            # Load call data
            self.stack_pop("a0")  # Offset
            instructions.append(f"    li a0, 0  # Placeholder for calldata")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: CALLDATALOAD")
                
        elif opcode == 'CALLDATASIZE':
            # Get size of call data
            instructions.append(f"    li a0, 0  # Placeholder for calldata size")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: CALLDATASIZE")
                
        elif opcode == 'CALLDATACOPY':
            # Copy call data to memory
            self.stack_pop("a2")  # Length
            self.stack_pop("a1")  # Source offset
            self.stack_pop("a0")  # Destination offset
            instructions.append(f"    # Placeholder for calldata copy")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: CALLDATACOPY (base)")
                instructions.append(f"    srli t0, a2, 5   # t0 = length / 32")
                instructions.append(f"    addi t0, t0, 1   # t0 = (length / 32) + 1")
                instructions.append(f"    addi a4, a4, t0  # Gas: CALLDATACOPY words")
                
        elif opcode == 'CODESIZE':
            # Get size of code
            instructions.append(f"    li a0, 0  # Placeholder for code size")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: CODESIZE")
                
        elif opcode == 'CODECOPY':
            # Copy code to memory
            self.stack_pop("a2")  # Length
            self.stack_pop("a1")  # Source offset
            self.stack_pop("a0")  # Destination offset
            instructions.append(f"    # Placeholder for code copy")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: CODECOPY (base)")
                instructions.append(f"    srli t0, a2, 5   # t0 = length / 32")
                instructions.append(f"    addi t0, t0, 1   # t0 = (length / 32) + 1")
                instructions.append(f"    addi a4, a4, t0  # Gas: CODECOPY words")
                
        elif opcode == 'GASPRICE':
            # Get gas price
            instructions.append(f"    li a0, 1  # Placeholder for gas price")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: GASPRICE")
                
        elif opcode == 'EXTCODESIZE':
            # Get external code size
            self.stack_pop("a0")  # Address
            instructions.append(f"    li a0, 0  # Placeholder for ext code size")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 20  # Gas: EXTCODESIZE")
                
        elif opcode == 'EXTCODECOPY':
            # Copy external code to memory
            self.stack_pop("a3")  # Length
            self.stack_pop("a2")  # Source offset
            self.stack_pop("a1")  # Destination offset
            self.stack_pop("a0")  # Address
            instructions.append(f"    # Placeholder for ext code copy")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 20  # Gas: EXTCODECOPY (base)")
                instructions.append(f"    srli t0, a3, 5   # t0 = length / 32")
                instructions.append(f"    addi t0, t0, 1   # t0 = (length / 32) + 1")
                instructions.append(f"    addi a4, a4, t0  # Gas: EXTCODECOPY words")
                
        elif opcode == 'RETURNDATASIZE':
            # Get size of return data
            instructions.append(f"    li a0, 0  # Placeholder for return data size")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: RETURNDATASIZE")
                
        elif opcode == 'RETURNDATACOPY':
            # Copy return data to memory
            self.stack_pop("a2")  # Length
            self.stack_pop("a1")  # Source offset
            self.stack_pop("a0")  # Destination offset
            instructions.append(f"    # Placeholder for return data copy")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: RETURNDATACOPY (base)")
                instructions.append(f"    srli t0, a2, 5   # t0 = length / 32")
                instructions.append(f"    addi t0, t0, 1   # t0 = (length / 32) + 1")
                instructions.append(f"    addi a4, a4, t0  # Gas: RETURNDATACOPY words")
                
        elif opcode == 'BLOCKHASH':
            # Get block hash
            self.stack_pop("a0")  # Block number
            instructions.append(f"    li a0, 0  # Placeholder for block hash")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 20  # Gas: BLOCKHASH")
                
        elif opcode == 'COINBASE':
            # Get block coinbase address
            instructions.append(f"    li a0, 0xCOINBASE  # Placeholder for coinbase")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: COINBASE")
                
        elif opcode == 'TIMESTAMP':
            # Get block timestamp
            instructions.append(f"    li a0, 0  # Placeholder for timestamp")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: TIMESTAMP")
                
        elif opcode == 'NUMBER':
            # Get block number
            instructions.append(f"    li a0, 0  # Placeholder for block number")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: NUMBER")
                
        elif opcode == 'DIFFICULTY':
            # Get block difficulty
            instructions.append(f"    li a0, 0  # Placeholder for difficulty")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: DIFFICULTY")
                
        elif opcode == 'GASLIMIT':
            # Get block gas limit
            instructions.append(f"    li a0, 0  # Placeholder for gas limit")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: GASLIMIT")
                
        elif opcode == 'MLOAD':
            # Load from memory
            self.stack_pop("a0")  # Offset
            instructions.append(f"    call evm_mload")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: MLOAD")
                
        elif opcode == 'MSTORE':
            # Store to memory
            self.stack_pop("a1")  # Value
            self.stack_pop("a0")  # Offset
            instructions.append(f"    call evm_mstore")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: MSTORE")
                
        elif opcode == 'MSTORE8':
            # Store a byte to memory
            self.stack_pop("a1")  # Value
            self.stack_pop("a0")  # Offset
            instructions.append(f"    andi a1, a1, 0xFF  # Get only the lowest byte")
            instructions.append(f"    lui t0, %hi(evm_memory)")
            instructions.append(f"    addi t0, t0, %lo(evm_memory)")
            instructions.append(f"    add t0, t0, a0")
            instructions.append(f"    sb a1, 0(t0)")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: MSTORE8")
                
        elif opcode == 'SLOAD':
            # Load from storage
            self.stack_pop("a0")  # Key
            instructions.append(f"    call evm_sload")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 50  # Gas: SLOAD")
                
        elif opcode == 'SSTORE':
            # Store to storage
            self.stack_pop("a1")  # Value
            self.stack_pop("a0")  # Key
            instructions.append(f"    call evm_sstore")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 20000  # Gas: SSTORE (worst case)")
                
        elif opcode == 'JUMP':
            # Jump to destination
            self.stack_pop("a0")  # Destination
            instructions.append(f"    # Calculate actual jump address")
            instructions.append(f"    # This is a placeholder - real implementation would map EVM PC to RISC-V address")
            instructions.append(f"    la t0, evm_addr_{operand if operand else 'dest'}  # Load target address")
            instructions.append(f"    jr t0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 8  # Gas: JUMP")
                
        elif opcode == 'JUMPI':
            # Jump if condition
            self.stack_pop("a1")  # Condition
            self.stack_pop("a0")  # Destination
            instructions.append(f"    # Jump if condition non-zero")
            instructions.append(f"    beqz a1, jumpi_skip")
            instructions.append(f"    la t0, evm_addr_{operand if operand else 'dest'}  # Load target address")
            instructions.append(f"    jr t0")
            instructions.append(f"jumpi_skip:")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 10  # Gas: JUMPI")
                
        elif opcode == 'PC':
            # Get program counter
            instructions.append(f"    li a0, 0  # Placeholder for PC value")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: PC")
                
        elif opcode == 'MSIZE':
            # Get memory size
            instructions.append(f"    li a0, 0  # Placeholder for memory size")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: MSIZE")
                
        elif opcode == 'GAS':
            # Get available gas
            if self.gas_metering:
                instructions.append(f"    # Calculate remaining gas")
                instructions.append(f"    li t0, 100000  # Initial gas (placeholder)")
                instructions.append(f"    sub a0, t0, a4")
            else:
                instructions.append(f"    li a0, 100000  # Placeholder for gas value")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 2  # Gas: GAS")
                
        elif opcode.startswith('DUP'):
            # Duplicate stack item
            try:
                index = int(opcode[3:]) - 1  # DUP1 -> index 0
                self.stack_peek(index, "a0")
                self.stack_push("a0")
            except ValueError:
                instructions.append(f"    # ERROR: Invalid DUP instruction")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: {opcode}")
                
        elif opcode.startswith('SWAP'):
            # Swap stack items
            try:
                depth = int(opcode[4:])  # SWAP1 -> depth 1
                
                # Peek at the top item and the item at depth
                self.stack_peek(0, "t0")
                self.stack_peek(depth, "t1")
                
                # Replace them with each other
                self.stack_replace(0, "t1")
                self.stack_replace(depth, "t0")
            except ValueError:
                instructions.append(f"    # ERROR: Invalid SWAP instruction")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 3  # Gas: {opcode}")
                
        elif opcode.startswith('LOG'):
            # Log event
            try:
                topics = int(opcode[3:])  # LOG0, LOG1, LOG2, etc.
                
                # Pop topics + 2 items (data offset and length)
                topic_regs = []
                for i in range(topics):
                    self.stack_pop(f"a{i+2}")
                    topic_regs.append(f"a{i+2}")
                    
                self.stack_pop("a1")  # Length
                self.stack_pop("a0")  # Offset
                
                instructions.append(f"    # Log event with {topics} topics")
                # In a real implementation, this would emit an event
            except ValueError:
                instructions.append(f"    # ERROR: Invalid LOG instruction")
            
            # Add gas cost
            if self.gas_metering:
                log_cost = 375 + (topics * 375)
                instructions.append(f"    addi a4, a4, {log_cost}  # Gas: {opcode}")
                
        elif opcode == 'CREATE':
            # Create new contract
            self.stack_pop("a2")  # Init code size
            self.stack_pop("a1")  # Init code offset
            self.stack_pop("a0")  # Value
            instructions.append(f"    li a0, 0  # Placeholder for new contract address")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 32000  # Gas: CREATE")
                
        elif opcode == 'CALL':
            # Call contract
            self.stack_pop("a6")  # Out size
            self.stack_pop("a5")  # Out offset
            self.stack_pop("a4")  # In size
            self.stack_pop("a3")  # In offset
            self.stack_pop("a2")  # Value
            self.stack_pop("a1")  # Address
            self.stack_pop("a0")  # Gas
            instructions.append(f"    li a0, 1  # Success (placeholder)")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 100  # Gas: CALL (placeholder)")
                
        elif opcode == 'CALLCODE':
            # Call contract code in current context
            self.stack_pop("a6")  # Out size
            self.stack_pop("a5")  # Out offset
            self.stack_pop("a4")  # In size
            self.stack_pop("a3")  # In offset
            self.stack_pop("a2")  # Value
            self.stack_pop("a1")  # Address
            self.stack_pop("a0")  # Gas
            instructions.append(f"    li a0, 1  # Success (placeholder)")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 100  # Gas: CALLCODE (placeholder)")
                
        elif opcode == 'RETURN':
            # Return data
            self.stack_pop("a1")  # Length
            self.stack_pop("a0")  # Offset
            instructions.append(f"    # Prepare return data")
            instructions.append(f"    j exit")
            
            # No gas cost since execution ends
                
        elif opcode == 'DELEGATECALL':
            # Call code with current context
            self.stack_pop("a5")  # Out size
            self.stack_pop("a4")  # Out offset
            self.stack_pop("a3")  # In size
            self.stack_pop("a2")  # In offset
            self.stack_pop("a1")  # Address
            self.stack_pop("a0")  # Gas
            instructions.append(f"    li a0, 1  # Success (placeholder)")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 100  # Gas: DELEGATECALL (placeholder)")
                
        elif opcode == 'STATICCALL':
            # Static call (no state changes allowed)
            self.stack_pop("a5")  # Out size
            self.stack_pop("a4")  # Out offset
            self.stack_pop("a3")  # In size
            self.stack_pop("a2")  # In offset
            self.stack_pop("a1")  # Address
            self.stack_pop("a0")  # Gas
            instructions.append(f"    li a0, 1  # Success (placeholder)")
            self.stack_push("a0")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 100  # Gas: STATICCALL (placeholder)")
                
        elif opcode == 'REVERT':
            # Revert state and return data
            self.stack_pop("a1")  # Length
            self.stack_pop("a0")  # Offset
            instructions.append(f"    # Prepare reverted data")
            instructions.append(f"    li a0, 1  # Revert flag")
            instructions.append(f"    j exit")
            
            # No gas cost since execution ends
                
        elif opcode == 'INVALID':
            # Invalid instruction
            instructions.append(f"    # Invalid instruction")
            instructions.append(f"    li a0, 0  # Failure")
            instructions.append(f"    j exit")
            
            # No gas cost since execution ends
                
        elif opcode == 'SELFDESTRUCT':
            # Self-destruct contract
            self.stack_pop("a0")  # Beneficiary address
            instructions.append(f"    # Self-destruct contract - send funds to beneficiary")
            instructions.append(f"    j exit")
            
            # Add gas cost
            if self.gas_metering:
                instructions.append(f"    addi a4, a4, 5000  # Gas: SELFDESTRUCT")
        
        else:
            # Unknown opcode
            instructions.append(f"    # Unknown opcode: {opcode}")
        
        return instructions
    
    def evm_to_riscv_label(self, evm_label: str) -> str:
        """Convert an EVM label to a RISC-V label."""
        # Strip the colon if present
        if evm_label.endswith(':'):
            evm_label = evm_label[:-1]
            
        # Check if we've already mapped this label
        if evm_label in self.label_map:
            return self.label_map[evm_label]
            
        # Create a new mapping
        riscv_label = f"evm_addr_{evm_label}"
        self.label_map[evm_label] = riscv_label
        return riscv_label
    
    def transpile(self) -> None:
        """Transpile EVM assembly to RISC-V assembly."""
        # Load the EVM assembly
        self.load_evm_asm()
        
        # Emit header
        self.emit_header()
        
        # Parse the EVM assembly
        parsed_instructions = self.parse_evm_asm()
        
        # Translate each instruction
        for opcode, operand, comment in parsed_instructions:
            riscv_instructions = self.translate_evm_instruction(opcode, operand, comment)
            self.riscv_asm.extend(riscv_instructions)
        
        # Emit footer
        self.emit_footer()
        
        # Write the RISC-V assembly to file
        try:
            with open(self.output_file, 'w') as f:
                for line in self.riscv_asm:
                    f.write(line + '\n')
        except IOError:
            print(f"Error: Could not write to output file {self.output_file}.")
            sys.exit(1)
    
    def analyze_stack_usage(self) -> Dict:
        """Analyze stack usage statistics."""
        return {
            "max_stack_depth": self.max_stack_depth,
            "register_stack_slots": len(self.stack_registers),
            "memory_stack_slots": max(0, self.max_stack_depth - len(self.stack_registers))
        }


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print("Usage: python riscv_emitter.py <input_asm_file> <output_riscv_file> [--gas-metering]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    gas_metering = "--gas-metering" in sys.argv
    
    print(f"Transpiling {input_file} to {output_file}...")
    emitter = RISCVEmitter(input_file, output_file, gas_metering)
    emitter.transpile()
    
    # Print stack usage statistics
    stats = emitter.analyze_stack_usage()
    print(f"Stack analysis:")
    print(f"  Maximum stack depth: {stats['max_stack_depth']}")
    print(f"  Register stack slots: {stats['register_stack_slots']}")
    print(f"  Memory stack slots: {stats['memory_stack_slots']}")
    
    print(f"Transpilation complete!")


if __name__ == "__main__":
    main()