import re
import logging

logger = logging.getLogger(__name__)

class EVMAssemblyParser:
    def __init__(self):
        self.instructions = []
        self.labels = {}
        self.basic_blocks = []

    def parse_file(self, filename):
        """Parse EVM assembly file and extract instructions"""
        try:
            with open(filename, 'r') as f:
                lines = f.readlines()

            instructions = []
            for line in lines:
                line = line.strip()
                if not line:
                    continue

                addr, opcode, value = self._parse_line(line)
                if opcode:
                    instructions.append({
                        'address': addr,
                        'opcode': opcode,
                        'value': value,
                        'size': self._get_instruction_size(opcode)
                    })

                    if opcode == 'JUMPDEST':
                        self.labels[addr] = f'L_{addr:x}'

            return instructions
        except Exception as e:
            logger.error(f"Error parsing file {filename}: {str(e)}")
            raise

    def _parse_line(self, line):
        """Parse a single line of EVM assembly"""
        match = re.match(r'([0-9a-fA-F]+):\s+(\w+)(?:\s+([0-9a-fA-F]+))?', line)
        if match:
            addr = int(match.group(1), 16)
            opcode = match.group(2)
            value = match.group(3)
            if value:
                value = int(value, 16)
            return addr, opcode, value
        return None, None, None

    def _get_instruction_size(self, opcode):
        """Get instruction size in bytes"""
        if opcode.startswith('PUSH'):
            try:
                n = int(opcode[4:])
                return n + 1
            except:
                return 1
        return 1
