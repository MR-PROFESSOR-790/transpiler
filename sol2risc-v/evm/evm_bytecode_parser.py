import os 
from utils.hex_utils import (
    hex_to_bytes,
    pad_hex,
    reverse_endian,
)
import sys
from utils.constants import EVM_OPCODES
from utils.logger import logger

class Instruction:
    def __init__(self, offset, opcode, mnemonics, operand = None):
        self.offset = offset
        self.opcode = opcode
        self.mnemonics = mnemonics
        self.operand = operand
        
        
    def __str__(self):
        if self.operand:
            return f"{self.offset:04x}: {self.mnemonics} {self.operand}"
        return f"{self.offset:04x}: {self.mnemonics}"
    

class EVMBytecodeParser:
    def __init__(self, bytecode):
        self.bytecode = bytecode.lower().replace('0x', '').strip()
        self.instructions = []
        self.offset = 0
        
    def parse(self):
        bytecode_bytes = hex_to_bytes(self.bytecode)
        length = len(bytecode_bytes)
        
        logger.info("starting EVM bytecode parsing")
        while self.offset < length:
            opcode = bytecode_bytes[self.offset]
            mnemonic = EVM_OPCODES.get(opcode, f"UNKNOWN_0x{opcode:02x}")
            logger.debug(f"Offset {self.offset}: Opcode 0x{opcode:02x} -> {mnemonic}")
            
            if mnemonic.startwith("PUSH"):
                push_size = int(mnemonic[4:])
                operand_start = self.offset + 1
                operand_end = operand_start + push_size
                
                if operand_end > length:
                    logger.warning(f"Bytecode ends unexpectedly at PUSH offset {self.offset}, expected {push_size} bytes."
                                   )
                    operand_bytes = bytecode_bytes[operand_start:]
                    operand = operand_bytes.hex().ljust(push_size * 2, '0')
                else:
                    operand_bytes = bytecode_bytes[operand_start:operand_end]
                    operand = operand_bytes.hex()
                
                self.instructions.append(
                    Instruction(self.offset, opcode, mnemonic, operand)
                )
                logger.debug(f"Push Operation: {operand}")
                self.offset += push_size + 1
            else:
                self.instructions.append(
                    Instruction(self.offset, opcode, mnemonic)
                )
                self.offset += 1
        logger.info(f"Parsing complete. Total instructions: {len(self.instructions)}")

        return self.instructions
    def print_instructions(self):
        for instruction in self.instructions:
            print(instruction)
    
    def to_assembly(self, output_file):
        with open(output_file, 'w') as f:
            for instruction in self.instructions:
                f.write(str(instruction) + '\n')
        logger.info(f"Assembly code written to {output_file}")
        
def read_bytecode_from_file(file_path):
   if not os.path.exists(file_path):
        logger.error(f"File not found: {file_path}")
        raise FileNotFoundError(f"File not found: {file_path}")
    
    
   with open(file_path, 'r') as f:
        content = f.read().strip()
        
        
   if content.startswith('0x'):
        content = content[2:]
   bytecode = ''.join(content.split()).lower()
   logger.info(f"Bytecode read from file: {file_path}, length: {len(bytecode)}")
   return bytecode


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python evm_bytecode_parser.py <input_file> <output_file>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    try:
        bytecode = read_bytecode_from_file(file_path)
        parser = EVMBytecodeParser(bytecode)
        parser.parse()
        parser.print_instructions()
    except FileNotFoundError as e:
        logger.exception(f"Failed to parse bytecode: {e}")
