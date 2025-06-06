# gas_costs.py - Gas cost calculation and tracking for EVM-to-RISC-V transpiler

import logging

# Static gas costs from Ethereum Yellow Paper
STATIC_GAS_COSTS = {
    "STOP": 0,
    "ADD": 3,
    "MUL": 5,
    "SUB": 3,
    "DIV": 5,
    "SDIV": 5,
    "MOD": 5,
    "SMOD": 5,
    "ADDMOD": 8,
    "MULMOD": 8,
    "EXP": 10,
    "SIGNEXTEND": 3,
    "LT": 3,
    "GT": 3,
    "SLT": 3,
    "SGT": 3,
    "EQ": 3,
    "ISZERO": 3,
    "AND": 3,
    "OR": 3,
    "XOR": 3,
    "NOT": 3,
    "BYTE": 3,
    "CALLDATALOAD": 3,
    "CALLDATACOPY": 3,
    "CODECOPY": 3,
    "POP": 2,
    "MLOAD": 3,
    "MSTORE": 3,
    "MSTORE8": 3,
    "JUMP": 8,
    "JUMPI": 10,
    "PC": 2,
    "MSIZE": 2,
    "GAS": 2,
    "PUSH1": 3,
    "PUSH2": 3,
    "PUSH3": 3,
    "PUSH4": 3,
    "PUSH5": 3,
    "PUSH6": 3,
    "PUSH7": 3,
    "PUSH8": 3,
    "PUSH9": 3,
    "PUSH10": 3,
    "PUSH11": 3,
    "PUSH12": 3,
    "PUSH13": 3,
    "PUSH14": 3,
    "PUSH15": 3,
    "PUSH16": 3,
    "PUSH17": 3,
    "PUSH18": 3,
    "PUSH19": 3,
    "PUSH20": 3,
    "PUSH21": 3,
    "PUSH22": 3,
    "PUSH23": 3,
    "PUSH24": 3,
    "PUSH25": 3,
    "PUSH26": 3,
    "PUSH27": 3,
    "PUSH28": 3,
    "PUSH29": 3,
    "PUSH30": 3,
    "PUSH31": 3,
    "PUSH32": 3,
    "DUP1": 3,
    "DUP2": 3,
    "DUP3": 3,
    "DUP4": 3,
    "DUP5": 3,
    "DUP6": 3,
    "DUP7": 3,
    "DUP8": 3,
    "DUP9": 3,
    "DUP10": 3,
    "DUP11": 3,
    "DUP12": 3,
    "DUP13": 3,
    "DUP14": 3,
    "DUP15": 3,
    "DUP16": 3,
    "SWAP1": 3,
    "SWAP2": 3,
    "SWAP3": 3,
    "SWAP4": 3,
    "SWAP5": 3,
    "SWAP6": 3,
    "SWAP7": 3,
    "SWAP8": 3,
    "SWAP9": 3,
    "SWAP10": 3,
    "SWAP11": 3,
    "SWAP12": 3,
    "SWAP13": 3,
    "SWAP14": 3,
    "SWAP15": 3,
    "SWAP16": 3,
    "LOG0": 375,
    "LOG1": 750,
    "LOG2": 1125,
    "LOG3": 1500,
    "LOG4": 1875,
    "CREATE": 32000,
    "CALL": 700,
    "CALLCODE": 700,
    "DELEGATECALL": 700,
    "STATICCALL": 700,
    "RETURN": 0,
    "REVERT": 0,
    "SELFDESTRUCT": 5000,
    "INVALID": 0,
}

class GasCostCalculator:
    """Handles gas cost calculation and deduction."""
    
    def __init__(self):
        self.context = None
        self.gas_costs = STATIC_GAS_COSTS.copy()
        self.unknown_opcode_cost = 3  # Default cost for unknown opcodes

    def set_context(self, context):
        """Set compilation context."""
        self.context = context
        self._init_dependencies()  # Initialize dependencies when context is set

    def calculate_gas_cost(self, opcode: str, context=None) -> int:
        """
        Calculate gas cost for an opcode.
        Args:
            opcode (str): EVM opcode
            context (Context, optional): Compilation context
        Returns:
            int: Gas cost
        """
        # Handle unknown opcodes
        if opcode.startswith("UNKNOWN_"):
            if context:
                context.add_warning(f"Using default gas cost for unknown opcode: {opcode}")
            return self.unknown_opcode_cost

        # Get base cost
        cost = self.gas_costs.get(opcode, self.unknown_opcode_cost)

        # Add dynamic costs
        if opcode.startswith("PUSH"):
            size = int(opcode[4:]) if len(opcode) > 4 else 1
            cost += size * 3
        elif opcode.startswith("DUP"):
            depth = int(opcode[3:]) if len(opcode) > 3 else 1
            cost += depth
        elif opcode.startswith("SWAP"):
            depth = int(opcode[4:]) if len(opcode) > 4 else 1
            cost += depth
        elif opcode.startswith("LOG"):
            topics = int(opcode[3:]) if len(opcode) > 3 else 0
            cost += topics * 375

        return cost

    def deduct_gas(self, amount: int) -> bool:
        """Deduct gas from remaining balance."""
        if self.context and hasattr(self.context, "gas_meter"):
            self.context.gas_meter["total"] -= amount
            return True
        return False

    def _init_dependencies(self):
        """Lazy-load dependencies to prevent circular import issues."""
        if self.context:  # Only initialize if context exists
            from .riscv_emitter import RiscvEmitter
            from .stack_emulator import StackEmulator
            from .memory_model import MemoryModel

            self.emit_runtime_call = RiscvEmitter.emit_runtime_calls
            self.stack_model = StackEmulator(context=self.context)
            self.memory_model = MemoryModel(self.context)

    # --- Public Methods ---

    def gas_cost_lookup(self, opcode: str) -> int:
        """
        Return static gas cost for an opcode.
        Args:
            opcode (str): EVM instruction name
        Returns:
            int: Gas cost or 0 if unknown
        """
        return STATIC_GAS_COSTS.get(opcode, 0)

    def calculate_memory_expansion_cost(self, old_size: int, new_size: int, context=None):
        """
        Memory expansion cost formula from EIP-150.
        Args:
            old_size (int): Current memory size (in bytes)
            new_size (int): New required memory size (in bytes)
            context (Context, optional): Compilation context
        Returns:
            int: Gas cost for expanding memory to this size
        """
        ctx = context or self.context
        if new_size <= old_size:
            return 0

        old_words = (old_size + 31) // 32
        new_words = (new_size + 31) // 32

        old_word_cost = old_words * 3
        new_word_cost = new_words * 3

        old_quad_cost = (old_words * old_words) // 512
        new_quad_cost = (new_words * new_words) // 512

        old_total = old_word_cost + old_quad_cost
        new_total = new_word_cost + new_quad_cost

        total_cost = new_total - old_total
        return max(total_cost, 0)

    def calculate_storage_cost(self, operation: str):
        """
        Calculate storage read/write cost based on operation type.
        Args:
            operation (str): 'read', 'write', 'reset', etc.
        Returns:
            int: Gas cost
        """
        costs = {
            "read": 100,
            "write": 20000,
            "reset": 5000,
            "delete": 15000
        }
        cost = costs.get(operation.lower(), 0)
        self.track_gas_usage({"opcode": f"storage_{operation}", "cost": cost})
        return cost

    def calculate_call_cost(self):
        """
        Estimate gas cost for CALL-like operations.
        Returns:
            int: Gas cost
        """
        base_cost = 700
        value_transfer = self.context.stack_model.peek(2)  # Assume value is at index 2
        if value_transfer != 0:
            base_cost += 9000  # Extra for value transfer
        self.track_gas_usage({"opcode": "CALL", "cost": base_cost})
        return base_cost

    def calculate_create_cost(self):
        """
        Estimate gas cost for CREATE operations.
        Returns:
            int: Gas cost
        """
        base_cost = 32000
        self.track_gas_usage({"opcode": "CREATE", "cost": base_cost})
        return base_cost

    def track_gas_usage(self, instruction: dict):
        """
        Update context with cumulative gas usage.
        Args:
            instruction (dict): Instruction metadata
        """
        opcode = instruction.get("opcode", "unknown")
        cost = instruction.get("cost", 0)
        self.context.gas_meter["total"] = self.context.gas_meter.get("total", 0) + cost
        breakdown = self.context.gas_meter.setdefault("breakdown", {})
        breakdown[opcode] = breakdown.get(opcode, 0) + cost
        logging.debug(f"Gas used by {opcode}: {cost} | Total so far: {self.context.gas_meter['total']}")

    def emit_gas_tracking_code(self):
        """
        Generate RISC-V assembly instructions to dynamically track gas usage.
        Returns:
            list[str]: Assembly lines for gas tracking
        """
        lines = []
        total_gas = self.context.gas_meter.get("total", 0)
        if total_gas > 0:
            lines.append(f"li a0, {total_gas}")
            lines.append("jal ra, deduct_gas")
        return lines

    def emit_runtime_call(self, opcode: str) -> str:
        """
        Emit RISC-V assembly for gas cost tracking.
        Args:
            opcode (str): EVM opcode
        Returns:
            str: RISC-V assembly
        """
        cost = self.calculate_gas_cost(opcode)
        return f"li a0, {cost}\njal ra, deduct_gas"