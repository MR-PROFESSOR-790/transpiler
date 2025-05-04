
EVM_OPCODES = {
    0x00: 'STOP',
    0x01: 'ADD',
    0x02: 'MUL',
    0x03: 'SUB',
    0x04: 'DIV',
    0x05: 'SDIV',
    0x06: 'MOD',
    0x07: 'SMOD',
    0x08: 'ADDMOD',
    0x09: 'MULMOD',
    0x0A: 'EXP',
    0x0B: 'SIGNEXTEND',
    0x10: 'LT',
    0x11: 'GT',
    0x12: 'SLT',
    0x13: 'SGT',
    0x14: 'EQ',
    0x15: 'ISZERO',
    0x16: 'AND',
    0x17: 'OR',
    0x18: 'XOR',
    0x19: 'NOT',
    0x1A: 'BYTE',
    0x1B: 'SHL',
    0x1C: 'SHR',
    0x1D: 'SAR',
    0x20: 'SHA3',
    0x30: 'ADDRESS',
    0x31: 'BALANCE',
    0x32: 'ORIGIN',
    0x33: 'CALLER',
    0x34: 'CALLVALUE',
    0x35: 'CALLDATALOAD',
    0x36: 'CALLDATASIZE',
    0x37: 'CALLDATACOPY',
    0x38: 'CODESIZE',
    0x39: 'CODECOPY',
    0x3A: 'GASPRICE',
    0x3B: 'EXTCODESIZE',
    0x3C: 'EXTCODECOPY',
    0x3D: 'RETURNDATASIZE',
    0x3E: 'RETURNDATACOPY',
    0x3F: 'EXTCODEHASH',
    0x40: 'BLOCKHASH',
    0x41: 'COINBASE',
    0x42: 'TIMESTAMP',
    0x43: 'NUMBER',
    0x44: 'DIFFICULTY',
    0x45: 'GASLIMIT',
    0x46: 'CHAINID',
    0x47: 'SELFBALANCE',
    0x48: 'BASEFEE',
    0x50: 'POP',
    0x51: 'MLOAD',
    0x52: 'MSTORE',
    0x53: 'MSTORE8',
    0x54: 'SLOAD',
    0x55: 'SSTORE',
    0x56: 'JUMP',
    0x57: 'JUMPI',
    0x58: 'PC',
    0x59: 'MSIZE',
    0x5A: 'GAS',
    0x5B: 'JUMPDEST',
}


for i in range(0, 33):
    EVM_OPCODES[0x5F + i] = f'PUSH{i}'
    
for i in range(0, 17):
    EVM_OPCODES[0x7F + i] = f'DUP{i}'

for i in range(0, 17):
    EVM_OPCODES[0x8F + i] = f'SWAP{i}'
    
for i in range(5):
    EVM_OPCODES[0xA0 + i] = f'LOG{i}'
    
EVM_OPCODES.update({
    0xF0: 'CREATE',
    0xF1: 'CALL',
    0xF2: 'CALLCODE',
    0xF3: 'RETURN',
    0xF4: 'DELEGATECALL',
    0xF5: 'CREATE2',
    0xFA: 'STATICCALL',
    0xFD: 'REVERT',
    0xFE: 'INVALID',
    0xFF: 'SELFDESTRUCT'
})

STACK_LIMIT = 1024
MEMORY_LIMIT = 1024 * 1024 * 64 

RISCV_REGISTERS = [
    "zero", "ra", "sp", "gp", "tp",
    "t0", "t1", "t2",
    "s0", "s1",
    "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
    "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11",
    "t3", "t4", "t5", "t6"
]

R_RISCV_TEMP0 = "t0"
R_RISCV_TEMP1 = "t1"
R_RISCV_TEMP2 = "t2"
R_RISCV_STACK_PTR = "sp"
R_RISCV_RETURN_ADDR = "ra"
R_RISCV_ARG0 = "a0"
R_RISCV_ARG1 = "a1"

# File paths for I/O
EVM_BIN_FILE = "output/test.evm"
RISC_ASM_FILE = "output/test.asm"
RISC_LOG_FILE = "output/test.log"
RISC_ELF_FILE = "output/test.elf"