# optimizer.py - Optimizer module for EVM-to-RISC-V transpiler

import logging


class InstructionOptimizer:
    """
    Main class responsible for optimizing EVM instruction sequences.
    
    Integrates with pattern recognition, arithmetic optimization,
    register allocation, and memory access patterns.
    """

    def __init__(self):
        """
        Initialize optimizer with optional context.
        """
        self.context = None

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

        from .pattern import PatternRecognizer
        from .arithmetic import ArithmeticTranslator

        # Create pattern recognizer instance
        self.pattern_recognizer = PatternRecognizer()
        self.pattern_recognizer.set_context(self.context)
        
        # Bind methods
        self.matches_known_pattern = self.pattern_recognizer.matches_known_pattern
        self.apply_pattern_rewrite = self.pattern_recognizer.apply_pattern_rewrite
        self.optimize_arithmetic_sequence = ArithmeticTranslator.optimize_arithmetic_sequence

    # --- Public Methods ---

    def optimize_instructions(self, instructions: list):
        """
        Main entry point for instruction optimization.
        
        Args:
            instructions (list): List of parsed EVM instructions
        Returns:
            list: Optimized instruction list
        """
        logging.debug("Starting optimization pass...")

        # Apply multiple optimization passes
        optimized = instructions.copy()

        optimized = self.perform_constant_folding(optimized)
        optimized = self.eliminate_dead_code(optimized)
        optimized = self.coalesce_operations(optimized)
        optimized = self.reorder_instructions(optimized)
        optimized = self.optimize_register_usage(optimized)
        optimized = self.optimize_memory_access(optimized)
        optimized = self.apply_peephole_optimizations(optimized)

        logging.debug(f"Optimization complete. Instructions reduced from {len(instructions)} → {len(optimized)}")
        return optimized

    def perform_constant_folding(self, instructions: list):
        """
        Replace constant expressions with their computed values.
        
        Args:
            instructions (list): EVM IR instructions
        Returns:
            list: Optimized instruction list
        """
        logging.debug("Performing constant folding...")
        optimized = []
        i = 0
        while i < len(instructions):
            instr = instructions[i]

            if instr.get("opcode") in ["PUSH1", "PUSH2"] and i + 1 < len(instructions):
                next_instr = instructions[i + 1]
                if next_instr.get("opcode") in ["PUSH1", "PUSH2"]:
                    # Push two constants in sequence
                    val1 = int(instr["value"], 16)
                    val2 = int(next_instr["value"], 16)
                    result = val1 + val2
                    optimized.append({"opcode": "PUSH1", "value": hex(result)})
                    i += 2
                    continue

            optimized.append(instr)
            i += 1

        return optimized

    def eliminate_dead_code(self, instructions: list):
        """
        Remove unreachable or unused instructions.
        
        Args:
            instructions (list): EVM IR instructions
        Returns:
            list: Optimized instruction list
        """
        logging.debug("Eliminating dead code...")
        optimized = []

        for instr in instructions:
            opcode = instr.get("opcode", "")
            if opcode == "JUMPDEST":
                optimized.append(instr)
            elif opcode == "JUMP":
                optimized.append(instr)
                break  # Everything after JUMP is dead
            else:
                optimized.append(instr)

        return optimized

    def coalesce_operations(self, instructions: list):
        """
        Merge repeated operations into single instructions where possible.
        
        Args:
            instructions (list): EVM IR instructions
        Returns:
            list: Optimized instruction list
        """
        logging.debug("Coalescing operations...")
        optimized = []
        i = 0
        while i < len(instructions):
            if i + 1 < len(instructions):
                curr = instructions[i]
                next_instr = instructions[i + 1]
                if curr.get("opcode") == "ADD" and next_instr.get("opcode") == "ADD":
                    optimized.append({"opcode": "ADDMOD", "args": []})  # Example rewrite
                    i += 2
                    continue
            optimized.append(instructions[i])
            i += 1

        return optimized

    def reorder_instructions(self, instructions: list):
        """
        Reorder instructions to improve register allocation and execution flow.
        
        Args:
            instructions (list): EVM IR instructions
        Returns:
            list: Optimized instruction list
        """
        logging.debug("Reordering instructions...")
        # This is a placeholder; real reordering would use liveness analysis
        return instructions.copy()

    def optimize_register_usage(self, instructions: list):
        """
        Optimize register usage by analyzing live ranges and reuse opportunities.
        
        Args:
            instructions (list): EVM IR instructions
        Returns:
            list: Optimized instruction list
        """
        logging.log("Optimizing register usage...")
        return instructions.copy()

    def optimize_memory_access(self, instructions: list):
        """
        Optimize memory accesses by combining loads/stores or eliminating redundant ones.
        
        Args:
            instructions (list): EVM IR instructions
        Returns:
            list: Optimized instruction list
        """
        logging.debug("Optimizing memory access...")
        optimized = []
        i = 0
        while i < len(instructions):
            if i + 1 < len(instructions):
                curr = instructions[i]
                next_instr = instructions[i + 1]
                if curr.get("opcode") == "MSTORE" and next_instr.get("opcode") == "MLOAD":
                    offset1 = curr.get("offset", 0)
                    offset2 = next_instr.get("offset", 0)
                    if offset1 == offset2:
                        # Skip redundant load after store
                        optimized.append(curr)
                        i += 2
                        continue
            optimized.append(instructions[i])
            i += 1

        return optimized

    def apply_peephole_optimizations(self, instructions: list):
        """
        Perform peephole-style optimizations based on small instruction patterns.
        
        Args:
            instructions (list): EVM IR instructions
        Returns:
            list: Optimized instruction list
        """
        logging.debug("Applying peephole optimizations...")
        optimized = []
        i = 0
        while i < len(instructions):
            if i + 1 < len(instructions):
                curr = instructions[i]
                next_instr = instructions[i + 1]
                if curr.get("opcode") == "POP" and next_instr.get("opcode") == "POP":
                    optimized.append({"opcode": "DUP1"})
                    i += 2
                    continue
            optimized.append(instructions[i])
            i += 1

        return optimized