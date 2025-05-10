"""
gas_cost.py - Handles gas cost calculations for EVM operations
This module provides gas cost information for EVM operations to be used in the
transpiler when generating equivalent RISC-V code.
"""

class GasCostCalculator:
    # Gas costs for EVM operations
    GAS_COSTS = {
        # 0s: Stop and Arithmetic Operations
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
        "EXP": 10,  # Base cost, actual cost depends on exponent
        "SIGNEXTEND": 5,
        
        # 10s: Comparison & Bitwise Logic Operations
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
        "SHL": 3,
        "SHR": 3,
        "SAR": 3,
        
        # 20s: SHA3
        "SHA3": 30,  # Base cost, additional cost per word
        
        # 30s: Environmental Information
        "ADDRESS": 2,
        "BALANCE": 700,
        "ORIGIN": 2,
        "CALLER": 2,
        "CALLVALUE": 2,
        "CALLDATALOAD": 3,
        "CALLDATASIZE": 2,
        "CALLDATACOPY": 3,  # Base cost, additional cost per word
        "CODESIZE": 2,
        "CODECOPY": 3,  # Base cost, additional cost per word
        "GASPRICE": 2,
        "EXTCODESIZE": 700,
        "EXTCODECOPY": 700,  # Base cost, additional cost per word
        "RETURNDATASIZE": 2,
        "RETURNDATACOPY": 3,  # Base cost, additional cost per word
        "EXTCODEHASH": 700,
        "BLOCKHASH": 20,
        
        # 40s: Block Information
        "COINBASE": 2,
        "TIMESTAMP": 2,
        "NUMBER": 2,
        "DIFFICULTY": 2,
        "GASLIMIT": 2,
        "CHAINID": 2,
        "SELFBALANCE": 5,
        "BASEFEE": 2,
        
        # 50s: Stack, Memory, Storage and Flow Operations
        "POP": 2,
        "MLOAD": 3,
        "MSTORE": 3,
        "MSTORE8": 3,
        "SLOAD": 800,
        "SSTORE": 5000,  # This is a simplification, actual cost depends on value change
        "JUMP": 8,
        "JUMPI": 10,
        "PC": 2,
        "MSIZE": 2,
        "GAS": 2,
        "JUMPDEST": 1,
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
        
        # 60s & 70s: Push Operations (already covered above)
        
        # 80s: Duplication Operations (already covered above)
        
        # 90s: Exchange Operations (already covered above)
        
        # a0s: Logging Operations
        "LOG0": 375,  # Base cost, additional cost per topic and data byte
        "LOG1": 750,  # Base cost, additional cost per topic and data byte
        "LOG2": 1125,  # Base cost, additional cost per topic and data byte
        "LOG3": 1500,  # Base cost, additional cost per topic and data byte
        "LOG4": 1875,  # Base cost, additional cost per topic and data byte
        
        # f0s: System Operations
        "CREATE": 32000,
        "CALL": 700,  # Base cost, additional costs apply
        "CALLCODE": 700,  # Base cost, additional costs apply
        "RETURN": 0,
        "DELEGATECALL": 700,  # Base cost, additional costs apply
        "CREATE2": 32000,  # Base cost, additional costs apply
        "STATICCALL": 700,  # Base cost, additional costs apply
        "REVERT": 0,
        "INVALID": 0,
        "SELFDESTRUCT": 5000,  # Simplified, actual cost depends on conditions
    }

    def __init__(self):
        """Initialize the gas cost calculator"""
        self.current_memory_words = 0

    def calculate_exp_gas(self, exponent_byte_size):
        """Calculate gas cost for EXP operation based on exponent byte size"""
        return 10 + 50 * exponent_byte_size

    def calculate_sha3_gas(self, data_size):
        """Calculate gas cost for SHA3 operation based on data size in words (32 bytes)"""
        words = (data_size + 31) // 32  # Round up to nearest word
        return 30 + 6 * words

    def calculate_memory_expansion_gas(self, current_words, new_words):
        """Calculate gas cost for memory expansion"""
        if new_words <= current_words:
            return 0
        return (new_words**2 // 512) - (current_words**2 // 512)

    def calculate_sstore_gas(self, current_value, new_value, original_value):
        """Calculate gas cost for SSTORE operation based on value changes"""
        if new_value == current_value:
            return 800  # SLOAD cost
        if current_value == 0:
            return 20000  # Set from zero
        if new_value == 0:
            return 5000  # Clearing storage (refund applies separately)
        return 5000  # Resetting to a non-zero value

    def get_gas_cost(self, opcode, *args):
        """Get the gas cost for an opcode with optional arguments for variable costs"""
        if opcode in self.GAS_COSTS:
            base_cost = self.GAS_COSTS[opcode]
            
            # Handle special cases
            if opcode == "EXP" and len(args) > 0:
                return self.calculate_exp_gas(args[0])
            elif opcode == "SHA3" and len(args) > 0:
                return self.calculate_sha3_gas(args[0])
            elif opcode == "SSTORE" and len(args) >= 3:
                return self.calculate_sstore_gas(args[0], args[1], args[2])
            
            return base_cost
        
        # Default for unknown opcodes
        return 0

# Example usage:
# calculator = GasCostCalculator()
# cost = calculator.get_gas_cost("ADD")