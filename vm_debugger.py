#!/usr/bin/env python3
"""
Interactive debugger for the RISC-V EVM VM

Provides an interactive debugging interface with commands for:
- Step-by-step execution
- Memory inspection
- Register inspection
- Breakpoint management
- EVM stack inspection
"""

import cmd
import sys
from riscv_evm_vm import RISCV_VM, logger
import logging

class VMDebugger(cmd.Cmd):
    """Interactive debugger for RISC-V VM"""
    
    intro = "RISC-V EVM VM Debugger. Type help or ? to list commands."
    prompt = "(vm-debug) "
    
    def __init__(self, vm: RISCV_VM):
        super().__init__()
        self.vm = vm
        self.running = False
    
    def do_load(self, arg):
        """Load an ELF file: load <filename>"""
        if not arg:
            print("Usage: load <filename>")
            return
        
        if self.vm.load_elf(arg):
            print(f"Successfully loaded {arg}")
            print(f"Entry point: 0x{self.vm.elf_header.entry_point:x}")
        else:
            print(f"Failed to load {arg}")
    
    def do_run(self, arg):
        """Run the program: run [max_instructions]"""
        max_inst = None
        if arg:
            try:
                max_inst = int(arg)
            except ValueError:
                print("Invalid number of instructions")
                return
        
        print("Running program...")
        self.running = True
        success = self.vm.run(max_inst)
        self.running = False
        
        if success:
            print("Program completed successfully")
        else:
            print("Program terminated")
        
        self.vm.print_state()
    
    def do_step(self, arg):
        """Execute a single instruction: step [count]"""
        count = 1
        if arg:
            try:
                count = int(arg)
            except ValueError:
                print("Invalid step count")
                return
        
        for i in range(count):
            print(f"\nStep {i+1}/{count}")
            print(f"PC: 0x{self.vm.cpu.pc:x}")
            
            try:
                instruction = self.vm.read_memory(self.vm.cpu.pc, 4)
                print(f"Next instruction: 0x{instruction:08x}")
            except:
                print("Cannot read next instruction")
            
            if not self.vm.step():
                print("Execution stopped")
                break
            
            print(f"New PC: 0x{self.vm.cpu.pc:x}")
        
        self.vm.print_state()
    
    def do_break(self, arg):
        """Set breakpoint: break <address_hex>"""
        if not arg:
            print("Current breakpoints:")
            for bp in self.vm.breakpoints:
                print(f"  0x{bp:x}")
            return
        
        try:
            addr = int(arg, 16)
            self.vm.add_breakpoint(addr)
        except ValueError:
            print("Invalid address format. Use hex without 0x prefix")
    
    def do_unbreak(self, arg):
        """Remove breakpoint: unbreak <address_hex>"""
        if not arg:
            print("Usage: unbreak <address_hex>")
            return
        
        try:
            addr = int(arg, 16)
            self.vm.remove_breakpoint(addr)
        except ValueError:
            print("Invalid address format")
    
    def do_reg(self, arg):
        """Show register: reg [register_number]"""
        if not arg:
            # Show all registers
            print("Registers:")
            for i in range(0, 32, 4):
                line = f"x{i:02d}-x{i+3:02d}: "
                for j in range(i, min(i+4, 32)):
                    line += f"0x{self.vm.cpu.registers[j]:016x} "
                print(line)
            return
        
        try:
            reg_num = int(arg)
            if 0 <= reg_num < 32:
                value = self.vm.read_register(reg_num)
                print(f"x{reg_num} = 0x{value:016x} ({value})")
            else:
                print("Register number must be 0-31")
        except ValueError:
            print("Invalid register number")
    
    def do_mem(self, arg):
        """Show memory: mem <address_hex> [size]"""
        parts = arg.split()
        if not parts:
            print("Usage: mem <address_hex> [size]")
            return
        
        try:
            addr = int(parts[0], 16)
            size = int(parts[1]) if len(parts) > 1 else 64
            
            print(f"Memory at 0x{addr:x}:")
            for i in range(0, size, 16):
                line = f"0x{addr+i:08x}: "
                hex_part = ""
                ascii_part = ""
                
                for j in range(16):
                    if i + j < size:
                        try:
                            byte_val = self.vm.read_memory(addr + i + j, 1)
                            hex_part += f"{byte_val:02x} "
                            ascii_part += chr(byte_val) if 32 <= byte_val < 127 else "."
                        except:
                            hex_part += "?? "
                            ascii_part += "?"
                    else:
                        hex_part += "   "
                        ascii_part += " "
                
                print(line + hex_part + " |" + ascii_part + "|")
        
        except ValueError:
            print("Invalid address format")
        except Exception as e:
            print(f"Error reading memory: {e}")
    
    def do_evm_stack(self, arg):
        """Show EVM stack: evm_stack [count]"""
        count = len(self.vm.evm_stack) if not arg else min(int(arg), len(self.vm.evm_stack))
        
        print(f"EVM Stack (depth: {len(self.vm.evm_stack)}):")
        if self.vm.evm_stack:
            for i in range(count):
                idx = len(self.vm.evm_stack) - 1 - i
                value = self.vm.evm_stack[idx]
                print(f"  [{idx}] = 0x{value:064x}")
        else:
            print("  Stack is empty")
    
    def do_evm_storage(self, arg):
        """Show EVM storage: evm_storage [key_hex]"""
        if not arg:
            print("EVM Storage:")
            for key, value in self.vm.evm_storage.items():
                print(f"  0x{key:x} = 0x{value:x}")
            return
        
        try:
            key = int(arg, 16)
            value = self.vm.evm_storage.get(key, 0)
            print(f"Storage[0x{key:x}] = 0x{value:x}")
        except ValueError:
            print("Invalid key format")
    
    def do_pc(self, arg):
        """Show or set program counter: pc [new_value_hex]"""
        if not arg:
            print(f"PC = 0x{self.vm.cpu.pc:x}")
            return
        
        try:
            new_pc = int(arg, 16)
            self.vm.cpu.pc = new_pc
            print(f"PC set to 0x{new_pc:x}")
        except ValueError:
            print("Invalid PC value")
    
    def do_gas(self, arg):
        """Show or set gas: gas [new_value]"""
        if not arg:
            print(f"Gas remaining: {self.vm.cpu.gas_remaining}")
            return
        
        try:
            new_gas = int(arg)
            self.vm.cpu.gas_remaining = new_gas
            print(f"Gas set to {new_gas}")
        except ValueError:
            print("Invalid gas value")
    
    def do_reset(self, arg):
        """Reset VM state"""
        self.vm.cpu.pc = self.vm.elf_header.entry_point
        self.vm.cpu.registers = [0] * 32
        self.vm.cpu.sp = 0x10000000
        self.vm.cpu.registers[2] = self.vm.cpu.sp
        self.vm.cpu.gas_remaining = 1000000
        self.vm.instruction_count = 0
        self.vm.evm_stack.clear()
        self.vm.evm_storage.clear()
        print("VM state reset")
    
    def do_info(self, arg):
        """Show VM information"""
        print(f"VM Information:")
        print(f"  Memory size: {self.vm.memory_size} bytes")
        print(f"  Instructions executed: {self.vm.instruction_count}")
        print(f"  Max instructions: {self.vm.max_instructions}")
        print(f"  PC: 0x{self.vm.cpu.pc:x}")
        print(f"  Gas remaining: {self.vm.cpu.gas_remaining}")
        print(f"  EVM stack depth: {len(self.vm.evm_stack)}")
        print(f"  EVM storage entries: {len(self.vm.evm_storage)}")
        print(f"  Breakpoints: {len(self.vm.breakpoints)}")
    
    def do_quit(self, arg):
        """Exit the debugger"""
        print("Goodbye!")
        return True
    
    def do_EOF(self, arg):
        """Exit on Ctrl+D"""
        print("\nGoodbye!")
        return True
    
    def emptyline(self):
        """Don't repeat last command on empty line"""
        pass

def main():
    """Main debugger entry point"""
    if len(sys.argv) > 1:
        # Set up logging
        logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
        
        # Create VM
        vm = RISCV_VM(debug=True)
        
        # Create debugger
        debugger = VMDebugger(vm)
        
        # Load ELF file if provided
        elf_file = sys.argv[1]
        print(f"Loading {elf_file}...")
        if vm.load_elf(elf_file):
            print(f"Successfully loaded {elf_file}")
            print(f"Entry point: 0x{vm.elf_header.entry_point:x}")
        else:
            print(f"Failed to load {elf_file}")
        
        # Start debugger
        debugger.cmdloop()
    else:
        print("Usage: python vm_debugger.py <elf_file>")
        print("Interactive debugger for RISC-V EVM VM")

if __name__ == "__main__":
    main()
