from typing import List, Dict

class EVMParser:
    def __init__(self):
        self.instructions = []
        self.unknown_opcodes = set()
        self.invalid_opcodes = set()
        self.warnings = []
        self.errors = []
        self.context = None
        self.current_offset = 0

    def set_context(self, context):
        """Set compilation context."""
        self.context = context

    def parse(self, bytecode: str) -> List[Dict]:
        """
        Parse EVM bytecode into a list of instructions.
        
        Args:
            bytecode (str): Hex string of EVM bytecode
        Returns:
            List[Dict]: List of parsed instructions
        """
        try:
            # Remove '0x' prefix if present
            if bytecode.startswith('0x'):
                bytecode = bytecode[2:]

            # Convert hex string to bytes
            code = bytes.fromhex(bytecode)
            self.current_offset = 0
            self.instructions = []
            self.unknown_opcodes.clear()
            self.invalid_opcodes.clear()
            self.warnings.clear()
            self.errors.clear()

            while self.current_offset < len(code):
                opcode = code[self.current_offset]
                instruction = self._parse_instruction(opcode, code)
                
                if instruction:
                    self.instructions.append(instruction)
                    
                    # Track unknown opcodes
                    if instruction["opcode"].startswith("UNKNOWN_"):
                        self.unknown_opcodes.add((instruction["opcode"], self.current_offset))
                        self.warnings.append(f"Unknown opcode at offset {self.current_offset}: {instruction['opcode']}")
                    
                    # Track invalid opcodes
                    if instruction["opcode"] == "INVALID":
                        self.invalid_opcodes.add((instruction["opcode"], self.current_offset))
                        self.errors.append(f"Invalid opcode at offset {self.current_offset}: {instruction['opcode']}")

                self.current_offset += 1

            # Update context with parsing results
            if self.context:
                self.context.unknown_opcodes.update(self.unknown_opcodes)
                self.context.invalid_opcodes.update(self.invalid_opcodes)
                self.context.warnings.extend(self.warnings)
                self.context.errors.extend(self.errors)

            return self.instructions

        except Exception as e:
            error_msg = f"Error parsing bytecode: {str(e)}"
            self.errors.append(error_msg)
            if self.context:
                self.context.add_error(error_msg)
            raise ValueError(error_msg)

    def _parse_instruction(self, opcode: int, code: bytes) -> Dict:
        """
        Parse a single instruction from the bytecode.
        
        Args:
            opcode (int): Opcode byte
            code (bytes): Full bytecode
        Returns:
            Dict: Parsed instruction
        """
        instruction = {
            "offset": self.current_offset,
            "opcode": self._get_opcode_name(opcode),
            "args": []
        }

        # Handle PUSH operations
        if 0x60 <= opcode <= 0x7f:
            n_bytes = opcode - 0x60 + 1
            if self.current_offset + n_bytes < len(code):
                value = int.from_bytes(code[self.current_offset + 1:self.current_offset + 1 + n_bytes], 'big')
                instruction["value"] = value
                instruction["args"].append(hex(value))
                self.current_offset += n_bytes
            else:
                self.errors.append(f"Invalid PUSH at offset {self.current_offset}: insufficient bytes")
                instruction["opcode"] = "INVALID"

        # Handle unknown opcodes
        elif opcode not in OPCODES:
            instruction["opcode"] = f"UNKNOWN_0x{opcode:02x}"
            self.warnings.append(f"Unknown opcode 0x{opcode:02x} at offset {self.current_offset}")

        return instruction

    def _get_opcode_name(self, opcode: int) -> str:
        """Get the name of an opcode."""
        return OPCODES.get(opcode, f"UNKNOWN_0x{opcode:02x}")

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