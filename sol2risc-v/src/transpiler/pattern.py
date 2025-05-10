"""
pattern.py - Identifies common EVM bytecode patterns and assists in RISC-V translation
This module helps identify patterns in EVM code for optimal translation to RISC-V.
It handles the mapping of stack-based operations to register-based equivalents.
"""

import re
from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional, Callable, Set

@dataclass
class EVMPattern:
    """Class to store recognized EVM patterns and their RISC-V equivalents"""
    name: str
    opcodes: List[str]
    # Function to generate RISC-V assembly for this pattern
    riscv_generator: Callable[[List[str], Dict], List[str]]
    # Optional prerequisites (e.g., certain stack configuration)
    prerequisites: Optional[Dict] = None

@dataclass
class StackOperation:
    """Represents an operation's stack effect"""
    pops: int  # Number of values popped from stack
    pushes: int  # Number of values pushed to stack
    
    @property
    def net_effect(self) -> int:
        """Net effect on stack size"""
        return self.pushes - self.pops

# Stack effects for EVM opcodes
STACK_EFFECTS = {
    # 0s: Stop and Arithmetic Operations
    "STOP": StackOperation(0, 0),
    "ADD": StackOperation(2, 1),
    "MUL": StackOperation(2, 1),
    "SUB": StackOperation(2, 1),
    "DIV": StackOperation(2, 1),
    "SDIV": StackOperation(2, 1),
    "MOD": StackOperation(2, 1),
    "SMOD": StackOperation(2, 1),
    "ADDMOD": StackOperation(3, 1),
    "MULMOD": StackOperation(3, 1),
    "EXP": StackOperation(2, 1),
    "SIGNEXTEND": StackOperation(2, 1),
    
    # 10s: Comparison & Bitwise Logic Operations
    "LT": StackOperation(2, 1),
    "GT": StackOperation(2, 1),
    "SLT": StackOperation(2, 1),
    "SGT": StackOperation(2, 1),
    "EQ": StackOperation(2, 1),
    "ISZERO": StackOperation(1, 1),
    "AND": StackOperation(2, 1),
    "OR": StackOperation(2, 1),
    "XOR": StackOperation(2, 1),
    "NOT": StackOperation(1, 1),
    "BYTE": StackOperation(2, 1),
    "SHL": StackOperation(2, 1),
    "SHR": StackOperation(2, 1),
    "SAR": StackOperation(2, 1),
    
    # 20s: SHA3
    "SHA3": StackOperation(2, 1),
    
    # 30s: Environmental Information
    "ADDRESS": StackOperation(0, 1),
    "BALANCE": StackOperation(1, 1),
    "ORIGIN": StackOperation(0, 1),
    "CALLER": StackOperation(0, 1),
    "CALLVALUE": StackOperation(0, 1),
    "CALLDATALOAD": StackOperation(1, 1),
    "CALLDATASIZE": StackOperation(0, 1),
    "CALLDATACOPY": StackOperation(3, 0),
    "CODESIZE": StackOperation(0, 1),
    "CODECOPY": StackOperation(3, 0),
    "GASPRICE": StackOperation(0, 1),
    "EXTCODESIZE": StackOperation(1, 1),
    "EXTCODECOPY": StackOperation(4, 0),
    "RETURNDATASIZE": StackOperation(0, 1),
    "RETURNDATACOPY": StackOperation(3, 0),
    "EXTCODEHASH": StackOperation(1, 1),
    "BLOCKHASH": StackOperation(1, 1),
    
    # 40s: Block Information
    "COINBASE": StackOperation(0, 1),
    "TIMESTAMP": StackOperation(0, 1),
    "NUMBER": StackOperation(0, 1),
    "DIFFICULTY": StackOperation(0, 1),
    "GASLIMIT": StackOperation(0, 1),
    "CHAINID": StackOperation(0, 1),
    "SELFBALANCE": StackOperation(0, 1),
    "BASEFEE": StackOperation(0, 1),
    
    # 50s: Stack, Memory, Storage and Flow Operations
    "POP": StackOperation(1, 0),
    "MLOAD": StackOperation(1, 1),
    "MSTORE": StackOperation(2, 0),
    "MSTORE8": StackOperation(2, 0),
    "SLOAD": StackOperation(1, 1),
    "SSTORE": StackOperation(2, 0),
    "JUMP": StackOperation(1, 0),
    "JUMPI": StackOperation(2, 0),
    "PC": StackOperation(0, 1),
    "MSIZE": StackOperation(0, 1),
    "GAS": StackOperation(0, 1),
    "JUMPDEST": StackOperation(0, 0),
    
    # 60s: Push Operations
    **{f"PUSH{i}": StackOperation(0, 1) for i in range(1, 33)},
    
    # 80s: Duplication Operations
    **{f"DUP{i}": StackOperation(i, i+1) for i in range(1, 17)},
    
    # 90s: Exchange Operations
    **{f"SWAP{i}": StackOperation(i+1, i+1) for i in range(1, 17)},
    
    # a0s: Logging Operations
    "LOG0": StackOperation(2, 0),
    "LOG1": StackOperation(3, 0),
    "LOG2": StackOperation(4, 0),
    "LOG3": StackOperation(5, 0),
    "LOG4": StackOperation(6, 0),
    
    # f0s: System Operations
    "CREATE": StackOperation(3, 1),
    "CALL": StackOperation(7, 1),
    "CALLCODE": StackOperation(7, 1),
    "RETURN": StackOperation(2, 0),
    "DELEGATECALL": StackOperation(6, 1),
    "CREATE2": StackOperation(4, 1),
    "STATICCALL": StackOperation(6, 1),
    "REVERT": StackOperation(2, 0),
    "INVALID": StackOperation(0, 0),
    "SELFDESTRUCT": StackOperation(1, 0),
}

# Register allocation for the RISC-V transpiler
class RegisterAllocator:
    """Manages RISC-V register allocation from EVM stack positions"""
    
    # RISC-V registers that can be used for stack elements
    AVAILABLE_REGISTERS = [f"a{i}" for i in range(8)] + [f"s{i}" for i in range(12)]
    
    # Special registers with specific purposes
    SPECIAL_REGISTERS = {
        "stack_pointer": "sp",
        "temp_reg1": "t0",
        "temp_reg2": "t1",
        "temp_reg3": "t2",
        "temp_reg4": "t3",
        "temp_reg5": "t4",
        "temp_reg6": "t5",
        "memory_pointer": "s0",  # Points to EVM memory area
        "storage_pointer": "s1",  # Points to EVM storage area
        "gas_counter": "s2",      # For tracking gas usage
    }
    
    def __init__(self):
        self.stack_to_reg = {}  # Maps stack positions to registers
        self.reg_to_stack = {}  # Maps registers to stack positions
        self.free_registers = set(self.AVAILABLE_REGISTERS.copy())
        self.spill_counter = 0  # Counter for stack spilling when out of registers
    
    def get_register(self, stack_pos):
        """Get register for a stack position, allocating if necessary"""
        if stack_pos in self.stack_to_reg:
            return self.stack_to_reg[stack_pos]
        
        if self.free_registers:
            reg = self.free_registers.pop()
            self.stack_to_reg[stack_pos] = reg
            self.reg_to_stack[reg] = stack_pos
            return reg
        
        # No free registers, need to spill to memory
        return self._spill_and_allocate(stack_pos)
    
    def _spill_and_allocate(self, stack_pos):
        """Spill least recently used register to memory and allocate it"""
        # For simplicity, spill the register with the lowest stack position
        victim_pos = min(self.stack_to_reg.keys())
        victim_reg = self.stack_to_reg[victim_pos]
        
        # Remove mappings
        del self.stack_to_reg[victim_pos]
        del self.reg_to_stack[victim_reg]
        
        # Allocate the freed register to the new stack position
        self.stack_to_reg[stack_pos] = victim_reg
        self.reg_to_stack[victim_reg] = stack_pos
        
        # Return spill information for the transpiler to generate spill code
        self.spill_counter += 1
        return victim_reg, victim_pos, self.spill_counter
    
    def free_register(self, stack_pos):
        """Free a register when stack position is popped"""
        if stack_pos in self.stack_to_reg:
            reg = self.stack_to_reg[stack_pos]
            del self.stack_to_reg[stack_pos]
            del self.reg_to_stack[reg]
            self.free_registers.add(reg)
    
    def get_special(self, name):
        """Get a special register by name"""
        return self.SPECIAL_REGISTERS.get(name)

# Pattern recognition and translation
def recognize_patterns(instructions):
    """Identify patterns in the EVM bytecode"""
    patterns = []
    i = 0
    
    while i < len(instructions):
        # Look for patterns here
        # Example: ADD followed by SUB might be recognized as a specific pattern
        
        # Simple pattern: PUSH followed by arithmetic
        if i + 1 < len(instructions):
            if instructions[i].startswith("PUSH") and instructions[i+1] in {"ADD", "SUB", "MUL", "DIV"}:
                patterns.append(("PUSH_ARITH", i, i+1))
                i += 2
                continue
        
        # No pattern recognized, move to next instruction
        i += 1
    
    return patterns

# Generator functions for RISC-V patterns
def gen_arithmetic(opcode, registers):
    """Generate RISC-V code for basic arithmetic operations"""
    if opcode == "ADD":
        return [f"add {registers['dest']}, {registers['src1']}, {registers['src2']}"]
    elif opcode == "SUB":
        return [f"sub {registers['dest']}, {registers['src1']}, {registers['src2']}"]
    elif opcode == "MUL":
        return [f"mul {registers['dest']}, {registers['src1']}, {registers['src2']}"]
    elif opcode == "DIV":
        return [f"div {registers['dest']}, {registers['src1']}, {registers['src2']}"]
    elif opcode == "AND":
        return [f"and {registers['dest']}, {registers['src1']}, {registers['src2']}"]
    elif opcode == "OR":
        return [f"or {registers['dest']}, {registers['src1']}, {registers['src2']}"]
    elif opcode == "XOR":
        return [f"xor {registers['dest']}, {registers['src1']}, {registers['src2']}"]
    # Add more as needed
    return []

def gen_push_immediate(value, dest_reg):
    """Generate RISC-V code for pushing immediate value to register"""
    # For 32-bit RISC-V, large values need multiple instructions
    if isinstance(value, int) and -2048 <= value <= 2047:
        return [f"li {dest_reg}, {value}"]
    else:
        # For larger values, needs multiple instructions
        return [
            f"lui {dest_reg}, %hi({value})",
            f"addi {dest_reg}, {dest_reg}, %lo({value})"
        ]

def gen_memory_access(opcode, registers):
    """Generate RISC-V code for memory operations"""
    if opcode == "MSTORE":
        return [
            # Adjust EVM memory address (multiply by 32 for word size)
            f"slli {registers['temp']}, {registers['addr']}, 5",
            f"add {registers['temp']}, {registers['memory_ptr']}, {registers['temp']}",
            f"sw {registers['value']}, 0({registers['temp']})"
        ]
    elif opcode == "MLOAD":
        return [
            # Adjust EVM memory address
            f"slli {registers['temp']}, {registers['addr']}, 5",
            f"add {registers['temp']}, {registers['memory_ptr']}, {registers['temp']}",
            f"lw {registers['dest']}, 0({registers['temp']})"
        ]
    # Add more as needed
    return []

def gen_stack_manipulation(opcode, registers):
    """Generate RISC-V code for stack manipulation operations (DUP, SWAP)"""
    if opcode.startswith("DUP"):
        n = int(opcode[3:])
        return [f"mv {registers['dest']}, {registers[f'src{n}']}"]
    elif opcode.startswith("SWAP"):
        n = int(opcode[4:])
        return [
            f"mv {registers['temp']}, {registers['top']}",
            f"mv {registers['top']}, {registers[f'src{n}']}",
            f"mv {registers[f'src{n}']}, {registers['temp']}"
        ]
    return []

def gen_comparison(opcode, registers):
    """Generate RISC-V code for comparison operations"""
    if opcode == "LT":
        return [
            f"slt {registers['dest']}, {registers['src1']}, {registers['src2']}"
        ]
    elif opcode == "GT":
        return [
            f"slt {registers['dest']}, {registers['src2']}, {registers['src1']}"
        ]
    elif opcode == "EQ":
        return [
            f"xor {registers['dest']}, {registers['src1']}, {registers['src2']}",
            f"seqz {registers['dest']}, {registers['dest']}"
        ]
    elif opcode == "ISZERO":
        return [f"seqz {registers['dest']}, {registers['src1']}"]
    # Add more as needed
    return []

def gen_control_flow(opcode, registers, labels):
    """Generate RISC-V code for control flow operations"""
    if opcode == "JUMP":
        return [f"j {labels[registers['dest']]}"]
    elif opcode == "JUMPI":
        return [
            f"bnez {registers['cond']}, {labels[registers['dest']]}",
        ]
    return []

def gen_special_operations(opcode, registers):
    """Generate RISC-V code for special EVM operations"""
    if opcode == "SHA3":
        # This would call into a SHA3 runtime library
        return [
            f"mv a0, {registers['offset']}",
            f"mv a1, {registers['size']}",
            f"call sha3_runtime",
            f"mv {registers['dest']}, a0"
        ]
    elif opcode == "RETURN":
        return [
            f"mv a0, {registers['offset']}",
            f"mv a1, {registers['size']}",
            f"call evm_return",
            f"j exit_contract"
        ]
    # Add more special operations as needed
    return []

# Common EVM patterns mapped to efficient RISC-V translations
COMMON_PATTERNS = [
    # Simple stack push followed by arithmetic
    EVMPattern(
        name="PUSH_THEN_ARITHMETIC",
        opcodes=["PUSH*", "ADD|SUB|MUL|DIV"],
        riscv_generator=lambda ops, ctx: [
            *gen_push_immediate(int(ops[0].split(' ')[1], 16), ctx["temp_reg"]),
            *gen_arithmetic(ops[1], {
                "dest": ctx["result_reg"],
                "src1": ctx["top_reg"],
                "src2": ctx["temp_reg"]
            })
        ]
    ),
    
    # Simple arithmetic between two stack values
    EVMPattern(
        name="STACK_ARITHMETIC",
        opcodes=["ADD|SUB|MUL|DIV|AND|OR|XOR"],
        riscv_generator=lambda ops, ctx: gen_arithmetic(ops[0], {
            "dest": ctx["result_reg"],
            "src1": ctx["top_reg"],
            "src2": ctx["second_reg"]
        })
    ),
    
    # Common comparison patterns
    EVMPattern(
        name="COMPARISON",
        opcodes=["LT|GT|EQ|ISZERO"],
        riscv_generator=lambda ops, ctx: gen_comparison(ops[0], {
            "dest": ctx["result_reg"],
            "src1": ctx["top_reg"],
            "src2": ctx.get("second_reg")
        })
    ),
    
    # Storage operations
    EVMPattern(
        name="STORAGE_ACCESS",
        opcodes=["SLOAD|SSTORE"],
        riscv_generator=lambda ops, ctx: [
            f"# Storage access for {ops[0]} - this will expand to multiple instructions",
            f"call evm_{ops[0].lower()}_handler"
        ]
    ),
    
    # Basic control flow
    EVMPattern(
        name="CONTROL_FLOW",
        opcodes=["JUMP|JUMPI"],
        riscv_generator=lambda ops, ctx: gen_control_flow(ops[0], {
            "dest": ctx["dest_reg"],
            "cond": ctx.get("cond_reg")
        }, ctx["labels"])
    ),
]

def match_pattern(instructions, start_idx, patterns):
    """Try to match a pattern starting at the given index"""
    for pattern in patterns:
        match_length = 0
        is_match = True
        
        for i, pattern_op in enumerate(pattern.opcodes):
            if start_idx + i >= len(instructions):
                is_match = False
                break
                
            # Handle pattern alternatives (e.g., "ADD|SUB")
            if "|" in pattern_op:
                alternatives = pattern_op.split("|")
                if not any(instructions[start_idx + i].startswith(alt) for alt in alternatives):
                    is_match = False
                    break
            # Handle wildcards (e.g., "PUSH*")
            elif pattern_op.endswith("*"):
                prefix = pattern_op[:-1]
                if not instructions[start_idx + i].startswith(prefix):
                    is_match = False
                    break
            # Exact match
            elif instructions[start_idx + i] != pattern_op:
                is_match = False
                break
                
            match_length += 1
        
        if is_match and match_length > 0:
            return pattern, match_length
    
    return None, 0

def scan_for_patterns(instructions):
    """Scan the instruction list for recognizable patterns"""
    results = []
    i = 0
    
    while i < len(instructions):
        pattern, length = match_pattern(instructions[i:], 0, COMMON_PATTERNS)
        
        if pattern:
            results.append((i, pattern, instructions[i:i+length]))
            i += length
        else:
            i += 1
    
    return results

def analyze_stack_usage(instructions):
    """Analyze the stack usage of a sequence of instructions"""
    stack_size = 0
    max_stack = 0
    stack_sizes = []
    
    for instr in instructions:
        # Extract the base opcode (ignoring parameters)
        opcode = instr.split(' ')[0]
        
        if opcode in STACK_EFFECTS:
            effect = STACK_EFFECTS[opcode]
            stack_size -= effect.pops
            stack_size += effect.pushes
            max_stack = max(max_stack, stack_size)
        else:
            # Handle unknown opcodes conservatively
            print(f"Warning: Unknown opcode '{opcode}' in stack analysis")
        
        stack_sizes.append(stack_size)
    
    return max_stack, stack_sizes

def find_basic_blocks(instructions):
    """
    Identify basic blocks in the EVM code
    A basic block is a sequence of instructions with no jumps in or out except at start/end
    """
    # First pass: identify all jump destinations
    jump_dests = set()
    labels = {}
    
    for i, instr in enumerate(instructions):
        if instr == "JUMPDEST":
            jump_dests.add(i)
            labels[i] = f"L{len(labels)}"
    
    # Second pass: find basic blocks
    blocks = []
    current_block = []
    current_block_start = 0
    
    for i, instr in enumerate(instructions):
        # Start a new block if this is a jump destination and we have a non-empty current block
        if i in jump_dests and current_block:
            blocks.append((current_block_start, current_block))
            current_block = []
            current_block_start = i
        
        # Add instruction to current block
        current_block.append(instr)
        
        # End block if this is a jump instruction
        if instr.startswith("JUMP") or instr == "STOP" or instr == "RETURN" or instr == "REVERT":
            blocks.append((current_block_start, current_block))
            current_block = []
            current_block_start = i + 1
    
    # Add the final block if it's not empty
    if current_block:
        blocks.append((current_block_start, current_block))
    
    return blocks, labels

def stack_to_registers(stack_depth, reg_allocator):
    """
    Map stack positions to registers based on current stack depth
    Returns a dictionary mapping stack positions to registers
    """
    reg_map = {}
    
    for i in range(stack_depth):
        reg_map[i] = reg_allocator.get_register(i)
    
    return reg_map

def transpile_instruction(instr, stack_depth, reg_allocator, labels=None):
    """
    Transpile a single EVM instruction to RISC-V assembly
    Returns a tuple of (RISC-V instructions, new stack depth)
    """
    opcode = instr.split(' ')[0]
    riscv_code = []
    
    # Get stack effect
    if opcode not in STACK_EFFECTS:
        # Handle unknown opcode
        riscv_code.append(f"# Unknown EVM opcode: {instr}")
        return riscv_code, stack_depth
    
    stack_effect = STACK_EFFECTS[opcode]
    new_stack_depth = stack_depth - stack_effect.pops + stack_effect.pushes
    
    # Map stack positions to registers
    stack_regs = {}
    for i in range(max(stack_depth, new_stack_depth)):
        if i < stack_depth or i < new_stack_depth:
            stack_regs[i] = reg_allocator.get_register(i)
    
    # Handle instruction categories
    if opcode.startswith("PUSH"):
        # Get the immediate value from the instruction
        parts = instr.split(' ', 1)
        if len(parts) > 1:
            value = parts[1]
            # Convert hex string to integer if it starts with 0x
            if value.startswith("0x"):
                value = int(value, 16)
            
            # Generate RISC-V li instruction
            riscv_code.extend(gen_push_immediate(value, stack_regs[new_stack_depth - 1]))
        else:
            riscv_code.append(f"# Error: PUSH instruction without value: {instr}")
    
    # Arithmetic operations
    elif opcode in {"ADD", "SUB", "MUL", "DIV", "AND", "OR", "XOR"}:
        riscv_code.extend(gen_arithmetic(opcode, {
            "dest": stack_regs[new_stack_depth - 1],
            "src1": stack_regs[stack_depth - 2],
            "src2": stack_regs[stack_depth - 1]
        }))
    
    # Comparison operations
    elif opcode in {"LT", "GT", "SLT", "SGT", "EQ", "ISZERO"}:
        riscv_code.extend(gen_comparison(opcode, {
            "dest": stack_regs[new_stack_depth - 1],
            "src1": stack_regs[stack_depth - 2] if opcode != "ISZERO" else stack_regs[stack_depth - 1],
            "src2": stack_regs[stack_depth - 1] if opcode != "ISZERO" else None
        }))
    
    # Memory operations
    elif opcode in {"MLOAD", "MSTORE", "MSTORE8"}:
        mem_ptr = reg_allocator.get_special("memory_pointer")
        temp_reg = reg_allocator.get_special("temp_reg1")
        
        if opcode == "MLOAD":
            riscv_code.extend(gen_memory_access(opcode, {
                "dest": stack_regs[new_stack_depth - 1],
                "addr": stack_regs[stack_depth - 1],
                "memory_ptr": mem_ptr,
                "temp": temp_reg
            }))
        elif opcode == "MSTORE":
            riscv_code.extend(gen_memory_access(opcode, {
                "addr": stack_regs[stack_depth - 2],
                "value": stack_regs[stack_depth - 1],
                "memory_ptr": mem_ptr,
                "temp": temp_reg
            }))
    
    # Stack manipulation (DUP, SWAP)
    elif opcode.startswith("DUP"):
        n = int(opcode[3:])
        riscv_code.extend(gen_stack_manipulation(opcode, {
            "dest": stack_regs[new_stack_depth - 1],
            **{f"src{i}": stack_regs[stack_depth - i] for i in range(1, n+1)}
        }))
    elif opcode.startswith("SWAP"):
        n = int(opcode[4:])
        temp_reg = reg_allocator.get_special("temp_reg1")
        riscv_code.extend(gen_stack_manipulation(opcode, {
            "top": stack_regs[stack_depth - 1],
            f"src{n}": stack_regs[stack_depth - n - 1],
            "temp": temp_reg
        }))
    
    # Control flow
    elif opcode in {"JUMP", "JUMPI"}:
        if labels is None:
            riscv_code.append(f"# Warning: Missing labels for {opcode}")
        else:
            if opcode == "JUMP":
                riscv_code.extend(gen_control_flow(opcode, {
                    "dest": stack_regs[stack_depth - 1]
                }, labels))
            elif opcode == "JUMPI":
                riscv_code.extend(gen_control_flow(opcode, {
                    "dest": stack_regs[stack_depth - 2],
                    "cond": stack_regs[stack_depth - 1]
                }, labels))
    
    # Special operations
    elif opcode in {"SHA3", "RETURN", "REVERT"}:
        if opcode == "SHA3":
            riscv_code.extend(gen_special_operations(opcode, {
                "dest": stack_regs[new_stack_depth - 1],
                "offset": stack_regs[stack_depth - 2],
                "size": stack_regs[stack_depth - 1]
            }))
        elif opcode in {"RETURN", "REVERT"}:
            riscv_code.extend(gen_special_operations(opcode, {
                "offset": stack_regs[stack_depth - 2],
                "size": stack_regs[stack_depth - 1]
            }))
    
    # Environmental operations
    elif opcode in {"ADDRESS", "BALANCE", "ORIGIN", "CALLER", "CALLVALUE",
                  "CALLDATALOAD", "CALLDATASIZE", "GASPRICE"}:
        riscv_code.append(f"# Environmental operation: {opcode}")
        riscv_code.append(f"call evm_{opcode.lower()}_handler")
        if stack_effect.pushes > 0:
            riscv_code.append(f"mv {stack_regs[new_stack_depth - 1]}, a0")
    
    # Other operations get a placeholder comment
    else:
        riscv_code.append(f"# TODO: Implement {opcode}")
    
    # Free registers for popped stack positions
    for i in range(stack_depth - 1, stack_depth - stack_effect.pops - 1, -1):
        if i >= 0:
            reg_allocator.free_register(i)
    
    return riscv_code, new_stack_depth

def transpile_basic_block(block_start, instructions, initial_stack_depth, reg_allocator, labels=None):
    """
    Transpile a basic block of EVM instructions to RISC-V assembly
    """
    riscv_code = []
    
    # Add label if this is a jump destination
    if block_start in labels:
        riscv_code.append(f"{labels[block_start]}:")
    
    # Process each instruction
    stack_depth = initial_stack_depth
    for instr in instructions:
        # Try to match a pattern first
        pattern, length = match_pattern([instr], 0, COMMON_PATTERNS)
        
        if pattern:
            # Use optimized pattern code
            pattern_code = pattern.riscv_generator([instr], {
                "top_reg": reg_allocator.get_register(stack_depth - 1) if stack_depth > 0 else None,
                "second_reg": reg_allocator.get_register(stack_depth - 2) if stack_depth > 1 else None,
                "result_reg": reg_allocator.get_register(stack_depth - 1) if stack_depth > 0 else reg_allocator.get_register(0),
                "temp_reg": reg_allocator.get_special("temp_reg1"),
                "labels": labels
            })
            riscv_code.append(f"# Pattern {pattern.name} for: {instr}")
            riscv_code.extend(pattern_code)
            
            # Update stack depth based on matched pattern
            opcode = instr.split(' ')[0]
            if opcode in STACK_EFFECTS:
                stack_effect = STACK_EFFECTS[opcode]
                stack_depth = stack_depth - stack_effect.pops + stack_effect.pushes
        else:
            # Process individual instruction
            instr_code, stack_depth = transpile_instruction(instr, stack_depth, reg_allocator, labels)
            riscv_code.append(f"# EVM: {instr}")
            riscv_code.extend(instr_code)
    
    return riscv_code, stack_depth

def generate_runtime_functions():
    """
    Generate RISC-V implementations of common EVM runtime functions
    """
    runtime_code = [
        "# EVM Runtime Support Functions",
        "",
        "# SHA3 (Keccak-256) implementation",
        "sha3_runtime:",
        "    # a0 = memory offset, a1 = size",
        "    # Implementation would call into a Keccak library",
        "    # Placeholder implementation",
        "    li a0, 0xDEADBEEF  # Dummy hash result",
        "    ret",
        "",
        "# EVM RETURN implementation",
        "evm_return:",
        "    # a0 = memory offset, a1 = size",
        "    # Copy data from EVM memory to output buffer",
        "    # Placeholder implementation",
        "    ret",
        "",
        "# EVM SLOAD implementation",
        "evm_sload_handler:",
        "    # a0 = key",
        "    # Load from storage",
        "    # Placeholder implementation",
        "    li a0, 0  # Default return value",
        "    ret",
        "",
        "# EVM SSTORE implementation",
        "evm_sstore_handler:",
        "    # a0 = key, a1 = value",
        "    # Store to storage",
        "    # Placeholder implementation",
        "    ret",
        "",
        "# Other EVM handlers would be implemented here",
        ""
    ]
    
    return runtime_code

def extract_push_value(instruction):
    """Extract the value from a PUSH instruction"""
    parts = instruction.split(' ', 1)
    if len(parts) > 1 and parts[0].startswith("PUSH"):
        value = parts[1]
        # Convert hex string to integer if it starts with 0x
        if value.startswith("0x"):
            return int(value, 16)
        return value
    return None

def resolve_jump_destinations(instructions):
    """
    Find all PUSH values that might be jump destinations
    """
    possible_dests = set()
    
    for i, instr in enumerate(instructions):
        if instr == "JUMPDEST":
            possible_dests.add(i)
        
        # Check if previous instructions push values that could be jump destinations
        for j in range(max(0, i-3), i):
            if j < len(instructions) and instructions[j].startswith("PUSH"):
                value = extract_push_value(instructions[j])
                if isinstance(value, int):
                    possible_dests.add(value)
    
    return possible_dests