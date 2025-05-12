import logging


class InstructionOptimizer:
    """
    Main class responsible for optimizing EVM instruction sequences.
    
    Integrates with pattern recognition, arithmetic optimization,
    register allocation, and memory access patterns.
    """

    def __init__(self, context=None):
        """
        Initialize optimizer with optional context.
        """
        self.context = context
        self.pattern_recognizer = None
        self.unknown_instruction_handling = "preserve"  # Can be 'preserve', 'replace', or 'remove'
        if context is not None:
            self._init_dependencies()

    def set_context(self, context):
        """
        Set compilation context.

        Args:
            context (Context): Shared state object
        """
        self.context = context
        self._init_dependencies()
        
    def set_unknown_handling(self, mode="preserve"):
        """
        Configure how unknown instructions are handled.
        
        Args:
            mode (str): One of 'preserve' (keep as is), 'remove' (filter out), 
                        or 'replace' (substitute with NOP)
        """
        valid_modes = ["preserve", "remove", "replace"]
        if mode not in valid_modes:
            logging.warning(f"Invalid unknown instruction handling mode: {mode}. " 
                          f"Must be one of {valid_modes}. Using 'preserve'.")
            mode = "preserve"
        
        self.unknown_instruction_handling = mode
        logging.info(f"Set unknown instruction handling to '{mode}'")

    def _init_dependencies(self):
        """Lazy-load dependent modules to avoid circular imports."""
        if self.context is None:
            return

        try:
            from .pattern import PatternRecognizer
            from .arithmetic import ArithmeticTranslator

            # Create pattern recognizer instance
            self.pattern_recognizer = PatternRecognizer()
            self.pattern_recognizer.set_context(self.context)

            # Bind methods
            self.matches_known_pattern = self.pattern_recognizer.matches_known_pattern
            self.apply_pattern_rewrite = self.pattern_recognizer.apply_pattern_rewrite
            self.optimize_arithmetic_sequence = ArithmeticTranslator.optimize_arithmetic_sequence
        except Exception as e:
            logging.warning(f"Failed to load dependencies: {str(e)}")
            # Initialize basic fallback functions if dependencies can't be loaded
            self.matches_known_pattern = lambda x: False
            self.apply_pattern_rewrite = lambda x: x
            self.optimize_arithmetic_sequence = lambda x: x

    # --- Public Methods ---

    def optimize_instructions(self, instructions: list, context=None):
        """
        Main entry point for instruction optimization.

        Args:
            instructions (list): List of parsed EVM instructions
            context (CompilationContext): Optional shared compilation state
        Returns:
            list: Optimized instruction list
        """
        if not instructions:
            logging.warning("No instructions to optimize")
            return []
            
        # Update context if provided
        if context is not None:
            self.set_context(context)
            
        logging.info("Starting instruction optimization...")
        start_count = len(instructions)
        logging.debug(f"Initial instruction count: {start_count}")

        try:
            optimized = instructions.copy()

            # First handle unknown instructions
            original_count = len(optimized)
            optimized = self.handle_unknown_instructions(optimized)
            if len(optimized) != original_count:
                logging.debug(f"After handling unknowns: {len(optimized)}")

            # Apply passes in order
            passes = [
                ("Constant Folding", self.perform_constant_folding),
                ("Dead Code Elimination", self.eliminate_dead_code),
                ("Operation Coalescing", self.coalesce_operations),
                ("Memory Access Optimization", self.optimize_memory_access),
                ("Peephole Optimizations", self.apply_peephole_optimizations),
            ]

            for name, func in passes:
                try:
                    logging.debug(f"Running optimization pass: {name}")
                    before = len(optimized)
                    optimized = func(optimized)
                    after = len(optimized)
                    if before != after:
                        logging.debug(f"{name} reduced instructions from {before} → {after}")
                except Exception as e:
                    logging.error(f"Error during '{name}': {str(e)}", exc_info=True)
                    # Continue with the next pass instead of failing completely

            logging.info(f"Optimization complete. Instructions reduced from {start_count} → {len(optimized)}")
            return optimized
        except Exception as e:
            logging.error(f"Critical error in optimizer: {str(e)}", exc_info=True)
            # Return original instructions instead of empty list to avoid pipeline failure
            return instructions

    def handle_unknown_instructions(self, instructions):
        """
        Handle unsupported or unknown opcodes based on configured policy.
        """
        if not instructions:
            return []
            
        result = []
        unknown_count = 0
        
        for instr in instructions:
            opcode = instr.get("opcode", "")
            
            # Skip instructions with type 'label' since they're not opcodes
            if instr.get("type") == "label":
                result.append(instr)
                continue
                
            if opcode.startswith("UNKNOWN"):
                unknown_count += 1
                
                if self.unknown_instruction_handling == "preserve":
                    # Keep the instruction but log it
                    logging.info(f"Preserving unknown instruction: {opcode}")
                    result.append(instr)
                    
                elif self.unknown_instruction_handling == "replace":
                    # Replace with NOP (represented as PUSH1 0, POP)
                    logging.info(f"Replacing unknown instruction {opcode} with NOP")
                    result.append({"opcode": "PUSH1", "value": "0x0", "args": ["0x0"], "stack_effect": 1})
                    result.append({"opcode": "POP", "args": [], "stack_effect": -1})
                    
                elif self.unknown_instruction_handling == "remove":
                    # Skip the instruction entirely
                    logging.info(f"Removing unknown instruction: {opcode}")
                    # Don't append to result
                    
                else:
                    # Should never happen due to validation in set_unknown_handling
                    logging.warning(f"Unknown handling mode '{self.unknown_instruction_handling}', preserving instruction")
                    result.append(instr)
            else:
                result.append(instr)
                
        if unknown_count > 0:
            logging.info(f"Handled {unknown_count} unknown instructions with mode '{self.unknown_instruction_handling}'")
            
        return result

    def perform_constant_folding(self, instructions: list):
        """
        Replace constant expressions with their computed values.
        """
        if not instructions:
            return []
            
        logging.debug("Performing constant folding...")
        optimized = []
        i = 0
        while i < len(instructions):
            instr = instructions[i]
            
            # Skip label instructions
            if instr.get("type") == "label":
                optimized.append(instr)
                i += 1
                continue
                
            # Check for constant expressions
            if instr.get("opcode") in ["PUSH1", "PUSH2"] and i + 1 < len(instructions):
                next_instr = instructions[i + 1]
                # Skip if next instruction is a label
                if next_instr.get("type") == "label":
                    optimized.append(instr)
                    i += 1
                    continue
                    
                if next_instr.get("opcode") in ["ADD", "MUL", "SUB", "DIV"]:
                    try:
                        # Check if value is valid
                        value = instr.get("value")
                        if value is None or not isinstance(value, str):
                            optimized.append(instr)
                            i += 1
                            continue
                            
                        # Try to parse the value safely
                        val1 = int(value, 16) if value.startswith("0x") else int(value, 16)
                        
                        # Look for preceding PUSH instruction
                        if i > 0 and instructions[i-1].get("opcode", "").startswith("PUSH"):
                            prev_value = instructions[i-1].get("value")
                            if prev_value is not None and isinstance(prev_value, str):
                                val2 = int(prev_value, 16) if prev_value.startswith("0x") else int(prev_value, 16)
                                
                                # Calculate result based on operation
                                result = None
                                if next_instr["opcode"] == "ADD":
                                    result = val1 + val2
                                elif next_instr["opcode"] == "MUL":
                                    result = val1 * val2
                                elif next_instr["opcode"] == "SUB":
                                    result = val2 - val1  # Note: order matters for SUB
                                elif next_instr["opcode"] == "DIV" and val1 != 0:
                                    result = val2 // val1  # Integer division
                                
                                if result is not None:
                                    # Replace last instruction with result and skip next two
                                    optimized.pop()  # Remove previous PUSH
                                    optimized.append({
                                        "opcode": "PUSH1" if result < 256 else "PUSH2", 
                                        "value": hex(result),
                                        "args": [hex(result)],
                                        "stack_effect": 1
                                    })
                                    i += 2  # Skip current PUSH and operation
                                    continue
                    except (ValueError, TypeError) as e:
                        logging.debug(f"Could not fold constants: {e}")
                        # Fall through to append the original instruction
            
            optimized.append(instr)
            i += 1
            
        return optimized

    def eliminate_dead_code(self, instructions: list):
        """
        Remove unreachable or unused instructions.
        """
        if not instructions:
            return []
            
        logging.debug("Eliminating dead code...")
        
        # First, identify all jump destinations
        jump_destinations = set()
        for i, instr in enumerate(instructions):
            if instr.get("opcode") == "JUMPDEST" or instr.get("jumpdest", False):
                jump_destinations.add(i)
            elif instr.get("type") == "label":
                jump_destinations.add(i)
        
        # Keep track of active blocks
        active_blocks = set([0])  # Start with entry point
        
        # Add jump destinations from explicit jumps
        for i, instr in enumerate(instructions):
            if instr.get("opcode") in ["JUMP", "JUMPI"] and "target_index" in instr:
                target = instr.get("target_index")
                if target >= 0:
                    active_blocks.add(target)
        
        # Collect live instructions
        optimized = []
        i = 0
        while i < len(instructions):
            instr = instructions[i]
            
            # Always include jump destinations and labels
            if i in jump_destinations or instr.get("type") == "label":
                optimized.append(instr)
                i += 1
                continue
                
            opcode = instr.get("opcode", "")
            
            # Handle unconditional control flow changes
            if opcode == "JUMP":
                optimized.append(instr)
                # If we can't determine where this jumps, keep everything after as well
                if "target_index" not in instr or instr["target_index"] < 0:
                    i += 1  # Continue normally
                else:
                    # Skip until next jump destination (dead code elimination)
                    i += 1
                    while i < len(instructions) and i not in jump_destinations:
                        i += 1
                    continue
            elif opcode in ["REVERT", "RETURN", "STOP", "INVALID"]:
                optimized.append(instr)
                # Everything after is dead until next jump destination
                i += 1
                while i < len(instructions) and i not in jump_destinations:
                    i += 1
                continue
            else:
                optimized.append(instr)
                i += 1
                
        return optimized

    def coalesce_operations(self, instructions: list):
        """
        Merge repeated operations into single instructions where possible.
        """
        if not instructions:
            return []
            
        logging.debug("Coalescing operations...")
        optimized = []
        i = 0
        while i < len(instructions):
            # Skip label instructions
            if instructions[i].get("type") == "label":
                optimized.append(instructions[i])
                i += 1
                continue
                
            if i + 1 < len(instructions):
                curr = instructions[i]
                next_instr = instructions[i + 1]
                
                # Skip if next instruction is a label
                if next_instr.get("type") == "label":
                    optimized.append(curr)
                    i += 1
                    continue
                
                # ADD + ADD -> MUL by 2
                if curr.get("opcode") == "ADD" and next_instr.get("opcode") == "ADD":
                    # Replace with PUSH1 2 + MUL
                    optimized.append({
                        "opcode": "PUSH1", 
                        "value": "0x2",
                        "args": ["0x2"],
                        "stack_effect": 1
                    })
                    optimized.append({
                        "opcode": "MUL", 
                        "args": [],
                        "stack_effect": -1
                    })
                    i += 2
                    continue
                    
                # PUSH1 0 + ADD -> NOP (optimization pattern)
                if (curr.get("opcode") == "PUSH1" and curr.get("value") == "0x0" and 
                    next_instr.get("opcode") == "ADD"):
                    # This is equivalent to a NOP - skip the PUSH0 instruction
                    optimized.append(next_instr)
                    i += 2
                    continue
                    
                # PUSH1 0 + MUL -> POP + PUSH1 0 (zero result)
                if (curr.get("opcode") == "PUSH1" and curr.get("value") == "0x0" and 
                    next_instr.get("opcode") == "MUL"):
                    optimized.append({"opcode": "POP", "args": [], "stack_effect": -1})
                    optimized.append({
                        "opcode": "PUSH1", 
                        "value": "0x0",
                        "args": ["0x0"],
                        "stack_effect": 1
                    })
                    i += 2
                    continue
                    
                # Other patterns can be added here
                
            optimized.append(instructions[i])
            i += 1
            
        return optimized

    def optimize_memory_access(self, instructions: list):
        """
        Optimize memory accesses by combining loads/stores or eliminating redundant ones.
        """
        if not instructions:
            return []
            
        logging.debug("Optimizing memory access...")
        optimized = []
        i = 0
        
        # Track last memory access by offset
        last_store = {}  # offset -> instruction index
        
        while i < len(instructions):
            instr = instructions[i]
            
            # Skip label instructions
            if instr.get("type") == "label":
                optimized.append(instr)
                i += 1
                continue
                
            opcode = instr.get("opcode", "")
            
            # Track memory stores
            if opcode == "MSTORE":
                offset = instr.get("offset")
                if offset is not None:
                    last_store[offset] = len(optimized)
            
            # Check for redundant memory loads
            if opcode == "MLOAD":
                offset = instr.get("offset")
                if offset is not None and offset in last_store:
                    # Look up the store instruction
                    store_idx = last_store[offset]
                    store_instr = optimized[store_idx]
                    
                    # If this is loading right after storing, we can optimize
                    if store_instr.get("opcode") == "MSTORE" and store_instr.get("offset") == offset:
                        # Add a DUP1 before the MSTORE in place of the MLOAD
                        dup_instr = {"opcode": "DUP1", "args": [], "stack_effect": 1}
                        optimized.insert(store_idx, dup_instr)
                        i += 1
                        continue
            
            # Check for consecutive memory operations that can be combined
            if i + 1 < len(instructions) and opcode in ["MSTORE", "MSTORE8"]:
                next_instr = instructions[i + 1]
                if next_instr.get("opcode") == opcode:
                    # Check if offsets are adjacent
                    curr_offset = instr.get("offset")
                    next_offset = next_instr.get("offset")
                    
                    if (curr_offset is not None and next_offset is not None and 
                        (opcode == "MSTORE" and next_offset == curr_offset + 32) or
                        (opcode == "MSTORE8" and next_offset == curr_offset + 1)):
                        # Could potentially combine into a single wider store
                        # This is complex and needs careful analysis of stack values
                        # For now, just keep track of this pattern
                        logging.debug(f"Potential memory access optimization at {i}")
            
            optimized.append(instr)
            i += 1
            
        return optimized

    def apply_peephole_optimizations(self, instructions: list):
        """
        Perform peephole-style optimizations based on small instruction patterns.
        """
        if not instructions:
            return []
            
        logging.debug("Applying peephole optimizations...")
        optimized = []
        i = 0
        while i < len(instructions):
            # Skip label instructions
            if instructions[i].get("type") == "label":
                optimized.append(instructions[i])
                i += 1
                continue
                
            if i + 1 < len(instructions):
                curr = instructions[i]
                next_instr = instructions[i + 1]
                
                # Skip if next instruction is a label
                if next_instr.get("type") == "label":
                    optimized.append(curr)
                    i += 1
                    continue
                
                # Pattern: POP followed by POP (wasteful)
                if curr.get("opcode") == "POP" and next_instr.get("opcode") == "POP":
                    # Replace with SWAP1 + POP which is more efficient for two values
                    optimized.append({"opcode": "SWAP1", "args": [], "stack_effect": 0})
                    optimized.append({"opcode": "POP", "args": [], "stack_effect": -1})
                    i += 2
                    continue
                    
                # Pattern: PUSH x, POP (useless push)
                if curr.get("opcode").startswith("PUSH") and next_instr.get("opcode") == "POP":
                    # Skip both instructions - they cancel each other out
                    i += 2
                    continue
                    
                # Pattern: DUP1, POP (useless dup)
                if curr.get("opcode") == "DUP1" and next_instr.get("opcode") == "POP":
                    # Skip both instructions - they cancel each other out
                    i += 2
                    continue
                    
                # Pattern: JUMPDEST, JUMP (directly jump to next instruction)
                if curr.get("opcode") == "JUMPDEST" and next_instr.get("opcode") == "JUMP":
                    target_idx = next_instr.get("target_index", -1)
                    if target_idx > i and target_idx < len(instructions):
                        # This is a forward jump - check if there's anything important between
                        # this jump and its destination
                        has_side_effects = False
                        for j in range(i+2, target_idx):
                            if j < len(instructions):
                                # Check if any instruction between has side effects
                                intermediate_op = instructions[j].get("opcode", "")
                                if intermediate_op and not intermediate_op.startswith(("PUSH", "DUP", "SWAP")):
                                    has_side_effects = True
                                    break
                        
                        if not has_side_effects:
                            # Can skip directly to target
                            optimized.append(curr)  # Keep the JUMPDEST
                            i = target_idx  # Jump to target directly
                            continue
                
                # Check for three instruction patterns
                if i + 2 < len(instructions):
                    next_next_instr = instructions[i + 2]
                    
                    # Pattern: PUSH1 0, PUSH1 x, SUB = PUSH1 -x
                    if (curr.get("opcode") == "PUSH1" and curr.get("value") == "0x0" and
                        next_instr.get("opcode").startswith("PUSH") and
                        next_next_instr.get("opcode") == "SUB"):
                        
                        try:
                            # Convert to negative value (2's complement for appropriate size)
                            val = int(next_instr.get("value", "0x0"), 16)
                            neg_val = (1 << (8 * (int(next_instr.get("opcode")[4:] or "1")))) - val
                            
                            # Replace with single negative push
                            optimized.append({
                                "opcode": next_instr.get("opcode"),
                                "value": hex(neg_val),
                                "args": [hex(neg_val)],
                                "stack_effect": 1
                            })
                            i += 3
                            continue
                        except (ValueError, TypeError) as e:
                            logging.debug(f"Could not optimize SUB pattern: {e}")
                    
                    # Pattern: DUP1, ISZERO, ISZERO = just DUP1 (double negation)
                    if (curr.get("opcode") == "DUP1" and
                        next_instr.get("opcode") == "ISZERO" and
                        next_next_instr.get("opcode") == "ISZERO"):
                        
                        # Double negation cancels out, just keep the DUP1
                        optimized.append(curr)
                        i += 3
                        continue
                        
            optimized.append(instructions[i])
            i += 1
            
        return optimized