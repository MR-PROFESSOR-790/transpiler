import re
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class OpcodeMapping:
    def __init__(self):
        self.opcode_map = {
            # Arithmetic
            "STOP": {"instr": "nop", "args": 0},
            "ADD": {"instr": "add", "args": 2},
            "MUL": {"instr": "mul", "args": 2},
            "SUB": {"instr": "sub", "args": 2},
            "DIV": {"instr": "div", "args": 2},
            "SDIV": {"instr": "div", "args": 2},
            "MOD": {"instr": "rem", "args": 2},
            "SMOD": {"instr": "rem", "args": 2},
            "ADDMOD": {"instr": "custom_addmod", "args": 3},
            "MULMOD": {"instr": "custom_mulmod", "args": 3},
            "EXP": {"instr": "custom_exp", "args": 2},
            "SIGNEXTEND": {"instr": "custom_signextend", "args": 2},

            # Bitwise/Comparison
            "LT": {"instr": "slt", "args": 2},
            "GT": {"instr": "sgt", "args": 2},
            "SLT": {"instr": "slt", "args": 2},
            "SGT": {"instr": "sgt", "args": 2},
            "EQ": {"instr": "custom_eq", "args": 2},
            "ISZERO": {"instr": "custom_iszero", "args": 1},
            "AND": {"instr": "and", "args": 2},
            "OR": {"instr": "or", "args": 2},
            "XOR": {"instr": "xor", "args": 2},
            "NOT": {"instr": "custom_not", "args": 1},
            "BYTE": {"instr": "custom_byte", "args": 2},
            "SHL": {"instr": "sll", "args": 2},
            "SHR": {"instr": "srl", "args": 2},
            "SAR": {"instr": "sra", "args": 2},

            # Memory and Storage
            "POP": {"instr": "custom_pop", "args": 1},
            "MLOAD": {"instr": "custom_mload", "args": 1},
            "MSTORE": {"instr": "custom_mstore", "args": 2},
            "MSTORE8": {"instr": "custom_mstore8", "args": 2},
            "SLOAD": {"instr": "custom_sload", "args": 1},
            "SSTORE": {"instr": "custom_sstore", "args": 2},

            # Control Flow
            "JUMP": {"instr": "custom_jump", "args": 1},
            "JUMPI": {"instr": "custom_jumpi", "args": 2},
            "PC": {"instr": "custom_pc", "args": 0},
            "JUMPDEST": {"instr": "label", "args": 0},

            # Duplication and Swap
            **{f"DUP{i}": {"instr": f"custom_dup{i}", "args": 0} for i in range(1, 17)},
            **{f"SWAP{i}": {"instr": f"custom_swap{i}", "args": 0} for i in range(1, 17)},

            # Push operations
            **{f"PUSH{i}": {"instr": "custom_push", "args": 0} for i in range(1, 33)},

            # Logging
            "LOG0": {"instr": "custom_log", "args": 2},
            "LOG1": {"instr": "custom_log", "args": 3},
            "LOG2": {"instr": "custom_log", "args": 4},
            "LOG3": {"instr": "custom_log", "args": 5},
            "LOG4": {"instr": "custom_log", "args": 6},

            # Termination
            "RETURN": {"instr": "custom_return", "args": 2},
            "REVERT": {"instr": "custom_revert", "args": 2},
            "INVALID": {"instr": "invalid", "args": 0},
            "SELFDESTRUCT": {"instr": "custom_selfdestruct", "args": 1},
        }

    def get_riscv_mapping(self, evm_opcode, actual_args_count=None):
        op = evm_opcode.upper()

        if self.is_push_opcode(op) or self.is_dup_opcode(op) or self.is_swap_opcode(op):
            logger.debug(f"Opcode {op} matched as push/dup/swap")
        elif op not in self.opcode_map:
            logger.error(f"Unknown opcode '{op}' requested.")
            raise NotImplementedError(f"EVM opcode '{op}' is not supported in mapping.")

        mapping = self.opcode_map[op]

        if actual_args_count is not None and mapping["args"] != actual_args_count:
            logger.warning(f"Opcode '{op}' expected {mapping['args']} args but got {actual_args_count}.")

        logger.info(f"Opcode '{op}' mapped to RISC-V '{mapping['instr']}' with {mapping['args']} args.")
        return mapping

    def is_push_opcode(self, opcode):
        return bool(re.match(r"^PUSH([1-9]|1[0-9]|2[0-9]|3[0-2])$", opcode.upper()))

    def is_dup_opcode(self, opcode):
        return bool(re.match(r"^DUP([1-9]|1[0-6])$", opcode.upper()))

    def is_swap_opcode(self, opcode):
        return bool(re.match(r"^SWAP([1-9]|1[0-6])$", opcode.upper()))

    def list_all_opcodes(self):
        return sorted(self.opcode_map.keys())

    def add_mapping(self, evm_opcode, riscv_instr, args):
        op = evm_opcode.upper()
        if op in self.opcode_map:
            logger.error(f"Opcode '{op}' already exists.")
            raise ValueError(f"Opcode '{op}' already exists in mapping.")
        self.opcode_map[op] = {"instr": riscv_instr, "args": args}
        logger.info(f"Added new mapping: {op} -> {riscv_instr} (args: {args})")

    def remove_mapping(self, evm_opcode):
        op = evm_opcode.upper()
        if op not in self.opcode_map:
            logger.error(f"Opcode '{op}' does not exist.")
            raise ValueError(f"Opcode '{op}' does not exist in mapping.")
        self.opcode_map.pop(op)
        logger.info(f"Removed opcode mapping: {op}")
