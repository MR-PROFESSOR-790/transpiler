import os
import sys
import json
from utils.hex_utils import hex_to_bytes
from utils.constants import EVM_OPCODES
from utils.logger import logger


class Instruction:
    def __init__(self, offset, opcode, mnemonics, operand=None):
        self.offset = offset
        self.opcode = opcode
        self.mnemonics = mnemonics
        self.operand = operand

    def __str__(self):
        if self.operand:
            return f"{self.offset:04x}: {self.mnemonics} {self.operand}"
        return f"{self.offset:04x}: {self.mnemonics}"

    def to_dict(self):
        return {
            "offset": self.offset,
            "opcode": f"0x{self.opcode:02x}",
            "mnemonics": self.mnemonics,
            "operand": self.operand or ""
        }


class EVMBytecodeParser:
    def __init__(self, bytecode):
        self.bytecode = bytecode.lower().replace('0x', '').strip()
        self.instructions = []
        self.offset = 0

    def parse(self):
        bytecode_bytes = hex_to_bytes(self.bytecode)
        length = len(bytecode_bytes)

        logger.info("Starting EVM bytecode parsing")
        while self.offset < length:
            opcode = bytecode_bytes[self.offset]
            mnemonic = EVM_OPCODES.get(opcode, f"UNKNOWN_0x{opcode:02x}")
            logger.debug(f"Offset {self.offset}: Opcode 0x{opcode:02x} -> {mnemonic}")

            if mnemonic.startswith("PUSH"):
                push_size = int(mnemonic[4:])
                operand_start = self.offset + 1
                operand_end = operand_start + push_size

                if operand_end > length:
                    logger.warning(f"Bytecode ends unexpectedly at PUSH offset {self.offset}, expected {push_size} bytes.")
                    operand_bytes = bytecode_bytes[operand_start:]
                    operand = operand_bytes.hex().ljust(push_size * 2, '0')
                else:
                    operand_bytes = bytecode_bytes[operand_start:operand_end]
                    operand = operand_bytes.hex()

                self.instructions.append(
                    Instruction(self.offset, opcode, mnemonic, operand)
                )
                logger.debug(f"PUSH operand [{push_size} bytes]: {operand}")
                self.offset += 1 + push_size
            else:
                if mnemonic.startswith("UNKNOWN"):
                    logger.warning(f"Unknown opcode at offset {self.offset}: 0x{opcode:02x}")
                self.instructions.append(
                    Instruction(self.offset, opcode, mnemonic)
                )
                self.offset += 1

        logger.info(f"Parsing complete. Total instructions: {len(self.instructions)}")
        return self.instructions

    def print_instructions(self):
        for instr in self.instructions:
            print(instr)

    def to_assembly(self, output_file):
        try:
            with open(output_file, 'w') as f:
                for instruction in self.instructions:
                    f.write(str(instruction) + '\n')
            logger.info(f"Assembly code written to {output_file}")
        except Exception as e:
            logger.exception(f"Failed to write assembly to {output_file}: {e}")

    def to_json(self, json_file):
        try:
            with open(json_file, 'w') as f:
                json.dump([instr.to_dict() for instr in self.instructions], f, indent=2)
            logger.info(f"JSON instruction dump written to {json_file}")
        except Exception as e:
            logger.exception(f"Failed to write JSON output: {e}")


def read_bytecode_from_file(file_path):
    if not os.path.exists(file_path):
        logger.error(f"File not found: {file_path}")
        raise FileNotFoundError(f"File not found: {file_path}")

    with open(file_path, 'r') as f:
        content = f.read().strip()

    if content.startswith('0x'):
        content = content[2:]
    bytecode = ''.join(content.split()).lower()

    if not all(c in '0123456789abcdef' for c in bytecode):
        logger.error(f"Invalid bytecode format in file: {file_path}")
        raise ValueError(f"Invalid bytecode format in file: {file_path}")

    logger.info(f"Bytecode read from file: {file_path}, length: {len(bytecode)}")
    return bytecode


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python evm_bytecode_parser.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    json_output = output_file + ".json"

    try:
        bytecode = read_bytecode_from_file(input_file)
        parser = EVMBytecodeParser(bytecode)
        parser.parse()
        parser.print_instructions()
        parser.to_assembly(output_file)
        parser.to_json(json_output)
    except Exception as e:
        logger.exception(f"Error occurred: {e}")
