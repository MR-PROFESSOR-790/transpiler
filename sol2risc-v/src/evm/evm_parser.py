import logging

class EVM_Parser:
    def parse_instruction(self, line: str) -> dict:
        """
        Parse a single EVM instruction line.
        
        Args:
            line (str): Raw instruction line
            
        Returns:
            dict: Parsed instruction with opcode, args, and value
        """
        if not line or not isinstance(line, str):
            return None
            
        line = line.strip()
        if not line:
            return None
            
        # Handle labels
        if line.endswith(':'):
            return {
                'type': 'label',
                'name': line[:-1].strip()
            }
            
        parts = line.split()
        if not parts:
            return None
            
        opcode = parts[0].upper()
        args = parts[1:] if len(parts) > 1 else []
        
        # Handle PUSH instructions
        if opcode.startswith('PUSH'):
            if opcode == 'PUSH0':
                return {
                    'opcode': 'PUSH0',
                    'args': [],
                    'value': '0'
                }
            try:
                size = int(opcode[4:])
                if args and args[0].startswith('0x'):
                    value = args[0]
                else:
                    value = '0x' + ''.join(args)
                return {
                    'opcode': opcode,
                    'args': args,
                    'value': value
                }
            except (ValueError, IndexError):
                logging.warning(f"Invalid PUSH instruction: {line}")
                return None
                
        # Handle other instructions
        return {
            'opcode': opcode,
            'args': args,
            'value': None
        }

    def parse(self, input_text: str) -> list:
        """
        Parse EVM assembly code into structured instructions.
        
        Args:
            input_text (str): Raw EVM assembly code
            
        Returns:
            list: List of parsed instructions
        """
        if not input_text or not isinstance(input_text, str):
            return []
            
        instructions = []
        for line in input_text.split('\n'):
            if not line or not isinstance(line, str):
                continue
                
            line = line.strip()
            if not line or line.startswith('//'):
                continue
                
            instruction = self.parse_instruction(line)
            if instruction:
                instructions.append(instruction)
            else:
                logging.warning(f"Invalid instruction skipped: {line}")
                
        return instructions 