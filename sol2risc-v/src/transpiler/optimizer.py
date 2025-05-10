# optimizer.py - Optimizer module for EVM-to-RISC-V transpiler

from .context_manager import Context
from .pattern import matches_known_pattern, apply_pattern_rewrite
from .arithmetic import optimize_arithmetic_sequence
import logging


def optimize_instructions(instructions: list, context: Context):
    """
    Main entry point for instruction optimization.
    
    Args:
        instructions (list): List of parsed EVM instructions
        context (Context): Shared compilation state
    Returns:
        list: Optimized instruction list
    """
    logging.log("Starting optimization pass...")

    # Apply multiple optimization passes
    optimized = instructions.copy()

    optimized = perform_constant_folding(optimized, context)
    optimized = eliminate_dead_code(optimized, context)
    optimized = coalesce_operations(optimized, context)
    optimized = reorder_instructions(optimized, context)
    optimized = optimize_register_usage(optimized, context)
    optimized = optimize_memory_access(optimized, context)
    optimized = apply_peephole_optimizations(optimized, context)

    logging.log(f"Optimization complete. Instructions reduced from {len(instructions)} → {len(optimized)}")
    return optimized


def perform_constant_folding(instructions: list, context: Context):
    """
    Replace constant expressions with their computed values.
    
    Args:
        instructions (list): EVM IR instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction list
    """
    logging.log("Performing constant folding...")
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


def eliminate_dead_code(instructions: list, context: Context):
    """
    Remove unreachable or unused instructions.
    
    Args:
        instructions (list): EVM IR instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction list
    """
    logging.log("Eliminating dead code...")
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


def coalesce_operations(instructions: list, context: Context):
    """
    Merge repeated operations into single instructions where possible.
    
    Args:
        instructions (list): EVM IR instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction list
    """
    logging.log("Coalescing operations...")
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


def reorder_instructions(instructions: list, context: Context):
    """
    Reorder instructions to improve register allocation and execution flow.
    
    Args:
        instructions (list): EVM IR instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction list
    """
    logging.log("Reordering instructions...")
    # This is a placeholder; real reordering would use liveness analysis
    return instructions.copy()


def optimize_register_usage(instructions: list, context: Context):
    """
    Optimize register usage by analyzing live ranges and reuse opportunities.
    
    Args:
        instructions (list): EVM IR instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction list
    """
    logging.log("Optimizing register usage...")
    return instructions.copy()


def optimize_memory_access(instructions: list, context: Context):
    """
    Optimize memory accesses by combining loads/stores or eliminating redundant ones.
    
    Args:
        instructions (list): EVM IR instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction list
    """
    logging.log("Optimizing memory access...")
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


def apply_peephole_optimizations(instructions: list, context: Context):
    """
    Perform peephole-style optimizations based on small instruction patterns.
    
    Args:
        instructions (list): EVM IR instructions
        context (Context): Compilation context
    Returns:
        list: Optimized instruction list
    """
    logging.log("Applying peephole optimizations...")
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