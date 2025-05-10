# evm_parser.py - Parser for EVM assembly into intermediate representation

import re
from .context_manager import create_transpilation_context, update_context_for_instruction
from .stack_emulator import calculate_stack_effect
from .pattern import detect_patterns
import logging
from logging import log_instruction_processing, log_error
import json


def parse_evm_assembly(input_file: str):
    """
    Main entry point to parse EVM assembly file into structured IR.
    
    Args:
        input_file (str): Path to .asm file containing EVM assembly
    Returns:
        list[dict]: Parsed instruction list in IR format
    """
    logging.log(f"Parsing EVM assembly from {input_file}")
    lines = _read_input_lines(input_file)
    instructions = []

    context = create_transpilation_context()
    labels = {}
    label_counter = 0

    for line_num, line in enumerate(lines):
        line = line.strip()
        if not line or line.startswith(";"):
            continue

        # Handle labels
        if line.endswith(":"):
            label_name = line[:-1].strip()
            labels[label_name] = len(instructions)
            instructions.append({
                "type": "label",
                "name": label_name,
                "index": len(instructions),
                "line": line_num
            })
            continue

        # Tokenize line into components
        instr = tokenize_instruction(line)
        if not instr:
            log_error(f"Failed to parse line: {line}", {"line": line}, context)
            continue

        # Add metadata
        instr["line"] = line_num
        instr["index"] = len(instructions)

        # Validate instruction
        if not validate_instruction(instr):
            log_error(f"Invalid instruction: {instr}", instr, context)
            continue

        # Track jump destinations
        if instr["opcode"] == "JUMPDEST":
            instr["jumpdest"] = True

        # Process using shared context
        update_context_for_instruction(instr, context)

        # Append to instruction stream
        instructions.append(instr)

    # Build CFG
    cfg = build_control_flow_graph(instructions)

    # Resolve jumps
    resolve_jumps(instructions, labels)

    # Detect function boundaries
    function_boundaries = detect_function_boundaries(instructions)

    # Analyze stack effects
    analyze_stack_effects(instructions)

    logging.log(f"Parsed {len(instructions)} instructions")
    return {
        "instructions": instructions,
        "cfg": cfg,
        "functions": function_boundaries,
        "labels": labels,
        "context": context
    }


def _read_input_lines(input_file: str):
    """Read input file line by line."""
    try:
        with open(input_file, 'r') as f:
            return f.readlines()
    except Exception as e:
        log_error(f"Failed to read input file: {e}", {})
        return []


def tokenize_instruction(line: str) -> dict:
    """
    Convert a single EVM assembly line into an instruction dictionary.
    
    Args:
        line (str): Line of EVM assembly
    Returns:
        dict: Parsed instruction with opcode and args
    """
    parts = re.split(r'\s+', line.strip(), maxsplit=1)
    if not parts:
        return None

    opcode = parts[0].upper()

    args = []
    if len(parts) > 1:
        args = [arg.strip() for arg in parts[1].split(",")]

    return {
        "opcode": opcode,
        "args": args,
        "value": args[0] if len(args) == 1 else None
    }


def validate_instruction(instruction: dict) -> bool:
    """
    Check if instruction conforms to expected format.
    
    Args:
        instruction (dict): Instruction dictionary
    Returns:
        bool: True if valid
    """
    opcode = instruction.get("opcode", "")
    args = instruction.get("args", [])

    if not opcode:
        return False

    # Basic validation rules
    if opcode.startswith("PUSH") and len(args) != 1:
        return False
    elif opcode.startswith("DUP") and len(args) != 0:
        return False
    elif opcode.startswith("SWAP") and len(args) != 0:
        return False
    elif opcode in ["JUMP", "JUMPI"] and len(args) != 0:
        return False

    return True


def build_control_flow_graph(instructions: list) -> dict:
    """
    Build control flow graph from instruction stream.
    
    Args:
        instructions (list): List of parsed instructions
    Returns:
        dict: Control flow graph
    """
    logging.log("Building control flow graph...")
    cfg = {}

    for i, instr in enumerate(instructions):
        opcode = instr.get("opcode", "")
        if opcode in ["JUMP", "JUMPI"]:
            cfg[i] = []
        elif opcode == "JUMPDEST":
            pass  # Start of new block
        else:
            cfg[i] = [i + 1] if i + 1 < len(instructions) else []

    # Connect JUMP destinations
    for i, instr in enumerate(instructions):
        opcode = instr.get("opcode", "")
        if opcode == "JUMP":
            target = instr.get("target_index")
            if target is not None:
                cfg[i].append(target)
        elif opcode == "JUMPI":
            target = instr.get("target_index")
            if target is not None:
                cfg[i].append(target)

    return cfg


def resolve_jumps(instructions: list, labels: dict):
    """
    Resolve symbolic jump destinations.
    
    Args:
        instructions (list): List of parsed instructions
        labels (dict): Map of label names to instruction indices
    """
    logging.log("Resolving jump destinations...")
    for instr in instructions:
        if instr.get("opcode") in ["JUMP", "JUMPI"]:
            target_label = instr.get("value", "").strip()
            if target_label in labels:
                instr["target_index"] = labels[target_label]
            else:
                instr["target_index"] = -1  # Unresolved


def detect_function_boundaries(instructions: list):
    """
    Identify likely function boundaries based on JUMPDEST usage.
    
    Args:
        instructions (list): List of parsed instructions
    Returns:
        list: List of function boundary tuples (start, end)
    """
    logging.log("Detecting function boundaries...")
    boundaries = []
    start_idx = None

    for i, instr in enumerate(instructions):
        if instr.get("opcode") == "JUMPDEST":
            if start_idx is not None:
                boundaries.append((start_idx, i))
            start_idx = i

    if start_idx is not None:
        boundaries.append((start_idx, len(instructions)))

    return boundaries


def analyze_stack_effects(instructions: list):
    """
    Analyze and annotate each instruction with its stack effect.
    
    Args:
        instructions (list): List of parsed instructions
    """
    logging.log("Analyzing stack effects...")
    for instr in instructions:
        opcode = instr.get("opcode", "")
        delta = calculate_stack_effect(opcode)
        instr["stack_effect"] = delta