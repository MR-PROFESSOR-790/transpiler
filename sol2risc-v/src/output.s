.section .text
.global _start

_start:
# 0x0000: PUSH1 128
li t0, 128
# 0x0002: PUSH1 64
li t1, 64
# 0x0004: MSTORE 
sw t1, 0(t0)
# 0x0005: CALLVALUE 
# TODO: Implement CALLVALUE
# 0x0006: DUP1 
mv t0, 0
# 0x0007: ISZERO 
seqz t1, t0
# 0x0008: PUSH1 14
li t0, 14
# 0x000a: JUMPI 
beq t1, zero, L_000a
# 0x000b: PUSH0 
li t0, None
# 0x000c: DUP1 
mv t1, t0
# 0x000d: REVERT 
# TODO: Implement REVERT
# 0x000e: JUMPDEST 
L_000e:
# 0x000f: POP 
# 0x0010: PUSH2 323
li t1, 323
# 0x0013: DUP1 
mv t2, t1
# 0x0014: PUSH2 28
li t3, 28
# 0x0017: PUSH0 
li t4, None
# 0x0018: CODECOPY 
# TODO: Implement CODECOPY
# 0x0019: PUSH0 
li t5, None
# 0x001a: RETURN 
# TODO: Implement RETURN
# 0x001b: INVALID 
invalid
# 0x001c: PUSH1 128
li t6, 128
# 0x001e: PUSH1 64
li s1, 64
# 0x0020: MSTORE 
sw s1, 0(t6)
# 0x0021: CALLVALUE 
# TODO: Implement CALLVALUE
# 0x0022: DUP1 
mv t6, t5
# 0x0023: ISZERO 
seqz s1, t6
# 0x0024: PUSH2 15
li t6, 15
# 0x0027: JUMPI 
beq s1, zero, L_0027
# 0x0028: PUSH0 
li t6, None
# 0x0029: DUP1 
mv s1, t6
# 0x002a: REVERT 
# TODO: Implement REVERT
# 0x002b: JUMPDEST 
L_002b:
# 0x002c: POP 
# 0x002d: PUSH1 4
li s1, 4
# 0x002f: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x0030: LT 
sltu
# 0x0031: PUSH2 52
li s2, 52
# 0x0034: JUMPI 
beq s1, zero, L_0034
# 0x0035: PUSH0 
li s1, None
# 0x0036: CALLDATALOAD 
# TODO: Implement CALLDATALOAD
# 0x0037: PUSH1 224
li s2, 224
# 0x0039: SHR 
srl
# 0x003a: DUP1 
mv s3, s2
# 0x003b: PUSH4 778358465
li s4, 778358465
# 0x0040: EQ 
# TODO: Implement EQ
# 0x0041: PUSH2 56
li s5, 56
# 0x0044: JUMPI 
beq s4, zero, L_0044
# 0x0045: DUP1 
mv s4, s3
# 0x0046: PUSH4 1616328221
li s5, 1616328221
# 0x004b: EQ 
# TODO: Implement EQ
# 0x004c: PUSH2 86
li s6, 86
# 0x004f: JUMPI 
beq s5, zero, L_004f
# 0x0050: JUMPDEST 
L_0050:
# 0x0051: PUSH0 
li s5, None
# 0x0052: DUP1 
mv s6, s5
# 0x0053: REVERT 
# TODO: Implement REVERT
# 0x0054: JUMPDEST 
L_0054:
# 0x0055: PUSH2 64
li s7, 64
# 0x0058: PUSH2 114
li s8, 114
# 0x005b: JUMP 
j L_005b
# 0x005c: JUMPDEST 
L_005c:
# 0x005d: PUSH1 64
li s8, 64
# 0x005f: MLOAD 
lw s9, 0(s8)
# 0x0060: PUSH2 77
li s8, 77
# 0x0063: SWAP2 
# TODO: Implement SWAP2
# 0x0064: SWAP1 
# 0x0065: PUSH2 155
li s10, 155
# 0x0068: JUMP 
j L_0068
# 0x0069: JUMPDEST 
L_0069:
# 0x006a: PUSH1 64
li s10, 64
# 0x006c: MLOAD 
lw s11, 0(s10)
# 0x006d: DUP1 
mv s10, s11
# 0x006e: SWAP2 
# TODO: Implement SWAP2
# 0x006f: SUB 
sub spill[0], s11, s10
# 0x0070: SWAP1 
# 0x0071: RETURN 
# TODO: Implement RETURN
# 0x0072: JUMPDEST 
L_0072:
# 0x0073: PUSH2 112
li s10, 112
# 0x0076: PUSH1 4
li s11, 4
# 0x0078: DUP1 
mv spill[1], s11
# 0x0079: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x007a: SUB 
sub spill[2], s11, spill[1]
# 0x007b: DUP2 
mv s11, s10
# 0x007c: ADD 
add spill[3], spill[2], s11
# 0x007d: SWAP1 
# 0x007e: PUSH2 107
li s11, 107
# 0x0081: SWAP2 
# TODO: Implement SWAP2
# 0x0082: SWAP1 
# 0x0083: PUSH2 226
li spill[4], 226
# 0x0086: JUMP 
j L_0086
# 0x0087: JUMPDEST 
L_0087:
# 0x0088: PUSH2 122
li spill[5], 122
# 0x008b: JUMP 
j L_008b
# 0x008c: JUMPDEST 
L_008c:
# 0x008d: STOP 
nop
# 0x008e: JUMPDEST 
L_008e:
# 0x008f: PUSH0 
li spill[6], None
# 0x0090: DUP1 
mv spill[7], spill[6]
# 0x0091: SLOAD 
# TODO: Implement SLOAD
# 0x0092: SWAP1 
# 0x0093: POP 
# 0x0094: SWAP1 
# 0x0095: JUMP 
j L_0095
# 0x0096: JUMPDEST 
L_0096:
# 0x0097: DUP1 
mv s10, spill[7]
# 0x0098: PUSH0 
li spill[8], None
# 0x0099: DUP2 
mv spill[9], s10
# 0x009a: SWAP1 
# 0x009b: SSTORE 
# TODO: Implement SSTORE
# 0x009c: POP 
# 0x009d: POP 
# 0x009e: JUMP 
j L_009e
# 0x009f: JUMPDEST 
L_009f:
# 0x00a0: PUSH0 
li s10, None
# 0x00a1: DUP2 
mv spill[10], spill[7]
# 0x00a2: SWAP1 
# 0x00a3: POP 
# 0x00a4: SWAP2 
# TODO: Implement SWAP2
# 0x00a5: SWAP1 
# 0x00a6: POP 
# 0x00a7: JUMP 
j L_00a7
# 0x00a8: JUMPDEST 
L_00a8:
# 0x00a9: PUSH2 149
li s10, 149
# 0x00ac: DUP2 
mv spill[11], s11
# 0x00ad: PUSH2 131
li spill[12], 131
# 0x00b0: JUMP 
j L_00b0
# 0x00b1: JUMPDEST 
L_00b1:
# 0x00b2: DUP3 
mv spill[13], s11
# 0x00b3: MSTORE 
sw spill[13], 0(spill[11])
# 0x00b4: POP 
# 0x00b5: POP 
# 0x00b6: JUMP 
j L_00b6
# 0x00b7: JUMPDEST 
L_00b7:
# 0x00b8: PUSH0 
li s10, None
# 0x00b9: PUSH1 32
li s11, 32
# 0x00bb: DUP3 
mv spill[14], s9
# 0x00bc: ADD 
add spill[15], s11, spill[14]
# 0x00bd: SWAP1 
# 0x00be: POP 
# 0x00bf: PUSH2 174
li s10, 174
# 0x00c2: PUSH0 
li s11, None
# 0x00c3: DUP4 
mv spill[16], s9
# 0x00c4: ADD 
add spill[17], s11, spill[16]
# 0x00c5: DUP5 
mv s11, spill[0]
# 0x00c6: PUSH2 140
li spill[18], 140
# 0x00c9: JUMP 
j L_00c9
# 0x00ca: JUMPDEST 
L_00ca:
# 0x00cb: SWAP3 
# TODO: Implement SWAP3
# 0x00cc: SWAP2 
# TODO: Implement SWAP2
# 0x00cd: POP 
# 0x00ce: POP 
# 0x00cf: JUMP 
j L_00cf
# 0x00d0: JUMPDEST 
L_00d0:
# 0x00d1: PUSH0 
li s10, None
# 0x00d2: DUP1 
mv s11, s10
# 0x00d3: REVERT 
# TODO: Implement REVERT
# 0x00d4: JUMPDEST 
L_00d4:
# 0x00d5: PUSH2 193
li spill[19], 193
# 0x00d8: DUP2 
mv spill[20], s11
# 0x00d9: PUSH2 131
li spill[21], 131
# 0x00dc: JUMP 
j L_00dc
# 0x00dd: JUMPDEST 
L_00dd:
# 0x00de: DUP2 
mv spill[22], spill[19]
# 0x00df: EQ 
# TODO: Implement EQ
# 0x00e0: PUSH2 203
li spill[23], 203
# 0x00e3: JUMPI 
beq spill[22], zero, L_00e3
# 0x00e4: PUSH0 
li spill[24], None
# 0x00e5: DUP1 
mv spill[25], spill[24]
# 0x00e6: REVERT 
# TODO: Implement REVERT
# 0x00e7: JUMPDEST 
L_00e7:
# 0x00e8: POP 
# 0x00e9: JUMP 
j L_00e9
# 0x00ea: JUMPDEST 
L_00ea:
# 0x00eb: PUSH0 
li spill[26], None
# 0x00ec: DUP2 
mv spill[27], spill[20]
# 0x00ed: CALLDATALOAD 
# TODO: Implement CALLDATALOAD
# 0x00ee: SWAP1 
# 0x00ef: POP 
# 0x00f0: PUSH2 220
li spill[28], 220
# 0x00f3: DUP2 
mv spill[29], spill[27]
# 0x00f4: PUSH2 184
li spill[30], 184
# 0x00f7: JUMP 
j L_00f7
# 0x00f8: JUMPDEST 
L_00f8:
# 0x00f9: SWAP3 
# TODO: Implement SWAP3
# 0x00fa: SWAP2 
# TODO: Implement SWAP2
# 0x00fb: POP 
# 0x00fc: POP 
# 0x00fd: JUMP 
j L_00fd
# 0x00fe: JUMPDEST 
L_00fe:
# 0x00ff: PUSH0 
li spill[31], None
# 0x0100: PUSH1 32
li spill[32], 32
# 0x0102: DUP3 
mv spill[33], spill[20]
# 0x0103: DUP5 
mv spill[34], spill[19]
# 0x0104: SUB 
sub spill[35], spill[33], spill[34]
# 0x0105: SLT 
slt
# 0x0106: ISZERO 
seqz spill[36], spill[35]
# 0x0107: PUSH2 247
li spill[37], 247
# 0x010a: JUMPI 
beq spill[36], zero, L_010a
# 0x010b: PUSH2 246
li spill[38], 246
# 0x010e: PUSH2 180
li spill[39], 180
# 0x0111: JUMP 
j L_0111
# 0x0112: JUMPDEST 
L_0112:
# 0x0113: JUMPDEST 
L_0113:
# 0x0114: PUSH0 
li spill[40], None
# 0x0115: PUSH2 260
li spill[41], 260
# 0x0118: DUP5 
mv spill[42], spill[31]
# 0x0119: DUP3 
mv spill[43], spill[40]
# 0x011a: DUP6 
mv spill[44], spill[32]
# 0x011b: ADD 
add spill[45], spill[43], spill[44]
# 0x011c: PUSH2 206
li spill[46], 206
# 0x011f: JUMP 
j L_011f
# 0x0120: JUMPDEST 
L_0120:
# 0x0121: SWAP2 
# TODO: Implement SWAP2
# 0x0122: POP 
# 0x0123: POP 
# 0x0124: SWAP3 
# TODO: Implement SWAP3
# 0x0125: SWAP2 
# TODO: Implement SWAP2
# 0x0126: POP 
# 0x0127: POP 
# 0x0128: JUMP 
j L_0128
# 0x0129: INVALID 
invalid
# 0x012a: LOG2 
# TODO: Implement LOG2
# 0x012b: PUSH5 452857328472
li spill[47], 452857328472
# 0x0131: UNKNOWN_0x22 
invalid
# 0x0132: SLT 
slt
# 0x0133: SHA3 
# TODO: Implement SHA3
# 0x0134: SWAP11 
# TODO: Implement SWAP11
# 0x0135: UNKNOWN_0x0d 
invalid
# 0x0136: UNKNOWN_0xd3 
invalid
# 0x0137: MSTORE8 
# TODO: Implement MSTORE8
# 0x0138: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x0139: UNKNOWN_0xaf 
invalid
# 0x013a: CALL 
# TODO: Implement CALL
# 0x013b: UNKNOWN_0xeb 
invalid
# 0x013c: RETURNDATACOPY 
invalid
# 0x013d: UNKNOWN_0xeb 
invalid
# 0x013e: GT 
sgtu
# 0x013f: UNKNOWN_0xdb 
invalid
# 0x0140: PUSH23 16318918667218439395937000232262327082130987742439632748
li spill[48], 16318918667218439395937000232262327082130987742439632748
# 0x0158: PUSH4 1124075546
li spill[49], 1124075546
# 0x015d: STOP 
nop
# 0x015e: CALLER 
# TODO: Implement CALLER