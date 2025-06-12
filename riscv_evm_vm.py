#!/usr/bin/env python3
"""
RISC-V Virtual Machine for EVM-Transpiled Code

This VM is specifically designed to execute RISC-V assembly code that has been
transpiled from EVM (Ethereum Virtual Machine) assembly. It provides:

1. ELF file loading and parsing
2. RISC-V instruction execution simulation
3. EVM-specific runtime environment
4. Advanced debugging and diagnostics
5. Segmentation fault prevention and error handling
"""

import struct
import sys
import os
import logging
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field
from enum import Enum
import argparse

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class VMException(Exception):
    """Base exception for VM-related errors"""
    pass

class SegmentationFault(VMException):
    """Memory access violation"""
    pass

class InvalidInstruction(VMException):
    """Invalid or unsupported instruction"""
    pass

class OutOfGas(VMException):
    """Out of gas error (EVM compatibility)"""
    pass

@dataclass
class ELFHeader:
    """ELF file header structure"""
    entry_point: int = 0
    program_headers: List[Dict] = field(default_factory=list)
    section_headers: List[Dict] = field(default_factory=list)

@dataclass
class CPUState:
    """RISC-V CPU state"""
    # 32 general-purpose registers (x0-x31)
    registers: List[int] = field(default_factory=lambda: [0] * 32)
    # Program counter
    pc: int = 0
    # Stack pointer (aliased to x2)
    sp: int = 0
    # EVM-specific registers
    gas_remaining: int = 1000000
    evm_stack_depth: int = 0
    
    def __post_init__(self):
        # x0 is always zero
        self.registers[0] = 0
        # Initialize stack pointer (x2)
        self.sp = 0x10000000  # High memory address for stack
        self.registers[2] = self.sp

class InstructionType(Enum):
    R_TYPE = "R"  # Register-register operations
    I_TYPE = "I"  # Immediate operations
    S_TYPE = "S"  # Store operations
    B_TYPE = "B"  # Branch operations
    U_TYPE = "U"  # Upper immediate
    J_TYPE = "J"  # Jump operations

class RISCV_VM:
    """RISC-V Virtual Machine optimized for EVM-transpiled code"""
    
    def __init__(self, memory_size: int = 16 * 1024 * 1024, debug: bool = False):
        self.debug = debug
        self.memory_size = memory_size
        self.memory = bytearray(memory_size)
        self.cpu = CPUState()
        self.elf_header = ELFHeader()
        
        # EVM-specific storage
        self.evm_stack: List[int] = []  # 256-bit values stored as integers
        self.evm_memory: bytearray = bytearray(1024 * 1024)  # 1MB EVM memory
        self.evm_storage: Dict[int, int] = {}
        self.evm_calldata: bytes = b""
        
        # Memory regions
        self.STACK_BASE = 0x10000000
        self.HEAP_BASE = 0x20000000
        self.EVM_MEMORY_BASE = 0x30000000
        
        # Execution statistics
        self.instruction_count = 0
        self.max_instructions = 10000000  # Safety limit
        
        # Breakpoints for debugging
        self.breakpoints: set = set()
        
        logger.info(f"VM initialized with {memory_size} bytes of memory")
    
    def load_elf(self, elf_path: str) -> bool:
        """Load and parse ELF file"""
        try:
            with open(elf_path, 'rb') as f:
                elf_data = f.read()
            
            # Basic ELF header parsing (simplified)
            if len(elf_data) < 64:
                raise VMException(f"File too small to be valid ELF: {len(elf_data)} bytes")
            
            # Check ELF magic
            if elf_data[:4] != b'\x7fELF':
                raise VMException("Invalid ELF magic number")
            
            # Parse ELF header (simplified for RISC-V 64-bit)
            ei_class = elf_data[4]  # 1=32-bit, 2=64-bit
            ei_data = elf_data[5]   # 1=little-endian, 2=big-endian
            
            if ei_class != 2:
                raise VMException("Only 64-bit ELF files supported")
            if ei_data != 1:
                raise VMException("Only little-endian ELF files supported")
            
            # Extract entry point (64-bit little-endian at offset 24)
            self.elf_header.entry_point = struct.unpack('<Q', elf_data[24:32])[0]
            
            # For now, load the entire file into memory starting at address 0
            if len(elf_data) > self.memory_size:
                raise VMException("ELF file too large for memory")
            
            # Copy ELF data to memory
            self.memory[0:len(elf_data)] = elf_data
            
            # Set up proper memory layout for RISC-V EVM execution
            # Initialize memory regions that the transpiler expects
            self.setup_memory_regions()
            
            # Set PC to entry point (typically 0x10000 for _start)
            self.cpu.pc = self.elf_header.entry_point
            
            # Initialize stack pointer properly for RISC-V
            # Based on the disassembly, _start sets up: lui sp,0x29; li t0,512; add sp,sp,t0; andi sp,sp,-16; addi sp,sp,-64
            # This results in sp = 0x29000 + 512 = 0x29200, aligned to 16-byte boundary, then -64 = 0x291C0
            self.cpu.sp = 0x29000 + 512  # Base stack address from disassembly
            self.cpu.sp = self.cpu.sp & ~15  # Align to 16-byte boundary  
            self.cpu.sp = self.cpu.sp - 64   # Initial frame
            self.cpu.registers[2] = self.cpu.sp  # x2 is the stack pointer
            
            logger.info(f"ELF loaded: entry_point=0x{self.elf_header.entry_point:x}, sp=0x{self.cpu.sp:x}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to load ELF file {elf_path}: {e}")
            return False
    
    def setup_memory_regions(self):
        """Setup memory regions expected by the transpiler"""
        # Based on disassembly, key memory regions:
        # MEM_BASE = 0x20000 (used by calldatasize and others)
        # CALLDATA_BASE = 0x20400
        # STACK_BASE varies but around 0x29000
        # EVM_STACK area around 0x26120
        
        # Initialize MEM_BASE area (0x20000)
        mem_base = 0x20000
        if mem_base + 1024 < len(self.memory):
            # Clear MEM_BASE region
            for i in range(1024):
                self.memory[mem_base + i] = 0
        
        # Initialize CALLDATA_BASE area (0x20400) 
        calldata_base = 0x20400
        if calldata_base + 1024 < len(self.memory):
            # Clear CALLDATA region
            for i in range(1024):
                self.memory[calldata_base + i] = 0
        
        # Initialize EVM stack area (around 0x26120)
        evm_stack_base = 0x26120
        if evm_stack_base + 0x1000 < len(self.memory):
            # Clear EVM stack region
            for i in range(0x1000):
                self.memory[evm_stack_base + i] = 0
    
    def check_memory_access(self, address: int, size: int = 4, write: bool = False) -> bool:
        """Check if memory access is valid"""
        if address < 0 or address + size > self.memory_size:
            raise SegmentationFault(f"Memory access out of bounds: 0x{address:x} (size {size})")
        return True
    
    def read_memory(self, address: int, size: int) -> int:
        """Read from memory with bounds checking"""
        self.check_memory_access(address, size)
        
        if size == 1:
            return self.memory[address]
        elif size == 2:
            return struct.unpack('<H', self.memory[address:address+2])[0]
        elif size == 4:
            return struct.unpack('<I', self.memory[address:address+4])[0]
        elif size == 8:
            return struct.unpack('<Q', self.memory[address:address+8])[0]
        else:
            raise VMException(f"Unsupported memory read size: {size}")
    
    def write_memory(self, address: int, value: int, size: int):
        """Write to memory with bounds checking"""
        self.check_memory_access(address, size, write=True)
        
        if size == 1:
            self.memory[address] = value & 0xFF
        elif size == 2:
            struct.pack_into('<H', self.memory, address, value & 0xFFFF)
        elif size == 4:
            struct.pack_into('<I', self.memory, address, value & 0xFFFFFFFF)
        elif size == 8:
            struct.pack_into('<Q', self.memory, address, value & 0xFFFFFFFFFFFFFFFF)
        else:
            raise VMException(f"Unsupported memory write size: {size}")
    
    def read_register(self, reg: int) -> int:
        """Read from register"""
        if reg < 0 or reg >= 32:
            raise VMException(f"Invalid register number: {reg}")
        return self.cpu.registers[reg]
    
    def write_register(self, reg: int, value: int):
        """Write to register"""
        if reg < 0 or reg >= 32:
            raise VMException(f"Invalid register number: {reg}")
        if reg == 0:
            return  # x0 is always zero
        
        # Sign extend for 64-bit
        value = value & 0xFFFFFFFFFFFFFFFF
        self.cpu.registers[reg] = value
        
        # Update stack pointer alias
        if reg == 2:
            self.cpu.sp = value
    
    def sign_extend(self, value: int, bits: int) -> int:
        """Sign extend a value"""
        sign_bit = 1 << (bits - 1)
        return (value & (sign_bit - 1)) - (value & sign_bit)
    
    def fetch_instruction(self) -> int:
        """Fetch instruction from memory"""
        try:
            instruction = self.read_memory(self.cpu.pc, 4)
            self.cpu.pc += 4
            return instruction
        except SegmentationFault:
            raise SegmentationFault(f"Instruction fetch failed at PC=0x{self.cpu.pc:x}")
    
    def decode_r_type(self, instruction: int) -> Tuple[int, int, int, int, int]:
        """Decode R-type instruction"""
        rd = (instruction >> 7) & 0x1F
        funct3 = (instruction >> 12) & 0x7
        rs1 = (instruction >> 15) & 0x1F
        rs2 = (instruction >> 20) & 0x1F
        funct7 = (instruction >> 25) & 0x7F
        return rd, funct3, rs1, rs2, funct7
    
    def decode_i_type(self, instruction: int) -> Tuple[int, int, int, int]:
        """Decode I-type instruction"""
        rd = (instruction >> 7) & 0x1F
        funct3 = (instruction >> 12) & 0x7
        rs1 = (instruction >> 15) & 0x1F
        imm = self.sign_extend((instruction >> 20) & 0xFFF, 12)
        return rd, funct3, rs1, imm
    
    def decode_s_type(self, instruction: int) -> Tuple[int, int, int, int]:
        """Decode S-type instruction"""
        imm_low = (instruction >> 7) & 0x1F
        funct3 = (instruction >> 12) & 0x7
        rs1 = (instruction >> 15) & 0x1F
        rs2 = (instruction >> 20) & 0x1F
        imm_high = (instruction >> 25) & 0x7F
        imm = self.sign_extend((imm_high << 5) | imm_low, 12)
        return funct3, rs1, rs2, imm
    
    def decode_b_type(self, instruction: int) -> Tuple[int, int, int, int]:
        """Decode B-type instruction"""
        imm_11 = (instruction >> 7) & 0x1
        imm_1_4 = (instruction >> 8) & 0xF
        funct3 = (instruction >> 12) & 0x7
        rs1 = (instruction >> 15) & 0x1F
        rs2 = (instruction >> 20) & 0x1F
        imm_5_10 = (instruction >> 25) & 0x3F
        imm_12 = (instruction >> 31) & 0x1
        
        imm = (imm_12 << 12) | (imm_11 << 11) | (imm_5_10 << 5) | (imm_1_4 << 1)
        imm = self.sign_extend(imm, 13)
        return funct3, rs1, rs2, imm
    
    def decode_u_type(self, instruction: int) -> Tuple[int, int]:
        """Decode U-type instruction"""
        rd = (instruction >> 7) & 0x1F
        imm = instruction & 0xFFFFF000
        return rd, imm
    
    def decode_j_type(self, instruction: int) -> Tuple[int, int]:
        """Decode J-type instruction"""
        rd = (instruction >> 7) & 0x1F
        imm_12_19 = (instruction >> 12) & 0xFF
        imm_11 = (instruction >> 20) & 0x1
        imm_1_10 = (instruction >> 21) & 0x3FF
        imm_20 = (instruction >> 31) & 0x1
        
        imm = (imm_20 << 20) | (imm_12_19 << 12) | (imm_11 << 11) | (imm_1_10 << 1)
        imm = self.sign_extend(imm, 21)
        return rd, imm
    
    def execute_instruction(self, instruction: int) -> bool:
        """Execute a single instruction"""
        opcode = instruction & 0x7F
        
        try:
            if opcode == 0x37:  # LUI
                rd, imm = self.decode_u_type(instruction)
                self.write_register(rd, imm)
                if self.debug:
                    logger.debug(f"LUI x{rd}, 0x{imm:x}")
            
            elif opcode == 0x17:  # AUIPC
                rd, imm = self.decode_u_type(instruction)
                self.write_register(rd, (self.cpu.pc - 4) + imm)
                if self.debug:
                    logger.debug(f"AUIPC x{rd}, 0x{imm:x}")
            
            elif opcode == 0x6F:  # JAL
                rd, imm = self.decode_j_type(instruction)
                self.write_register(rd, self.cpu.pc)
                self.cpu.pc = (self.cpu.pc - 4) + imm
                if self.debug:
                    logger.debug(f"JAL x{rd}, 0x{self.cpu.pc:x}")
            
            elif opcode == 0x67:  # JALR
                rd, funct3, rs1, imm = self.decode_i_type(instruction)
                target = (self.read_register(rs1) + imm) & ~1
                self.write_register(rd, self.cpu.pc)
                self.cpu.pc = target
                if self.debug:
                    logger.debug(f"JALR x{rd}, x{rs1}, {imm}")
            
            elif opcode == 0x63:  # Branch instructions
                funct3, rs1, rs2, imm = self.decode_b_type(instruction)
                rs1_val = self.read_register(rs1)
                rs2_val = self.read_register(rs2)
                
                branch_taken = False
                if funct3 == 0x0:  # BEQ
                    branch_taken = rs1_val == rs2_val
                elif funct3 == 0x1:  # BNE
                    branch_taken = rs1_val != rs2_val
                elif funct3 == 0x4:  # BLT
                    branch_taken = self.sign_extend(rs1_val, 64) < self.sign_extend(rs2_val, 64)
                elif funct3 == 0x5:  # BGE
                    branch_taken = self.sign_extend(rs1_val, 64) >= self.sign_extend(rs2_val, 64)
                elif funct3 == 0x6:  # BLTU
                    branch_taken = rs1_val < rs2_val
                elif funct3 == 0x7:  # BGEU
                    branch_taken = rs1_val >= rs2_val
                
                if branch_taken:
                    self.cpu.pc = (self.cpu.pc - 4) + imm
                
                if self.debug:
                    logger.debug(f"Branch funct3={funct3}, taken={branch_taken}")
            
            elif opcode == 0x03:  # Load instructions
                rd, funct3, rs1, imm = self.decode_i_type(instruction)
                address = self.read_register(rs1) + imm
                
                if funct3 == 0x0:  # LB
                    value = self.sign_extend(self.read_memory(address, 1), 8)
                elif funct3 == 0x1:  # LH
                    value = self.sign_extend(self.read_memory(address, 2), 16)
                elif funct3 == 0x2:  # LW
                    value = self.sign_extend(self.read_memory(address, 4), 32)
                elif funct3 == 0x3:  # LD
                    value = self.read_memory(address, 8)
                elif funct3 == 0x4:  # LBU
                    value = self.read_memory(address, 1)
                elif funct3 == 0x5:  # LHU
                    value = self.read_memory(address, 2)
                elif funct3 == 0x6:  # LWU
                    value = self.read_memory(address, 4)
                else:
                    raise InvalidInstruction(f"Invalid load funct3: {funct3}")
                
                self.write_register(rd, value)
                if self.debug:
                    logger.debug(f"Load x{rd} <- [0x{address:x}] = 0x{value:x}")
            
            elif opcode == 0x23:  # Store instructions
                funct3, rs1, rs2, imm = self.decode_s_type(instruction)
                address = self.read_register(rs1) + imm
                value = self.read_register(rs2)
                
                if funct3 == 0x0:  # SB
                    self.write_memory(address, value, 1)
                elif funct3 == 0x1:  # SH
                    self.write_memory(address, value, 2)
                elif funct3 == 0x2:  # SW
                    self.write_memory(address, value, 4)
                elif funct3 == 0x3:  # SD
                    self.write_memory(address, value, 8)
                else:
                    raise InvalidInstruction(f"Invalid store funct3: {funct3}")
                
                if self.debug:
                    logger.debug(f"Store [0x{address:x}] <- x{rs2} = 0x{value:x}")
            
            elif opcode == 0x13:  # Immediate arithmetic
                rd, funct3, rs1, imm = self.decode_i_type(instruction)
                rs1_val = self.read_register(rs1)
                
                if funct3 == 0x0:  # ADDI
                    result = rs1_val + imm
                elif funct3 == 0x2:  # SLTI
                    result = 1 if self.sign_extend(rs1_val, 64) < imm else 0
                elif funct3 == 0x3:  # SLTIU
                    result = 1 if rs1_val < (imm & 0xFFFFFFFFFFFFFFFF) else 0
                elif funct3 == 0x4:  # XORI
                    result = rs1_val ^ imm
                elif funct3 == 0x6:  # ORI
                    result = rs1_val | imm
                elif funct3 == 0x7:  # ANDI
                    result = rs1_val & imm
                elif funct3 == 0x1:  # SLLI
                    shamt = imm & 0x3F
                    result = rs1_val << shamt
                elif funct3 == 0x5:  # SRLI/SRAI
                    shamt = imm & 0x3F
                    if imm & 0x400:  # SRAI
                        result = self.sign_extend(rs1_val, 64) >> shamt
                    else:  # SRLI
                        result = rs1_val >> shamt
                else:
                    raise InvalidInstruction(f"Invalid immediate arithmetic funct3: {funct3}")
                
                self.write_register(rd, result)
                if self.debug:
                    logger.debug(f"Immediate arithmetic x{rd} = x{rs1} op {imm} = 0x{result:x}")
            
            elif opcode == 0x33:  # Register arithmetic
                rd, funct3, rs1, rs2, funct7 = self.decode_r_type(instruction)
                rs1_val = self.read_register(rs1)
                rs2_val = self.read_register(rs2)
                
                if funct3 == 0x0:
                    if funct7 == 0x00:  # ADD
                        result = rs1_val + rs2_val
                    elif funct7 == 0x20:  # SUB
                        result = rs1_val - rs2_val
                    else:
                        raise InvalidInstruction(f"Invalid ADD/SUB funct7: {funct7}")
                elif funct3 == 0x1:  # SLL
                    result = rs1_val << (rs2_val & 0x3F)
                elif funct3 == 0x2:  # SLT
                    result = 1 if self.sign_extend(rs1_val, 64) < self.sign_extend(rs2_val, 64) else 0
                elif funct3 == 0x3:  # SLTU
                    result = 1 if rs1_val < rs2_val else 0
                elif funct3 == 0x4:  # XOR
                    result = rs1_val ^ rs2_val
                elif funct3 == 0x5:
                    if funct7 == 0x00:  # SRL
                        result = rs1_val >> (rs2_val & 0x3F)
                    elif funct7 == 0x20:  # SRA
                        result = self.sign_extend(rs1_val, 64) >> (rs2_val & 0x3F)
                    else:
                        raise InvalidInstruction(f"Invalid SRL/SRA funct7: {funct7}")
                elif funct3 == 0x6:  # OR
                    result = rs1_val | rs2_val
                elif funct3 == 0x7:  # AND
                    result = rs1_val & rs2_val
                else:
                    raise InvalidInstruction(f"Invalid register arithmetic funct3: {funct3}")
                
                self.write_register(rd, result)
                if self.debug:
                    logger.debug(f"Register arithmetic x{rd} = x{rs1} op x{rs2} = 0x{result:x}")
            
            elif opcode == 0x73:  # System instructions
                if instruction == 0x00000073:  # ECALL
                    return self.handle_ecall()
                elif instruction == 0x00100073:  # EBREAK
                    logger.info("EBREAK encountered - entering debug mode")
                    return False
                else:
                    raise InvalidInstruction(f"Unknown system instruction: 0x{instruction:x}")
            
            else:
                raise InvalidInstruction(f"Unknown opcode: 0x{opcode:x}")
            
            return True
            
        except Exception as e:
            logger.error(f"Execution error at PC=0x{self.cpu.pc-4:x}, instruction=0x{instruction:x}: {e}")
            raise
    
    def handle_ecall(self) -> bool:
        """Handle system calls (ECALL instruction)"""
        syscall_num = self.read_register(17)  # a7 register
        
        if syscall_num == 93:  # exit
            exit_code = self.read_register(10)  # a0 register
            logger.info(f"Program exited with code {exit_code}")
            return False
        elif syscall_num == 1001:  # EVM storage read
            key = self.read_register(10)  # a0
            value = self.evm_storage.get(key, 0)
            self.write_register(10, value)
            logger.debug(f"EVM storage read: key=0x{key:x}, value=0x{value:x}")
        elif syscall_num == 1002:  # EVM storage write
            key = self.read_register(10)  # a0
            value = self.read_register(11)  # a1
            self.evm_storage[key] = value
            logger.debug(f"EVM storage write: key=0x{key:x}, value=0x{value:x}")
        else:
            logger.warning(f"Unknown syscall: {syscall_num}")
        
        return True
    
    def run(self, max_instructions: Optional[int] = None) -> bool:
        """Run the VM until completion or error"""
        if max_instructions:
            self.max_instructions = max_instructions
        
        logger.info(f"Starting execution from PC=0x{self.cpu.pc:x}")
        
        try:
            while self.instruction_count < self.max_instructions:
                # Check for breakpoints
                if self.cpu.pc in self.breakpoints:
                    logger.info(f"Breakpoint hit at PC=0x{self.cpu.pc:x}")
                    self.print_state()
                    input("Press Enter to continue...")
                
                # Fetch and execute instruction
                instruction = self.fetch_instruction()
                self.instruction_count += 1
                
                # Deduct gas for EVM compatibility
                if self.cpu.gas_remaining > 0:
                    self.cpu.gas_remaining -= 1
                else:
                    raise OutOfGas("Out of gas")
                
                if not self.execute_instruction(instruction):
                    break
                
                # Periodic status update
                if self.instruction_count % 10000 == 0:
                    logger.info(f"Executed {self.instruction_count} instructions, PC=0x{self.cpu.pc:x}")
            
            if self.instruction_count >= self.max_instructions:
                logger.warning(f"Maximum instruction limit reached: {self.max_instructions}")
                return False
            
            logger.info(f"Execution completed successfully after {self.instruction_count} instructions")
            return True
            
        except Exception as e:
            logger.error(f"VM execution failed: {e}")
            self.print_state()
            return False
    
    def print_state(self):
        """Print current VM state for debugging"""
        print(f"\n=== VM State ===")
        print(f"PC: 0x{self.cpu.pc:x}")
        print(f"Instructions executed: {self.instruction_count}")
        print(f"Gas remaining: {self.cpu.gas_remaining}")
        
        print("\nRegisters:")
        for i in range(0, 32, 4):
            print(f"x{i:02d}-x{i+3:02d}: " + " ".join(f"0x{self.cpu.registers[j]:016x}" for j in range(i, min(i+4, 32))))
        
        print(f"\nStack (SP=0x{self.cpu.sp:x}):")
        try:
            for i in range(8):
                addr = self.cpu.sp + i * 8
                value = self.read_memory(addr, 8)
                print(f"  [0x{addr:x}] = 0x{value:016x}")
        except:
            print("  Stack not accessible")
        
        print(f"\nEVM Stack depth: {len(self.evm_stack)}")
        if self.evm_stack:
            print("Top 4 EVM stack values:")
            for i, value in enumerate(self.evm_stack[-4:]):
                print(f"  [{len(self.evm_stack)-1-i}] = 0x{value:064x}")
    
    def add_breakpoint(self, address: int):
        """Add a breakpoint at the specified address"""
        self.breakpoints.add(address)
        logger.info(f"Breakpoint added at 0x{address:x}")
    
    def remove_breakpoint(self, address: int):
        """Remove a breakpoint"""
        self.breakpoints.discard(address)
        logger.info(f"Breakpoint removed from 0x{address:x}")
    
    def step(self) -> bool:
        """Execute a single instruction"""
        try:
            instruction = self.fetch_instruction()
            self.instruction_count += 1
            return self.execute_instruction(instruction)
        except Exception as e:
            logger.error(f"Step execution failed: {e}")
            return False

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="RISC-V VM for EVM-transpiled code")
    parser.add_argument("elf_file", help="ELF file to execute")
    parser.add_argument("--memory", type=int, default=64, help="Memory size in MB (default: 64)")
    parser.add_argument("--max-instructions", type=int, default=10000000, help="Maximum instructions to execute")
    parser.add_argument("--debug", action="store_true", help="Enable debug output")
    parser.add_argument("--breakpoint", type=str, action="append", help="Add breakpoint at address (hex)")
    
    args = parser.parse_args()
    
    # Set debug level
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Create VM
    vm = RISCV_VM(memory_size=args.memory * 1024 * 1024, debug=args.debug)
    
    # Add breakpoints
    if args.breakpoint:
        for bp in args.breakpoint:
            try:
                addr = int(bp, 16)
                vm.add_breakpoint(addr)
            except ValueError:
                logger.error(f"Invalid breakpoint address: {bp}")
                return 1
    
    # Load ELF file
    if not vm.load_elf(args.elf_file):
        logger.error("Failed to load ELF file")
        return 1
    
    # Run VM
    success = vm.run(args.max_instructions)
    
    if args.debug:
        vm.print_state()
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
