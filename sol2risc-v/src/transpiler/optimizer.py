"""
EVM to RISC-V Transpiler Optimizer

This module optimizes the intermediate representation generated from EVM code
before final conversion to RISC-V assembly.

Key optimizations:
1. Stack to register mapping
2. Constant folding
3. Dead code elimination 
4. Peephole optimizations
5. Control flow optimizations
"""

import sys
import json
import copy
from collections import defaultdict, namedtuple

# IR structure (matches the parser output)
IR_Instruction = namedtuple('IR_Instruction', 
                          ['opcode', 'args', 'stack_in', 'stack_out', 'gas', 'pc'])
IR_BasicBlock = namedtuple('IR_BasicBlock', 
                          ['id', 'instructions', 'successors', 'predecessors'])

# Register allocation tracking
RegAlloc = namedtuple('RegAlloc', ['var_to_reg', 'reg_to_var', 'next_reg'])

class IROptimizer:
    """Optimizes the intermediate representation of EVM code for RISC-V conversion."""
    
    def __init__(self):
        self.ir_data = None
        self.instructions = []
        self.basic_blocks = []
        self.cfg = {}
        self.stack_analysis = {}
        
        # RISC-V has 32 general-purpose registers (x0-x31)
        # x0 is hardwired to 0, x1 is return address, x2 is stack pointer
        # We'll use x5-x31 for our allocations (x3-x4 for temporary values)
        self.available_regs = list(range(5, 32))
        
        # Special registers we'll use
        self.sp_reg = 2     # x2: Stack pointer
        self.ra_reg = 1     # x1: Return address
        self.zero_reg = 0   # x0: Zero register
        self.tmp1_reg = 3   # x3: First temporary register
        self.tmp2_reg = 4   # x4: Second temporary register
        
        # Stack-to-register mapping
        self.stack_to_reg = {}  # Maps stack positions to registers
        self.reg_allocation = RegAlloc({}, {}, 5)  # Start with x5
    
    def load_ir(self, filename):
        """Load intermediate representation from a JSON file."""
        with open(filename, 'r') as f:
            self.ir_data = json.load(f)
        
        # Convert JSON structures back to named tuples
        self.instructions = [
            IR_Instruction(
                opcode=instr['opcode'],
                args=instr['args'],
                stack_in=instr['stack_in'],
                stack_out=instr['stack_out'],
                gas=instr['gas'],
                pc=instr['pc']
            )
            for instr in self.ir_data['instructions']
        ]
        
        # Rebuild basic blocks
        self.basic_blocks = []
        pc_to_instr = {instr.pc: instr for instr in self.instructions}
        
        for block_data in self.ir_data['basic_blocks']:
            block_instrs = [pc_to_instr[pc] for pc in block_data['instructions'] if pc in pc_to_instr]
            block = IR_BasicBlock(
                id=block_data['id'],
                instructions=block_instrs,
                successors=block_data['successors'],
                predecessors=block_data['predecessors']
            )
            self.basic_blocks.append(block)
        
        self.cfg = self.ir_data['control_flow_graph']
        self.stack_analysis = self.ir_data['stack_analysis']
        
        return self.ir_data
    
    def optimize(self):
        """Apply all optimizations to the IR."""
        if not self.ir_data:
            raise ValueError("No IR data loaded. Call load_ir first.")
        
        # Make a copy of the original IR for comparison later
        original_ir = copy.deepcopy(self.ir_data)
        
        # Apply optimizations in sequence
        self._constant_folding()
        self._dead_code_elimination()
        self._peephole_optimization()
        self._allocate_registers()
        
        # Return the optimized IR and stats
        return {
            'original_instruction_count': len(original_ir['instructions']),
            'optimized_instruction_count': len(self.instructions),
            'reduction_percentage': (1 - len(self.instructions) / len(original_ir['instructions'])) * 100,
            'register_allocation': self.stack_to_reg,
            'optimized_ir': self._get_current_ir()
        }
    
    def _constant_folding(self):
        """
        Perform constant folding optimization.
        
        This optimization identifies sequences where constant values are pushed onto
        the stack and then operated on, and computes the result at compile time.
        """
        # Process each basic block separately
        for block_idx, block in enumerate(self.basic_blocks):
            new_instructions = []
            stack_sim = []  # Stack simulator for constant folding
            
            i = 0
            while i < len(block.instructions):
                instr = block.instructions[i]
                
                # Check if this is a PUSH operation
                if instr.opcode.startswith('PUSH'):
                    # Push value to simulated stack
                    try:
                        value = int(instr.args[0], 16) if instr.args else 0
                        stack_sim.append(('const', value))
                    except ValueError:
                        stack_sim.append(('unknown', None))
                    
                    new_instructions.append(instr)
                    i += 1
                    continue
                
                # Check if we can fold a constant operation
                if instr.opcode in ('ADD', 'SUB', 'MUL', 'DIV', 'MOD', 'AND', 'OR', 'XOR'):
                    if (len(stack_sim) >= 2 and 
                        stack_sim[-1][0] == 'const' and 
                        stack_sim[-2][0] == 'const'):
                        
                        # Get the two topmost stack values
                        _, val2 = stack_sim.pop()
                        _, val1 = stack_sim.pop()
                        
                        # Compute result
                        result = None
                        if instr.opcode == 'ADD':
                            result = (val1 + val2) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                        elif instr.opcode == 'SUB':
                            result = (val1 - val2) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                        elif instr.opcode == 'MUL':
                            result = (val1 * val2) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                        elif instr.opcode == 'DIV' and val2 != 0:
                            result = val1 // val2
                        elif instr.opcode == 'MOD' and val2 != 0:
                            result = val1 % val2
                        elif instr.opcode == 'AND':
                            result = val1 & val2
                        elif instr.opcode == 'OR':
                            result = val1 | val2
                        elif instr.opcode == 'XOR':
                            result = val1 ^ val2
                        
                        if result is not None:
                            # Replace the instructions with a PUSH
                            hex_result = hex(result)[2:]
                            # Determine the minimum size needed for the PUSH
                            size = (len(hex_result) + 1) // 2  # Each byte is 2 hex chars
                            size = max(1, size)  # At least PUSH1
                            size = min(32, size)  # Maximum is PUSH32
                            
                            # Create the replacement PUSH instruction
                            push_instr = IR_Instruction(
                                opcode=f"PUSH{size}",
                                args=[hex_result],
                                stack_in=0,
                                stack_out=1,
                                gas=3,  # Standard gas for PUSH
                                pc=instr.pc  # Keep the same PC for simplicity
                            )
                            
                            new_instructions.append(push_instr)
                            stack_sim.append(('const', result))
                            i += 1
                            continue
                
                # Handle stack manipulation operations
                if instr.opcode.startswith('DUP'):
                    dup_idx = int(instr.opcode[3:])
                    if len(stack_sim) >= dup_idx:
                        # Duplicate the value at position dup_idx from top
                        val_type, val = stack_sim[-dup_idx]
                        stack_sim.append((val_type, val))
                elif instr.opcode.startswith('SWAP'):
                    swap_idx = int(instr.opcode[4:])
                    if len(stack_sim) >= swap_idx + 1:
                        # Swap the top of stack with the item at position swap_idx from top
                        stack_sim[-1], stack_sim[-swap_idx-1] = stack_sim[-swap_idx-1], stack_sim[-1]
                elif instr.opcode == 'POP' and stack_sim:
                    stack_sim.pop()
                else:
                    # Handle any operation that consumes stack items
                    for _ in range(instr.stack_in):
                        if stack_sim:
                            stack_sim.pop()
                    
                    # Handle any operation that produces stack items
                    for _ in range(instr.stack_out):
                        stack_sim.append(('unknown', None))
                
                new_instructions.append(instr)
                i += 1
            
            # Update the block with optimized instructions
            self.basic_blocks[block_idx] = block._replace(instructions=new_instructions)
        
        # Rebuild flat instruction list
        self.instructions = []
        for block in self.basic_blocks:
            self.instructions.extend(block.instructions)
    
    def _dead_code_elimination(self):
        """
        Eliminate dead code - code that has no effect on the output.
        
        This includes:
        1. Operations that push and immediately pop without using the value
        2. Unused JUMPDEST labels
        3. Unreachable code
        """
        # First, identify reachable blocks through a simple graph traversal
        reachable = set()
        worklist = [0]  # Start with entry block
        
        while worklist:
            block_idx = worklist.pop()
            if block_idx in reachable:
                continue
                
            reachable.add(block_idx)
            
            # Add successors to worklist
            for succ in self.basic_blocks[block_idx].successors:
                if succ not in reachable:
                    worklist.append(succ)
        
        # Remove unreachable blocks
        self.basic_blocks = [block for i, block in enumerate(self.basic_blocks) if i in reachable]
        
        # Rebuild block IDs and CFG
        for i, block in enumerate(self.basic_blocks):
            self.basic_blocks[i] = block._replace(id=i)
        
        # Create new ID mapping
        old_to_new_id = {}
        for i, block in enumerate(self.basic_blocks):
            old_to_new_id[block.id] = i
        
        # Update successors and predecessors with new IDs
        for i, block in enumerate(self.basic_blocks):
            new_successors = [old_to_new_id.get(s, s) for s in block.successors if s in old_to_new_id]
            new_predecessors = [old_to_new_id.get(p, p) for p in block.predecessors if p in old_to_new_id]
            self.basic_blocks[i] = block._replace(successors=new_successors, predecessors=new_predecessors)
        
        # Rebuild CFG
        self.cfg = {i: block.successors for i, block in enumerate(self.basic_blocks)}
        
        # Now handle push-pop pairs and other simple cases within each block
        for block_idx, block in enumerate(self.basic_blocks):
            new_instructions = []
            i = 0
            
            while i < len(block.instructions):
                instr = block.instructions[i]
                
                # Case 1: PUSH followed by POP - remove both
                if (instr.opcode.startswith('PUSH') and 
                    i + 1 < len(block.instructions) and 
                    block.instructions[i+1].opcode == 'POP'):
                    # Skip both instructions
                    i += 2
                    continue
                
                # Case 2: Unused JUMPDEST with no predecessors
                if instr.opcode == 'JUMPDEST':
                    # Check if any block jumps to this instruction's PC
                    pc = instr.pc
                    has_jumpers = False
                    
                    for other_block in self.basic_blocks:
                        for other_instr in other_block.instructions:
                            if other_instr.opcode in ('JUMP', 'JUMPI') and other_block.id != block.id:
                                # Check if this might be a jump target
                                # This is conservative - we keep JUMPDEST if unsure
                                has_jumpers = True
                                break
                        if has_jumpers:
                            break
                    
                    if not has_jumpers and not block.predecessors:
                        # Skip this JUMPDEST if it's not a target
                        i += 1
                        continue
                
                new_instructions.append(instr)
                i += 1
            
            # Update the block with optimized instructions
            self.basic_blocks[block_idx] = block._replace(instructions=new_instructions)
        
        # Rebuild flat instruction list
        self.instructions = []
        for block in self.basic_blocks:
            self.instructions.extend(block.instructions)
    
    def _peephole_optimization(self):
        """
        Apply peephole optimizations.
        
        These are small, localized optimizations that replace specific
        instruction sequences with more efficient ones.
        """
        # Process each basic block separately
        for block_idx, block in enumerate(self.basic_blocks):
            new_instructions = []
            i = 0
            
            while i < len(block.instructions):
                instr = block.instructions[i]
                
                # Pattern 1: NOT(NOT(x)) -> x
                if (instr.opcode == 'NOT' and 
                    i + 1 < len(block.instructions) and 
                    block.instructions[i+1].opcode == 'NOT'):
                    # Skip both NOT operations
                    i += 2
                    continue
                
                # Pattern 2: PUSH0 (or PUSH1 0) ADD -> NOP
                if ((instr.opcode == 'PUSH1' and instr.args and instr.args[0] == '0') and
                    i + 1 < len(block.instructions) and 
                    block.instructions[i+1].opcode == 'ADD'):
                    # Replace with just the second operand (effectively a NOP)
                    # We keep the first operand implicitly
                    i += 2
                    continue
                
                # Pattern 3: XOR(x, x) -> PUSH0 (result is always 0)
                if (instr.opcode == 'DUP1' and 
                    i + 1 < len(block.instructions) and 
                    block.instructions[i+1].opcode == 'XOR'):
                    # Replace with PUSH1 0
                    new_instr = IR_Instruction(
                        opcode='PUSH1',
                        args=['0'],
                        stack_in=0,
                        stack_out=1,
                        gas=3,
                        pc=instr.pc
                    )
                    new_instructions.append(new_instr)
                    i += 2
                    continue
                
                # Pattern 4: ISZERO(ISZERO(x)) -> x (double negation)
                if (instr.opcode == 'ISZERO' and 
                    i + 1 < len(block.instructions) and 
                    block.instructions[i+1].opcode == 'ISZERO'):
                    # Skip both operations (they cancel out)
                    i += 2
                    continue
                
                new_instructions.append(instr)
                i += 1
            
            # Update the block with optimized instructions
            self.basic_blocks[block_idx] = block._replace(instructions=new_instructions)
        
        # Rebuild flat instruction list
        self.instructions = []
        for block in self.basic_blocks:
            self.instructions.extend(block.instructions)
    
    def _allocate_registers(self):
        """
        Perform register allocation for the stack values.
        
        This maps the EVM stack positions to RISC-V registers, which will be
        used during the final assembly generation.
        """
        # Analyze liveness of stack positions
        liveness = self._analyze_liveness()
        
        # Allocate registers using a simple linear scan algorithm
        reg_alloc = RegAlloc({}, {}, self.available_regs[0])  # Start with first available reg
        active = []  # Currently active intervals
        
        # Sort intervals by start point
        intervals = sorted(liveness.items(), key=lambda x: x[1][0])
        
        for stack_pos, (start, end) in intervals:
            # Expire old intervals
            active = [(pos, s, e, reg) for pos, s, e, reg in active if e >= start]
            
            if len(active) >= len(self.available_regs):
                # Spill to memory if we run out of registers
                # Find interval with the furthest end point
                active.sort(key=lambda x: x[2], reverse=True)
                spill_pos, _, _, spill_reg = active.pop(0)
                
                # Free the register
                reg_alloc.reg_to_var.pop(spill_reg)
                reg_alloc.var_to_reg.pop(spill_pos)
                
                # Allocate the freed register
                reg = spill_reg
            else:
                # Allocate a new register
                reg = self.available_regs[reg_alloc.next_reg - self.available_regs[0]]
                reg_alloc = reg_alloc._replace(next_reg=reg_alloc.next_reg + 1)
            
            # Assign register to stack position
            reg_alloc.var_to_reg[stack_pos] = reg
            reg_alloc.reg_to_var[reg] = stack_pos
            
            # Add to active list
            active.append((stack_pos, start, end, reg))
        
        # Update the stack-to-register mapping
        self.stack_to_reg = reg_alloc.var_to_reg
        self.reg_allocation = reg_alloc
        
        return self.stack_to_reg
    
    def _analyze_liveness(self):
        """
        Analyze liveness of stack positions.
        
        Returns a dictionary mapping stack positions to (start, end) instruction indices.
        """
        liveness = {}
        stack_pos = 0
        
        # First pass: assign stack positions
        for i, instr in enumerate(self.instructions):
            # Handle stack inputs (they're live until this instruction)
            for j in range(instr.stack_in):
                pos = stack_pos - j - 1
                if pos not in liveness:
                    # Position hasn't been seen before
                    liveness[pos] = (i, i)
                else:
                    # Update end point
                    start, _ = liveness[pos]
                    liveness[pos] = (start, i)
            
            # Update stack pointer
            stack_pos -= instr.stack_in
            stack_pos += instr.stack_out
            
            # Handle stack outputs (they're live from this instruction)
            for j in range(instr.stack_out):
                pos = stack_pos - j - 1
                liveness[pos] = (i, i)  # Initially live only at this instruction
        
        # Second pass: propagate liveness backwards
        for i in range(len(self.instructions) - 1, -1, -1):
            instr = self.instructions[i]
            
            # Handle stack outputs (they're live from this instruction onwards)
            stack_pos = 0
            for j in range(i):
                prev_instr = self.instructions[j]
                stack_pos -= prev_instr.stack_in
                stack_pos += prev_instr.stack_out
            
            # Update stack pointer for this instruction
            cur_stack_pos = stack_pos
            cur_stack_pos -= instr.stack_in
            cur_stack_pos += instr.stack_out
            
            # Update liveness for values produced by this instruction
            for j in range(instr.stack_out):
                pos = cur_stack_pos - j - 1
                if pos in liveness:
                    # Extend liveness to the end of the program if used later
                    start, end = liveness[pos]
                    if end > i:
                        liveness[pos] = (i, end)
        
        return liveness
    
    def _get_current_ir(self):
        """Get the current IR in serializable format."""
        return {
            'instructions': [
                {
                    'opcode': instr.opcode,
                    'args': instr.args,
                    'stack_in': instr.stack_in,
                    'stack_out': instr.stack_out,
                    'gas': instr.gas,
                    'pc': instr.pc
                }
                for instr in self.instructions
            ],
            'basic_blocks': [
                {
                    'id': block.id,
                    'instructions': [instr.pc for instr in block.instructions],
                    'successors': block.successors,
                    'predecessors': block.predecessors
                }
                for block in self.basic_blocks
            ],
            'control_flow_graph': self.cfg,
            'stack_to_reg': self.stack_to_reg
        }
    
    def save_optimized_ir(self, filename):
        """Save the optimized IR to a file."""
        with open(filename, 'w') as f:
            json.dump(self._get_current_ir(), f, indent=2)