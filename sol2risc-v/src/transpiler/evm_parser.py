#!/usr/bin/env python3
"""
EVM Parser - Converts EVM bytecode/assembly to an intermediate representation
suitable for translation to RISC-V assembly.

This module parses EVM bytecode or assembly and creates an intermediate
representation that captures the stack operations, memory accesses, and
control flow structures.
"""

import sys
import re
import json
from collections import defaultdict, namedtuple

# Intermediate representation structures
IR_Instruction = namedtuple('IR_Instruction', 
                          ['opcode', 'args', 'stack_in', 'stack_out', 'gas', 'pc'])
IR_BasicBlock = namedtuple('IR_BasicBlock', 
                          ['id', 'instructions', 'successors', 'predecessors'])

# EVM opcode information
EVM_OPCODES = {
    # Arithmetic Operations
    'ADD': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'MUL': {'stack_in': 2, 'stack_out': 1, 'gas': 5},
    'SUB': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'DIV': {'stack_in': 2, 'stack_out': 1, 'gas': 5},
    'SDIV': {'stack_in': 2, 'stack_out': 1, 'gas': 5},
    'MOD': {'stack_in': 2, 'stack_out': 1, 'gas': 5},
    'SMOD': {'stack_in': 2, 'stack_out': 1, 'gas': 5},
    'ADDMOD': {'stack_in': 3, 'stack_out': 1, 'gas': 8},
    'MULMOD': {'stack_in': 3, 'stack_out': 1, 'gas': 8},
    'EXP': {'stack_in': 2, 'stack_out': 1, 'gas': 10},  # Base cost, actual is dynamic
    'SIGNEXTEND': {'stack_in': 2, 'stack_out': 1, 'gas': 5},
    
    # Comparison & Bitwise Logic Operations
    'LT': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'GT': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'SLT': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'SGT': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'EQ': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'ISZERO': {'stack_in': 1, 'stack_out': 1, 'gas': 3},
    'AND': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'OR': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'XOR': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'NOT': {'stack_in': 1, 'stack_out': 1, 'gas': 3},
    'BYTE': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'SHL': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'SHR': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    'SAR': {'stack_in': 2, 'stack_out': 1, 'gas': 3},
    
    # SHA3
    'SHA3': {'stack_in': 2, 'stack_out': 1, 'gas': 30},  # Base cost, actual is dynamic
    
    # Environmental Information
    'ADDRESS': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'BALANCE': {'stack_in': 1, 'stack_out': 1, 'gas': 700},
    'ORIGIN': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'CALLER': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'CALLVALUE': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'CALLDATALOAD': {'stack_in': 1, 'stack_out': 1, 'gas': 3},
    'CALLDATASIZE': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'CALLDATACOPY': {'stack_in': 3, 'stack_out': 0, 'gas': 3},  # Base cost, actual is dynamic
    'CODESIZE': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'CODECOPY': {'stack_in': 3, 'stack_out': 0, 'gas': 3},  # Base cost, actual is dynamic
    'GASPRICE': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'EXTCODESIZE': {'stack_in': 1, 'stack_out': 1, 'gas': 700},
    'EXTCODECOPY': {'stack_in': 4, 'stack_out': 0, 'gas': 700},  # Base cost, actual is dynamic
    'RETURNDATASIZE': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'RETURNDATACOPY': {'stack_in': 3, 'stack_out': 0, 'gas': 3},  # Base cost, actual is dynamic
    'EXTCODEHASH': {'stack_in': 1, 'stack_out': 1, 'gas': 700},
    
    # Block Information
    'BLOCKHASH': {'stack_in': 1, 'stack_out': 1, 'gas': 20},
    'COINBASE': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'TIMESTAMP': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'NUMBER': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'DIFFICULTY': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'GASLIMIT': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'CHAINID': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'SELFBALANCE': {'stack_in': 0, 'stack_out': 1, 'gas': 5},
    
    # Stack, Memory, Storage and Flow Operations
    'POP': {'stack_in': 1, 'stack_out': 0, 'gas': 2},
    'MLOAD': {'stack_in': 1, 'stack_out': 1, 'gas': 3},
    'MSTORE': {'stack_in': 2, 'stack_out': 0, 'gas': 3},
    'MSTORE8': {'stack_in': 2, 'stack_out': 0, 'gas': 3},
    'SLOAD': {'stack_in': 1, 'stack_out': 1, 'gas': 800},
    'SSTORE': {'stack_in': 2, 'stack_out': 0, 'gas': 5000},  # Base cost, actual is dynamic
    'JUMP': {'stack_in': 1, 'stack_out': 0, 'gas': 8},
    'JUMPI': {'stack_in': 2, 'stack_out': 0, 'gas': 10},
    'PC': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'MSIZE': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'GAS': {'stack_in': 0, 'stack_out': 1, 'gas': 2},
    'JUMPDEST': {'stack_in': 0, 'stack_out': 0, 'gas': 1},
    
    # Push Operations (0x60-0x7f)
    'PUSH1': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH2': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH3': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH4': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH5': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH6': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH7': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH8': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH9': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH10': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH11': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH12': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH13': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH14': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH15': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH16': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH17': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH18': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH19': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH20': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH21': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH22': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH23': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH24': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH25': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH26': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH27': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH28': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH29': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH30': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH31': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    'PUSH32': {'stack_in': 0, 'stack_out': 1, 'gas': 3},
    
    # Duplication Operations (0x80-0x8f)
    'DUP1': {'stack_in': 1, 'stack_out': 2, 'gas': 3},
    'DUP2': {'stack_in': 2, 'stack_out': 3, 'gas': 3},
    'DUP3': {'stack_in': 3, 'stack_out': 4, 'gas': 3},
    'DUP4': {'stack_in': 4, 'stack_out': 5, 'gas': 3},
    'DUP5': {'stack_in': 5, 'stack_out': 6, 'gas': 3},
    'DUP6': {'stack_in': 6, 'stack_out': 7, 'gas': 3},
    'DUP7': {'stack_in': 7, 'stack_out': 8, 'gas': 3},
    'DUP8': {'stack_in': 8, 'stack_out': 9, 'gas': 3},
    'DUP9': {'stack_in': 9, 'stack_out': 10, 'gas': 3},
    'DUP10': {'stack_in': 10, 'stack_out': 11, 'gas': 3},
    'DUP11': {'stack_in': 11, 'stack_out': 12, 'gas': 3},
    'DUP12': {'stack_in': 12, 'stack_out': 13, 'gas': 3},
    'DUP13': {'stack_in': 13, 'stack_out': 14, 'gas': 3},
    'DUP14': {'stack_in': 14, 'stack_out': 15, 'gas': 3},
    'DUP15': {'stack_in': 15, 'stack_out': 16, 'gas': 3},
    'DUP16': {'stack_in': 16, 'stack_out': 17, 'gas': 3},
    
    # Exchange Operations (0x90-0x9f)
    'SWAP1': {'stack_in': 2, 'stack_out': 2, 'gas': 3},
    'SWAP2': {'stack_in': 3, 'stack_out': 3, 'gas': 3},
    'SWAP3': {'stack_in': 4, 'stack_out': 4, 'gas': 3},
    'SWAP4': {'stack_in': 5, 'stack_out': 5, 'gas': 3},
    'SWAP5': {'stack_in': 6, 'stack_out': 6, 'gas': 3},
    'SWAP6': {'stack_in': 7, 'stack_out': 7, 'gas': 3},
    'SWAP7': {'stack_in': 8, 'stack_out': 8, 'gas': 3},
    'SWAP8': {'stack_in': 9, 'stack_out': 9, 'gas': 3},
    'SWAP9': {'stack_in': 10, 'stack_out': 10, 'gas': 3},
    'SWAP10': {'stack_in': 11, 'stack_out': 11, 'gas': 3},
    'SWAP11': {'stack_in': 12, 'stack_out': 12, 'gas': 3},
    'SWAP12': {'stack_in': 13, 'stack_out': 13, 'gas': 3},
    'SWAP13': {'stack_in': 14, 'stack_out': 14, 'gas': 3},
    'SWAP14': {'stack_in': 15, 'stack_out': 15, 'gas': 3},
    'SWAP15': {'stack_in': 16, 'stack_out': 16, 'gas': 3},
    'SWAP16': {'stack_in': 17, 'stack_out': 17, 'gas': 3},
    
    # Logging Operations (0xa0-0xa4)
    'LOG0': {'stack_in': 2, 'stack_out': 0, 'gas': 375},  # Base cost, actual is dynamic
    'LOG1': {'stack_in': 3, 'stack_out': 0, 'gas': 750},  # Base cost, actual is dynamic
    'LOG2': {'stack_in': 4, 'stack_out': 0, 'gas': 1125},  # Base cost, actual is dynamic
    'LOG3': {'stack_in': 5, 'stack_out': 0, 'gas': 1500},  # Base cost, actual is dynamic
    'LOG4': {'stack_in': 6, 'stack_out': 0, 'gas': 1875},  # Base cost, actual is dynamic
    
    # System Operations (0xf0-0xff)
    'CREATE': {'stack_in': 3, 'stack_out': 1, 'gas': 32000},
    'CALL': {'stack_in': 7, 'stack_out': 1, 'gas': 700},  # Base cost, actual is dynamic
    'CALLCODE': {'stack_in': 7, 'stack_out': 1, 'gas': 700},  # Base cost, actual is dynamic
    'RETURN': {'stack_in': 2, 'stack_out': 0, 'gas': 0},
    'DELEGATECALL': {'stack_in': 6, 'stack_out': 1, 'gas': 700},  # Base cost, actual is dynamic
    'CREATE2': {'stack_in': 4, 'stack_out': 1, 'gas': 32000},  # Base cost, actual is dynamic
    'STATICCALL': {'stack_in': 6, 'stack_out': 1, 'gas': 700},  # Base cost, actual is dynamic
    'REVERT': {'stack_in': 2, 'stack_out': 0, 'gas': 0},
    'INVALID': {'stack_in': 0, 'stack_out': 0, 'gas': 0},
    'SELFDESTRUCT': {'stack_in': 1, 'stack_out': 0, 'gas': 5000},  # Base cost, actual is dynamic
}

class EVMParser:
    """Parser for EVM assembly or bytecode."""
    
    def __init__(self):
        self.instructions = []
        self.basic_blocks = []
        self.jumpdests = set()
        self.control_flow_graph = {}
    
    def parse_file(self, filename):
        """Parse EVM assembly from a file."""
        with open(filename, 'r') as f:
            content = f.read()
        
        if self._is_bytecode(content):
            return self.parse_bytecode(content)
        else:
            return self.parse_assembly(content)
    
    def _is_bytecode(self, content):
        """Check if the content is bytecode (hex) or assembly."""
        # Simple heuristic: if it's mostly hex characters, it's probably bytecode
        hex_chars = set('0123456789abcdefABCDEF')
        content = content.strip()
        
        # Check if it's a 0x-prefixed hex string
        if content.startswith('0x'):
            content = content[2:]
        
        # If >90% are hex characters, assume bytecode
        char_count = len(content)
        hex_count = sum(1 for c in content if c in hex_chars)
        
        return hex_count / char_count > 0.9 if char_count > 0 else False
    
    def parse_bytecode(self, bytecode):
        """Parse EVM bytecode into instructions."""
        if bytecode.startswith('0x'):
            bytecode = bytecode[2:]
        
        # Convert hex string to bytes
        try:
            bytecode_bytes = bytes.fromhex(bytecode)
        except ValueError:
            raise ValueError("Invalid bytecode hex string")
        
        pc = 0
        while pc < len(bytecode_bytes):
            opcode_byte = bytecode_bytes[pc]
            
            # Get opcode name
            if opcode_byte < 0x60:  # Non-PUSH opcodes
                opcode_name = self._get_opcode_name(opcode_byte)
                args = []
                next_pc = pc + 1
            elif 0x60 <= opcode_byte <= 0x7F:  # PUSH opcodes
                push_size = opcode_byte - 0x5F  # PUSH1 is 0x60, so PUSH1 gets size 1
                opcode_name = f"PUSH{push_size}"
                
                # Get the pushed value
                if pc + 1 + push_size <= len(bytecode_bytes):
                    pushed_bytes = bytecode_bytes[pc+1:pc+1+push_size]
                    args = [pushed_bytes.hex()]
                else:
                    # Not enough bytes for the PUSH operation
                    args = ["<incomplete>"]
                
                next_pc = pc + 1 + push_size
            else:
                opcode_name = self._get_opcode_name(opcode_byte)
                args = []
                next_pc = pc + 1
            
            # Record JUMPDEST for control flow analysis
            if opcode_name == 'JUMPDEST':
                self.jumpdests.add(pc)
            
            # Create instruction with metadata
            opcode_info = EVM_OPCODES.get(opcode_name, {'stack_in': 0, 'stack_out': 0, 'gas': 0})
            instruction = IR_Instruction(
                opcode=opcode_name,
                args=args,
                stack_in=opcode_info['stack_in'],
                stack_out=opcode_info['stack_out'],
                gas=opcode_info['gas'],
                pc=pc
            )
            
            self.instructions.append(instruction)
            pc = next_pc
        
        # Analyze control flow
        self._analyze_control_flow()
        
        return self.instructions
    
    def parse_assembly(self, assembly):
        """Parse EVM assembly text into instructions."""
        lines = assembly.strip().split('\n')
        pc = 0
        
        for line in lines:
            # Skip empty lines and comments
            line = line.strip()
            if not line or line.startswith(';') or line.startswith('//'):
                continue
            
            # Parse labels as JUMPDEST
            if line.endswith(':'):
                label = line[:-1].strip()
                opcode_name = 'JUMPDEST'
                args = []
                self.jumpdests.add(pc)
            else:
                # Split into opcode and arguments
                parts = line.split(None, 1)
                opcode_name = parts[0].upper()
                
                # Handle PUSH special case
                if opcode_name.startswith('PUSH') and len(parts) > 1:
                    args = [parts[1].strip()]
                else:
                    args = []
            
            # Create instruction with metadata
            opcode_info = EVM_OPCODES.get(opcode_name, {'stack_in': 0, 'stack_out': 0, 'gas': 0})
            instruction = IR_Instruction(
                opcode=opcode_name,
                args=args,
                stack_in=opcode_info['stack_in'],
                stack_out=opcode_info['stack_out'],
                gas=opcode_info['gas'],
                pc=pc
            )
            
            self.instructions.append(instruction)
            
            # Update PC (estimate, as real PC would depend on actual bytecode)
            if opcode_name.startswith('PUSH'):
                push_size = int(opcode_name[4:])
                pc += 1 + push_size
            else:
                pc += 1
        
        # Analyze control flow
        self._analyze_control_flow()
        
        return self.instructions
    
    def _get_opcode_name(self, opcode_byte):
        """Get opcode name from byte value."""
        # This is a simplified mapping
        opcodes = {
            0x00: 'STOP',
            0x01: 'ADD',
            0x02: 'MUL',
            0x03: 'SUB',
            0x04: 'DIV',
            0x05: 'SDIV',
            0x06: 'MOD',
            0x07: 'SMOD',
            0x08: 'ADDMOD',
            0x09: 'MULMOD',
            0x0A: 'EXP',
            0x0B: 'SIGNEXTEND',
            # Comparison & Bitwise Logic
            0x10: 'LT',
            0x11: 'GT',
            0x12: 'SLT',
            0x13: 'SGT',
            0x14: 'EQ',
            0x15: 'ISZERO',
            0x16: 'AND',
            0x17: 'OR',
            0x18: 'XOR',
            0x19: 'NOT',
            0x1A: 'BYTE',
            0x1B: 'SHL',
            0x1C: 'SHR',
            0x1D: 'SAR',
            # SHA3
            0x20: 'SHA3',
            # Environmental Information
            0x30: 'ADDRESS',
            0x31: 'BALANCE',
            0x32: 'ORIGIN',
            0x33: 'CALLER',
            0x34: 'CALLVALUE',
            0x35: 'CALLDATALOAD',
            0x36: 'CALLDATASIZE',
            0x37: 'CALLDATACOPY',
            0x38: 'CODESIZE',
            0x39: 'CODECOPY',
            0x3A: 'GASPRICE',
            0x3B: 'EXTCODESIZE',
            0x3C: 'EXTCODECOPY',
            0x3D: 'RETURNDATASIZE',
            0x3E: 'RETURNDATACOPY',
            0x3F: 'EXTCODEHASH',
            # Block Information
            0x40: 'BLOCKHASH',
            0x41: 'COINBASE',
            0x42: 'TIMESTAMP',
            0x43: 'NUMBER',
            0x44: 'DIFFICULTY',
            0x45: 'GASLIMIT',
            0x46: 'CHAINID',
            0x47: 'SELFBALANCE',
            # Stack, Memory, Storage and Flow Operations
            0x50: 'POP',
            0x51: 'MLOAD',
            0x52: 'MSTORE',
            0x53: 'MSTORE8',
            0x54: 'SLOAD',
            0x55: 'SSTORE',
            0x56: 'JUMP',
            0x57: 'JUMPI',
            0x58: 'PC',
            0x59: 'MSIZE',
            0x5A: 'GAS',
            0x5B: 'JUMPDEST',
            # Logging
            0xA0: 'LOG0',
            0xA1: 'LOG1',
            0xA2: 'LOG2',
            0xA3: 'LOG3',
            0xA4: 'LOG4',
            # System operations
            0xF0: 'CREATE',
            0xF1: 'CALL',
            0xF2: 'CALLCODE',
            0xF3: 'RETURN',
            0xF4: 'DELEGATECALL',
            0xF5: 'CREATE2',
            0xFA: 'STATICCALL',
            0xFD: 'REVERT',
            0xFE: 'INVALID',
            0xFF: 'SELFDESTRUCT',
        }
        
        # Handle PUSH opcodes (0x60-0x7F)
        if 0x60 <= opcode_byte <= 0x7F:
            push_size = opcode_byte - 0x5F
            return f"PUSH{push_size}"
        
        # Handle DUP opcodes (0x80-0x8F)
        if 0x80 <= opcode_byte <= 0x8F:
            dup_position = opcode_byte - 0x7F
            return f"DUP{dup_position}"
        
        # Handle SWAP opcodes (0x90-0x9F)
        if 0x90 <= opcode_byte <= 0x9F:
            swap_position = opcode_byte - 0x8F
            return f"SWAP{swap_position}"
        
        return opcodes.get(opcode_byte, f"UNKNOWN_{hex(opcode_byte)}")
    
    def _analyze_control_flow(self):
        """Analyze control flow and build basic blocks."""
        if not self.instructions:
            return
        
        # First pass: identify basic block boundaries
        block_starts = {0}  # Entry point is always a block start
        
        # Add all JUMPDESTs as potential block starts
        block_starts.update(self.jumpdests)
        
        # Find all block ends (JUMP, JUMPI, RETURN, REVERT, STOP, etc.)
        # And add their successors as block starts
        for i, instr in enumerate(self.instructions):
            if instr.opcode in ('JUMP', 'JUMPI', 'RETURN', 'REVERT', 'STOP', 'INVALID', 'SELFDESTRUCT'):
                # The next instruction (if any) starts a new block
                if i + 1 < len(self.instructions):
                    block_starts.add(self.instructions[i+1].pc)
            
            # For JUMPI, the fallthrough instruction is also a block start
            if instr.opcode == 'JUMPI' and i + 1 < len(self.instructions):
                block_starts.add(self.instructions[i+1].pc)
        
        # Sort block start PCs
        block_starts = sorted(block_starts)
        
        # Second pass: create basic blocks
        pc_to_index = {instr.pc: i for i, instr in enumerate(self.instructions)}
        
        # Build basic blocks
        block_id = 0
        for i in range(len(block_starts)):
            start_pc = block_starts[i]
            # Find block end (next block start or end of program)
            end_pc = block_starts[i+1] if i + 1 < len(block_starts) else float('inf')
            
            # Collect instructions for this block
            block_instrs = []
            instr_idx = pc_to_index.get(start_pc)
            
            if instr_idx is None:
                continue  # Invalid block start
                
            while instr_idx < len(self.instructions):
                instr = self.instructions[instr_idx]
                if instr.pc >= end_pc:
                    break
                block_instrs.append(instr)
                instr_idx += 1
            
            if not block_instrs:
                continue  # Empty block
            
            # Create basic block
            block = IR_BasicBlock(
                id=block_id,
                instructions=block_instrs,
                successors=[],
                predecessors=[]
            )
            self.basic_blocks.append(block)
            block_id += 1
        
        # Third pass: connect basic blocks (build CFG)
        for i, block in enumerate(self.basic_blocks):
            if not block.instructions:
                continue
                
            last_instr = block.instructions[-1]
            
            # Handle different control flow cases
            if last_instr.opcode == 'JUMP':
                # Find the target block for unconditional jump
                # This requires stack analysis to determine jump destination
                target_pcs = self._find_jump_targets(block)
                for target_pc in target_pcs:
                    for j, target_block in enumerate(self.basic_blocks):
                        if target_block.instructions and target_block.instructions[0].pc == target_pc:
                            block._replace(successors=block.successors + [j])
                            target_block._replace(predecessors=target_block.predecessors + [i])
                            break
                            
            elif last_instr.opcode == 'JUMPI':
                # Conditional jump has two possible targets:
                # 1. The actual jump target
                target_pcs = self._find_jump_targets(block)
                for target_pc in target_pcs:
                    for j, target_block in enumerate(self.basic_blocks):
                        if target_block.instructions and target_block.instructions[0].pc == target_pc:
                            block._replace(successors=block.successors + [j])
                            target_block._replace(predecessors=target_block.predecessors + [i])
                            break
                
                # 2. The fall-through block (the next block)
                if i + 1 < len(self.basic_blocks):
                    block._replace(successors=block.successors + [i+1])
                    self.basic_blocks[i+1]._replace(predecessors=self.basic_blocks[i+1].predecessors + [i])
                    
            elif last_instr.opcode not in ('RETURN', 'REVERT', 'STOP', 'INVALID', 'SELFDESTRUCT'):
                # Fall-through to next block
                if i + 1 < len(self.basic_blocks):
                    block._replace(successors=[i+1])
                    self.basic_blocks[i+1]._replace(predecessors=self.basic_blocks[i+1].predecessors + [i])
        
        # Build control flow graph
        self.control_flow_graph = {i: block.successors for i, block in enumerate(self.basic_blocks)}
        
        return self.basic_blocks
    
    def _find_jump_targets(self, block):
        """
        Try to determine jump targets through static analysis.
        This is a simplified version and won't handle all cases.
        """
        targets = []
        
        # Look for PUSH* followed immediately by JUMP/JUMPI pattern
        for i in range(len(block.instructions) - 1):
            instr = block.instructions[i]
            next_instr = block.instructions[i+1]
            
            # Check for PUSH* followed by JUMP/JUMPI
            if (instr.opcode.startswith('PUSH') and 
                next_instr.opcode in ('JUMP', 'JUMPI')):
                
                # Extract the push value as the jump target
                if instr.args:
                    try:
                        # Convert hex string to int
                        target = int(instr.args[0], 16)
                        if target in self.jumpdests:
                            targets.append(target)
                    except ValueError:
                        pass
        
        return targets
    
    def to_ir(self):
        """
        Convert the parsed EVM code to intermediate representation suitable
        for conversion to RISC-V.
        """
        # For now, we'll just return our internal representation
        return {
            'instructions': self.instructions,
            'basic_blocks': self.basic_blocks,
            'control_flow_graph': self.control_flow_graph,
        }
    
    def analyze_stack(self):
        """
        Perform stack analysis to track stack usage.
        This helps with register allocation for RISC-V.
        """
        stack_depths = {}
        max_stack = 0
        current_stack = 0
        
        for instr in self.instructions:
            # Record stack depth at this instruction
            stack_depths[instr.pc] = current_stack
            
            # Update stack depth based on opcode
            current_stack -= instr.stack_in
            current_stack += instr.stack_out
            
            # Track maximum stack depth
            max_stack = max(max_stack, current_stack)
            
            # Sanity check
            if current_stack < 0:
                print(f"Warning: Stack underflow at PC {instr.pc}, opcode {instr.opcode}")
                current_stack = 0  # Reset to avoid cascading errors
        
        return {
            'stack_depths': stack_depths,
            'max_stack': max_stack
        }
    
    def save_ir(self, filename):
        """Save the intermediate representation to a JSON file."""
        ir_data = self.to_ir()
        
        # Convert instructions and basic blocks to serializable format
        serializable_ir = {
            'instructions': [
                {
                    'opcode': instr.opcode,
                    'args': instr.args,
                    'stack_in': instr.stack_in,
                    'stack_out': instr.stack_out,
                    'gas': instr.gas,
                    'pc': instr.pc
                }
                for instr in ir_data['instructions']
            ],
            'basic_blocks': [
                {
                    'id': block.id,
                    'instructions': [instr.pc for instr in block.instructions],
                    'successors': block.successors,
                    'predecessors': block.predecessors
                }
                for block in ir_data['basic_blocks']
            ],
            'control_flow_graph': ir_data['control_flow_graph'],
            'stack_analysis': self.analyze_stack()
        }
        
        with open(filename, 'w') as f:
            json.dump(serializable_ir, f, indent=2)
        
        return filename