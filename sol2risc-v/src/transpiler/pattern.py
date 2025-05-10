# pattern.py - Pattern recognition and optimization layer for EVM-to-RISC-V

from .stack_emulator import calculate_stack_effect
import logging


def detect_patterns(instructions):
    """
    Main function to detect all known patterns in instruction stream.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        dict: Map of detected pattern types to list of matched ranges
    """
    logging.info("Starting pattern detection...")

    patterns = {
        "constant_folding": detect_constant_folding_opportunities(instructions),
        "storage_access": detect_common_storage_patterns(instructions),
        "repeated_ops": detect_repeated_operations(instructions),
        "dead_code": detect_dead_code(instructions),
        "unreachable_code": detect_unreachable_code(instructions),
        "function_signature": detect_known_function_signatures(instructions),
        "memory_pattern": detect_memory_access_patterns(instructions),
        "loop_pattern": detect_loop_patterns(instructions),
    }

    # Log results
    for pattern_type, matches in patterns.items():
        if matches:
            logging.log(f"Found {len(matches)} '{pattern_type}' patterns")
    return patterns


def optimize_pattern(pattern_type, match_info, context):
    """
    Apply transformation based on detected pattern.
    
    Args:
        pattern_type (str): Type of pattern to optimize
        match_info (dict): Matched pattern data
        context (Context): Shared compilation state
    Returns:
        list[dict]: Optimized instruction sequence or original if no change
    """
    logging.log(f"Optimizing pattern: {pattern_type}")
    if pattern_type == "constant_folding":
        return apply_constant_folding(match_info["range"], context)
    elif pattern_type == "dead_code":
        return remove_instructions(match_info["range"])
    elif pattern_type == "repeated_ops":
        return coalesce_operations(match_info["range"], context)
    elif pattern_type == "memory_pattern":
        return optimize_memory_access(match_info["range"], context)
    else:
        return match_info["original"]


# ---------------------------
# Specific Pattern Detectors
# ---------------------------


def detect_constant_folding_opportunities(instructions):
    """
    Find sequences of pushes followed by arithmetic ops that can be folded.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing instruction range and values
    """
    matches = []
    i = 0
    while i < len(instructions) - 1:
        instr1 = instructions[i]
        instr2 = instructions[i + 1]
        if instr1.get("opcode").startswith("PUSH") and instr2.get("opcode").startswith("PUSH"):
            if i + 2 < len(instructions):
                op_instr = instructions[i + 2]
                if op_instr.get("opcode") in ["ADD", "MUL"]:
                    values = [int(instr1["value"], 16), int(instr2["value"], 16)]
                    matches.append({
                        "range": (i, i + 3),
                        "values": values,
                        "op": op_instr["opcode"],
                        "original": instructions[i:i+3]
                    })
                    i += 3
                    continue
        i += 1
    return matches


def detect_common_storage_patterns(instructions):
    """
    Detect repeated storage access patterns (SLOAD/SSTORE).
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing instruction range and metadata
    """
    matches = []
    i = 0
    while i < len(instructions) - 1:
        instr1 = instructions[i]
        instr2 = instructions[i + 1]
        if instr1.get("opcode") == "SLOAD" and instr2.get("opcode") == "SLOAD":
            matches.append({
                "range": (i, i + 2),
                "type": "duplicate_sload",
                "original": instructions[i:i+2]
            })
        i += 1
    return matches


def detect_repeated_operations(instructions):
    """
    Detect repeated arithmetic operations that can be coalesced.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing instruction range and metadata
    """
    matches = []
    i = 0
    while i < len(instructions) - 1:
        instr1 = instructions[i]
        instr2 = instructions[i + 1]
        if instr1.get("opcode") == "ADD" and instr2.get("opcode") == "ADD":
            matches.append({
                "range": (i, i + 2),
                "type": "repeated_add",
                "original": instructions[i:i+2]
            })
        i += 1
    return matches


def detect_dead_code(instructions):
    """
    Detect unreachable code after STOP or RETURN.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing instruction range and metadata
    """
    matches = []
    i = 0
    while i < len(instructions):
        opcode = instructions[i].get("opcode")
        if opcode in ["STOP", "RETURN", "REVERT", "JUMP", "INVALID"]:
            # Everything after is dead until next JUMPDEST
            j = i + 1
            while j < len(instructions):
                next_opcode = instructions[j].get("opcode")
                if next_opcode == "JUMPDEST":
                    break
                j += 1
            if j > i + 1:
                matches.append({
                    "range": (i + 1, j),
                    "type": "dead_code",
                    "original": instructions[i+1:j]
                })
            i = j
        else:
            i += 1
    return matches


def detect_unreachable_code(instructions):
    """
    Detect code between non-conditional jumps and the next destination.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing instruction range and metadata
    """
    matches = []
    i = 0
    while i < len(instructions):
        opcode = instructions[i].get("opcode")
        if opcode == "JUMP":
            j = i + 1
            while j < len(instructions):
                if instructions[j].get("opcode") == "JUMPDEST":
                    break
                j += 1
            if j > i + 1:
                matches.append({
                    "range": (i + 1, j),
                    "type": "unreachable_code",
                    "original": instructions[i+1:j]
                })
            i = j
        else:
            i += 1
    return matches


def detect_known_function_signatures(instructions):
    """
    Detect well-known Solidity function signatures.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing function signature info
    """
    matches = []
    for i, instr in enumerate(instructions):
        if instr.get("opcode") == "PUSH4" and i + 1 < len(instructions):
            next_instr = instructions[i + 1]
            if next_instr.get("opcode") == "EQ":
                func_sig = instr.get("value", "")
                matches.append({
                    "range": (i, i + 2),
                    "signature": func_sig,
                    "type": "function_selector"
                })
    return matches


def detect_memory_access_patterns(instructions):
    """
    Detect memory copy or allocation patterns.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing memory access info
    """
    matches = []
    i = 0
    while i < len(instructions) - 2:
        instr1 = instructions[i]
        instr2 = instructions[i + 1]
        instr3 = instructions[i + 2]
        if instr1.get("opcode") == "PUSH1" and instr2.get("opcode") == "PUSH1" and instr3.get("opcode") == "CALLDATACOPY":
            matches.append({
                "range": (i, i + 3),
                "type": "calldatacopy_pattern"
            })
        i += 1
    return matches


def detect_loop_patterns(instructions):
    """
    Detect simple loop patterns using JUMPI.
    
    Args:
        instructions (list[dict]): List of parsed EVM instructions
    Returns:
        list[dict]: Matches containing loop start/end indices
    """
    matches = []
    jumpdest_indices = {}
    for i, instr in enumerate(instructions):
        if instr.get("opcode") == "JUMPDEST":
            jumpdest_indices[instr.get("label", f"L{i}")] = i

    for i, instr in enumerate(instructions):
        if instr.get("opcode") == "JUMPI":
            # Look ahead for potential back edges
            for j in range(i + 1, min(i + 10, len(instructions))):
                target_label = instructions[j].get("label")
                if target_label in jumpdest_indices:
                    target_idx = jumpdest_indices[target_label]
                    if target_idx < i:
                        matches.append({
                            "range": (target_idx, i + 1),
                            "type": "loop_pattern"
                        })
    return matches


# ---------------------------
# Helper Functions
# ---------------------------

def apply_constant_folding(range_tuple, context):
    """Replace two PUSHes and an ADD/MUL with a single PUSH."""
    start, end = range_tuple
    instrs = context.ir[start:end]
    val1 = int(instrs[0]["value"], 16)
    val2 = int(instrs[1]["value"], 16)
    op = instrs[2]["opcode"]
    result = val1 + val2 if op == "ADD" else val1 * val2
    return [{"opcode": "PUSH1", "value": hex(result)}]


def remove_instructions(range_tuple):
    """Remove a block of instructions."""
    start, end = range_tuple
    return []


def coalesce_operations(range_tuple, context):
    """Replace two similar operations with a combined one."""
    start, end = range_tuple
    return [{"opcode": "ADDMOD"}]


def optimize_memory_access(range_tuple, context):
    """Replace memory copy pattern with optimized version."""
    return [{"opcode": "MCOPY"}]