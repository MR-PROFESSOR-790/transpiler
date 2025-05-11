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
        self.stack = {
            "size": 0,
            "max_size": 0,
            "history": [],
            "spill_offsets": {}
        }
        self.memory = {
            "base": "MEM_BASE",
            "size": 0,
            "allocated": {},
            "last_used": 0
        }
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
        self.unknown_opcodes = set()
        self.invalid_opcodes = set()
        self.warnings = []
        self.errors = []
        self.debug_info = {}

        # First initialize dependencies
        self._init_dependencies()

        # Then initialize models using the bound methods
        try:
            if hasattr(self, 'initialize_stack_model'):
                self.initialize_stack_model()
            if hasattr(self, 'initialize_memory_model'):
                self.initialize_memory_model()
        except Exception as e:
            logging.error(f"Error during context initialization: {e}")
            raise

        logging.debug("Compilation context initialized")

    def _init_dependencies(self):
        """Lazy-load dependencies to prevent circular import issues."""
        try:
            from .stack_emulator import StackEmulator
            from .memory_model import MemoryModel
            from .gas_costs import GasCostCalculator

            # Create instances with proper initialization
            self.stack_emulator = StackEmulator(self)
            self.memory_model = MemoryModel()  # Initialize without context first
            self.memory_model.context = self   # Then set context
            self.gas_calculator = GasCostCalculator()
            self.gas_calculator.set_context(self)

            # Bind methods - moved before any initialization calls
            self.initialize_stack_model = self.stack_emulator.initialize_stack_model
            self.simulate_instruction_stack_effect = self.stack_emulator.simulate_instruction_stack_effect
            self.initialize_memory_model = self.memory_model.initialize_memory_model
            self.calculate_gas_cost = self.gas_calculator.calculate_gas_cost
            self.track_gas_usage = self.gas_calculator.track_gas_usage
            self.emit_runtime_call = self.gas_calculator.emit_runtime_call

            logging.debug("Dependencies initialized successfully")
        except ImportError as e:
            logging.error(f"Failed to import required modules: {e}")
            self._fallback_stack_init()
            self._fallback_memory_init()
            raise
        except Exception as e:
            logging.error(f"Error during dependency initialization: {e}")
            self._fallback_stack_init()
            self._fallback_memory_init()
            raise

    # Add fallback initialization methods
    def _fallback_stack_init(self):
        """Fallback stack initialization if StackEmulator fails to load"""
        self.stack = {
            "size": 0,
            "max_size": 0,
            "history": [],
            "spill_offsets": {}
        }
        logging.warning("Using fallback stack initialization")

    def _fallback_memory_init(self):
        """Fallback memory initialization if MemoryModel fails to load"""
        self.memory = {
            "base": "MEM_BASE",
            "size": 0,
            "allocated": {},
            "last_used": 0
        }
        logging.warning("Using fallback memory initialization")

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
            logging.error(f"Stack inconsistency in instruction: {opcode}")

        # Calculate and track gas cost
        gas_cost = self.calculate_gas_cost(opcode, self)
        self.gas_meter["total"] += gas_cost
        breakdown = self.gas_meter["breakdown"]
        breakdown[opcode] = breakdown.get(opcode, 0) + gas_cost

        # Optional: track memory expansion, storage access, etc.
        logging.debug(f"Processing instruction: {instruction}")

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

    def add_unknown_opcode(self, opcode, offset):
        """Add an unknown opcode to tracking."""
        self.unknown_opcodes.add((opcode, offset))
        self.warnings.append(f"Unknown opcode at offset {offset}: {opcode}")

    def add_invalid_opcode(self, opcode, offset):
        """Add an invalid opcode to tracking."""
        self.invalid_opcodes.add((opcode, offset))
        self.errors.append(f"Invalid opcode at offset {offset}: {opcode}")

    def add_warning(self, warning):
        """Add a warning message."""
        self.warnings.append(warning)

    def add_error(self, error):
        """Add an error message."""
        self.errors.append(error)

    def get_unknown_opcodes(self):
        """Get set of unknown opcodes encountered."""
        return self.unknown_opcodes

    def get_invalid_opcodes(self):
        """Get set of invalid opcodes encountered."""
        return self.invalid_opcodes

    def get_warnings(self):
        """Get list of warnings generated."""
        return self.warnings

    def get_errors(self):
        """Get list of errors generated."""
        return self.errors

    def generate_debug_info(self, instructions):
        """Generate debug information for the compilation."""
        self.debug_info = {
            "instructions": [str(instr) for instr in instructions],
            "unknown_opcodes": list(self.unknown_opcodes),
            "invalid_opcodes": list(self.invalid_opcodes),
            "warnings": self.warnings,
            "errors": self.errors,
            "stack_depth": self.stack_emulator.max_depth,
            "memory_usage": self.memory_model.get_usage(),
            "gas_usage": self.gas_meter["total"]
        }
        return self.debug_info

    def create_source_map(self, evm_instructions, riscv_instructions):
        """Create mapping between EVM and RISC-V instructions."""
        self.source_map = {
            "evm_to_riscv": {},
            "riscv_to_evm": {}
        }
        
        # Map EVM instructions to RISC-V instructions
        for i, evm_instr in enumerate(evm_instructions):
            if i < len(riscv_instructions):
                self.source_map["evm_to_riscv"][str(evm_instr)] = riscv_instructions[i]
                self.source_map["riscv_to_evm"][riscv_instructions[i]] = str(evm_instr)
        
        return self.source_map


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