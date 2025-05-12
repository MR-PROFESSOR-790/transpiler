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

            # First filter out unknown instructions
            optimized = self.remove_unknown_instructions(optimized)
            logging.debug(f"After removing unknowns: {len(optimized)}")

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

    def remove_unknown_instructions(self, instructions):
        """
        Filter out unsupported or unknown opcodes.
        """
        if not instructions:
            return []
            
        filtered = []
        for instr in instructions:
            opcode = instr.get("opcode", "")
            # Skip instructions with type 'label' since they're not opcodes
            if instr.get("type") == "label":
                filtered.append(instr)
                continue
                
            if opcode.startswith("UNKNOWN"):
                logging.warning(f"Skipping unsupported instruction: {opcode}")
                continue
            filtered.append(instr)
        return filtered

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
                    
                if next_instr.get("opcode") in ["ADD", "MUL"]:
                    try:
                        # Check if value is valid
                        value = instr.get("value")
                        if value is None or not isinstance(value, str):
                            optimized.append(instr)
                            i += 1
                            continue
                            
                        # Try to parse the value safely
                        val1 = int(value, 16) if value.startswith("0x") else int(value, 16)
                        
                        # Check if next instruction has a value
                        value2 = next_instr.get("value")
                        if value2 is None or not isinstance(value2, str):
                            optimized.append(instr)
                            i += 1
                            continue
                            
                        val2 = int(value2, 16) if value2.startswith("0x") else int(value2, 16)
                        
                        result = {
                            "ADD": val1 + val2,
                            "MUL": val1 * val2
                        }.get(next_instr["opcode"])
                        
                        if result is not None:
                            optimized.append({
                                "opcode": "PUSH1", 
                                "value": hex(result),
                                "args": [hex(result)],
                                "stack_effect": instr.get("stack_effect", 0)
                            })
                            i += 2
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
                    optimized.append({
                        "opcode": "MUL", 
                        "args": ["0x2"],
                        "value": "0x2",
                        "stack_effect": curr.get("stack_effect", 0)
                    })
                    i += 2
                    continue
                    
                # PUSH1 0 + ADD -> NOP (optimization pattern)
                if (curr.get("opcode") == "PUSH1" and curr.get("value") == "0x0" and 
                    next_instr.get("opcode") == "ADD"):
                    # This is equivalent to a NOP - skip both instructions
                    # Just keep the ADD instruction which effectively does nothing
                    optimized.append(next_instr)
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
                
                # MSTORE followed by MLOAD at same offset - eliminate the MLOAD
                if curr.get("opcode") == "MSTORE" and next_instr.get("opcode") == "MLOAD":
                    offset1 = curr.get("offset", -1)
                    offset2 = next_instr.get("offset", -2)  # Use different default to force mismatch
                    
                    # If we can't determine offsets, be conservative
                    if offset1 == offset2 and offset1 >= 0:
                        # Keep the value on stack by modifying MSTORE to DUP before store
                        # This preserves both the store and provides the value to whoever
                        # was going to consume the MLOAD result
                        dup_instr = {"opcode": "DUP1", "args": [], "stack_effect": 1}
                        optimized.append(dup_instr)
                        optimized.append(curr)
                        i += 2
                        continue
            
            optimized.append(instructions[i])
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
                    # Replace with SWAP1 + POP which is more efficient since it removes both values with one POP
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
                    if "target_index" in next_instr and next_instr["target_index"] == i:
                        # This is a jump to itself - potential infinite loop
                        # Keep it as is to preserve semantics
                        optimized.append(curr)
                        i += 1
                        continue
                        
            optimized.append(instructions[i])
            i += 1
            
        return optimized