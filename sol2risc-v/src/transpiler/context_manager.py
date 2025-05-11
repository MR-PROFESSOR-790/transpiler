# context_manager.py - Shared context management for EVM-to-RISC-V transpiler

import logging


class CompilationContext:
    """
    Central context object shared between all transpiler components.

    Encapsulates stack state, memory model, gas metering, function info,
    jump destinations, labels, source map, and optimization tracking.
    """

    def __init__(self):
        # Core context data structures
        self.stack = {}
        self.memory = {}
        self.storage = {}
        self.gas_meter = {
            "total": 0,
            "breakdown": {
                "static": 0,
                "dynamic": 0,
                "memory": 0,
                "storage": 0,
            },
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

        # Lazy-load internal dependencies
        self._init_dependencies()

        # Initialize sub-models
        self.initialize_stack_model()  # Remove self parameter
        self.initialize_memory_model()  # Remove self parameter

        logging.debug("Compilation context initialized")

    def _init_dependencies(self):
        """Lazy-load dependencies to prevent circular import issues."""
        from .stack_emulator import StackEmulator
        from .memory_model import MemoryModel
        from .gas_costs import GasCostCalculator

        # Create and initialize dependencies
        self.stack_emulator = StackEmulator(self)
        self.memory_model = MemoryModel(self)
        self.gas_calculator = GasCostCalculator()
        self.gas_calculator.set_context(self)

        # Bind all required methods
        self.initialize_stack_model = self.stack_emulator.initialize_stack_model
        self.simulate_instruction_stack_effect = self.stack_emulator.simulate_instruction_stack_effect
        self.initialize_memory_model = self.memory_model.initialize_memory_model
        self.calculate_gas_cost = self.gas_calculator.calculate_gas_cost
        self.track_gas_usage = self.gas_calculator.track_gas_usage
        self.emit_runtime_call = self.gas_calculator.emit_runtime_call

        logging.debug("Dependencies initialized")

    def update_context_for_instruction(self, instruction):
        """
        Update context based on instruction effects (stack, gas, memory).

        Args:
            instruction (dict): EVM instruction dictionary
        """
        opcode = instruction.get("opcode", "UNKNOWN")

        # Track jump destinations
        if opcode == "JUMPDEST":
            offset = instruction.get("offset", -1)
            if offset >= 0:
                self.jumpdests.add(offset)

        # Simulate stack effect
        success = self.simulate_instruction_stack_effect(instruction, self.stack)
        if not success:
            logging.error(f"Stack inconsistency in instruction: {opcode}")  # Fix logging call

        # Calculate and track gas cost
        gas_cost = self.calculate_gas_cost(opcode, self)
        self.gas_meter["total"] += gas_cost
        breakdown = self.gas_meter["breakdown"]
        breakdown[opcode] = breakdown.get(opcode, 0) + gas_cost

        # Optional: track memory expansion, storage access, etc.
        logging.debug(f"Processing instruction: {instruction}")  # Fix logging call

    def get_current_stack_state(self):
        """
        Get current stack size and contents.

        Returns:
            dict: Copy of current stack state
        """
        return self.stack.copy()

    def get_current_memory_state(self):
        """
        Get current memory model.

        Returns:
            dict: Copy of current memory state
        """
        return self.memory.copy()

    def get_current_storage_state(self):
        """
        Get current storage access tracking.

        Returns:
            dict: Copy of current storage state
        """
        return self.storage.copy()

    def get_current_gas_state(self):
        """
        Get current gas usage information.

        Returns:
            dict: Copy of gas meter data
        """
        return self.gas_meter.copy()

    def track_jump_destinations(self):
        """
        Return set of known jump destinations.

        Returns:
            set: Set of jump destination offsets
        """
        return self.jumpdests.copy()

    def get_current_scope(self):
        """
        Get current function or block scope.

        Returns:
            str: Current scope name
        """
        return self.function_info.get("scope", "unknown")


class ContextManager:
    """
    Factory and utility class for working with CompilationContext.

    Allows creation and management of context objects while preserving legacy interfaces.
    """

    @staticmethod
    def create_transpilation_context():
        """
        Create and return a new transpilation context.

        Returns:
            CompilationContext: Initialized context object
        """
        return CompilationContext()

    @staticmethod
    def update_context_for_instruction(instruction, context):
        """
        Static wrapper for updating context using CompilationContext instance method.
        """
        context.update_context_for_instruction(instruction)

    @staticmethod
    def get_current_stack_state(context):
        """
        Static wrapper to get current stack state.
        """
        return context.get_current_stack_state()

    @staticmethod
    def get_current_memory_state(context):
        """
        Static wrapper to get current memory state.
        """
        return context.get_current_memory_state()

    @staticmethod
    def get_current_storage_state(context):
        """
        Static wrapper to get current storage state.
        """
        return context.get_current_storage_state()

    @staticmethod
    def get_current_gas_state(context):
        """
        Static wrapper to get current gas usage.
        """
        return context.get_current_gas_state()

    @staticmethod
    def track_jump_destinations(context):
        """
        Static wrapper to get jump destinations.
        """
        return context.track_jump_destinations()

    @staticmethod
    def get_current_scope(context):
        """
        Static wrapper to get current scope.
        """
        return context.get_current_scope()