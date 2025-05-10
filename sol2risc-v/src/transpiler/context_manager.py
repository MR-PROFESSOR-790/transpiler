# context_manager.py - Shared context management for EVM-to-RISC-V transpiler

from .stack_emulator import initialize_stack_model, simulate_instruction_stack_effect
from .memory_model import initialize_memory_model
from .gas_costs import calculate_gas_cost, get_available_registers
import logging


class CompilationContext:
    """
    Central context object shared between all transpiler components.
    """

    def __init__(self):
        self.stack = {}
        self.memory = {}
        self.storage = {}
        self.gas_meter = {
            "total": 0,
            "breakdown": {},
        }
        self.function_info = {
            "name": "evm_entry",
            "args": [],
            "returns": [],
            "scope": "global"
        }
        self.jumpdests = set()
        self.labels = {}
        self.source_map = {}
        self.optimizations = []

        # Initialize sub-models
        initialize_stack_model(self)
        initialize_memory_model(self)

        logging.log("Compilation context initialized")


def create_transpilation_context():
    """
    Create and return a new transpilation context.
    
    Returns:
        CompilationContext: Initialized context object
    """
    return CompilationContext()


def update_context_for_instruction(instruction, context: CompilationContext):
    """
    Update context based on instruction effects (stack, gas, memory).
    
    Args:
        instruction (dict): EVM instruction dictionary
        context (CompilationContext): Current context
    """
    opcode = instruction.get("opcode", "UNKNOWN")

    # Track jump destinations
    if opcode == "JUMPDEST":
        offset = instruction.get("offset", -1)
        if offset >= 0:
            context.jumpdests.add(offset)

    # Simulate stack effect
    success = simulate_instruction_stack_effect(instruction, context.stack)
    if not success:
        logging.log_error(f"Stack inconsistency in instruction: {opcode}", instruction, context)

    # Calculate and track gas cost
    gas_cost = calculate_gas_cost(opcode, context)
    context.gas_meter["total"] += gas_cost
    breakdown = context.gas_meter["breakdown"]
    breakdown[opcode] = breakdown.get(opcode, 0) + gas_cost

    # Optional: track memory expansion, storage access, etc.

    logging.log_instruction_processing(instruction, context)


def get_current_stack_state(context: CompilationContext):
    """
    Get current stack size and contents.
    
    Args:
        context (CompilationContext): Context object
    Returns:
        dict: Copy of current stack state
    """
    return context.stack.copy()


def get_current_memory_state(context: CompilationContext):
    """
    Get current memory model.
    
    Args:
        context (CompilationContext): Context object
    Returns:
        dict: Copy of current memory state
    """
    return context.memory.copy()


def get_current_storage_state(context: CompilationContext):
    """
    Get current storage access tracking.
    
    Args:
        context (CompilationContext): Context object
    Returns:
        dict: Copy of current storage state
    """
    return context.storage.copy()


def get_current_gas_state(context: CompilationContext):
    """
    Get current gas usage information.
    
    Args:
        context (CompilationContext): Context object
    Returns:
        dict: Copy of gas meter data
    """
    return context.gas_meter.copy()


def track_jump_destinations(context: CompilationContext):
    """
    Return set of known jump destinations.
    
    Args:
        context (CompilationContext): Context object
    Returns:
        set: Set of jump destination offsets
    """
    return context.jumpdests.copy()


def get_current_scope(context: CompilationContext):
    """
    Get current function or block scope.
    
    Args:
        context (CompilationContext): Context object
    Returns:
        str: Current scope name
    """
    return context.function_info.get("scope", "unknown")