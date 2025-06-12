#!/usr/bin/env python3
"""
Test suite for the RISC-V EVM VM

Tests basic functionality, EVM-specific features, and edge cases.
"""

import unittest
import tempfile
import os
import struct
from riscv_evm_vm import RISCV_VM, SegmentationFault, InvalidInstruction

class TestRISCVVM(unittest.TestCase):
    """Test cases for RISC-V VM"""
    
    def setUp(self):
        """Set up test VM"""
        self.vm = RISCV_VM(memory_size=1024*1024, debug=False)
    
    def test_register_operations(self):
        """Test register read/write"""
        # Test writing to register
        self.vm.write_register(1, 0x12345678)
        self.assertEqual(self.vm.read_register(1), 0x12345678)
        
        # Test x0 always zero
        self.vm.write_register(0, 0x12345678)
        self.assertEqual(self.vm.read_register(0), 0)
        
        # Test register bounds
        with self.assertRaises(Exception):
            self.vm.read_register(32)
        with self.assertRaises(Exception):
            self.vm.write_register(-1, 0)
    
    def test_memory_operations(self):
        """Test memory read/write"""
        # Test different sizes
        self.vm.write_memory(0x1000, 0x12, 1)
        self.assertEqual(self.vm.read_memory(0x1000, 1), 0x12)
        
        self.vm.write_memory(0x1004, 0x1234, 2)
        self.assertEqual(self.vm.read_memory(0x1004, 2), 0x1234)
        
        self.vm.write_memory(0x1008, 0x12345678, 4)
        self.assertEqual(self.vm.read_memory(0x1008, 4), 0x12345678)
        
        self.vm.write_memory(0x1010, 0x123456789ABCDEF0, 8)
        self.assertEqual(self.vm.read_memory(0x1010, 8), 0x123456789ABCDEF0)
        
        # Test bounds checking
        with self.assertRaises(SegmentationFault):
            self.vm.read_memory(self.vm.memory_size, 1)
        
        with self.assertRaises(SegmentationFault):
            self.vm.write_memory(self.vm.memory_size, 0, 1)
    
    def test_instruction_decoding(self):
        """Test instruction decoding"""
        # Test ADDI x1, x0, 100 (0x06400093)
        instruction = 0x06400093
        rd, funct3, rs1, imm = self.vm.decode_i_type(instruction)
        self.assertEqual(rd, 1)
        self.assertEqual(funct3, 0)
        self.assertEqual(rs1, 0)
        self.assertEqual(imm, 100)
    
    def test_simple_program(self):
        """Test execution of a simple program"""
        # Create a simple program: ADDI x1, x0, 42; ADDI x2, x1, 1; ECALL
        program = [
            0x02a00093,  # ADDI x1, x0, 42
            0x00108113,  # ADDI x2, x1, 1  
            0x00000073   # ECALL (exit)
        ]
        
        # Load program into memory
        for i, inst in enumerate(program):
            self.vm.write_memory(0x1000 + i*4, inst, 4)
        
        # Set PC and run
        self.vm.cpu.pc = 0x1000
        
        # Execute instructions
        for _ in range(3):
            if self.vm.cpu.pc == 0x1000:
                # ADDI x1, x0, 42
                inst = self.vm.fetch_instruction()
                self.vm.execute_instruction(inst)
                self.assertEqual(self.vm.read_register(1), 42)
            elif self.vm.cpu.pc == 0x1004:
                # ADDI x2, x1, 1
                inst = self.vm.fetch_instruction()
                self.vm.execute_instruction(inst)
                self.assertEqual(self.vm.read_register(2), 43)
            elif self.vm.cpu.pc == 0x1008:
                # ECALL - should trigger exit
                inst = self.vm.fetch_instruction()
                result = self.vm.execute_instruction(inst)
                self.assertFalse(result)  # Should return False for exit
                break
    
    def test_branch_instructions(self):
        """Test branch instructions"""
        # Set up registers
        self.vm.write_register(1, 10)
        self.vm.write_register(2, 10)
        self.vm.cpu.pc = 0x1000
        
        # BEQ x1, x2, 8 (should branch)
        beq_inst = 0x00208463  # BEQ x1, x2, +8
        self.vm.execute_instruction(beq_inst)
        self.assertEqual(self.vm.cpu.pc, 0x1008)  # Should have branched
        
        # Reset PC
        self.vm.cpu.pc = 0x1000
        self.vm.write_register(2, 5)  # Different value
        
        # BEQ x1, x2, 8 (should not branch)
        self.vm.execute_instruction(beq_inst)
        self.assertEqual(self.vm.cpu.pc, 0x1004)  # Should not have branched
    
    def test_load_store(self):
        """Test load and store instructions"""
        # Set up base address in register
        self.vm.write_register(1, 0x2000)
        self.vm.cpu.pc = 0x1000
        
        # Store word: SW x2, 0(x1) where x2 = 0x12345678
        self.vm.write_register(2, 0x12345678)
        sw_inst = 0x0020a023  # SW x2, 0(x1)
        self.vm.execute_instruction(sw_inst)
        
        # Verify memory was written
        value = self.vm.read_memory(0x2000, 4)
        self.assertEqual(value, 0x12345678)
        
        # Load word: LW x3, 0(x1)
        lw_inst = 0x0000a183  # LW x3, 0(x1)
        self.vm.execute_instruction(lw_inst)
        
        # Verify register was loaded
        self.assertEqual(self.vm.read_register(3), 0x12345678)
    
    def test_evm_syscalls(self):
        """Test EVM-specific syscalls"""
        # Test storage write
        self.vm.write_register(10, 0x123)  # key
        self.vm.write_register(11, 0x456)  # value
        self.vm.write_register(17, 1002)   # syscall number
        
        result = self.vm.handle_ecall()
        self.assertTrue(result)
        self.assertEqual(self.vm.evm_storage[0x123], 0x456)
        
        # Test storage read
        self.vm.write_register(10, 0x123)  # key
        self.vm.write_register(17, 1001)   # syscall number
        
        result = self.vm.handle_ecall()
        self.assertTrue(result)
        self.assertEqual(self.vm.read_register(10), 0x456)  # Should return stored value
    
    def test_sign_extension(self):
        """Test sign extension"""
        # Test positive number
        result = self.vm.sign_extend(0x7FF, 12)
        self.assertEqual(result, 0x7FF)
        
        # Test negative number
        result = self.vm.sign_extend(0x800, 12)
        self.assertEqual(result, -2048)
    
    def create_minimal_elf(self, instructions):
        """Create a minimal ELF file for testing"""
        # This is a simplified ELF creation for testing
        # In practice, you'd want to use proper ELF libraries
        
        # ELF header (simplified)
        elf_header = bytearray(64)
        elf_header[0:4] = b'\x7fELF'  # Magic
        elf_header[4] = 2           # 64-bit
        elf_header[5] = 1           # Little endian
        elf_header[6] = 1           # ELF version
        
        # Entry point at offset 24 (little endian)
        struct.pack_into('<Q', elf_header, 24, 0x10000)
        
        # Create temporary file
        with tempfile.NamedTemporaryFile(delete=False) as f:
            f.write(elf_header)
            
            # Pad to load address
            f.write(b'\x00' * (0x10000 - len(elf_header)))
            
            # Write instructions
            for inst in instructions:
                f.write(struct.pack('<I', inst))
            
            return f.name
    
    def test_elf_loading(self):
        """Test ELF file loading"""
        # Create a test ELF with a simple program
        instructions = [
            0x02a00093,  # ADDI x1, x0, 42
            0x00000073   # ECALL
        ]
        
        elf_file = self.create_minimal_elf(instructions)
        
        try:
            # Load ELF
            success = self.vm.load_elf(elf_file)
            self.assertTrue(success)
            self.assertEqual(self.vm.cpu.pc, 0x10000)
            
        finally:
            # Clean up
            os.unlink(elf_file)

class TestVMIntegration(unittest.TestCase):
    """Integration tests for VM with actual transpiled code"""
    
    def setUp(self):
        self.vm = RISCV_VM(debug=True)
    
    def test_with_sample_output(self):
        """Test with actual output from transpiler"""
        # This would test with the actual output.elf from the transpiler
        # For now, we'll simulate what such a test would look like
        
        if os.path.exists("/app/sol2risc-v/src/output.elf"):
            success = self.vm.load_elf("/app/sol2risc-v/src/output.elf")
            if success:
                print(f"Successfully loaded ELF, entry point: 0x{self.vm.cpu.pc:x}")
                
                # Try to run a few instructions
                try:
                    for i in range(10):
                        if not self.vm.step():
                            break
                        print(f"Step {i+1}: PC=0x{self.vm.cpu.pc:x}")
                except Exception as e:
                    print(f"Execution stopped with error: {e}")
                    self.vm.print_state()

if __name__ == '__main__':
    # Run tests
    unittest.main(argv=[''], exit=False, verbosity=2)
    
    # Also run integration test if output file exists
    print("\n" + "="*50)
    print("Running integration test with actual transpiler output...")
    
    integration_test = TestVMIntegration()
    integration_test.setUp()
    integration_test.test_with_sample_output()
