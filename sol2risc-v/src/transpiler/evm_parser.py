import re
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple, Set

# ======================
# Data Structures
# ======================

@dataclass
class EVMInstruction:
    address: Optional[str] = None   # Hex address e.g. '0000'
    opcode: str = ""
    args: List[str] = None
    line_number: int = -1
    label: Optional[str] = None     # Optional symbolic label
    is_jump_target: bool = False

    def __post_init__(self):
        if self.args is None:
            self.args = []

@dataclass
class RISCVInstruction:
    opcode: str
    rd: Optional[str] = None      # Destination register
    rs1: Optional[str] = None     # Source register 1
    rs2: Optional[str] = None     # Source register 2
    imm: Optional[int] = None     # Immediate value
    label: Optional[str] = None   # Label for jumps

# ======================
# Parser Core Functions
# ======================

def parse_evm_assembly(input_file: str) -> List[EVMInstruction]:
    """
    Main parsing function to read EVM assembly file and return list of EVMInstruction objects.
    Handles:
      - Address-prefixed lines (like '0000: PUSH1 80')
      - Symbolic labels
      - UNKNOWN_XXX opcodes
      - Inline comments
    """
    instructions = []
    line_number = 0
    current_label = None

    with open(input_file, 'r') as f:
        for line in f:
            line = line.strip()
            line_number += 1

            if not line or line.startswith(';'):
                continue

            # Match optional address prefix and instruction
            match = re.match(r'^(?:([0-9a-fA-F]{4}):)?\s*(.+)$', line)
            if not match:
                continue

            address, instr_part = match.groups()

            # Check for label (before parsing instruction)
            label_match = re.match(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*:$|^\s*(tag_[0-9]+)\s*:$', instr_part)
            if label_match:
                label_name = label_match.group(1) or label_match.group(2)
                current_label = label_name
                continue

            # Tokenize instruction part
            tokens = re.split(r'\s+', instr_part)
            if not tokens:
                continue

            opcode = tokens[0]
            args = tokens[1:]

            # Build instruction object
            instr_obj = EVMInstruction(
                address=address,
                opcode=opcode,
                args=args,
                line_number=line_number,
                label=current_label
            )
            current_label = None  # Clear after assigning

            # Validate instruction
            try:
                validate_instruction(instr_obj)
            except ValueError as e:
                print(f"Line {line_number}: Warning: {str(e)}")

            instructions.append(instr_obj)

    # Post-processing
    resolve_jumps(instructions)
    detect_function_boundaries(instructions)
    analyze_stack_effects(instructions)
    build_control_flow_graph(instructions)

    return instructions


def tokenize_instruction(line: str) -> dict:
    """
    Break assembly line into components: opcode, args, comments, etc.
    Not used directly anymore, but kept for reference.
    """
    line = line.split('//')[0].strip()
    tokens = re.split(r'\s+', line)
    if not tokens:
        return None
    return {
        'opcode': tokens[0],
        'args': tokens[1:]
    }


def validate_instruction(instr: EVMInstruction) -> None:
    """
    Validate that the instruction matches expected format and operand count.
    Now handles PUSH operations correctly with special case for PUSH0.
    """
    # Special handling for PUSH operations
    if instr.opcode == 'PUSH0':
        # PUSH0 doesn't require an argument as it pushes 0 onto the stack
        return
    elif instr.opcode.startswith('PUSH'):
        if len(instr.args) != 1:
            raise ValueError(f"Expected 1 argument for {instr.opcode}, got {len(instr.args)}")
        return

    evm_opcode_metadata = {
        # Standard Opcodes
        'STOP': 0, 'ADD': 0, 'MUL': 0, 'SUB': 0, 'DIV': 0,
        'SDIV': 0, 'MOD': 0, 'SMOD': 0, 'ADDMOD': 0, 'MULMOD': 0,
        'EXP': 0, 'SIGNEXTEND': 0, 'LT': 0, 'GT': 0, 'SLT': 0,
        'SGT': 0, 'EQ': 0, 'ISZERO': 0, 'AND': 0, 'OR': 0,
        'XOR': 0, 'NOT': 0, 'BYTE': 0, 'SHL': 0, 'SHR': 0, 'SAR': 0,
        'SHA3': 0, 'ADDRESS': 0, 'BALANCE': 0, 'ORIGIN': 0, 'CALLER': 0,
        'CALLVALUE': 0, 'CALLDATALOAD': 0, 'CALLDATASIZE': 0, 'CALLDATACOPY': 0,
        'CODESIZE': 0, 'CODECOPY': 0, 'GASPRICE': 0, 'EXTCODESIZE': 0,
        'EXTCODECOPY': 0, 'RETURNDATASIZE': 0, 'RETURNDATACOPY': 0,
        'BLOCKHASH': 0, 'COINBASE': 0, 'TIMESTAMP': 0, 'NUMBER': 0,
        'DIFFICULTY': 0, 'GASLIMIT': 0, 'CHAINID': 0, 'SELFBALANCE': 0,
        'POP': 0, 'MLOAD': 0, 'MSTORE': 0, 'MSTORE8': 0, 'SLOAD': 0,
        'SSTORE': 0, 'JUMP': 0, 'JUMPI': 0, 'PC': 0, 'MSIZE': 0,
        'GAS': 0, 'JUMPDEST': 0,

        # Pushes: All take 0 arguments
        **{f"PUSH{i}": 0 for i in range(1, 33)},

        # New PUSH0 from EIP-3855
        'PUSH0': 0,

        # Dup and Swap
        **{f"DUP{i}": 0 for i in range(1, 17)},
        **{f"SWAP{i}": 0 for i in range(1, 17)},

        # Logs
        **{f"LOG{i}": 0 for i in range(0, 5)},

        # System
        'CREATE': 0, 'CALL': 0, 'CALLCODE': 0,
        'RETURN': 0, 'DELEGATECALL': 0, 'CREATE2': 0, 'STATICCALL': 0,
        'REVERT': 0, 'INVALID': 0, 'SELFDESTRUCT': 0,

        # Unknown opcodes
        **{f"UNKNOWN_0x{i:02x}": 0 for i in range(0x00, 0xff)}
    }

    expected_args = evm_opcode_metadata.get(instr.opcode, -1)

    if expected_args == -1:
        raise ValueError(f"Unknown opcode: {instr.opcode}")
    if len(instr.args) != expected_args:
        raise ValueError(f"Expected {expected_args} arguments for {instr.opcode}, got {len(instr.args)}")


# ======================
# Analysis Functions
# ======================

def build_control_flow_graph(instructions: List[EVMInstruction]):
    """Placeholder for CFG construction."""
    pass


def resolve_jumps(instructions: List[EVMInstruction]):
    """Resolve jump targets by mapping labels to indices."""
    label_map = {}
    for idx, instr in enumerate(instructions):
        if instr.label:
            label_map[instr.label] = idx
        if instr.opcode == "JUMPDEST":
            if instr.label:
                label_map[instr.label] = idx

    for instr in instructions:
        if instr.opcode in ("JUMP", "JUMPI") and instr.args:
            target = instr.args[0]
            if target in label_map:
                instr.args[0] = str(label_map[target])
            elif re.match(r'tag_\d+', target) or re.match(r'[0-9a-fA-F]+', target):
                # Allow unresolved tag or hex address
                pass
            else:
                print(f"Warning: Unresolved jump target '{target}' at line {instr.line_number}")


def detect_function_boundaries(instructions: List[EVMInstruction]):
    """Detect function boundaries based on common patterns."""
    pass


def analyze_stack_effects(instructions: List[EVMInstruction]):
    """Analyze stack usage per instruction."""
    stack_effect_table = {
        'STOP': 0, 'ADD': -1, 'MUL': -1, 'SUB': -1, 'DIV': -1,
        'SDIV': -1, 'MOD': -1, 'SMOD': -1, 'ADDMOD': -2, 'MULMOD': -2,
        'EXP': -1, 'SIGNEXTEND': -1, 'LT': -1, 'GT': -1, 'SLT': -1,
        'SGT': -1, 'EQ': -1, 'ISZERO': 0, 'AND': -1, 'OR': -1,
        'XOR': -1, 'NOT': 0, 'BYTE': -1, 'SHL': -1, 'SHR': -1, 'SAR': -1,
        'SHA3': -1, 'ADDRESS': +1, 'BALANCE': +1, 'ORIGIN': +1, 'CALLER': +1,
        'CALLVALUE': +1, 'CALLDATALOAD': +1, 'CALLDATASIZE': +1, 'CALLDATACOPY': -3,
        'CODESIZE': +1, 'CODECOPY': -2, 'GASPRICE': +1, 'EXTCODESIZE': +1,
        'EXTCODECOPY': -3, 'RETURNDATASIZE': +1, 'RETURNDATACOPY': -3,
        'BLOCKHASH': +1, 'COINBASE': +1, 'TIMESTAMP': +1, 'NUMBER': +1,
        'DIFFICULTY': +1, 'GASLIMIT': +1, 'CHAINID': +1, 'SELFBALANCE': +1,
        'POP': -1, 'MLOAD': -1, 'MSTORE': -2, 'MSTORE8': -2, 'SLOAD': -1,
        'SSTORE': -2, 'JUMP': 0, 'JUMPI': -1, 'PC': +1, 'MSIZE': +1,
        'GAS': +1, 'JUMPDEST': 0,

        **{f"PUSH{i}": +1 for i in range(1, 33)},
        'PUSH0': +1,

        **{f"DUP{i}": +1 for i in range(1, 17)},
        **{f"SWAP{i}": 0 for i in range(1, 17)},

        'LOG0': -2, 'LOG1': -3, 'LOG2': -4, 'LOG3': -5, 'LOG4': -6,
        'CREATE': -3, 'CALL': -7, 'CALLCODE': -7, 'RETURN': -2,
        'DELEGATECALL': -6, 'CREATE2': -4, 'STATICCALL': -6, 'REVERT': -2,
        'INVALID': 0, 'SELFDESTRUCT': -1,

        **{f"UNKNOWN_0x{i:02x}": 0 for i in range(0x00, 0xff)},
    }
    stack_depth = 0
    for instr in instructions:
        effect = stack_effect_table.get(instr.opcode, 0)
        stack_depth += effect
        if stack_depth < 0:
            print(f"[WARNING] Stack underflow detected at {instr.opcode} (depth: {stack_depth})")


def convert_stack_to_register_ops(evm_instructions: List[EVMInstruction]) -> List[RISCVInstruction]:
    """Convert EVM stack operations to RISC-V register operations."""
    riscv_instructions = []
    current_stack = []
    reg_counter = 0
    sp_offset = 0  # Stack pointer offset for spilling

    def get_next_reg():
        nonlocal reg_counter
        # Use only t0-t6 (x5-x7, x28-x31) and a0-a7 (x10-x17) for general purpose
        if reg_counter < 8:
            reg = f"a{reg_counter}"  # Use a0-a7 first
        elif reg_counter < 15:
            reg = f"t{reg_counter-8}"  # Then use t0-t6
        else:
            # If we run out of registers, spill to stack
            reg = spill_to_stack()
        reg_counter = (reg_counter + 1) % 15
        return reg

    def spill_to_stack():
        nonlocal sp_offset
        # Save oldest register to stack
        oldest_reg = current_stack[0]
        sp_offset -= 4
        riscv_instructions.append(RISCVInstruction(
            opcode='sw',
            rs2=oldest_reg,
            rs1='sp',
            imm=sp_offset
        ))
        return oldest_reg

    # Initialize stack pointer
    riscv_instructions.append(RISCVInstruction(
        opcode='addi',
        rd='sp',
        rs1='sp',
        imm=-64  # Reserve stack space
    ))

    for instr in evm_instructions:
        if instr.opcode.startswith('PUSH'):
            # Convert PUSH to LI (Load Immediate)
            reg = get_next_reg()
            value = 0 if instr.opcode == 'PUSH0' else int(instr.args[0], 16)
            riscv_instructions.append(RISCVInstruction(
                opcode='li',
                rd=reg,
                imm=value
            ))
            current_stack.append(reg)
            
        elif instr.opcode in ['ADD', 'SUB', 'MUL', 'DIV']:
            if len(current_stack) >= 2:
                rs2 = current_stack.pop()
                rs1 = current_stack.pop()
                rd = get_next_reg()
                riscv_instructions.append(RISCVInstruction(
                    opcode=instr.opcode.lower(),
                    rd=rd,
                    rs1=rs1,
                    rs2=rs2
               ))
                current_stack.append(rd)

        elif instr.opcode == 'MSTORE':
            if len(current_stack) >= 2:
                value_reg = current_stack.pop()
                addr_reg = current_stack.pop()
                riscv_instructions.append(RISCVInstruction(
                    opcode='sw',
                    rs2=value_reg,
                    rs1=addr_reg,
                    imm=0
                ))

        elif instr.opcode == 'JUMPI':
            if len(current_stack) >= 2:
                cond_reg = current_stack.pop()
                target_reg = current_stack.pop()
                label = f"L_{target_reg}"
                riscv_instructions.append(RISCVInstruction(
                    opcode='bnez',
                    rs1=cond_reg,
                    label=label
                ))

        elif instr.opcode == 'JUMPDEST':
            riscv_instructions.append(RISCVInstruction(
                opcode='label',
                label=f"L_{instr.address}"
            ))

    # Restore stack pointer
    riscv_instructions.append(RISCVInstruction(
        opcode='addi',
        rd='sp',
        rs1='sp',
        imm=64
    ))

    return riscv_instructions

# ======================
# CLI Entry Point
# ======================

if __name__ == "__main__":
    import sys

    if len(sys.argv) != 2:
        print("Usage: python evm_parser.py <input.evm>")
        sys.exit(1)

    input_file = sys.argv[1]
    try:
        instructions = parse_evm_assembly(input_file)
        riscv_instructions = convert_stack_to_register_ops(instructions)
        
        print("\nParsed Instructions:")
        for i, instr in enumerate(instructions):
            label = instr.label if instr.label else ''
            addr = instr.address if instr.address else ''
            print(f"{i:3d} [{addr}] [{label}] {instr.opcode} {' '.join(instr.args)}")
        
        print("\nRISC-V Instructions:")
        for i, instr in enumerate(riscv_instructions):
            if instr.imm is not None:
                print(f"{i:3d} {instr.opcode} {instr.rd or ''}, {instr.imm}")
            else:
                print(f"{i:3d} {instr.opcode} {instr.rd or ''}, {instr.rs1 or ''}, {instr.rs2 or ''}")
    except Exception as e:
        print(f"[ERROR] {e}")