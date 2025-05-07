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
# 0x0008: PUSH2 15
li t0, 15
# 0x000b: JUMPI 
beq t1, zero, L_000b
# 0x000c: PUSH0 
li t0, None
# 0x000d: DUP1 
mv t1, t0
# 0x000e: REVERT 
# TODO: Implement REVERT
# 0x000f: JUMPDEST 
L_000f:
# 0x0010: POP 
# 0x0011: PUSH1 64
li t1, 64
# 0x0013: MLOAD 
lw t2, 0(t1)
# 0x0014: PUSH2 5134
li t1, 5134
# 0x0017: CODESIZE 
invalid
# 0x0018: SUB 
sub t3, t2, t1
# 0x0019: DUP1 
mv t1, t3
# 0x001a: PUSH2 5134
li t2, 5134
# 0x001d: DUP4 
mv t4, t0
# 0x001e: CODECOPY 
# TODO: Implement CODECOPY
# 0x001f: DUP2 
mv t5, t2
# 0x0020: DUP2 
mv t6, t4
# 0x0021: ADD 
add s1, t5, t6
# 0x0022: PUSH1 64
li t5, 64
# 0x0024: MSTORE 
sw t5, 0(s1)
# 0x0025: DUP2 
mv t5, t2
# 0x0026: ADD 
add t6, t4, t5
# 0x0027: SWAP1 
# 0x0028: PUSH2 49
li t4, 49
# 0x002b: SWAP2 
# TODO: Implement SWAP2
# 0x002c: SWAP1 
# 0x002d: PUSH2 754
li t5, 754
# 0x0030: JUMP 
j L_0030
# 0x0031: JUMPDEST 
L_0031:
# 0x0032: CALLER 
# TODO: Implement CALLER
# 0x0033: PUSH0 
li t5, None
# 0x0034: DUP1 
mv s1, t5
# 0x0035: PUSH2 256
li s2, 256
# 0x0038: EXP 
# TODO: Implement EXP
# 0x0039: DUP2 
mv s3, s1
# 0x003a: SLOAD 
# TODO: Implement SLOAD
# 0x003b: DUP2 
mv s4, s2
# 0x003c: PUSH20 1461501637330902918203684832716283019655932542975
li s5, 1461501637330902918203684832716283019655932542975
# 0x0051: MUL 
mul s6, s4, s5
# 0x0052: NOT 
# TODO: Implement NOT
# 0x0053: AND 
and s4, s3, s6
# 0x0054: SWAP1 
# 0x0055: DUP4 
mv s3, t5
# 0x0056: PUSH20 1461501637330902918203684832716283019655932542975
li s5, 1461501637330902918203684832716283019655932542975
# 0x006b: AND 
and s6, s3, s5
# 0x006c: MUL 
mul s3, s2, s6
# 0x006d: OR 
or s2, s4, s3
# 0x006e: SWAP1 
# 0x006f: SSTORE 
# TODO: Implement SSTORE
# 0x0070: POP 
# 0x0071: PUSH1 1
li s1, 1
# 0x0073: DUP1 
mv s3, s1
# 0x0074: PUSH0 
li s4, None
# 0x0075: DUP1 
mv s5, s4
# 0x0076: PUSH0 
li s6, None
# 0x0077: SWAP1 
# 0x0078: SLOAD 
# TODO: Implement SLOAD
# 0x0079: SWAP1 
# 0x007a: PUSH2 256
li s7, 256
# 0x007d: EXP 
# TODO: Implement EXP
# 0x007e: SWAP1 
# 0x007f: DIV 
divu s8, s7, s6
# 0x0080: PUSH20 1461501637330902918203684832716283019655932542975
li s6, 1461501637330902918203684832716283019655932542975
# 0x0095: AND 
and s7, s8, s6
# 0x0096: PUSH20 1461501637330902918203684832716283019655932542975
li s6, 1461501637330902918203684832716283019655932542975
# 0x00ab: AND 
and s8, s7, s6
# 0x00ac: PUSH20 1461501637330902918203684832716283019655932542975
li s6, 1461501637330902918203684832716283019655932542975
# 0x00c1: AND 
and s7, s8, s6
# 0x00c2: DUP2 
mv s6, s5
# 0x00c3: MSTORE 
sw s6, 0(s7)
# 0x00c4: PUSH1 32
li s6, 32
# 0x00c6: ADD 
add s7, s5, s6
# 0x00c7: SWAP1 
# 0x00c8: DUP2 
mv s5, s7
# 0x00c9: MSTORE 
sw s5, 0(s4)
# 0x00ca: PUSH1 32
li s4, 32
# 0x00cc: ADD 
add s5, s7, s4
# 0x00cd: PUSH0 
li s4, None
# 0x00ce: SHA3 
# TODO: Implement SHA3
# 0x00cf: PUSH0 
li s6, None
# 0x00d0: ADD 
add s7, s4, s6
# 0x00d1: DUP2 
mv s4, s5
# 0x00d2: SWAP1 
# 0x00d3: SSTORE 
# TODO: Implement SSTORE
# 0x00d4: POP 
# 0x00d5: PUSH0 
li s6, None
# 0x00d6: JUMPDEST 
L_00d6:
# 0x00d7: DUP2 
mv s7, s4
# 0x00d8: MLOAD 
lw s8, 0(s7)
# 0x00d9: DUP2 
mv s7, s6
# 0x00da: LT 
sltu
# 0x00db: ISZERO 
seqz s9, s7
# 0x00dc: PUSH2 343
li s7, 343
# 0x00df: JUMPI 
beq s9, zero, L_00df
# 0x00e0: PUSH1 2
li s7, 2
# 0x00e2: PUSH1 64
li s9, 64
# 0x00e4: MLOAD 
lw s10, 0(s9)
# 0x00e5: DUP1 
mv s9, s10
# 0x00e6: PUSH1 64
li s11, 64
# 0x00e8: ADD 
add spill[0], s9, s11
# 0x00e9: PUSH1 64
li s9, 64
# 0x00eb: MSTORE 
sw s9, 0(spill[0])
# 0x00ec: DUP1 
mv s9, s10
# 0x00ed: DUP5 
mv s11, s6
# 0x00ee: DUP5 
mv spill[1], s8
# 0x00ef: DUP2 
mv spill[2], s11
# 0x00f0: MLOAD 
lw spill[3], 0(spill[2])
# 0x00f1: DUP2 
mv spill[4], spill[1]
# 0x00f2: LT 
sltu
# 0x00f3: PUSH2 255
li spill[5], 255
# 0x00f6: JUMPI 
beq spill[4], zero, L_00f6
# 0x00f7: PUSH2 254
li spill[6], 254
# 0x00fa: PUSH2 825
li spill[7], 825
# 0x00fd: JUMP 
j L_00fd
# 0x00fe: JUMPDEST 
L_00fe:
# 0x00ff: JUMPDEST 
L_00ff:
# 0x0100: PUSH1 32
li spill[8], 32
# 0x0102: MUL 
mul spill[9], spill[6], spill[8]
# 0x0103: PUSH1 32
li spill[10], 32
# 0x0105: ADD 
add spill[11], spill[9], spill[10]
# 0x0106: ADD 
add spill[12], spill[3], spill[11]
# 0x0107: MLOAD 
lw spill[13], 0(spill[12])
# 0x0108: DUP2 
mv spill[14], spill[1]
# 0x0109: MSTORE 
sw spill[14], 0(spill[13])
# 0x010a: PUSH1 32
li spill[15], 32
# 0x010c: ADD 
add spill[16], spill[1], spill[15]
# 0x010d: PUSH0 
li spill[17], None
# 0x010e: DUP2 
mv spill[18], spill[16]
# 0x010f: MSTORE 
sw spill[18], 0(spill[17])
# 0x0110: POP 
# 0x0111: SWAP1 
# 0x0112: DUP1 
mv spill[19], s9
# 0x0113: PUSH1 1
li spill[20], 1
# 0x0115: DUP2 
mv spill[21], spill[19]
# 0x0116: SLOAD 
# TODO: Implement SLOAD
# 0x0117: ADD 
add spill[22], spill[20], spill[21]
# 0x0118: DUP1 
mv spill[23], spill[22]
# 0x0119: DUP3 
mv spill[24], spill[19]
# 0x011a: SSTORE 
# TODO: Implement SSTORE
# 0x011b: DUP1 
mv spill[25], spill[24]
# 0x011c: SWAP2 
# TODO: Implement SWAP2
# 0x011d: POP 
# 0x011e: POP 
# 0x011f: PUSH1 1
li spill[26], 1
# 0x0121: SWAP1 
# 0x0122: SUB 
sub spill[27], spill[26], spill[23]
# 0x0123: SWAP1 
# 0x0124: PUSH0 
li spill[28], None
# 0x0125: MSTORE 
sw spill[28], 0(spill[22])
# 0x0126: PUSH1 32
li spill[29], 32
# 0x0128: PUSH0 
li spill[30], None
# 0x0129: SHA3 
# TODO: Implement SHA3
# 0x012a: SWAP1 
# 0x012b: PUSH1 2
li spill[31], 2
# 0x012d: MUL 
mul spill[32], spill[29], spill[31]
# 0x012e: ADD 
add spill[33], spill[30], spill[32]
# 0x012f: PUSH0 
li spill[34], None
# 0x0130: SWAP1 
# 0x0131: SWAP2 
# TODO: Implement SWAP2
# 0x0132: SWAP1 
# 0x0133: SWAP2 
# TODO: Implement SWAP2
# 0x0134: SWAP1 
# 0x0135: SWAP2 
# TODO: Implement SWAP2
# 0x0136: POP 
# 0x0137: PUSH0 
li spill[35], None
# 0x0138: DUP3 
mv spill[36], spill[27]
# 0x0139: ADD 
add spill[37], spill[35], spill[36]
# 0x013a: MLOAD 
lw spill[38], 0(spill[37])
# 0x013b: DUP2 
mv spill[39], spill[34]
# 0x013c: PUSH0 
li spill[40], None
# 0x013d: ADD 
add spill[41], spill[39], spill[40]
# 0x013e: SSTORE 
# TODO: Implement SSTORE
# 0x013f: PUSH1 32
li spill[42], 32
# 0x0141: DUP3 
mv spill[43], spill[38]
# 0x0142: ADD 
add spill[44], spill[42], spill[43]
# 0x0143: MLOAD 
lw spill[45], 0(spill[44])
# 0x0144: DUP2 
mv spill[46], spill[41]
# 0x0145: PUSH1 1
li spill[47], 1
# 0x0147: ADD 
add spill[48], spill[46], spill[47]
# 0x0148: SSTORE 
# TODO: Implement SSTORE
# 0x0149: POP 
# 0x014a: POP 
# 0x014b: DUP1 
mv spill[49], spill[41]
# 0x014c: DUP1 
mv spill[50], spill[49]
# 0x014d: PUSH1 1
li spill[51], 1
# 0x014f: ADD 
add spill[52], spill[50], spill[51]
# 0x0150: SWAP2 
# TODO: Implement SWAP2
# 0x0151: POP 
# 0x0152: POP 
# 0x0153: PUSH2 214
li spill[53], 214
# 0x0156: JUMP 
j L_0156
# 0x0157: JUMPDEST 
L_0157:
# 0x0158: POP 
# 0x0159: POP 
# 0x015a: PUSH2 870
li spill[54], 870
# 0x015d: JUMP 
j L_015d
# 0x015e: JUMPDEST 
L_015e:
# 0x015f: PUSH0 
li spill[55], None
# 0x0160: PUSH1 64
li spill[56], 64
# 0x0162: MLOAD 
lw spill[57], 0(spill[56])
# 0x0163: SWAP1 
# 0x0164: POP 
# 0x0165: SWAP1 
# 0x0166: JUMP 
j L_0166
# 0x0167: JUMPDEST 
L_0167:
# 0x0168: PUSH0 
li spill[58], None
# 0x0169: DUP1 
mv spill[59], spill[58]
# 0x016a: REVERT 
# TODO: Implement REVERT
# 0x016b: JUMPDEST 
L_016b:
# 0x016c: PUSH0 
li spill[60], None
# 0x016d: DUP1 
mv spill[61], spill[60]
# 0x016e: REVERT 
# TODO: Implement REVERT
# 0x016f: JUMPDEST 
L_016f:
# 0x0170: PUSH0 
li spill[62], None
# 0x0171: DUP1 
mv spill[63], spill[62]
# 0x0172: REVERT 
# TODO: Implement REVERT
# 0x0173: JUMPDEST 
L_0173:
# 0x0174: PUSH0 
li spill[64], None
# 0x0175: PUSH1 31
li spill[65], 31
# 0x0177: NOT 
# TODO: Implement NOT
# 0x0178: PUSH1 31
li spill[66], 31
# 0x017a: DUP4 
mv spill[67], spill[63]
# 0x017b: ADD 
add spill[68], spill[66], spill[67]
# 0x017c: AND 
and spill[69], spill[65], spill[68]
# 0x017d: SWAP1 
# 0x017e: POP 
# 0x017f: SWAP2 
# TODO: Implement SWAP2
# 0x0180: SWAP1 
# 0x0181: POP 
# 0x0182: JUMP 
j L_0182
# 0x0183: JUMPDEST 
L_0183:
# 0x0184: DUP0 
mv spill[70], 0
# 0x0185: UNKNOWN_0x4e 
invalid
# 0x0186: BASEFEE 
invalid
# 0x0187: PUSH28 11900288958546962096864737128254758852035145780262049571737140461568
li spill[71], 11900288958546962096864737128254758852035145780262049571737140461568
# 0x01a4: STOP 
nop
# 0x01a5: PUSH0 
li spill[72], None
# 0x01a6: MSTORE 
sw spill[72], 0(spill[71])
# 0x01a7: PUSH1 65
li spill[73], 65
# 0x01a9: PUSH1 4
li spill[74], 4
# 0x01ab: MSTORE 
sw spill[74], 0(spill[73])
# 0x01ac: PUSH1 36
li spill[75], 36
# 0x01ae: PUSH0 
li spill[76], None
# 0x01af: REVERT 
# TODO: Implement REVERT
# 0x01b0: JUMPDEST 
L_01b0:
# 0x01b1: PUSH2 441
li spill[77], 441
# 0x01b4: DUP3 
mv spill[78], spill[75]
# 0x01b5: PUSH2 371
li spill[79], 371
# 0x01b8: JUMP 
j L_01b8
# 0x01b9: JUMPDEST 
L_01b9:
# 0x01ba: DUP2 
mv spill[80], spill[77]
# 0x01bb: ADD 
add spill[81], spill[78], spill[80]
# 0x01bc: DUP2 
mv spill[82], spill[77]
# 0x01bd: DUP2 
mv spill[83], spill[81]
# 0x01be: LT 
sltu
# 0x01bf: PUSH8 18446744073709551615
li spill[84], 18446744073709551615
# 0x01c8: DUP3 
mv spill[85], spill[82]
# 0x01c9: GT 
sgtu
# 0x01ca: OR 
or spill[86], spill[84], spill[85]
# 0x01cb: ISZERO 
seqz spill[87], spill[86]
# 0x01cc: PUSH2 472
li spill[88], 472
# 0x01cf: JUMPI 
beq spill[87], zero, L_01cf
# 0x01d0: PUSH2 471
li spill[89], 471
# 0x01d3: PUSH2 387
li spill[90], 387
# 0x01d6: JUMP 
j L_01d6
# 0x01d7: JUMPDEST 
L_01d7:
# 0x01d8: JUMPDEST 
L_01d8:
# 0x01d9: DUP1 
mv spill[91], spill[89]
# 0x01da: PUSH1 64
li spill[92], 64
# 0x01dc: MSTORE 
sw spill[92], 0(spill[91])
# 0x01dd: POP 
# 0x01de: POP 
# 0x01df: POP 
# 0x01e0: JUMP 
j L_01e0
# 0x01e1: JUMPDEST 
L_01e1:
# 0x01e2: PUSH0 
li spill[93], None
# 0x01e3: PUSH2 490
li spill[94], 490
# 0x01e6: PUSH2 350
li spill[95], 350
# 0x01e9: JUMP 
j L_01e9
# 0x01ea: JUMPDEST 
L_01ea:
# 0x01eb: SWAP1 
# 0x01ec: POP 
# 0x01ed: PUSH2 502
li spill[96], 502
# 0x01f0: DUP3 
mv spill[97], spill[77]
# 0x01f1: DUP3 
mv spill[98], spill[94]
# 0x01f2: PUSH2 432
li spill[99], 432
# 0x01f5: JUMP 
j L_01f5
# 0x01f6: JUMPDEST 
L_01f6:
# 0x01f7: SWAP2 
# TODO: Implement SWAP2
# 0x01f8: SWAP1 
# 0x01f9: POP 
# 0x01fa: JUMP 
j L_01fa
# 0x01fb: JUMPDEST 
L_01fb:
# 0x01fc: PUSH0 
li spill[100], None
# 0x01fd: PUSH8 18446744073709551615
li spill[101], 18446744073709551615
# 0x0206: DUP3 
mv spill[102], spill[96]
# 0x0207: GT 
sgtu
# 0x0208: ISZERO 
seqz spill[103], spill[102]
# 0x0209: PUSH2 533
li spill[104], 533
# 0x020c: JUMPI 
beq spill[103], zero, L_020c
# 0x020d: PUSH2 532
li spill[105], 532
# 0x0210: PUSH2 387
li spill[106], 387
# 0x0213: JUMP 
j L_0213
# 0x0214: JUMPDEST 
L_0214:
# 0x0215: JUMPDEST 
L_0215:
# 0x0216: PUSH1 32
li spill[107], 32
# 0x0218: DUP3 
mv spill[108], spill[101]
# 0x0219: MUL 
mul spill[109], spill[107], spill[108]
# 0x021a: SWAP1 
# 0x021b: POP 
# 0x021c: PUSH1 32
li spill[110], 32
# 0x021e: DUP2 
mv spill[111], spill[109]
# 0x021f: ADD 
add spill[112], spill[110], spill[111]
# 0x0220: SWAP1 
# 0x0221: POP 
# 0x0222: SWAP2 
# TODO: Implement SWAP2
# 0x0223: SWAP1 
# 0x0224: POP 
# 0x0225: JUMP 
j L_0225
# 0x0226: JUMPDEST 
L_0226:
# 0x0227: PUSH0 
li spill[113], None
# 0x0228: DUP1 
mv spill[114], spill[113]
# 0x0229: REVERT 
# TODO: Implement REVERT
# 0x022a: JUMPDEST 
L_022a:
# 0x022b: PUSH0 
li spill[115], None
# 0x022c: DUP2 
mv spill[116], spill[114]
# 0x022d: SWAP1 
# 0x022e: POP 
# 0x022f: SWAP2 
# TODO: Implement SWAP2
# 0x0230: SWAP1 
# 0x0231: POP 
# 0x0232: JUMP 
j L_0232
# 0x0233: JUMPDEST 
L_0233:
# 0x0234: PUSH2 572
li spill[117], 572
# 0x0237: DUP2 
mv spill[118], spill[113]
# 0x0238: PUSH2 554
li spill[119], 554
# 0x023b: JUMP 
j L_023b
# 0x023c: JUMPDEST 
L_023c:
# 0x023d: DUP2 
mv spill[120], spill[117]
# 0x023e: EQ 
# TODO: Implement EQ
# 0x023f: PUSH2 582
li spill[121], 582
# 0x0242: JUMPI 
beq spill[120], zero, L_0242
# 0x0243: PUSH0 
li spill[122], None
# 0x0244: DUP1 
mv spill[123], spill[122]
# 0x0245: REVERT 
# TODO: Implement REVERT
# 0x0246: JUMPDEST 
L_0246:
# 0x0247: POP 
# 0x0248: JUMP 
j L_0248
# 0x0249: JUMPDEST 
L_0249:
# 0x024a: PUSH0 
li spill[124], None
# 0x024b: DUP2 
mv spill[125], spill[118]
# 0x024c: MLOAD 
lw spill[126], 0(spill[125])
# 0x024d: SWAP1 
# 0x024e: POP 
# 0x024f: PUSH2 599
li spill[127], 599
# 0x0252: DUP2 
mv spill[128], spill[126]
# 0x0253: PUSH2 563
li spill[129], 563
# 0x0256: JUMP 
j L_0256
# 0x0257: JUMPDEST 
L_0257:
# 0x0258: SWAP3 
# TODO: Implement SWAP3
# 0x0259: SWAP2 
# TODO: Implement SWAP2
# 0x025a: POP 
# 0x025b: POP 
# 0x025c: JUMP 
j L_025c
# 0x025d: JUMPDEST 
L_025d:
# 0x025e: PUSH0 
li spill[130], None
# 0x025f: PUSH2 623
li spill[131], 623
# 0x0262: PUSH2 618
li spill[132], 618
# 0x0265: DUP5 
mv spill[133], spill[117]
# 0x0266: PUSH2 507
li spill[134], 507
# 0x0269: JUMP 
j L_0269
# 0x026a: JUMPDEST 
L_026a:
# 0x026b: PUSH2 481
li spill[135], 481
# 0x026e: JUMP 
j L_026e
# 0x026f: JUMPDEST 
L_026f:
# 0x0270: SWAP1 
# 0x0271: POP 
# 0x0272: DUP1 
mv spill[136], spill[133]
# 0x0273: DUP4 
mv spill[137], spill[130]
# 0x0274: DUP3 
mv spill[138], spill[133]
# 0x0275: MSTORE 
sw spill[138], 0(spill[137])
# 0x0276: PUSH1 32
li spill[139], 32
# 0x0278: DUP3 
mv spill[140], spill[133]
# 0x0279: ADD 
add spill[141], spill[139], spill[140]
# 0x027a: SWAP1 
# 0x027b: POP 
# 0x027c: PUSH1 32
li spill[142], 32
# 0x027e: DUP5 
mv spill[143], spill[130]
# 0x027f: MUL 
mul spill[144], spill[142], spill[143]
# 0x0280: DUP4 
mv spill[145], spill[131]
# 0x0281: ADD 
add spill[146], spill[144], spill[145]
# 0x0282: DUP6 
mv spill[147], spill[118]
# 0x0283: DUP2 
mv spill[148], spill[146]
# 0x0284: GT 
sgtu
# 0x0285: ISZERO 
seqz spill[149], spill[148]
# 0x0286: PUSH2 658
li spill[150], 658
# 0x0289: JUMPI 
beq spill[149], zero, L_0289
# 0x028a: PUSH2 657
li spill[151], 657
# 0x028d: PUSH2 550
li spill[152], 550
# 0x0290: JUMP 
j L_0290
# 0x0291: JUMPDEST 
L_0291:
# 0x0292: JUMPDEST 
L_0292:
# 0x0293: DUP4 
mv spill[153], spill[141]
# 0x0294: JUMPDEST 
L_0294:
# 0x0295: DUP2 
mv spill[154], spill[151]
# 0x0296: DUP2 
mv spill[155], spill[153]
# 0x0297: LT 
sltu
# 0x0298: ISZERO 
seqz spill[156], spill[155]
# 0x0299: PUSH2 699
li spill[157], 699
# 0x029c: JUMPI 
beq spill[156], zero, L_029c
# 0x029d: DUP1 
mv spill[158], spill[154]
# 0x029e: PUSH2 679
li spill[159], 679
# 0x02a1: DUP9 
mv spill[160], spill[133]
# 0x02a2: DUP3 
mv spill[161], spill[158]
# 0x02a3: PUSH2 585
li spill[162], 585
# 0x02a6: JUMP 
j L_02a6
# 0x02a7: JUMPDEST 
L_02a7:
# 0x02a8: DUP5 
mv spill[163], spill[154]
# 0x02a9: MSTORE 
sw spill[163], 0(spill[161])
# 0x02aa: PUSH1 32
li spill[164], 32
# 0x02ac: DUP5 
mv spill[165], spill[154]
# 0x02ad: ADD 
add spill[166], spill[164], spill[165]
# 0x02ae: SWAP4 
# TODO: Implement SWAP4
# 0x02af: POP 
# 0x02b0: POP 
# 0x02b1: PUSH1 32
li spill[167], 32
# 0x02b3: DUP2 
mv spill[168], spill[159]
# 0x02b4: ADD 
add spill[169], spill[167], spill[168]
# 0x02b5: SWAP1 
# 0x02b6: POP 
# 0x02b7: PUSH2 660
li spill[170], 660
# 0x02ba: JUMP 
j L_02ba
# 0x02bb: JUMPDEST 
L_02bb:
# 0x02bc: POP 
# 0x02bd: POP 
# 0x02be: POP 
# 0x02bf: SWAP4 
# TODO: Implement SWAP4
# 0x02c0: SWAP3 
# TODO: Implement SWAP3
# 0x02c1: POP 
# 0x02c2: POP 
# 0x02c3: POP 
# 0x02c4: JUMP 
j L_02c4
# 0x02c5: JUMPDEST 
L_02c5:
# 0x02c6: PUSH0 
li spill[171], None
# 0x02c7: DUP3 
mv spill[172], spill[133]
# 0x02c8: PUSH1 31
li spill[173], 31
# 0x02ca: DUP4 
mv spill[174], spill[141]
# 0x02cb: ADD 
add spill[175], spill[173], spill[174]
# 0x02cc: SLT 
slt
# 0x02cd: PUSH2 729
li spill[176], 729
# 0x02d0: JUMPI 
beq spill[175], zero, L_02d0
# 0x02d1: PUSH2 728
li spill[177], 728
# 0x02d4: PUSH2 367
li spill[178], 367
# 0x02d7: JUMP 
j L_02d7
# 0x02d8: JUMPDEST 
L_02d8:
# 0x02d9: JUMPDEST 
L_02d9:
# 0x02da: DUP2 
mv spill[179], spill[172]
# 0x02db: MLOAD 
lw spill[180], 0(spill[179])
# 0x02dc: PUSH2 745
li spill[181], 745
# 0x02df: DUP5 
mv spill[182], spill[171]
# 0x02e0: DUP3 
mv spill[183], spill[180]
# 0x02e1: PUSH1 32
li spill[184], 32
# 0x02e3: DUP7 
mv spill[185], spill[172]
# 0x02e4: ADD 
add spill[186], spill[184], spill[185]
# 0x02e5: PUSH2 605
li spill[187], 605
# 0x02e8: JUMP 
j L_02e8
# 0x02e9: JUMPDEST 
L_02e9:
# 0x02ea: SWAP2 
# TODO: Implement SWAP2
# 0x02eb: POP 
# 0x02ec: POP 
# 0x02ed: SWAP3 
# TODO: Implement SWAP3
# 0x02ee: SWAP2 
# TODO: Implement SWAP2
# 0x02ef: POP 
# 0x02f0: POP 
# 0x02f1: JUMP 
j L_02f1
# 0x02f2: JUMPDEST 
L_02f2:
# 0x02f3: PUSH0 
li spill[188], None
# 0x02f4: PUSH1 32
li spill[189], 32
# 0x02f6: DUP3 
mv spill[190], spill[177]
# 0x02f7: DUP5 
mv spill[191], spill[172]
# 0x02f8: SUB 
sub spill[192], spill[190], spill[191]
# 0x02f9: SLT 
slt
# 0x02fa: ISZERO 
seqz spill[193], spill[192]
# 0x02fb: PUSH2 775
li spill[194], 775
# 0x02fe: JUMPI 
beq spill[193], zero, L_02fe
# 0x02ff: PUSH2 774
li spill[195], 774
# 0x0302: PUSH2 359
li spill[196], 359
# 0x0305: JUMP 
j L_0305
# 0x0306: JUMPDEST 
L_0306:
# 0x0307: JUMPDEST 
L_0307:
# 0x0308: PUSH0 
li spill[197], None
# 0x0309: DUP3 
mv spill[198], spill[189]
# 0x030a: ADD 
add spill[199], spill[197], spill[198]
# 0x030b: MLOAD 
lw spill[200], 0(spill[199])
# 0x030c: PUSH8 18446744073709551615
li spill[201], 18446744073709551615
# 0x0315: DUP2 
mv spill[202], spill[200]
# 0x0316: GT 
sgtu
# 0x0317: ISZERO 
seqz spill[203], spill[202]
# 0x0318: PUSH2 804
li spill[204], 804
# 0x031b: JUMPI 
beq spill[203], zero, L_031b
# 0x031c: PUSH2 803
li spill[205], 803
# 0x031f: PUSH2 363
li spill[206], 363
# 0x0322: JUMP 
j L_0322
# 0x0323: JUMPDEST 
L_0323:
# 0x0324: JUMPDEST 
L_0324:
# 0x0325: PUSH2 816
li spill[207], 816
# 0x0328: DUP5 
mv spill[208], spill[195]
# 0x0329: DUP3 
mv spill[209], spill[205]
# 0x032a: DUP6 
mv spill[210], spill[200]
# 0x032b: ADD 
add spill[211], spill[209], spill[210]
# 0x032c: PUSH2 709
li spill[212], 709
# 0x032f: JUMP 
j L_032f
# 0x0330: JUMPDEST 
L_0330:
# 0x0331: SWAP2 
# TODO: Implement SWAP2
# 0x0332: POP 
# 0x0333: POP 
# 0x0334: SWAP3 
# TODO: Implement SWAP3
# 0x0335: SWAP2 
# TODO: Implement SWAP2
# 0x0336: POP 
# 0x0337: POP 
# 0x0338: JUMP 
j L_0338
# 0x0339: JUMPDEST 
L_0339:
# 0x033a: DUP0 
mv spill[213], 0
# 0x033b: UNKNOWN_0x4e 
invalid
# 0x033c: BASEFEE 
invalid
# 0x033d: PUSH28 11900288958546962096864737128254758852035145780262049571737140461568
li spill[214], 11900288958546962096864737128254758852035145780262049571737140461568
# 0x035a: STOP 
nop
# 0x035b: PUSH0 
li spill[215], None
# 0x035c: MSTORE 
sw spill[215], 0(spill[214])
# 0x035d: PUSH1 50
li spill[216], 50
# 0x035f: PUSH1 4
li spill[217], 4
# 0x0361: MSTORE 
sw spill[217], 0(spill[216])
# 0x0362: PUSH1 36
li spill[218], 36
# 0x0364: PUSH0 
li spill[219], None
# 0x0365: REVERT 
# TODO: Implement REVERT
# 0x0366: JUMPDEST 
L_0366:
# 0x0367: PUSH2 4251
li spill[220], 4251
# 0x036a: DUP1 
mv spill[221], spill[220]
# 0x036b: PUSH2 883
li spill[222], 883
# 0x036e: PUSH0 
li spill[223], None
# 0x036f: CODECOPY 
# TODO: Implement CODECOPY
# 0x0370: PUSH0 
li spill[224], None
# 0x0371: RETURN 
# TODO: Implement RETURN
# 0x0372: INVALID 
invalid
# 0x0373: PUSH1 128
li spill[225], 128
# 0x0375: PUSH1 64
li spill[226], 64
# 0x0377: MSTORE 
sw spill[226], 0(spill[225])
# 0x0378: CALLVALUE 
# TODO: Implement CALLVALUE
# 0x0379: DUP1 
mv spill[227], spill[224]
# 0x037a: ISZERO 
seqz spill[228], spill[227]
# 0x037b: PUSH2 15
li spill[229], 15
# 0x037e: JUMPI 
beq spill[228], zero, L_037e
# 0x037f: PUSH0 
li spill[230], None
# 0x0380: DUP1 
mv spill[231], spill[230]
# 0x0381: REVERT 
# TODO: Implement REVERT
# 0x0382: JUMPDEST 
L_0382:
# 0x0383: POP 
# 0x0384: PUSH1 4
li spill[232], 4
# 0x0386: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x0387: LT 
sltu
# 0x0388: PUSH2 134
li spill[233], 134
# 0x038b: JUMPI 
beq spill[232], zero, L_038b
# 0x038c: PUSH0 
li spill[234], None
# 0x038d: CALLDATALOAD 
# TODO: Implement CALLDATALOAD
# 0x038e: PUSH1 224
li spill[235], 224
# 0x0390: SHR 
srl
# 0x0391: DUP1 
mv spill[236], spill[235]
# 0x0392: PUSH4 1621094845
li spill[237], 1621094845
# 0x0397: GT 
sgtu
# 0x0398: PUSH2 89
li spill[238], 89
# 0x039b: JUMPI 
beq spill[237], zero, L_039b
# 0x039c: DUP1 
mv spill[239], spill[236]
# 0x039d: PUSH4 1621094845
li spill[240], 1621094845
# 0x03a2: EQ 
# TODO: Implement EQ
# 0x03a3: PUSH2 273
li spill[241], 273
# 0x03a6: JUMPI 
beq spill[240], zero, L_03a6
# 0x03a7: DUP1 
mv spill[242], spill[239]
# 0x03a8: PUSH4 2658897249
li spill[243], 2658897249
# 0x03ad: EQ 
# TODO: Implement EQ
# 0x03ae: PUSH2 303
li spill[244], 303
# 0x03b1: JUMPI 
beq spill[243], zero, L_03b1
# 0x03b2: DUP1 
mv spill[245], spill[242]
# 0x03b3: PUSH4 2750157709
li spill[246], 2750157709
# 0x03b8: EQ 
# TODO: Implement EQ
# 0x03b9: PUSH2 331
li spill[247], 331
# 0x03bc: JUMPI 
beq spill[246], zero, L_03bc
# 0x03bd: DUP1 
mv spill[248], spill[245]
# 0x03be: PUSH4 3803862000
li spill[249], 3803862000
# 0x03c3: EQ 
# TODO: Implement EQ
# 0x03c4: PUSH2 382
li spill[250], 382
# 0x03c7: JUMPI 
beq spill[249], zero, L_03c7
# 0x03c8: PUSH2 134
li spill[251], 134
# 0x03cb: JUMP 
j L_03cb
# 0x03cc: JUMPDEST 
L_03cc:
# 0x03cd: DUP1 
mv spill[252], spill[248]
# 0x03ce: PUSH4 18987327
li spill[253], 18987327
# 0x03d3: EQ 
# TODO: Implement EQ
# 0x03d4: PUSH2 138
li spill[254], 138
# 0x03d7: JUMPI 
beq spill[253], zero, L_03d7
# 0x03d8: DUP1 
mv spill[255], spill[252]
# 0x03d9: PUSH4 20770955
li spill[256], 20770955
# 0x03de: EQ 
# TODO: Implement EQ
# 0x03df: PUSH2 166
li spill[257], 166
# 0x03e2: JUMPI 
beq spill[256], zero, L_03e2
# 0x03e3: DUP1 
mv spill[258], spill[255]
# 0x03e4: PUSH4 776042191
li spill[259], 776042191
# 0x03e9: EQ 
# TODO: Implement EQ
# 0x03ea: PUSH2 215
li spill[260], 215
# 0x03ed: JUMPI 
beq spill[259], zero, L_03ed
# 0x03ee: DUP1 
mv spill[261], spill[258]
# 0x03ef: PUSH4 1545185628
li spill[262], 1545185628
# 0x03f4: EQ 
# TODO: Implement EQ
# 0x03f5: PUSH2 245
li spill[263], 245
# 0x03f8: JUMPI 
beq spill[262], zero, L_03f8
# 0x03f9: JUMPDEST 
L_03f9:
# 0x03fa: PUSH0 
li spill[264], None
# 0x03fb: DUP1 
mv spill[265], spill[264]
# 0x03fc: REVERT 
# TODO: Implement REVERT
# 0x03fd: JUMPDEST 
L_03fd:
# 0x03fe: PUSH2 164
li spill[266], 164
# 0x0401: PUSH1 4
li spill[267], 4
# 0x0403: DUP1 
mv spill[268], spill[267]
# 0x0404: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x0405: SUB 
sub spill[269], spill[267], spill[268]
# 0x0406: DUP2 
mv spill[270], spill[266]
# 0x0407: ADD 
add spill[271], spill[269], spill[270]
# 0x0408: SWAP1 
# 0x0409: PUSH2 159
li spill[272], 159
# 0x040c: SWAP2 
# TODO: Implement SWAP2
# 0x040d: SWAP1 
# 0x040e: PUSH2 2591
li spill[273], 2591
# 0x0411: JUMP 
j L_0411
# 0x0412: JUMPDEST 
L_0412:
# 0x0413: PUSH2 412
li spill[274], 412
# 0x0416: JUMP 
j L_0416
# 0x0417: JUMPDEST 
L_0417:
# 0x0418: STOP 
nop
# 0x0419: JUMPDEST 
L_0419:
# 0x041a: PUSH2 192
li spill[275], 192
# 0x041d: PUSH1 4
li spill[276], 4
# 0x041f: DUP1 
mv spill[277], spill[276]
# 0x0420: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x0421: SUB 
sub spill[278], spill[276], spill[277]
# 0x0422: DUP2 
mv spill[279], spill[275]
# 0x0423: ADD 
add spill[280], spill[278], spill[279]
# 0x0424: SWAP1 
# 0x0425: PUSH2 187
li spill[281], 187
# 0x0428: SWAP2 
# TODO: Implement SWAP2
# 0x0429: SWAP1 
# 0x042a: PUSH2 2591
li spill[282], 2591
# 0x042d: JUMP 
j L_042d
# 0x042e: JUMPDEST 
L_042e:
# 0x042f: PUSH2 727
li spill[283], 727
# 0x0432: JUMP 
j L_0432
# 0x0433: JUMPDEST 
L_0433:
# 0x0434: PUSH1 64
li spill[284], 64
# 0x0436: MLOAD 
lw spill[285], 0(spill[284])
# 0x0437: PUSH2 206
li spill[286], 206
# 0x043a: SWAP3 
# TODO: Implement SWAP3
# 0x043b: SWAP2 
# TODO: Implement SWAP2
# 0x043c: SWAP1 
# 0x043d: PUSH2 2673
li spill[287], 2673
# 0x0440: JUMP 
j L_0440
# 0x0441: JUMPDEST 
L_0441:
# 0x0442: PUSH1 64
li spill[288], 64
# 0x0444: MLOAD 
lw spill[289], 0(spill[288])
# 0x0445: DUP1 
mv spill[290], spill[289]
# 0x0446: SWAP2 
# TODO: Implement SWAP2
# 0x0447: SUB 
sub spill[291], spill[289], spill[290]
# 0x0448: SWAP1 
# 0x0449: RETURN 
# TODO: Implement RETURN
# 0x044a: JUMPDEST 
L_044a:
# 0x044b: PUSH2 223
li spill[292], 223
# 0x044e: PUSH2 774
li spill[293], 774
# 0x0451: JUMP 
j L_0451
# 0x0452: JUMPDEST 
L_0452:
# 0x0453: PUSH1 64
li spill[294], 64
# 0x0455: MLOAD 
lw spill[295], 0(spill[294])
# 0x0456: PUSH2 236
li spill[296], 236
# 0x0459: SWAP2 
# TODO: Implement SWAP2
# 0x045a: SWAP1 
# 0x045b: PUSH2 2775
li spill[297], 2775
# 0x045e: JUMP 
j L_045e
# 0x045f: JUMPDEST 
L_045f:
# 0x0460: PUSH1 64
li spill[298], 64
# 0x0462: MLOAD 
lw spill[299], 0(spill[298])
# 0x0463: DUP1 
mv spill[300], spill[299]
# 0x0464: SWAP2 
# TODO: Implement SWAP2
# 0x0465: SUB 
sub spill[301], spill[299], spill[300]
# 0x0466: SWAP1 
# 0x0467: RETURN 
# TODO: Implement RETURN
# 0x0468: JUMPDEST 
L_0468:
# 0x0469: PUSH2 271
li spill[302], 271
# 0x046c: PUSH1 4
li spill[303], 4
# 0x046e: DUP1 
mv spill[304], spill[303]
# 0x046f: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x0470: SUB 
sub spill[305], spill[303], spill[304]
# 0x0471: DUP2 
mv spill[306], spill[302]
# 0x0472: ADD 
add spill[307], spill[305], spill[306]
# 0x0473: SWAP1 
# 0x0474: PUSH2 266
li spill[308], 266
# 0x0477: SWAP2 
# TODO: Implement SWAP2
# 0x0478: SWAP1 
# 0x0479: PUSH2 2842
li spill[309], 2842
# 0x047c: JUMP 
j L_047c
# 0x047d: JUMPDEST 
L_047d:
# 0x047e: PUSH2 809
li spill[310], 809
# 0x0481: JUMP 
j L_0481
# 0x0482: JUMPDEST 
L_0482:
# 0x0483: STOP 
nop
# 0x0484: JUMPDEST 
L_0484:
# 0x0485: PUSH2 281
li spill[311], 281
# 0x0488: PUSH2 1795
li spill[312], 1795
# 0x048b: JUMP 
j L_048b
# 0x048c: JUMPDEST 
L_048c:
# 0x048d: PUSH1 64
li spill[313], 64
# 0x048f: MLOAD 
lw spill[314], 0(spill[313])
# 0x0490: PUSH2 294
li spill[315], 294
# 0x0493: SWAP2 
# TODO: Implement SWAP2
# 0x0494: SWAP1 
# 0x0495: PUSH2 2885
li spill[316], 2885
# 0x0498: JUMP 
j L_0498
# 0x0499: JUMPDEST 
L_0499:
# 0x049a: PUSH1 64
li spill[317], 64
# 0x049c: MLOAD 
lw spill[318], 0(spill[317])
# 0x049d: DUP1 
mv spill[319], spill[318]
# 0x049e: SWAP2 
# TODO: Implement SWAP2
# 0x049f: SUB 
sub spill[320], spill[318], spill[319]
# 0x04a0: SWAP1 
# 0x04a1: RETURN 
# TODO: Implement RETURN
# 0x04a2: JUMPDEST 
L_04a2:
# 0x04a3: PUSH2 329
li spill[321], 329
# 0x04a6: PUSH1 4
li spill[322], 4
# 0x04a8: DUP1 
mv spill[323], spill[322]
# 0x04a9: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x04aa: SUB 
sub spill[324], spill[322], spill[323]
# 0x04ab: DUP2 
mv spill[325], spill[321]
# 0x04ac: ADD 
add spill[326], spill[324], spill[325]
# 0x04ad: SWAP1 
# 0x04ae: PUSH2 324
li spill[327], 324
# 0x04b1: SWAP2 
# TODO: Implement SWAP2
# 0x04b2: SWAP1 
# 0x04b3: PUSH2 2842
li spill[328], 2842
# 0x04b6: JUMP 
j L_04b6
# 0x04b7: JUMPDEST 
L_04b7:
# 0x04b8: PUSH2 1918
li spill[329], 1918
# 0x04bb: JUMP 
j L_04bb
# 0x04bc: JUMPDEST 
L_04bc:
# 0x04bd: STOP 
nop
# 0x04be: JUMPDEST 
L_04be:
# 0x04bf: PUSH2 357
li spill[330], 357
# 0x04c2: PUSH1 4
li spill[331], 4
# 0x04c4: DUP1 
mv spill[332], spill[331]
# 0x04c5: CALLDATASIZE 
# TODO: Implement CALLDATASIZE
# 0x04c6: SUB 
sub spill[333], spill[331], spill[332]
# 0x04c7: DUP2 
mv spill[334], spill[330]
# 0x04c8: ADD 
add spill[335], spill[333], spill[334]
# 0x04c9: SWAP1 
# 0x04ca: PUSH2 352
li spill[336], 352
# 0x04cd: SWAP2 
# TODO: Implement SWAP2
# 0x04ce: SWAP1 
# 0x04cf: PUSH2 2842
li spill[337], 2842
# 0x04d2: JUMP 
j L_04d2
# 0x04d3: JUMPDEST 
L_04d3:
# 0x04d4: PUSH2 2400
li spill[338], 2400
# 0x04d7: JUMP 
j L_04d7
# 0x04d8: JUMPDEST 
L_04d8:
# 0x04d9: PUSH1 64
li spill[339], 64
# 0x04db: MLOAD 
lw spill[340], 0(spill[339])
# 0x04dc: PUSH2 373
li spill[341], 373
# 0x04df: SWAP5 
# TODO: Implement SWAP5
# 0x04e0: SWAP4 
# TODO: Implement SWAP4
# 0x04e1: SWAP3 
# TODO: Implement SWAP3
# 0x04e2: SWAP2 
# TODO: Implement SWAP2
# 0x04e3: SWAP1 
# 0x04e4: PUSH2 2936
li spill[342], 2936
# 0x04e7: JUMP 
j L_04e7
# 0x04e8: JUMPDEST 
L_04e8:
# 0x04e9: PUSH1 64
li spill[343], 64
# 0x04eb: MLOAD 
lw spill[344], 0(spill[343])
# 0x04ec: DUP1 
mv spill[345], spill[344]
# 0x04ed: SWAP2 
# TODO: Implement SWAP2
# 0x04ee: SUB 
sub spill[346], spill[344], spill[345]
# 0x04ef: SWAP1 
# 0x04f0: RETURN 
# TODO: Implement RETURN
# 0x04f1: JUMPDEST 
L_04f1:
# 0x04f2: PUSH2 390
li spill[347], 390
# 0x04f5: PUSH2 2488
li spill[348], 2488
# 0x04f8: JUMP 
j L_04f8
# 0x04f9: JUMPDEST 
L_04f9:
# 0x04fa: PUSH1 64
li spill[349], 64
# 0x04fc: MLOAD 
lw spill[350], 0(spill[349])
# 0x04fd: PUSH2 403
li spill[351], 403
# 0x0500: SWAP2 
# TODO: Implement SWAP2
# 0x0501: SWAP1 
# 0x0502: PUSH2 3003
li spill[352], 3003
# 0x0505: JUMP 
j L_0505
# 0x0506: JUMPDEST 
L_0506:
# 0x0507: PUSH1 64
li spill[353], 64
# 0x0509: MLOAD 
lw spill[354], 0(spill[353])
# 0x050a: DUP1 
mv spill[355], spill[354]
# 0x050b: SWAP2 
# TODO: Implement SWAP2
# 0x050c: SUB 
sub spill[356], spill[354], spill[355]
# 0x050d: SWAP1 
# 0x050e: RETURN 
# TODO: Implement RETURN
# 0x050f: JUMPDEST 
L_050f:
# 0x0510: PUSH0 
li spill[357], None
# 0x0511: PUSH1 1
li spill[358], 1
# 0x0513: PUSH0 
li spill[359], None
# 0x0514: CALLER 
# TODO: Implement CALLER
# 0x0515: PUSH20 1461501637330902918203684832716283019655932542975
li spill[360], 1461501637330902918203684832716283019655932542975
# 0x052a: AND 
and spill[361], spill[359], spill[360]
# 0x052b: PUSH20 1461501637330902918203684832716283019655932542975
li spill[362], 1461501637330902918203684832716283019655932542975
# 0x0540: AND 
and spill[363], spill[361], spill[362]
# 0x0541: DUP2 
mv spill[364], spill[358]
# 0x0542: MSTORE 
sw spill[364], 0(spill[363])
# 0x0543: PUSH1 32
li spill[365], 32
# 0x0545: ADD 
add spill[366], spill[358], spill[365]
# 0x0546: SWAP1 
# 0x0547: DUP2 
mv spill[367], spill[366]
# 0x0548: MSTORE 
sw spill[367], 0(spill[357])
# 0x0549: PUSH1 32
li spill[368], 32
# 0x054b: ADD 
add spill[369], spill[366], spill[368]
# 0x054c: PUSH0 
li spill[370], None
# 0x054d: SHA3 
# TODO: Implement SHA3
# 0x054e: SWAP1 
# 0x054f: POP 
# 0x0550: PUSH0 
li spill[371], None
# 0x0551: DUP2 
mv spill[372], spill[370]
# 0x0552: PUSH0 
li spill[373], None
# 0x0553: ADD 
add spill[374], spill[372], spill[373]
# 0x0554: SLOAD 
# TODO: Implement SLOAD
# 0x0555: SUB 
sub spill[375], spill[371], spill[374]
# 0x0556: PUSH2 545
li spill[376], 545
# 0x0559: JUMPI 
beq spill[375], zero, L_0559
# 0x055a: PUSH1 64
li spill[377], 64
# 0x055c: MLOAD 
lw spill[378], 0(spill[377])
# 0x055d: DUP0 
mv spill[379], 0
# 0x055e: ADDMOD 
# TODO: Implement ADDMOD
# 0x055f: UNKNOWN_0xc3 
invalid
# 0x0560: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[380], 257110087081438444086713934774586016403552479005246853648220160
# 0x057b: STOP 
nop
# 0x057c: STOP 
nop
# 0x057d: STOP 
nop
# 0x057e: DUP2 
mv spill[381], spill[379]
# 0x057f: MSTORE 
sw spill[381], 0(spill[380])
# 0x0580: PUSH1 4
li spill[382], 4
# 0x0582: ADD 
add spill[383], spill[379], spill[382]
# 0x0583: PUSH2 536
li spill[384], 536
# 0x0586: SWAP1 
# 0x0587: PUSH2 3118
li spill[385], 3118
# 0x058a: JUMP 
j L_058a
# 0x058b: JUMPDEST 
L_058b:
# 0x058c: PUSH1 64
li spill[386], 64
# 0x058e: MLOAD 
lw spill[387], 0(spill[386])
# 0x058f: DUP1 
mv spill[388], spill[387]
# 0x0590: SWAP2 
# TODO: Implement SWAP2
# 0x0591: SUB 
sub spill[389], spill[387], spill[388]
# 0x0592: SWAP1 
# 0x0593: REVERT 
# TODO: Implement REVERT
# 0x0594: JUMPDEST 
L_0594:
# 0x0595: DUP1 
mv spill[390], spill[383]
# 0x0596: PUSH1 1
li spill[391], 1
# 0x0598: ADD 
add spill[392], spill[390], spill[391]
# 0x0599: PUSH0 
li spill[393], None
# 0x059a: SWAP1 
# 0x059b: SLOAD 
# TODO: Implement SLOAD
# 0x059c: SWAP1 
# 0x059d: PUSH2 256
li spill[394], 256
# 0x05a0: EXP 
# TODO: Implement EXP
# 0x05a1: SWAP1 
# 0x05a2: DIV 
divu spill[395], spill[394], spill[393]
# 0x05a3: PUSH1 255
li spill[396], 255
# 0x05a5: AND 
and spill[397], spill[395], spill[396]
# 0x05a6: ISZERO 
seqz spill[398], spill[397]
# 0x05a7: PUSH2 626
li spill[399], 626
# 0x05aa: JUMPI 
beq spill[398], zero, L_05aa
# 0x05ab: PUSH1 64
li spill[400], 64
# 0x05ad: MLOAD 
lw spill[401], 0(spill[400])
# 0x05ae: DUP0 
mv spill[402], 0
# 0x05af: ADDMOD 
# TODO: Implement ADDMOD
# 0x05b0: UNKNOWN_0xc3 
invalid
# 0x05b1: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[403], 257110087081438444086713934774586016403552479005246853648220160
# 0x05cc: STOP 
nop
# 0x05cd: STOP 
nop
# 0x05ce: STOP 
nop
# 0x05cf: DUP2 
mv spill[404], spill[402]
# 0x05d0: MSTORE 
sw spill[404], 0(spill[403])
# 0x05d1: PUSH1 4
li spill[405], 4
# 0x05d3: ADD 
add spill[406], spill[402], spill[405]
# 0x05d4: PUSH2 617
li spill[407], 617
# 0x05d7: SWAP1 
# 0x05d8: PUSH2 3222
li spill[408], 3222
# 0x05db: JUMP 
j L_05db
# 0x05dc: JUMPDEST 
L_05dc:
# 0x05dd: PUSH1 64
li spill[409], 64
# 0x05df: MLOAD 
lw spill[410], 0(spill[409])
# 0x05e0: DUP1 
mv spill[411], spill[410]
# 0x05e1: SWAP2 
# TODO: Implement SWAP2
# 0x05e2: SUB 
sub spill[412], spill[410], spill[411]
# 0x05e3: SWAP1 
# 0x05e4: REVERT 
# TODO: Implement REVERT
# 0x05e5: JUMPDEST 
L_05e5:
# 0x05e6: PUSH1 1
li spill[413], 1
# 0x05e8: DUP2 
mv spill[414], spill[406]
# 0x05e9: PUSH1 1
li spill[415], 1
# 0x05eb: ADD 
add spill[416], spill[414], spill[415]
# 0x05ec: PUSH0 
li spill[417], None
# 0x05ed: PUSH2 256
li spill[418], 256
# 0x05f0: EXP 
# TODO: Implement EXP
# 0x05f1: DUP2 
mv spill[419], spill[417]
# 0x05f2: SLOAD 
# TODO: Implement SLOAD
# 0x05f3: DUP2 
mv spill[420], spill[418]
# 0x05f4: PUSH1 255
li spill[421], 255
# 0x05f6: MUL 
mul spill[422], spill[420], spill[421]
# 0x05f7: NOT 
# TODO: Implement NOT
# 0x05f8: AND 
and spill[423], spill[419], spill[422]
# 0x05f9: SWAP1 
# 0x05fa: DUP4 
mv spill[424], spill[416]
# 0x05fb: ISZERO 
seqz spill[425], spill[424]
# 0x05fc: ISZERO 
seqz spill[426], spill[425]
# 0x05fd: MUL 
mul spill[427], spill[418], spill[426]
# 0x05fe: OR 
or spill[428], spill[423], spill[427]
# 0x05ff: SWAP1 
# 0x0600: SSTORE 
# TODO: Implement SSTORE
# 0x0601: POP 
# 0x0602: DUP2 
mv spill[429], spill[416]
# 0x0603: DUP2 
mv spill[430], spill[428]
# 0x0604: PUSH1 2
li spill[431], 2
# 0x0606: ADD 
add spill[432], spill[430], spill[431]
# 0x0607: DUP2 
mv spill[433], spill[429]
# 0x0608: SWAP1 
# 0x0609: SSTORE 
# TODO: Implement SSTORE
# 0x060a: POP 
# 0x060b: DUP1 
mv spill[434], spill[433]
# 0x060c: PUSH0 
li spill[435], None
# 0x060d: ADD 
add spill[436], spill[434], spill[435]
# 0x060e: SLOAD 
# TODO: Implement SLOAD
# 0x060f: PUSH1 2
li spill[437], 2
# 0x0611: DUP4 
mv spill[438], spill[429]
# 0x0612: DUP2 
mv spill[439], spill[437]
# 0x0613: SLOAD 
# TODO: Implement SLOAD
# 0x0614: DUP2 
mv spill[440], spill[438]
# 0x0615: LT 
sltu
# 0x0616: PUSH2 687
li spill[441], 687
# 0x0619: JUMPI 
beq spill[440], zero, L_0619
# 0x061a: PUSH2 686
li spill[442], 686
# 0x061d: PUSH2 3252
li spill[443], 3252
# 0x0620: JUMP 
j L_0620
# 0x0621: JUMPDEST 
L_0621:
# 0x0622: JUMPDEST 
L_0622:
# 0x0623: SWAP1 
# 0x0624: PUSH0 
li spill[444], None
# 0x0625: MSTORE 
sw spill[444], 0(spill[439])
# 0x0626: PUSH1 32
li spill[445], 32
# 0x0628: PUSH0 
li spill[446], None
# 0x0629: SHA3 
# TODO: Implement SHA3
# 0x062a: SWAP1 
# 0x062b: PUSH1 2
li spill[447], 2
# 0x062d: MUL 
mul spill[448], spill[445], spill[447]
# 0x062e: ADD 
add spill[449], spill[446], spill[448]
# 0x062f: PUSH1 1
li spill[450], 1
# 0x0631: ADD 
add spill[451], spill[449], spill[450]
# 0x0632: PUSH0 
li spill[452], None
# 0x0633: DUP3 
mv spill[453], spill[442]
# 0x0634: DUP3 
mv spill[454], spill[451]
# 0x0635: SLOAD 
# TODO: Implement SLOAD
# 0x0636: PUSH2 716
li spill[455], 716
# 0x0639: SWAP2 
# TODO: Implement SWAP2
# 0x063a: SWAP1 
# 0x063b: PUSH2 3342
li spill[456], 3342
# 0x063e: JUMP 
j L_063e
# 0x063f: JUMPDEST 
L_063f:
# 0x0640: SWAP3 
# TODO: Implement SWAP3
# 0x0641: POP 
# 0x0642: POP 
# 0x0643: DUP2 
mv spill[457], spill[452]
# 0x0644: SWAP1 
# 0x0645: SSTORE 
# TODO: Implement SSTORE
# 0x0646: POP 
# 0x0647: POP 
# 0x0648: POP 
# 0x0649: JUMP 
j L_0649
# 0x064a: JUMPDEST 
L_064a:
# 0x064b: PUSH1 2
li spill[458], 2
# 0x064d: DUP2 
mv spill[459], spill[442]
# 0x064e: DUP2 
mv spill[460], spill[458]
# 0x064f: SLOAD 
# TODO: Implement SLOAD
# 0x0650: DUP2 
mv spill[461], spill[459]
# 0x0651: LT 
sltu
# 0x0652: PUSH2 742
li spill[462], 742
# 0x0655: JUMPI 
beq spill[461], zero, L_0655
# 0x0656: PUSH0 
li spill[463], None
# 0x0657: DUP1 
mv spill[464], spill[463]
# 0x0658: REVERT 
# TODO: Implement REVERT
# 0x0659: JUMPDEST 
L_0659:
# 0x065a: SWAP1 
# 0x065b: PUSH0 
li spill[465], None
# 0x065c: MSTORE 
sw spill[465], 0(spill[463])
# 0x065d: PUSH1 32
li spill[466], 32
# 0x065f: PUSH0 
li spill[467], None
# 0x0660: SHA3 
# TODO: Implement SHA3
# 0x0661: SWAP1 
# 0x0662: PUSH1 2
li spill[468], 2
# 0x0664: MUL 
mul spill[469], spill[466], spill[468]
# 0x0665: ADD 
add spill[470], spill[467], spill[469]
# 0x0666: PUSH0 
li spill[471], None
# 0x0667: SWAP2 
# TODO: Implement SWAP2
# 0x0668: POP 
# 0x0669: SWAP1 
# 0x066a: POP 
# 0x066b: DUP1 
mv spill[472], spill[470]
# 0x066c: PUSH0 
li spill[473], None
# 0x066d: ADD 
add spill[474], spill[472], spill[473]
# 0x066e: SLOAD 
# TODO: Implement SLOAD
# 0x066f: SWAP1 
# 0x0670: DUP1 
mv spill[475], spill[470]
# 0x0671: PUSH1 1
li spill[476], 1
# 0x0673: ADD 
add spill[477], spill[475], spill[476]
# 0x0674: SLOAD 
# TODO: Implement SLOAD
# 0x0675: SWAP1 
# 0x0676: POP 
# 0x0677: DUP3 
mv spill[478], spill[460]
# 0x0678: JUMP 
j L_0678
# 0x0679: JUMPDEST 
L_0679:
# 0x067a: PUSH0 
li spill[479], None
# 0x067b: DUP1 
mv spill[480], spill[479]
# 0x067c: SLOAD 
# TODO: Implement SLOAD
# 0x067d: SWAP1 
# 0x067e: PUSH2 256
li spill[481], 256
# 0x0681: EXP 
# TODO: Implement EXP
# 0x0682: SWAP1 
# 0x0683: DIV 
divu spill[482], spill[481], spill[479]
# 0x0684: PUSH20 1461501637330902918203684832716283019655932542975
li spill[483], 1461501637330902918203684832716283019655932542975
# 0x0699: AND 
and spill[484], spill[482], spill[483]
# 0x069a: DUP2 
mv spill[485], spill[480]
# 0x069b: JUMP 
j L_069b
# 0x069c: JUMPDEST 
L_069c:
# 0x069d: PUSH0 
li spill[486], None
# 0x069e: PUSH1 1
li spill[487], 1
# 0x06a0: PUSH0 
li spill[488], None
# 0x06a1: CALLER 
# TODO: Implement CALLER
# 0x06a2: PUSH20 1461501637330902918203684832716283019655932542975
li spill[489], 1461501637330902918203684832716283019655932542975
# 0x06b7: AND 
and spill[490], spill[488], spill[489]
# 0x06b8: PUSH20 1461501637330902918203684832716283019655932542975
li spill[491], 1461501637330902918203684832716283019655932542975
# 0x06cd: AND 
and spill[492], spill[490], spill[491]
# 0x06ce: DUP2 
mv spill[493], spill[487]
# 0x06cf: MSTORE 
sw spill[493], 0(spill[492])
# 0x06d0: PUSH1 32
li spill[494], 32
# 0x06d2: ADD 
add spill[495], spill[487], spill[494]
# 0x06d3: SWAP1 
# 0x06d4: DUP2 
mv spill[496], spill[495]
# 0x06d5: MSTORE 
sw spill[496], 0(spill[486])
# 0x06d6: PUSH1 32
li spill[497], 32
# 0x06d8: ADD 
add spill[498], spill[495], spill[497]
# 0x06d9: PUSH0 
li spill[499], None
# 0x06da: SHA3 
# TODO: Implement SHA3
# 0x06db: SWAP1 
# 0x06dc: POP 
# 0x06dd: PUSH0 
li spill[500], None
# 0x06de: DUP2 
mv spill[501], spill[499]
# 0x06df: PUSH0 
li spill[502], None
# 0x06e0: ADD 
add spill[503], spill[501], spill[502]
# 0x06e1: SLOAD 
# TODO: Implement SLOAD
# 0x06e2: SUB 
sub spill[504], spill[500], spill[503]
# 0x06e3: PUSH2 942
li spill[505], 942
# 0x06e6: JUMPI 
beq spill[504], zero, L_06e6
# 0x06e7: PUSH1 64
li spill[506], 64
# 0x06e9: MLOAD 
lw spill[507], 0(spill[506])
# 0x06ea: DUP0 
mv spill[508], 0
# 0x06eb: ADDMOD 
# TODO: Implement ADDMOD
# 0x06ec: UNKNOWN_0xc3 
invalid
# 0x06ed: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[509], 257110087081438444086713934774586016403552479005246853648220160
# 0x0708: STOP 
nop
# 0x0709: STOP 
nop
# 0x070a: STOP 
nop
# 0x070b: DUP2 
mv spill[510], spill[508]
# 0x070c: MSTORE 
sw spill[510], 0(spill[509])
# 0x070d: PUSH1 4
li spill[511], 4
# 0x070f: ADD 
add spill[512], spill[508], spill[511]
# 0x0710: PUSH2 933
li spill[513], 933
# 0x0713: SWAP1 
# 0x0714: PUSH2 3467
li spill[514], 3467
# 0x0717: JUMP 
j L_0717
# 0x0718: JUMPDEST 
L_0718:
# 0x0719: PUSH1 64
li spill[515], 64
# 0x071b: MLOAD 
lw spill[516], 0(spill[515])
# 0x071c: DUP1 
mv spill[517], spill[516]
# 0x071d: SWAP2 
# TODO: Implement SWAP2
# 0x071e: SUB 
sub spill[518], spill[516], spill[517]
# 0x071f: SWAP1 
# 0x0720: REVERT 
# TODO: Implement REVERT
# 0x0721: JUMPDEST 
L_0721:
# 0x0722: DUP1 
mv spill[519], spill[512]
# 0x0723: PUSH1 1
li spill[520], 1
# 0x0725: ADD 
add spill[521], spill[519], spill[520]
# 0x0726: PUSH0 
li spill[522], None
# 0x0727: SWAP1 
# 0x0728: SLOAD 
# TODO: Implement SLOAD
# 0x0729: SWAP1 
# 0x072a: PUSH2 256
li spill[523], 256
# 0x072d: EXP 
# TODO: Implement EXP
# 0x072e: SWAP1 
# 0x072f: DIV 
divu spill[524], spill[523], spill[522]
# 0x0730: PUSH1 255
li spill[525], 255
# 0x0732: AND 
and spill[526], spill[524], spill[525]
# 0x0733: ISZERO 
seqz spill[527], spill[526]
# 0x0734: PUSH2 1023
li spill[528], 1023
# 0x0737: JUMPI 
beq spill[527], zero, L_0737
# 0x0738: PUSH1 64
li spill[529], 64
# 0x073a: MLOAD 
lw spill[530], 0(spill[529])
# 0x073b: DUP0 
mv spill[531], 0
# 0x073c: ADDMOD 
# TODO: Implement ADDMOD
# 0x073d: UNKNOWN_0xc3 
invalid
# 0x073e: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[532], 257110087081438444086713934774586016403552479005246853648220160
# 0x0759: STOP 
nop
# 0x075a: STOP 
nop
# 0x075b: STOP 
nop
# 0x075c: DUP2 
mv spill[533], spill[531]
# 0x075d: MSTORE 
sw spill[533], 0(spill[532])
# 0x075e: PUSH1 4
li spill[534], 4
# 0x0760: ADD 
add spill[535], spill[531], spill[534]
# 0x0761: PUSH2 1014
li spill[536], 1014
# 0x0764: SWAP1 
# 0x0765: PUSH2 3571
li spill[537], 3571
# 0x0768: JUMP 
j L_0768
# 0x0769: JUMPDEST 
L_0769:
# 0x076a: PUSH1 64
li spill[538], 64
# 0x076c: MLOAD 
lw spill[539], 0(spill[538])
# 0x076d: DUP1 
mv spill[540], spill[539]
# 0x076e: SWAP2 
# TODO: Implement SWAP2
# 0x076f: SUB 
sub spill[541], spill[539], spill[540]
# 0x0770: SWAP1 
# 0x0771: REVERT 
# TODO: Implement REVERT
# 0x0772: JUMPDEST 
L_0772:
# 0x0773: CALLER 
# TODO: Implement CALLER
# 0x0774: PUSH20 1461501637330902918203684832716283019655932542975
li spill[542], 1461501637330902918203684832716283019655932542975
# 0x0789: AND 
and spill[543], spill[535], spill[542]
# 0x078a: DUP3 
mv spill[544], spill[536]
# 0x078b: PUSH20 1461501637330902918203684832716283019655932542975
li spill[545], 1461501637330902918203684832716283019655932542975
# 0x07a0: AND 
and spill[546], spill[544], spill[545]
# 0x07a1: SUB 
sub spill[547], spill[543], spill[546]
# 0x07a2: PUSH2 1133
li spill[548], 1133
# 0x07a5: JUMPI 
beq spill[547], zero, L_07a5
# 0x07a6: PUSH1 64
li spill[549], 64
# 0x07a8: MLOAD 
lw spill[550], 0(spill[549])
# 0x07a9: DUP0 
mv spill[551], 0
# 0x07aa: ADDMOD 
# TODO: Implement ADDMOD
# 0x07ab: UNKNOWN_0xc3 
invalid
# 0x07ac: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[552], 257110087081438444086713934774586016403552479005246853648220160
# 0x07c7: STOP 
nop
# 0x07c8: STOP 
nop
# 0x07c9: STOP 
nop
# 0x07ca: DUP2 
mv spill[553], spill[551]
# 0x07cb: MSTORE 
sw spill[553], 0(spill[552])
# 0x07cc: PUSH1 4
li spill[554], 4
# 0x07ce: ADD 
add spill[555], spill[551], spill[554]
# 0x07cf: PUSH2 1124
li spill[556], 1124
# 0x07d2: SWAP1 
# 0x07d3: PUSH2 3675
li spill[557], 3675
# 0x07d6: JUMP 
j L_07d6
# 0x07d7: JUMPDEST 
L_07d7:
# 0x07d8: PUSH1 64
li spill[558], 64
# 0x07da: MLOAD 
lw spill[559], 0(spill[558])
# 0x07db: DUP1 
mv spill[560], spill[559]
# 0x07dc: SWAP2 
# TODO: Implement SWAP2
# 0x07dd: SUB 
sub spill[561], spill[559], spill[560]
# 0x07de: SWAP1 
# 0x07df: REVERT 
# TODO: Implement REVERT
# 0x07e0: JUMPDEST 
L_07e0:
# 0x07e1: JUMPDEST 
L_07e1:
# 0x07e2: PUSH0 
li spill[562], None
# 0x07e3: PUSH20 1461501637330902918203684832716283019655932542975
li spill[563], 1461501637330902918203684832716283019655932542975
# 0x07f8: AND 
and spill[564], spill[562], spill[563]
# 0x07f9: PUSH1 1
li spill[565], 1
# 0x07fb: PUSH0 
li spill[566], None
# 0x07fc: DUP5 
mv spill[567], spill[561]
# 0x07fd: PUSH20 1461501637330902918203684832716283019655932542975
li spill[568], 1461501637330902918203684832716283019655932542975
# 0x0812: AND 
and spill[569], spill[567], spill[568]
# 0x0813: PUSH20 1461501637330902918203684832716283019655932542975
li spill[570], 1461501637330902918203684832716283019655932542975
# 0x0828: AND 
and spill[571], spill[569], spill[570]
# 0x0829: DUP2 
mv spill[572], spill[566]
# 0x082a: MSTORE 
sw spill[572], 0(spill[571])
# 0x082b: PUSH1 32
li spill[573], 32
# 0x082d: ADD 
add spill[574], spill[566], spill[573]
# 0x082e: SWAP1 
# 0x082f: DUP2 
mv spill[575], spill[574]
# 0x0830: MSTORE 
sw spill[575], 0(spill[565])
# 0x0831: PUSH1 32
li spill[576], 32
# 0x0833: ADD 
add spill[577], spill[574], spill[576]
# 0x0834: PUSH0 
li spill[578], None
# 0x0835: SHA3 
# TODO: Implement SHA3
# 0x0836: PUSH1 1
li spill[579], 1
# 0x0838: ADD 
add spill[580], spill[578], spill[579]
# 0x0839: PUSH1 1
li spill[581], 1
# 0x083b: SWAP1 
# 0x083c: SLOAD 
# TODO: Implement SLOAD
# 0x083d: SWAP1 
# 0x083e: PUSH2 256
li spill[582], 256
# 0x0841: EXP 
# TODO: Implement EXP
# 0x0842: SWAP1 
# 0x0843: DIV 
divu spill[583], spill[582], spill[581]
# 0x0844: PUSH20 1461501637330902918203684832716283019655932542975
li spill[584], 1461501637330902918203684832716283019655932542975
# 0x0859: AND 
and spill[585], spill[583], spill[584]
# 0x085a: PUSH20 1461501637330902918203684832716283019655932542975
li spill[586], 1461501637330902918203684832716283019655932542975
# 0x086f: AND 
and spill[587], spill[585], spill[586]
# 0x0870: EQ 
# TODO: Implement EQ
# 0x0871: PUSH2 1495
li spill[588], 1495
# 0x0874: JUMPI 
beq spill[587], zero, L_0874
# 0x0875: PUSH1 1
li spill[589], 1
# 0x0877: PUSH0 
li spill[590], None
# 0x0878: DUP4 
mv spill[591], spill[577]
# 0x0879: PUSH20 1461501637330902918203684832716283019655932542975
li spill[592], 1461501637330902918203684832716283019655932542975
# 0x088e: AND 
and spill[593], spill[591], spill[592]
# 0x088f: PUSH20 1461501637330902918203684832716283019655932542975
li spill[594], 1461501637330902918203684832716283019655932542975
# 0x08a4: AND 
and spill[595], spill[593], spill[594]
# 0x08a5: DUP2 
mv spill[596], spill[590]
# 0x08a6: MSTORE 
sw spill[596], 0(spill[595])
# 0x08a7: PUSH1 32
li spill[597], 32
# 0x08a9: ADD 
add spill[598], spill[590], spill[597]
# 0x08aa: SWAP1 
# 0x08ab: DUP2 
mv spill[599], spill[598]
# 0x08ac: MSTORE 
sw spill[599], 0(spill[589])
# 0x08ad: PUSH1 32
li spill[600], 32
# 0x08af: ADD 
add spill[601], spill[598], spill[600]
# 0x08b0: PUSH0 
li spill[602], None
# 0x08b1: SHA3 
# TODO: Implement SHA3
# 0x08b2: PUSH1 1
li spill[603], 1
# 0x08b4: ADD 
add spill[604], spill[602], spill[603]
# 0x08b5: PUSH1 1
li spill[605], 1
# 0x08b7: SWAP1 
# 0x08b8: SLOAD 
# TODO: Implement SLOAD
# 0x08b9: SWAP1 
# 0x08ba: PUSH2 256
li spill[606], 256
# 0x08bd: EXP 
# TODO: Implement EXP
# 0x08be: SWAP1 
# 0x08bf: DIV 
divu spill[607], spill[606], spill[605]
# 0x08c0: PUSH20 1461501637330902918203684832716283019655932542975
li spill[608], 1461501637330902918203684832716283019655932542975
# 0x08d5: AND 
and spill[609], spill[607], spill[608]
# 0x08d6: SWAP2 
# TODO: Implement SWAP2
# 0x08d7: POP 
# 0x08d8: CALLER 
# TODO: Implement CALLER
# 0x08d9: PUSH20 1461501637330902918203684832716283019655932542975
li spill[610], 1461501637330902918203684832716283019655932542975
# 0x08ee: AND 
and spill[611], spill[604], spill[610]
# 0x08ef: DUP3 
mv spill[612], spill[580]
# 0x08f0: PUSH20 1461501637330902918203684832716283019655932542975
li spill[613], 1461501637330902918203684832716283019655932542975
# 0x0905: AND 
and spill[614], spill[612], spill[613]
# 0x0906: SUB 
sub spill[615], spill[611], spill[614]
# 0x0907: PUSH2 1490
li spill[616], 1490
# 0x090a: JUMPI 
beq spill[615], zero, L_090a
# 0x090b: PUSH1 64
li spill[617], 64
# 0x090d: MLOAD 
lw spill[618], 0(spill[617])
# 0x090e: DUP0 
mv spill[619], 0
# 0x090f: ADDMOD 
# TODO: Implement ADDMOD
# 0x0910: UNKNOWN_0xc3 
invalid
# 0x0911: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[620], 257110087081438444086713934774586016403552479005246853648220160
# 0x092c: STOP 
nop
# 0x092d: STOP 
nop
# 0x092e: STOP 
nop
# 0x092f: DUP2 
mv spill[621], spill[619]
# 0x0930: MSTORE 
sw spill[621], 0(spill[620])
# 0x0931: PUSH1 4
li spill[622], 4
# 0x0933: ADD 
add spill[623], spill[619], spill[622]
# 0x0934: PUSH2 1481
li spill[624], 1481
# 0x0937: SWAP1 
# 0x0938: PUSH2 3779
li spill[625], 3779
# 0x093b: JUMP 
j L_093b
# 0x093c: JUMPDEST 
L_093c:
# 0x093d: PUSH1 64
li spill[626], 64
# 0x093f: MLOAD 
lw spill[627], 0(spill[626])
# 0x0940: DUP1 
mv spill[628], spill[627]
# 0x0941: SWAP2 
# TODO: Implement SWAP2
# 0x0942: SUB 
sub spill[629], spill[627], spill[628]
# 0x0943: SWAP1 
# 0x0944: REVERT 
# TODO: Implement REVERT
# 0x0945: JUMPDEST 
L_0945:
# 0x0946: PUSH2 1134
li spill[630], 1134
# 0x0949: JUMP 
j L_0949
# 0x094a: JUMPDEST 
L_094a:
# 0x094b: PUSH0 
li spill[631], None
# 0x094c: PUSH1 1
li spill[632], 1
# 0x094e: PUSH0 
li spill[633], None
# 0x094f: DUP5 
mv spill[634], spill[629]
# 0x0950: PUSH20 1461501637330902918203684832716283019655932542975
li spill[635], 1461501637330902918203684832716283019655932542975
# 0x0965: AND 
and spill[636], spill[634], spill[635]
# 0x0966: PUSH20 1461501637330902918203684832716283019655932542975
li spill[637], 1461501637330902918203684832716283019655932542975
# 0x097b: AND 
and spill[638], spill[636], spill[637]
# 0x097c: DUP2 
mv spill[639], spill[633]
# 0x097d: MSTORE 
sw spill[639], 0(spill[638])
# 0x097e: PUSH1 32
li spill[640], 32
# 0x0980: ADD 
add spill[641], spill[633], spill[640]
# 0x0981: SWAP1 
# 0x0982: DUP2 
mv spill[642], spill[641]
# 0x0983: MSTORE 
sw spill[642], 0(spill[632])
# 0x0984: PUSH1 32
li spill[643], 32
# 0x0986: ADD 
add spill[644], spill[641], spill[643]
# 0x0987: PUSH0 
li spill[645], None
# 0x0988: SHA3 
# TODO: Implement SHA3
# 0x0989: SWAP1 
# 0x098a: POP 
# 0x098b: PUSH1 1
li spill[646], 1
# 0x098d: DUP2 
mv spill[647], spill[645]
# 0x098e: PUSH0 
li spill[648], None
# 0x098f: ADD 
add spill[649], spill[647], spill[648]
# 0x0990: SLOAD 
# TODO: Implement SLOAD
# 0x0991: LT 
sltu
# 0x0992: ISZERO 
seqz spill[650], spill[649]
# 0x0993: PUSH2 1575
li spill[651], 1575
# 0x0996: JUMPI 
beq spill[650], zero, L_0996
# 0x0997: PUSH0 
li spill[652], None
# 0x0998: DUP1 
mv spill[653], spill[652]
# 0x0999: REVERT 
# TODO: Implement REVERT
# 0x099a: JUMPDEST 
L_099a:
# 0x099b: PUSH1 1
li spill[654], 1
# 0x099d: DUP3 
mv spill[655], spill[652]
# 0x099e: PUSH1 1
li spill[656], 1
# 0x09a0: ADD 
add spill[657], spill[655], spill[656]
# 0x09a1: PUSH0 
li spill[658], None
# 0x09a2: PUSH2 256
li spill[659], 256
# 0x09a5: EXP 
# TODO: Implement EXP
# 0x09a6: DUP2 
mv spill[660], spill[658]
# 0x09a7: SLOAD 
# TODO: Implement SLOAD
# 0x09a8: DUP2 
mv spill[661], spill[659]
# 0x09a9: PUSH1 255
li spill[662], 255
# 0x09ab: MUL 
mul spill[663], spill[661], spill[662]
# 0x09ac: NOT 
# TODO: Implement NOT
# 0x09ad: AND 
and spill[664], spill[660], spill[663]
# 0x09ae: SWAP1 
# 0x09af: DUP4 
mv spill[665], spill[657]
# 0x09b0: ISZERO 
seqz spill[666], spill[665]
# 0x09b1: ISZERO 
seqz spill[667], spill[666]
# 0x09b2: MUL 
mul spill[668], spill[659], spill[667]
# 0x09b3: OR 
or spill[669], spill[664], spill[668]
# 0x09b4: SWAP1 
# 0x09b5: SSTORE 
# TODO: Implement SSTORE
# 0x09b6: POP 
# 0x09b7: DUP3 
mv spill[670], spill[654]
# 0x09b8: DUP3 
mv spill[671], spill[657]
# 0x09b9: PUSH1 1
li spill[672], 1
# 0x09bb: ADD 
add spill[673], spill[671], spill[672]
# 0x09bc: PUSH1 1
li spill[674], 1
# 0x09be: PUSH2 256
li spill[675], 256
# 0x09c1: EXP 
# TODO: Implement EXP
# 0x09c2: DUP2 
mv spill[676], spill[674]
# 0x09c3: SLOAD 
# TODO: Implement SLOAD
# 0x09c4: DUP2 
mv spill[677], spill[675]
# 0x09c5: PUSH20 1461501637330902918203684832716283019655932542975
li spill[678], 1461501637330902918203684832716283019655932542975
# 0x09da: MUL 
mul spill[679], spill[677], spill[678]
# 0x09db: NOT 
# TODO: Implement NOT
# 0x09dc: AND 
and spill[680], spill[676], spill[679]
# 0x09dd: SWAP1 
# 0x09de: DUP4 
mv spill[681], spill[673]
# 0x09df: PUSH20 1461501637330902918203684832716283019655932542975
li spill[682], 1461501637330902918203684832716283019655932542975
# 0x09f4: AND 
and spill[683], spill[681], spill[682]
# 0x09f5: MUL 
mul spill[684], spill[675], spill[683]
# 0x09f6: OR 
or spill[685], spill[680], spill[684]
# 0x09f7: SWAP1 
# 0x09f8: SSTORE 
# TODO: Implement SSTORE
# 0x09f9: POP 
# 0x09fa: DUP1 
mv spill[686], spill[685]
# 0x09fb: PUSH1 1
li spill[687], 1
# 0x09fd: ADD 
add spill[688], spill[686], spill[687]
# 0x09fe: PUSH0 
li spill[689], None
# 0x09ff: SWAP1 
# 0x0a00: SLOAD 
# TODO: Implement SLOAD
# 0x0a01: SWAP1 
# 0x0a02: PUSH2 256
li spill[690], 256
# 0x0a05: EXP 
# TODO: Implement EXP
# 0x0a06: SWAP1 
# 0x0a07: DIV 
divu spill[691], spill[690], spill[689]
# 0x0a08: PUSH1 255
li spill[692], 255
# 0x0a0a: AND 
and spill[693], spill[691], spill[692]
# 0x0a0b: ISZERO 
seqz spill[694], spill[693]
# 0x0a0c: PUSH2 1761
li spill[695], 1761
# 0x0a0f: JUMPI 
beq spill[694], zero, L_0a0f
# 0x0a10: DUP2 
mv spill[696], spill[685]
# 0x0a11: PUSH0 
li spill[697], None
# 0x0a12: ADD 
add spill[698], spill[696], spill[697]
# 0x0a13: SLOAD 
# TODO: Implement SLOAD
# 0x0a14: PUSH1 2
li spill[699], 2
# 0x0a16: DUP3 
mv spill[700], spill[688]
# 0x0a17: PUSH1 2
li spill[701], 2
# 0x0a19: ADD 
add spill[702], spill[700], spill[701]
# 0x0a1a: SLOAD 
# TODO: Implement SLOAD
# 0x0a1b: DUP2 
mv spill[703], spill[699]
# 0x0a1c: SLOAD 
# TODO: Implement SLOAD
# 0x0a1d: DUP2 
mv spill[704], spill[702]
# 0x0a1e: LT 
sltu
# 0x0a1f: PUSH2 1720
li spill[705], 1720
# 0x0a22: JUMPI 
beq spill[704], zero, L_0a22
# 0x0a23: PUSH2 1719
li spill[706], 1719
# 0x0a26: PUSH2 3252
li spill[707], 3252
# 0x0a29: JUMP 
j L_0a29
# 0x0a2a: JUMPDEST 
L_0a2a:
# 0x0a2b: JUMPDEST 
L_0a2b:
# 0x0a2c: SWAP1 
# 0x0a2d: PUSH0 
li spill[708], None
# 0x0a2e: MSTORE 
sw spill[708], 0(spill[703])
# 0x0a2f: PUSH1 32
li spill[709], 32
# 0x0a31: PUSH0 
li spill[710], None
# 0x0a32: SHA3 
# TODO: Implement SHA3
# 0x0a33: SWAP1 
# 0x0a34: PUSH1 2
li spill[711], 2
# 0x0a36: MUL 
mul spill[712], spill[709], spill[711]
# 0x0a37: ADD 
add spill[713], spill[710], spill[712]
# 0x0a38: PUSH1 1
li spill[714], 1
# 0x0a3a: ADD 
add spill[715], spill[713], spill[714]
# 0x0a3b: PUSH0 
li spill[716], None
# 0x0a3c: DUP3 
mv spill[717], spill[706]
# 0x0a3d: DUP3 
mv spill[718], spill[715]
# 0x0a3e: SLOAD 
# TODO: Implement SLOAD
# 0x0a3f: PUSH2 1749
li spill[719], 1749
# 0x0a42: SWAP2 
# TODO: Implement SWAP2
# 0x0a43: SWAP1 
# 0x0a44: PUSH2 3342
li spill[720], 3342
# 0x0a47: JUMP 
j L_0a47
# 0x0a48: JUMPDEST 
L_0a48:
# 0x0a49: SWAP3 
# TODO: Implement SWAP3
# 0x0a4a: POP 
# 0x0a4b: POP 
# 0x0a4c: DUP2 
mv spill[721], spill[716]
# 0x0a4d: SWAP1 
# 0x0a4e: SSTORE 
# TODO: Implement SSTORE
# 0x0a4f: POP 
# 0x0a50: PUSH2 1790
li spill[722], 1790
# 0x0a53: JUMP 
j L_0a53
# 0x0a54: JUMPDEST 
L_0a54:
# 0x0a55: DUP2 
mv spill[723], spill[716]
# 0x0a56: PUSH0 
li spill[724], None
# 0x0a57: ADD 
add spill[725], spill[723], spill[724]
# 0x0a58: SLOAD 
# TODO: Implement SLOAD
# 0x0a59: DUP2 
mv spill[726], spill[721]
# 0x0a5a: PUSH0 
li spill[727], None
# 0x0a5b: ADD 
add spill[728], spill[726], spill[727]
# 0x0a5c: PUSH0 
li spill[729], None
# 0x0a5d: DUP3 
mv spill[730], spill[725]
# 0x0a5e: DUP3 
mv spill[731], spill[728]
# 0x0a5f: SLOAD 
# TODO: Implement SLOAD
# 0x0a60: PUSH2 1782
li spill[732], 1782
# 0x0a63: SWAP2 
# TODO: Implement SWAP2
# 0x0a64: SWAP1 
# 0x0a65: PUSH2 3342
li spill[733], 3342
# 0x0a68: JUMP 
j L_0a68
# 0x0a69: JUMPDEST 
L_0a69:
# 0x0a6a: SWAP3 
# TODO: Implement SWAP3
# 0x0a6b: POP 
# 0x0a6c: POP 
# 0x0a6d: DUP2 
mv spill[734], spill[729]
# 0x0a6e: SWAP1 
# 0x0a6f: SSTORE 
# TODO: Implement SSTORE
# 0x0a70: POP 
# 0x0a71: JUMPDEST 
L_0a71:
# 0x0a72: POP 
# 0x0a73: POP 
# 0x0a74: POP 
# 0x0a75: JUMP 
j L_0a75
# 0x0a76: JUMPDEST 
L_0a76:
# 0x0a77: PUSH0 
li spill[735], None
# 0x0a78: DUP1 
mv spill[736], spill[735]
# 0x0a79: PUSH0 
li spill[737], None
# 0x0a7a: SWAP1 
# 0x0a7b: POP 
# 0x0a7c: PUSH0 
li spill[738], None
# 0x0a7d: JUMPDEST 
L_0a7d:
# 0x0a7e: PUSH1 2
li spill[739], 2
# 0x0a80: DUP1 
mv spill[740], spill[739]
# 0x0a81: SLOAD 
# TODO: Implement SLOAD
# 0x0a82: SWAP1 
# 0x0a83: POP 
# 0x0a84: DUP2 
mv spill[741], spill[738]
# 0x0a85: LT 
sltu
# 0x0a86: ISZERO 
seqz spill[742], spill[741]
# 0x0a87: PUSH2 1913
li spill[743], 1913
# 0x0a8a: JUMPI 
beq spill[742], zero, L_0a8a
# 0x0a8b: DUP2 
mv spill[744], spill[738]
# 0x0a8c: PUSH1 2
li spill[745], 2
# 0x0a8e: DUP3 
mv spill[746], spill[740]
# 0x0a8f: DUP2 
mv spill[747], spill[745]
# 0x0a90: SLOAD 
# TODO: Implement SLOAD
# 0x0a91: DUP2 
mv spill[748], spill[746]
# 0x0a92: LT 
sltu
# 0x0a93: PUSH2 1836
li spill[749], 1836
# 0x0a96: JUMPI 
beq spill[748], zero, L_0a96
# 0x0a97: PUSH2 1835
li spill[750], 1835
# 0x0a9a: PUSH2 3252
li spill[751], 3252
# 0x0a9d: JUMP 
j L_0a9d
# 0x0a9e: JUMPDEST 
L_0a9e:
# 0x0a9f: JUMPDEST 
L_0a9f:
# 0x0aa0: SWAP1 
# 0x0aa1: PUSH0 
li spill[752], None
# 0x0aa2: MSTORE 
sw spill[752], 0(spill[747])
# 0x0aa3: PUSH1 32
li spill[753], 32
# 0x0aa5: PUSH0 
li spill[754], None
# 0x0aa6: SHA3 
# TODO: Implement SHA3
# 0x0aa7: SWAP1 
# 0x0aa8: PUSH1 2
li spill[755], 2
# 0x0aaa: MUL 
mul spill[756], spill[753], spill[755]
# 0x0aab: ADD 
add spill[757], spill[754], spill[756]
# 0x0aac: PUSH1 1
li spill[758], 1
# 0x0aae: ADD 
add spill[759], spill[757], spill[758]
# 0x0aaf: SLOAD 
# TODO: Implement SLOAD
# 0x0ab0: GT 
sgtu
# 0x0ab1: ISZERO 
seqz spill[760], spill[759]
# 0x0ab2: PUSH2 1900
li spill[761], 1900
# 0x0ab5: JUMPI 
beq spill[760], zero, L_0ab5
# 0x0ab6: PUSH1 2
li spill[762], 2
# 0x0ab8: DUP2 
mv spill[763], spill[750]
# 0x0ab9: DUP2 
mv spill[764], spill[762]
# 0x0aba: SLOAD 
# TODO: Implement SLOAD
# 0x0abb: DUP2 
mv spill[765], spill[763]
# 0x0abc: LT 
sltu
# 0x0abd: PUSH2 1878
li spill[766], 1878
# 0x0ac0: JUMPI 
beq spill[765], zero, L_0ac0
# 0x0ac1: PUSH2 1877
li spill[767], 1877
# 0x0ac4: PUSH2 3252
li spill[768], 3252
# 0x0ac7: JUMP 
j L_0ac7
# 0x0ac8: JUMPDEST 
L_0ac8:
# 0x0ac9: JUMPDEST 
L_0ac9:
# 0x0aca: SWAP1 
# 0x0acb: PUSH0 
li spill[769], None
# 0x0acc: MSTORE 
sw spill[769], 0(spill[764])
# 0x0acd: PUSH1 32
li spill[770], 32
# 0x0acf: PUSH0 
li spill[771], None
# 0x0ad0: SHA3 
# TODO: Implement SHA3
# 0x0ad1: SWAP1 
# 0x0ad2: PUSH1 2
li spill[772], 2
# 0x0ad4: MUL 
mul spill[773], spill[770], spill[772]
# 0x0ad5: ADD 
add spill[774], spill[771], spill[773]
# 0x0ad6: PUSH1 1
li spill[775], 1
# 0x0ad8: ADD 
add spill[776], spill[774], spill[775]
# 0x0ad9: SLOAD 
# TODO: Implement SLOAD
# 0x0ada: SWAP2 
# TODO: Implement SWAP2
# 0x0adb: POP 
# 0x0adc: DUP1 
mv spill[777], spill[767]
# 0x0add: SWAP3 
# TODO: Implement SWAP3
# 0x0ade: POP 
# 0x0adf: JUMPDEST 
L_0adf:
# 0x0ae0: DUP1 
mv spill[778], spill[767]
# 0x0ae1: DUP1 
mv spill[779], spill[778]
# 0x0ae2: PUSH1 1
li spill[780], 1
# 0x0ae4: ADD 
add spill[781], spill[779], spill[780]
# 0x0ae5: SWAP2 
# TODO: Implement SWAP2
# 0x0ae6: POP 
# 0x0ae7: POP 
# 0x0ae8: PUSH2 1802
li spill[782], 1802
# 0x0aeb: JUMP 
j L_0aeb
# 0x0aec: JUMPDEST 
L_0aec:
# 0x0aed: POP 
# 0x0aee: POP 
# 0x0aef: SWAP1 
# 0x0af0: JUMP 
j L_0af0
# 0x0af1: JUMPDEST 
L_0af1:
# 0x0af2: PUSH0 
li spill[783], None
# 0x0af3: DUP1 
mv spill[784], spill[783]
# 0x0af4: SLOAD 
# TODO: Implement SLOAD
# 0x0af5: SWAP1 
# 0x0af6: PUSH2 256
li spill[785], 256
# 0x0af9: EXP 
# TODO: Implement EXP
# 0x0afa: SWAP1 
# 0x0afb: DIV 
divu spill[786], spill[785], spill[783]
# 0x0afc: PUSH20 1461501637330902918203684832716283019655932542975
li spill[787], 1461501637330902918203684832716283019655932542975
# 0x0b11: AND 
and spill[788], spill[786], spill[787]
# 0x0b12: PUSH20 1461501637330902918203684832716283019655932542975
li spill[789], 1461501637330902918203684832716283019655932542975
# 0x0b27: AND 
and spill[790], spill[788], spill[789]
# 0x0b28: CALLER 
# TODO: Implement CALLER
# 0x0b29: PUSH20 1461501637330902918203684832716283019655932542975
li spill[791], 1461501637330902918203684832716283019655932542975
# 0x0b3e: AND 
and spill[792], spill[790], spill[791]
# 0x0b3f: EQ 
# TODO: Implement EQ
# 0x0b40: PUSH2 2059
li spill[793], 2059
# 0x0b43: JUMPI 
beq spill[792], zero, L_0b43
# 0x0b44: PUSH1 64
li spill[794], 64
# 0x0b46: MLOAD 
lw spill[795], 0(spill[794])
# 0x0b47: DUP0 
mv spill[796], 0
# 0x0b48: ADDMOD 
# TODO: Implement ADDMOD
# 0x0b49: UNKNOWN_0xc3 
invalid
# 0x0b4a: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[797], 257110087081438444086713934774586016403552479005246853648220160
# 0x0b65: STOP 
nop
# 0x0b66: STOP 
nop
# 0x0b67: STOP 
nop
# 0x0b68: DUP2 
mv spill[798], spill[796]
# 0x0b69: MSTORE 
sw spill[798], 0(spill[797])
# 0x0b6a: PUSH1 4
li spill[799], 4
# 0x0b6c: ADD 
add spill[800], spill[796], spill[799]
# 0x0b6d: PUSH2 2050
li spill[801], 2050
# 0x0b70: SWAP1 
# 0x0b71: PUSH2 3921
li spill[802], 3921
# 0x0b74: JUMP 
j L_0b74
# 0x0b75: JUMPDEST 
L_0b75:
# 0x0b76: PUSH1 64
li spill[803], 64
# 0x0b78: MLOAD 
lw spill[804], 0(spill[803])
# 0x0b79: DUP1 
mv spill[805], spill[804]
# 0x0b7a: SWAP2 
# TODO: Implement SWAP2
# 0x0b7b: SUB 
sub spill[806], spill[804], spill[805]
# 0x0b7c: SWAP1 
# 0x0b7d: REVERT 
# TODO: Implement REVERT
# 0x0b7e: JUMPDEST 
L_0b7e:
# 0x0b7f: PUSH1 1
li spill[807], 1
# 0x0b81: PUSH0 
li spill[808], None
# 0x0b82: DUP3 
mv spill[809], spill[800]
# 0x0b83: PUSH20 1461501637330902918203684832716283019655932542975
li spill[810], 1461501637330902918203684832716283019655932542975
# 0x0b98: AND 
and spill[811], spill[809], spill[810]
# 0x0b99: PUSH20 1461501637330902918203684832716283019655932542975
li spill[812], 1461501637330902918203684832716283019655932542975
# 0x0bae: AND 
and spill[813], spill[811], spill[812]
# 0x0baf: DUP2 
mv spill[814], spill[808]
# 0x0bb0: MSTORE 
sw spill[814], 0(spill[813])
# 0x0bb1: PUSH1 32
li spill[815], 32
# 0x0bb3: ADD 
add spill[816], spill[808], spill[815]
# 0x0bb4: SWAP1 
# 0x0bb5: DUP2 
mv spill[817], spill[816]
# 0x0bb6: MSTORE 
sw spill[817], 0(spill[807])
# 0x0bb7: PUSH1 32
li spill[818], 32
# 0x0bb9: ADD 
add spill[819], spill[816], spill[818]
# 0x0bba: PUSH0 
li spill[820], None
# 0x0bbb: SHA3 
# TODO: Implement SHA3
# 0x0bbc: PUSH1 1
li spill[821], 1
# 0x0bbe: ADD 
add spill[822], spill[820], spill[821]
# 0x0bbf: PUSH0 
li spill[823], None
# 0x0bc0: SWAP1 
# 0x0bc1: SLOAD 
# TODO: Implement SLOAD
# 0x0bc2: SWAP1 
# 0x0bc3: PUSH2 256
li spill[824], 256
# 0x0bc6: EXP 
# TODO: Implement EXP
# 0x0bc7: SWAP1 
# 0x0bc8: DIV 
divu spill[825], spill[824], spill[823]
# 0x0bc9: PUSH1 255
li spill[826], 255
# 0x0bcb: AND 
and spill[827], spill[825], spill[826]
# 0x0bcc: ISZERO 
seqz spill[828], spill[827]
# 0x0bcd: PUSH2 2200
li spill[829], 2200
# 0x0bd0: JUMPI 
beq spill[828], zero, L_0bd0
# 0x0bd1: PUSH1 64
li spill[830], 64
# 0x0bd3: MLOAD 
lw spill[831], 0(spill[830])
# 0x0bd4: DUP0 
mv spill[832], 0
# 0x0bd5: ADDMOD 
# TODO: Implement ADDMOD
# 0x0bd6: UNKNOWN_0xc3 
invalid
# 0x0bd7: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[833], 257110087081438444086713934774586016403552479005246853648220160
# 0x0bf2: STOP 
nop
# 0x0bf3: STOP 
nop
# 0x0bf4: STOP 
nop
# 0x0bf5: DUP2 
mv spill[834], spill[832]
# 0x0bf6: MSTORE 
sw spill[834], 0(spill[833])
# 0x0bf7: PUSH1 4
li spill[835], 4
# 0x0bf9: ADD 
add spill[836], spill[832], spill[835]
# 0x0bfa: PUSH2 2191
li spill[837], 2191
# 0x0bfd: SWAP1 
# 0x0bfe: PUSH2 4025
li spill[838], 4025
# 0x0c01: JUMP 
j L_0c01
# 0x0c02: JUMPDEST 
L_0c02:
# 0x0c03: PUSH1 64
li spill[839], 64
# 0x0c05: MLOAD 
lw spill[840], 0(spill[839])
# 0x0c06: DUP1 
mv spill[841], spill[840]
# 0x0c07: SWAP2 
# TODO: Implement SWAP2
# 0x0c08: SUB 
sub spill[842], spill[840], spill[841]
# 0x0c09: SWAP1 
# 0x0c0a: REVERT 
# TODO: Implement REVERT
# 0x0c0b: JUMPDEST 
L_0c0b:
# 0x0c0c: PUSH0 
li spill[843], None
# 0x0c0d: PUSH1 1
li spill[844], 1
# 0x0c0f: PUSH0 
li spill[845], None
# 0x0c10: DUP4 
mv spill[846], spill[836]
# 0x0c11: PUSH20 1461501637330902918203684832716283019655932542975
li spill[847], 1461501637330902918203684832716283019655932542975
# 0x0c26: AND 
and spill[848], spill[846], spill[847]
# 0x0c27: PUSH20 1461501637330902918203684832716283019655932542975
li spill[849], 1461501637330902918203684832716283019655932542975
# 0x0c3c: AND 
and spill[850], spill[848], spill[849]
# 0x0c3d: DUP2 
mv spill[851], spill[845]
# 0x0c3e: MSTORE 
sw spill[851], 0(spill[850])
# 0x0c3f: PUSH1 32
li spill[852], 32
# 0x0c41: ADD 
add spill[853], spill[845], spill[852]
# 0x0c42: SWAP1 
# 0x0c43: DUP2 
mv spill[854], spill[853]
# 0x0c44: MSTORE 
sw spill[854], 0(spill[844])
# 0x0c45: PUSH1 32
li spill[855], 32
# 0x0c47: ADD 
add spill[856], spill[853], spill[855]
# 0x0c48: PUSH0 
li spill[857], None
# 0x0c49: SHA3 
# TODO: Implement SHA3
# 0x0c4a: PUSH0 
li spill[858], None
# 0x0c4b: ADD 
add spill[859], spill[857], spill[858]
# 0x0c4c: SLOAD 
# TODO: Implement SLOAD
# 0x0c4d: EQ 
# TODO: Implement EQ
# 0x0c4e: PUSH2 2329
li spill[860], 2329
# 0x0c51: JUMPI 
beq spill[859], zero, L_0c51
# 0x0c52: PUSH1 64
li spill[861], 64
# 0x0c54: MLOAD 
lw spill[862], 0(spill[861])
# 0x0c55: DUP0 
mv spill[863], 0
# 0x0c56: ADDMOD 
# TODO: Implement ADDMOD
# 0x0c57: UNKNOWN_0xc3 
invalid
# 0x0c58: PUSH26 257110087081438444086713934774586016403552479005246853648220160
li spill[864], 257110087081438444086713934774586016403552479005246853648220160
# 0x0c73: STOP 
nop
# 0x0c74: STOP 
nop
# 0x0c75: STOP 
nop
# 0x0c76: DUP2 
mv spill[865], spill[863]
# 0x0c77: MSTORE 
sw spill[865], 0(spill[864])
# 0x0c78: PUSH1 4
li spill[866], 4
# 0x0c7a: ADD 
add spill[867], spill[863], spill[866]
# 0x0c7b: PUSH2 2320
li spill[868], 2320
# 0x0c7e: SWAP1 
# 0x0c7f: PUSH2 4167
li spill[869], 4167
# 0x0c82: JUMP 
j L_0c82
# 0x0c83: JUMPDEST 
L_0c83:
# 0x0c84: PUSH1 64
li spill[870], 64
# 0x0c86: MLOAD 
lw spill[871], 0(spill[870])
# 0x0c87: DUP1 
mv spill[872], spill[871]
# 0x0c88: SWAP2 
# TODO: Implement SWAP2
# 0x0c89: SUB 
sub spill[873], spill[871], spill[872]
# 0x0c8a: SWAP1 
# 0x0c8b: REVERT 
# TODO: Implement REVERT
# 0x0c8c: JUMPDEST 
L_0c8c:
# 0x0c8d: PUSH1 1
li spill[874], 1
# 0x0c8f: DUP1 
mv spill[875], spill[874]
# 0x0c90: PUSH0 
li spill[876], None
# 0x0c91: DUP4 
mv spill[877], spill[867]
# 0x0c92: PUSH20 1461501637330902918203684832716283019655932542975
li spill[878], 1461501637330902918203684832716283019655932542975
# 0x0ca7: AND 
and spill[879], spill[877], spill[878]
# 0x0ca8: PUSH20 1461501637330902918203684832716283019655932542975
li spill[880], 1461501637330902918203684832716283019655932542975
# 0x0cbd: AND 
and spill[881], spill[879], spill[880]
# 0x0cbe: DUP2 
mv spill[882], spill[876]
# 0x0cbf: MSTORE 
sw spill[882], 0(spill[881])
# 0x0cc0: PUSH1 32
li spill[883], 32
# 0x0cc2: ADD 
add spill[884], spill[876], spill[883]
# 0x0cc3: SWAP1 
# 0x0cc4: DUP2 
mv spill[885], spill[884]
# 0x0cc5: MSTORE 
sw spill[885], 0(spill[875])
# 0x0cc6: PUSH1 32
li spill[886], 32
# 0x0cc8: ADD 
add spill[887], spill[884], spill[886]
# 0x0cc9: PUSH0 
li spill[888], None
# 0x0cca: SHA3 
# TODO: Implement SHA3
# 0x0ccb: PUSH0 
li spill[889], None
# 0x0ccc: ADD 
add spill[890], spill[888], spill[889]
# 0x0ccd: DUP2 
mv spill[891], spill[887]
# 0x0cce: SWAP1 
# 0x0ccf: SSTORE 
# TODO: Implement SSTORE
# 0x0cd0: POP 
# 0x0cd1: POP 
# 0x0cd2: JUMP 
j L_0cd2
# 0x0cd3: JUMPDEST 
L_0cd3:
# 0x0cd4: PUSH1 1
li spill[892], 1
# 0x0cd6: PUSH1 32
li spill[893], 32
# 0x0cd8: MSTORE 
sw spill[893], 0(spill[892])
# 0x0cd9: DUP1 
mv spill[894], spill[874]
# 0x0cda: PUSH0 
li spill[895], None
# 0x0cdb: MSTORE 
sw spill[895], 0(spill[894])
# 0x0cdc: PUSH1 64
li spill[896], 64
# 0x0cde: PUSH0 
li spill[897], None
# 0x0cdf: SHA3 
# TODO: Implement SHA3
# 0x0ce0: PUSH0 
li spill[898], None
# 0x0ce1: SWAP2 
# TODO: Implement SWAP2
# 0x0ce2: POP 
# 0x0ce3: SWAP1 
# 0x0ce4: POP 
# 0x0ce5: DUP1 
mv spill[899], spill[897]
# 0x0ce6: PUSH0 
li spill[900], None
# 0x0ce7: ADD 
add spill[901], spill[899], spill[900]
# 0x0ce8: SLOAD 
# TODO: Implement SLOAD
# 0x0ce9: SWAP1 
# 0x0cea: DUP1 
mv spill[902], spill[897]
# 0x0ceb: PUSH1 1
li spill[903], 1
# 0x0ced: ADD 
add spill[904], spill[902], spill[903]
# 0x0cee: PUSH0 
li spill[905], None
# 0x0cef: SWAP1 
# 0x0cf0: SLOAD 
# TODO: Implement SLOAD
# 0x0cf1: SWAP1 
# 0x0cf2: PUSH2 256
li spill[906], 256
# 0x0cf5: EXP 
# TODO: Implement EXP
# 0x0cf6: SWAP1 
# 0x0cf7: DIV 
divu spill[907], spill[906], spill[905]
# 0x0cf8: PUSH1 255
li spill[908], 255
# 0x0cfa: AND 
and spill[909], spill[907], spill[908]
# 0x0cfb: SWAP1 
# 0x0cfc: DUP1 
mv spill[910], spill[904]
# 0x0cfd: PUSH1 1
li spill[911], 1
# 0x0cff: ADD 
add spill[912], spill[910], spill[911]
# 0x0d00: PUSH1 1
li spill[913], 1
# 0x0d02: SWAP1 
# 0x0d03: SLOAD 
# TODO: Implement SLOAD
# 0x0d04: SWAP1 
# 0x0d05: PUSH2 256
li spill[914], 256
# 0x0d08: EXP 
# TODO: Implement EXP
# 0x0d09: SWAP1 
# 0x0d0a: DIV 
divu spill[915], spill[914], spill[913]
# 0x0d0b: PUSH20 1461501637330902918203684832716283019655932542975
li spill[916], 1461501637330902918203684832716283019655932542975
# 0x0d20: AND 
and spill[917], spill[915], spill[916]
# 0x0d21: SWAP1 
# 0x0d22: DUP1 
mv spill[918], spill[912]
# 0x0d23: PUSH1 2
li spill[919], 2
# 0x0d25: ADD 
add spill[920], spill[918], spill[919]
# 0x0d26: SLOAD 
# TODO: Implement SLOAD
# 0x0d27: SWAP1 
# 0x0d28: POP 
# 0x0d29: DUP5 
mv spill[921], spill[897]
# 0x0d2a: JUMP 
j L_0d2a
# 0x0d2b: JUMPDEST 
L_0d2b:
# 0x0d2c: PUSH0 
li spill[922], None
# 0x0d2d: PUSH1 2
li spill[923], 2
# 0x0d2f: PUSH2 2499
li spill[924], 2499
# 0x0d32: PUSH2 1795
li spill[925], 1795
# 0x0d35: JUMP 
j L_0d35
# 0x0d36: JUMPDEST 
L_0d36:
# 0x0d37: DUP2 
mv spill[926], spill[923]
# 0x0d38: SLOAD 
# TODO: Implement SLOAD
# 0x0d39: DUP2 
mv spill[927], spill[924]
# 0x0d3a: LT 
sltu
# 0x0d3b: PUSH2 2516
li spill[928], 2516
# 0x0d3e: JUMPI 
beq spill[927], zero, L_0d3e
# 0x0d3f: PUSH2 2515
li spill[929], 2515
# 0x0d42: PUSH2 3252
li spill[930], 3252
# 0x0d45: JUMP 
j L_0d45
# 0x0d46: JUMPDEST 
L_0d46:
# 0x0d47: JUMPDEST 
L_0d47:
# 0x0d48: SWAP1 
# 0x0d49: PUSH0 
li spill[931], None
# 0x0d4a: MSTORE 
sw spill[931], 0(spill[926])
# 0x0d4b: PUSH1 32
li spill[932], 32
# 0x0d4d: PUSH0 
li spill[933], None
# 0x0d4e: SHA3 
# TODO: Implement SHA3
# 0x0d4f: SWAP1 
# 0x0d50: PUSH1 2
li spill[934], 2
# 0x0d52: MUL 
mul spill[935], spill[932], spill[934]
# 0x0d53: ADD 
add spill[936], spill[933], spill[935]
# 0x0d54: PUSH0 
li spill[937], None
# 0x0d55: ADD 
add spill[938], spill[936], spill[937]
# 0x0d56: SLOAD 
# TODO: Implement SLOAD
# 0x0d57: SWAP1 
# 0x0d58: POP 
# 0x0d59: SWAP1 
# 0x0d5a: JUMP 
j L_0d5a
# 0x0d5b: JUMPDEST 
L_0d5b:
# 0x0d5c: PUSH0 
li spill[939], None
# 0x0d5d: DUP1 
mv spill[940], spill[939]
# 0x0d5e: REVERT 
# TODO: Implement REVERT
# 0x0d5f: JUMPDEST 
L_0d5f:
# 0x0d60: PUSH0 
li spill[941], None
# 0x0d61: DUP2 
mv spill[942], spill[940]
# 0x0d62: SWAP1 
# 0x0d63: POP 
# 0x0d64: SWAP2 
# TODO: Implement SWAP2
# 0x0d65: SWAP1 
# 0x0d66: POP 
# 0x0d67: JUMP 
j L_0d67
# 0x0d68: JUMPDEST 
L_0d68:
# 0x0d69: PUSH2 2558
li spill[943], 2558
# 0x0d6c: DUP2 
mv spill[944], spill[939]
# 0x0d6d: PUSH2 2540
li spill[945], 2540
# 0x0d70: JUMP 
j L_0d70
# 0x0d71: JUMPDEST 
L_0d71:
# 0x0d72: DUP2 
mv spill[946], spill[943]
# 0x0d73: EQ 
# TODO: Implement EQ
# 0x0d74: PUSH2 2568
li spill[947], 2568
# 0x0d77: JUMPI 
beq spill[946], zero, L_0d77
# 0x0d78: PUSH0 
li spill[948], None
# 0x0d79: DUP1 
mv spill[949], spill[948]
# 0x0d7a: REVERT 
# TODO: Implement REVERT
# 0x0d7b: JUMPDEST 
L_0d7b:
# 0x0d7c: POP 
# 0x0d7d: JUMP 
j L_0d7d
# 0x0d7e: JUMPDEST 
L_0d7e:
# 0x0d7f: PUSH0 
li spill[950], None
# 0x0d80: DUP2 
mv spill[951], spill[944]
# 0x0d81: CALLDATALOAD 
# TODO: Implement CALLDATALOAD
# 0x0d82: SWAP1 
# 0x0d83: POP 
# 0x0d84: PUSH2 2585
li spill[952], 2585
# 0x0d87: DUP2 
mv spill[953], spill[951]
# 0x0d88: PUSH2 2549
li spill[954], 2549
# 0x0d8b: JUMP 
j L_0d8b
# 0x0d8c: JUMPDEST 
L_0d8c:
# 0x0d8d: SWAP3 
# TODO: Implement SWAP3
# 0x0d8e: SWAP2 
# TODO: Implement SWAP2
# 0x0d8f: POP 
# 0x0d90: POP 
# 0x0d91: JUMP 
j L_0d91
# 0x0d92: JUMPDEST 
L_0d92:
# 0x0d93: PUSH0 
li spill[955], None
# 0x0d94: PUSH1 32
li spill[956], 32
# 0x0d96: DUP3 
mv spill[957], spill[944]
# 0x0d97: DUP5 
mv spill[958], spill[943]
# 0x0d98: SUB 
sub spill[959], spill[957], spill[958]
# 0x0d99: SLT 
slt
# 0x0d9a: ISZERO 
seqz spill[960], spill[959]
# 0x0d9b: PUSH2 2612
li spill[961], 2612
# 0x0d9e: JUMPI 
beq spill[960], zero, L_0d9e
# 0x0d9f: PUSH2 2611
li spill[962], 2611
# 0x0da2: PUSH2 2536
li spill[963], 2536
# 0x0da5: JUMP 
j L_0da5
# 0x0da6: JUMPDEST 
L_0da6:
# 0x0da7: JUMPDEST 
L_0da7:
# 0x0da8: PUSH0 
li spill[964], None
# 0x0da9: PUSH2 2625
li spill[965], 2625
# 0x0dac: DUP5 
mv spill[966], spill[955]
# 0x0dad: DUP3 
mv spill[967], spill[964]
# 0x0dae: DUP6 
mv spill[968], spill[956]
# 0x0daf: ADD 
add spill[969], spill[967], spill[968]
# 0x0db0: PUSH2 2571
li spill[970], 2571
# 0x0db3: JUMP 
j L_0db3
# 0x0db4: JUMPDEST 
L_0db4:
# 0x0db5: SWAP2 
# TODO: Implement SWAP2
# 0x0db6: POP 
# 0x0db7: POP 
# 0x0db8: SWAP3 
# TODO: Implement SWAP3
# 0x0db9: SWAP2 
# TODO: Implement SWAP2
# 0x0dba: POP 
# 0x0dbb: POP 
# 0x0dbc: JUMP 
j L_0dbc
# 0x0dbd: JUMPDEST 
L_0dbd:
# 0x0dbe: PUSH0 
li spill[971], None
# 0x0dbf: DUP2 
mv spill[972], spill[956]
# 0x0dc0: SWAP1 
# 0x0dc1: POP 
# 0x0dc2: SWAP2 
# TODO: Implement SWAP2
# 0x0dc3: SWAP1 
# 0x0dc4: POP 
# 0x0dc5: JUMP 
j L_0dc5
# 0x0dc6: JUMPDEST 
L_0dc6:
# 0x0dc7: PUSH2 2652
li spill[973], 2652
# 0x0dca: DUP2 
mv spill[974], spill[955]
# 0x0dcb: PUSH2 2634
li spill[975], 2634
# 0x0dce: JUMP 
j L_0dce
# 0x0dcf: JUMPDEST 
L_0dcf:
# 0x0dd0: DUP3 
mv spill[976], spill[955]
# 0x0dd1: MSTORE 
sw spill[976], 0(spill[974])
# 0x0dd2: POP 
# 0x0dd3: POP 
# 0x0dd4: JUMP 
j L_0dd4
# 0x0dd5: JUMPDEST 
L_0dd5:
# 0x0dd6: PUSH2 2667
li spill[977], 2667
# 0x0dd9: DUP2 
mv spill[978], spill[943]
# 0x0dda: PUSH2 2540
li spill[979], 2540
# 0x0ddd: JUMP 
j L_0ddd
# 0x0dde: JUMPDEST 
L_0dde:
# 0x0ddf: DUP3 
mv spill[980], spill[943]
# 0x0de0: MSTORE 
sw spill[980], 0(spill[978])
# 0x0de1: POP 
# 0x0de2: POP 
# 0x0de3: JUMP 
j L_0de3
# 0x0de4: JUMPDEST 
L_0de4:
# 0x0de5: PUSH0 
li spill[981], None
# 0x0de6: PUSH1 64
li spill[982], 64
# 0x0de8: DUP3 
mv spill[983], spill[938]
# 0x0de9: ADD 
add spill[984], spill[982], spill[983]
# 0x0dea: SWAP1 
# 0x0deb: POP 
# 0x0dec: PUSH2 2692
li spill[985], 2692
# 0x0def: PUSH0 
li spill[986], None
# 0x0df0: DUP4 
mv spill[987], spill[938]
# 0x0df1: ADD 
add spill[988], spill[986], spill[987]
# 0x0df2: DUP6 
mv spill[989], spill[922]
# 0x0df3: PUSH2 2643
li spill[990], 2643
# 0x0df6: JUMP 
j L_0df6
# 0x0df7: JUMPDEST 
L_0df7:
# 0x0df8: PUSH2 2705
li spill[991], 2705
# 0x0dfb: PUSH1 32
li spill[992], 32
# 0x0dfd: DUP4 
mv spill[993], spill[988]
# 0x0dfe: ADD 
add spill[994], spill[992], spill[993]
# 0x0dff: DUP5 
mv spill[995], spill[985]
# 0x0e00: PUSH2 2658
li spill[996], 2658
# 0x0e03: JUMP 
j L_0e03
# 0x0e04: JUMPDEST 
L_0e04:
# 0x0e05: SWAP4 
# TODO: Implement SWAP4
# 0x0e06: SWAP3 
# TODO: Implement SWAP3
# 0x0e07: POP 
# 0x0e08: POP 
# 0x0e09: POP 
# 0x0e0a: JUMP 
j L_0e0a
# 0x0e0b: JUMPDEST 
L_0e0b:
# 0x0e0c: PUSH0 
li spill[997], None
# 0x0e0d: PUSH20 1461501637330902918203684832716283019655932542975
li spill[998], 1461501637330902918203684832716283019655932542975
# 0x0e22: DUP3 
mv spill[999], spill[988]
# 0x0e23: AND 
and spill[1000], spill[998], spill[999]
# 0x0e24: SWAP1 
# 0x0e25: POP 
# 0x0e26: SWAP2 
# TODO: Implement SWAP2
# 0x0e27: SWAP1 
# 0x0e28: POP 
# 0x0e29: JUMP 
j L_0e29
# 0x0e2a: JUMPDEST 
L_0e2a:
# 0x0e2b: PUSH0 
li spill[1001], None
# 0x0e2c: PUSH2 2753
li spill[1002], 2753
# 0x0e2f: DUP3 
mv spill[1003], spill[985]
# 0x0e30: PUSH2 2712
li spill[1004], 2712
# 0x0e33: JUMP 
j L_0e33
# 0x0e34: JUMPDEST 
L_0e34:
# 0x0e35: SWAP1 
# 0x0e36: POP 
# 0x0e37: SWAP2 
# TODO: Implement SWAP2
# 0x0e38: SWAP1 
# 0x0e39: POP 
# 0x0e3a: JUMP 
j L_0e3a
# 0x0e3b: JUMPDEST 
L_0e3b:
# 0x0e3c: PUSH2 2769
li spill[1005], 2769
# 0x0e3f: DUP2 
mv spill[1006], spill[985]
# 0x0e40: PUSH2 2743
li spill[1007], 2743
# 0x0e43: JUMP 
j L_0e43
# 0x0e44: JUMPDEST 
L_0e44:
# 0x0e45: DUP3 
mv spill[1008], spill[985]
# 0x0e46: MSTORE 
sw spill[1008], 0(spill[1006])
# 0x0e47: POP 
# 0x0e48: POP 
# 0x0e49: JUMP 
j L_0e49
# 0x0e4a: JUMPDEST 
L_0e4a:
# 0x0e4b: PUSH0 
li spill[1009], None
# 0x0e4c: PUSH1 32
li spill[1010], 32
# 0x0e4e: DUP3 
mv spill[1011], spill[938]
# 0x0e4f: ADD 
add spill[1012], spill[1010], spill[1011]
# 0x0e50: SWAP1 
# 0x0e51: POP 
# 0x0e52: PUSH2 2794
li spill[1013], 2794
# 0x0e55: PUSH0 
li spill[1014], None
# 0x0e56: DUP4 
mv spill[1015], spill[938]
# 0x0e57: ADD 
add spill[1016], spill[1014], spill[1015]
# 0x0e58: DUP5 
mv spill[1017], spill[923]
# 0x0e59: PUSH2 2760
li spill[1018], 2760
# 0x0e5c: JUMP 
j L_0e5c
# 0x0e5d: JUMPDEST 
L_0e5d:
# 0x0e5e: SWAP3 
# TODO: Implement SWAP3
# 0x0e5f: SWAP2 
# TODO: Implement SWAP2
# 0x0e60: POP 
# 0x0e61: POP 
# 0x0e62: JUMP 
j L_0e62
# 0x0e63: JUMPDEST 
L_0e63:
# 0x0e64: PUSH2 2809
li spill[1019], 2809
# 0x0e67: DUP2 
mv spill[1020], spill[1012]
# 0x0e68: PUSH2 2743
li spill[1021], 2743
# 0x0e6b: JUMP 
j L_0e6b
# 0x0e6c: JUMPDEST 
L_0e6c:
# 0x0e6d: DUP2 
mv spill[1022], spill[1019]
# 0x0e6e: EQ 
# TODO: Implement EQ
# 0x0e6f: PUSH2 2819
li spill[1023], 2819
# 0x0e72: JUMPI 
beq spill[1022], zero, L_0e72
# 0x0e73: PUSH0 
li spill[1024], None
# 0x0e74: DUP1 
mv spill[1025], spill[1024]
# 0x0e75: REVERT 
# TODO: Implement REVERT
# 0x0e76: JUMPDEST 
L_0e76:
# 0x0e77: POP 
# 0x0e78: JUMP 
j L_0e78
# 0x0e79: JUMPDEST 
L_0e79:
# 0x0e7a: PUSH0 
li spill[1026], None
# 0x0e7b: DUP2 
mv spill[1027], spill[1020]
# 0x0e7c: CALLDATALOAD 
# TODO: Implement CALLDATALOAD
# 0x0e7d: SWAP1 
# 0x0e7e: POP 
# 0x0e7f: PUSH2 2836
li spill[1028], 2836
# 0x0e82: DUP2 
mv spill[1029], spill[1027]
# 0x0e83: PUSH2 2800
li spill[1030], 2800
# 0x0e86: JUMP 
j L_0e86
# 0x0e87: JUMPDEST 
L_0e87:
# 0x0e88: SWAP3 
# TODO: Implement SWAP3
# 0x0e89: SWAP2 
# TODO: Implement SWAP2
# 0x0e8a: POP 
# 0x0e8b: POP 
# 0x0e8c: JUMP 
j L_0e8c
# 0x0e8d: JUMPDEST 
L_0e8d:
# 0x0e8e: PUSH0 
li spill[1031], None
# 0x0e8f: PUSH1 32
li spill[1032], 32
# 0x0e91: DUP3 
mv spill[1033], spill[1020]
# 0x0e92: DUP5 
mv spill[1034], spill[1019]
# 0x0e93: SUB 
sub spill[1035], spill[1033], spill[1034]
# 0x0e94: SLT 
slt
# 0x0e95: ISZERO 
seqz spill[1036], spill[1035]
# 0x0e96: PUSH2 2863
li spill[1037], 2863
# 0x0e99: JUMPI 
beq spill[1036], zero, L_0e99
# 0x0e9a: PUSH2 2862
li spill[1038], 2862
# 0x0e9d: PUSH2 2536
li spill[1039], 2536
# 0x0ea0: JUMP 
j L_0ea0
# 0x0ea1: JUMPDEST 
L_0ea1:
# 0x0ea2: JUMPDEST 
L_0ea2:
# 0x0ea3: PUSH0 
li spill[1040], None
# 0x0ea4: PUSH2 2876
li spill[1041], 2876
# 0x0ea7: DUP5 
mv spill[1042], spill[1031]
# 0x0ea8: DUP3 
mv spill[1043], spill[1040]
# 0x0ea9: DUP6 
mv spill[1044], spill[1032]
# 0x0eaa: ADD 
add spill[1045], spill[1043], spill[1044]
# 0x0eab: PUSH2 2822
li spill[1046], 2822
# 0x0eae: JUMP 
j L_0eae
# 0x0eaf: JUMPDEST 
L_0eaf:
# 0x0eb0: SWAP2 
# TODO: Implement SWAP2
# 0x0eb1: POP 
# 0x0eb2: POP 
# 0x0eb3: SWAP3 
# TODO: Implement SWAP3
# 0x0eb4: SWAP2 
# TODO: Implement SWAP2
# 0x0eb5: POP 
# 0x0eb6: POP 
# 0x0eb7: JUMP 
j L_0eb7
# 0x0eb8: JUMPDEST 
L_0eb8:
# 0x0eb9: PUSH0 
li spill[1047], None
# 0x0eba: PUSH1 32
li spill[1048], 32
# 0x0ebc: DUP3 
mv spill[1049], spill[1032]
# 0x0ebd: ADD 
add spill[1050], spill[1048], spill[1049]
# 0x0ebe: SWAP1 
# 0x0ebf: POP 
# 0x0ec0: PUSH2 2904
li spill[1051], 2904
# 0x0ec3: PUSH0 
li spill[1052], None
# 0x0ec4: DUP4 
mv spill[1053], spill[1032]
# 0x0ec5: ADD 
add spill[1054], spill[1052], spill[1053]
# 0x0ec6: DUP5 
mv spill[1055], spill[1031]
# 0x0ec7: PUSH2 2658
li spill[1056], 2658
# 0x0eca: JUMP 
j L_0eca
# 0x0ecb: JUMPDEST 
L_0ecb:
# 0x0ecc: SWAP3 
# TODO: Implement SWAP3
# 0x0ecd: SWAP2 
# TODO: Implement SWAP2
# 0x0ece: POP 
# 0x0ecf: POP 
# 0x0ed0: JUMP 
j L_0ed0
# 0x0ed1: JUMPDEST 
L_0ed1:
# 0x0ed2: PUSH0 
li spill[1057], None
# 0x0ed3: DUP2 
mv spill[1058], spill[1050]
# 0x0ed4: ISZERO 
seqz spill[1059], spill[1058]
# 0x0ed5: ISZERO 
seqz spill[1060], spill[1059]
# 0x0ed6: SWAP1 
# 0x0ed7: POP 
# 0x0ed8: SWAP2 
# TODO: Implement SWAP2
# 0x0ed9: SWAP1 
# 0x0eda: POP 
# 0x0edb: JUMP 
j L_0edb
# 0x0edc: JUMPDEST 
L_0edc:
# 0x0edd: PUSH2 2930
li spill[1061], 2930
# 0x0ee0: DUP2 
mv spill[1062], spill[1032]
# 0x0ee1: PUSH2 2910
li spill[1063], 2910
# 0x0ee4: JUMP 
j L_0ee4
# 0x0ee5: JUMPDEST 
L_0ee5:
# 0x0ee6: DUP3 
mv spill[1064], spill[1032]
# 0x0ee7: MSTORE 
sw spill[1064], 0(spill[1062])
# 0x0ee8: POP 
# 0x0ee9: POP 
# 0x0eea: JUMP 
j L_0eea
# 0x0eeb: JUMPDEST 
L_0eeb:
# 0x0eec: PUSH0 
li spill[1065], None
# 0x0eed: PUSH1 128
li spill[1066], 128
# 0x0eef: DUP3 
mv spill[1067], spill[1020]
# 0x0ef0: ADD 
add spill[1068], spill[1066], spill[1067]
# 0x0ef1: SWAP1 
# 0x0ef2: POP 
# 0x0ef3: PUSH2 2955
li spill[1069], 2955
# 0x0ef6: PUSH0 
li spill[1070], None
# 0x0ef7: DUP4 
mv spill[1071], spill[1020]
# 0x0ef8: ADD 
add spill[1072], spill[1070], spill[1071]
# 0x0ef9: DUP8 
mv spill[1073], spill[923]
# 0x0efa: PUSH2 2658
li spill[1074], 2658
# 0x0efd: JUMP 
j L_0efd
# 0x0efe: JUMPDEST 
L_0efe:
# 0x0eff: PUSH2 2968
li spill[1075], 2968
# 0x0f02: PUSH1 32
li spill[1076], 32
# 0x0f04: DUP4 
mv spill[1077], spill[1072]
# 0x0f05: ADD 
add spill[1078], spill[1076], spill[1077]
# 0x0f06: DUP7 
mv spill[1079], spill[1020]
# 0x0f07: PUSH2 2921
li spill[1080], 2921
# 0x0f0a: JUMP 
j L_0f0a
# 0x0f0b: JUMPDEST 
L_0f0b:
# 0x0f0c: PUSH2 2981
li spill[1081], 2981
# 0x0f0f: PUSH1 64
li spill[1082], 64
# 0x0f11: DUP4 
mv spill[1083], spill[1078]
# 0x0f12: ADD 
add spill[1084], spill[1082], spill[1083]
# 0x0f13: DUP6 
mv spill[1085], spill[1073]
# 0x0f14: PUSH2 2760
li spill[1086], 2760
# 0x0f17: JUMP 
j L_0f17
# 0x0f18: JUMPDEST 
L_0f18:
# 0x0f19: PUSH2 2994
li spill[1087], 2994
# 0x0f1c: PUSH1 96
li spill[1088], 96
# 0x0f1e: DUP4 
mv spill[1089], spill[1084]
# 0x0f1f: ADD 
add spill[1090], spill[1088], spill[1089]
# 0x0f20: DUP5 
mv spill[1091], spill[1081]
# 0x0f21: PUSH2 2658
li spill[1092], 2658
# 0x0f24: JUMP 
j L_0f24
# 0x0f25: JUMPDEST 
L_0f25:
# 0x0f26: SWAP6 
# TODO: Implement SWAP6
# 0x0f27: SWAP5 
# TODO: Implement SWAP5
# 0x0f28: POP 
# 0x0f29: POP 
# 0x0f2a: POP 
# 0x0f2b: POP 
# 0x0f2c: POP 
# 0x0f2d: JUMP 
j L_0f2d
# 0x0f2e: JUMPDEST 
L_0f2e:
# 0x0f2f: PUSH0 
li spill[1093], None
# 0x0f30: PUSH1 32
li spill[1094], 32
# 0x0f32: DUP3 
mv spill[1095], spill[1079]
# 0x0f33: ADD 
add spill[1096], spill[1094], spill[1095]
# 0x0f34: SWAP1 
# 0x0f35: POP 
# 0x0f36: PUSH2 3022
li spill[1097], 3022
# 0x0f39: PUSH0 
li spill[1098], None
# 0x0f3a: DUP4 
mv spill[1099], spill[1079]
# 0x0f3b: ADD 
add spill[1100], spill[1098], spill[1099]
# 0x0f3c: DUP5 
mv spill[1101], spill[1078]
# 0x0f3d: PUSH2 2643
li spill[1102], 2643
# 0x0f40: JUMP 
j L_0f40
# 0x0f41: JUMPDEST 
L_0f41:
# 0x0f42: SWAP3 
# TODO: Implement SWAP3
# 0x0f43: SWAP2 
# TODO: Implement SWAP2
# 0x0f44: POP 
# 0x0f45: POP 
# 0x0f46: JUMP 
j L_0f46
# 0x0f47: JUMPDEST 
L_0f47:
# 0x0f48: PUSH0 
li spill[1103], None
# 0x0f49: DUP3 
mv spill[1104], spill[1079]
# 0x0f4a: DUP3 
mv spill[1105], spill[1096]
# 0x0f4b: MSTORE 
sw spill[1105], 0(spill[1104])
# 0x0f4c: PUSH1 32
li spill[1106], 32
# 0x0f4e: DUP3 
mv spill[1107], spill[1096]
# 0x0f4f: ADD 
add spill[1108], spill[1106], spill[1107]
# 0x0f50: SWAP1 
# 0x0f51: POP 
# 0x0f52: SWAP3 
# TODO: Implement SWAP3
# 0x0f53: SWAP2 
# TODO: Implement SWAP2
# 0x0f54: POP 
# 0x0f55: POP 
# 0x0f56: JUMP 
j L_0f56
# 0x0f57: JUMPDEST 
L_0f57:
# 0x0f58: DUP0 
mv spill[1109], 0
# 0x0f59: BASEFEE 
invalid
# 0x0f5a: PUSH2 29472
li spill[1110], 29472
# 0x0f5d: PUSH15 577003053036148005291623374830662757
li spill[1111], 577003053036148005291623374830662757
# 0x0f6d: STOP 
nop
# 0x0f6e: STOP 
nop
# 0x0f6f: STOP 
nop
# 0x0f70: STOP 
nop
# 0x0f71: STOP 
nop
# 0x0f72: STOP 
nop
# 0x0f73: STOP 
nop
# 0x0f74: STOP 
nop
# 0x0f75: STOP 
nop
# 0x0f76: STOP 
nop
# 0x0f77: STOP 
nop
# 0x0f78: STOP 
nop
# 0x0f79: PUSH0 
li spill[1112], None
# 0x0f7a: DUP3 
mv spill[1113], spill[1110]
# 0x0f7b: ADD 
add spill[1114], spill[1112], spill[1113]
# 0x0f7c: MSTORE 
sw spill[1114], 0(spill[1111])
# 0x0f7d: POP 
# 0x0f7e: JUMP 
j L_0f7e
# 0x0f7f: JUMPDEST 
L_0f7f:
# 0x0f80: PUSH0 
li spill[1115], None
# 0x0f81: PUSH2 3096
li spill[1116], 3096
# 0x0f84: PUSH1 20
li spill[1117], 20
# 0x0f86: DUP4 
mv spill[1118], spill[1078]
# 0x0f87: PUSH2 3028
li spill[1119], 3028
# 0x0f8a: JUMP 
j L_0f8a
# 0x0f8b: JUMPDEST 
L_0f8b:
# 0x0f8c: SWAP2 
# TODO: Implement SWAP2
# 0x0f8d: POP 
# 0x0f8e: PUSH2 3107
li spill[1120], 3107
# 0x0f91: DUP3 
mv spill[1121], spill[1116]
# 0x0f92: PUSH2 3044
li spill[1122], 3044
# 0x0f95: JUMP 
j L_0f95
# 0x0f96: JUMPDEST 
L_0f96:
# 0x0f97: PUSH1 32
li spill[1123], 32
# 0x0f99: DUP3 
mv spill[1124], spill[1120]
# 0x0f9a: ADD 
add spill[1125], spill[1123], spill[1124]
# 0x0f9b: SWAP1 
# 0x0f9c: POP 
# 0x0f9d: SWAP2 
# TODO: Implement SWAP2
# 0x0f9e: SWAP1 
# 0x0f9f: POP 
# 0x0fa0: JUMP 
j L_0fa0
# 0x0fa1: JUMPDEST 
L_0fa1:
# 0x0fa2: PUSH0 
li spill[1126], None
# 0x0fa3: PUSH1 32
li spill[1127], 32
# 0x0fa5: DUP3 
mv spill[1128], spill[1117]
# 0x0fa6: ADD 
add spill[1129], spill[1127], spill[1128]
# 0x0fa7: SWAP1 
# 0x0fa8: POP 
# 0x0fa9: DUP2 
mv spill[1130], spill[1117]
# 0x0faa: DUP2 
mv spill[1131], spill[1129]
# 0x0fab: SUB 
sub spill[1132], spill[1130], spill[1131]
# 0x0fac: PUSH0 
li spill[1133], None
# 0x0fad: DUP4 
mv spill[1134], spill[1117]
# 0x0fae: ADD 
add spill[1135], spill[1133], spill[1134]
# 0x0faf: MSTORE 
sw spill[1135], 0(spill[1132])
# 0x0fb0: PUSH2 3141
li spill[1136], 3141
# 0x0fb3: DUP2 
mv spill[1137], spill[1129]
# 0x0fb4: PUSH2 3084
li spill[1138], 3084
# 0x0fb7: JUMP 
j L_0fb7
# 0x0fb8: JUMPDEST 
L_0fb8:
# 0x0fb9: SWAP1 
# 0x0fba: POP 
# 0x0fbb: SWAP2 
# TODO: Implement SWAP2
# 0x0fbc: SWAP1 
# 0x0fbd: POP 
# 0x0fbe: JUMP 
j L_0fbe
# 0x0fbf: JUMPDEST 
L_0fbf:
# 0x0fc0: DUP0 
mv spill[1139], 0
# 0x0fc1: COINBASE 
# TODO: Implement COINBASE
# 0x0fc2: PUSH13 9063386252893636456120710344192
li spill[1140], 9063386252893636456120710344192
# 0x0fd0: STOP 
nop
# 0x0fd1: STOP 
nop
# 0x0fd2: STOP 
nop
# 0x0fd3: STOP 
nop
# 0x0fd4: STOP 
nop
# 0x0fd5: STOP 
nop
# 0x0fd6: STOP 
nop
# 0x0fd7: STOP 
nop
# 0x0fd8: STOP 
nop
# 0x0fd9: STOP 
nop
# 0x0fda: STOP 
nop
# 0x0fdb: STOP 
nop
# 0x0fdc: STOP 
nop
# 0x0fdd: STOP 
nop
# 0x0fde: STOP 
nop
# 0x0fdf: STOP 
nop
# 0x0fe0: STOP 
nop
# 0x0fe1: PUSH0 
li spill[1141], None
# 0x0fe2: DUP3 
mv spill[1142], spill[1139]
# 0x0fe3: ADD 
add spill[1143], spill[1141], spill[1142]
# 0x0fe4: MSTORE 
sw spill[1143], 0(spill[1140])
# 0x0fe5: POP 
# 0x0fe6: JUMP 
j L_0fe6
# 0x0fe7: JUMPDEST 
L_0fe7:
# 0x0fe8: PUSH0 
li spill[1144], None
# 0x0fe9: PUSH2 3200
li spill[1145], 3200
# 0x0fec: PUSH1 14
li spill[1146], 14
# 0x0fee: DUP4 
mv spill[1147], spill[1116]
# 0x0fef: PUSH2 3028
li spill[1148], 3028
# 0x0ff2: JUMP 
j L_0ff2
# 0x0ff3: JUMPDEST 
L_0ff3:
# 0x0ff4: SWAP2 
# TODO: Implement SWAP2
# 0x0ff5: POP 
# 0x0ff6: PUSH2 3211
li spill[1149], 3211
# 0x0ff9: DUP3 
mv spill[1150], spill[1145]
# 0x0ffa: PUSH2 3148
li spill[1151], 3148
# 0x0ffd: JUMP 
j L_0ffd
# 0x0ffe: JUMPDEST 
L_0ffe:
# 0x0fff: PUSH1 32
li spill[1152], 32
# 0x1001: DUP3 
mv spill[1153], spill[1149]
# 0x1002: ADD 
add spill[1154], spill[1152], spill[1153]
# 0x1003: SWAP1 
# 0x1004: POP 
# 0x1005: SWAP2 
# TODO: Implement SWAP2
# 0x1006: SWAP1 
# 0x1007: POP 
# 0x1008: JUMP 
j L_1008
# 0x1009: JUMPDEST 
L_1009:
# 0x100a: PUSH0 
li spill[1155], None
# 0x100b: PUSH1 32
li spill[1156], 32
# 0x100d: DUP3 
mv spill[1157], spill[1146]
# 0x100e: ADD 
add spill[1158], spill[1156], spill[1157]
# 0x100f: SWAP1 
# 0x1010: POP 
# 0x1011: DUP2 
mv spill[1159], spill[1146]
# 0x1012: DUP2 
mv spill[1160], spill[1158]
# 0x1013: SUB 
sub spill[1161], spill[1159], spill[1160]
# 0x1014: PUSH0 
li spill[1162], None
# 0x1015: DUP4 
mv spill[1163], spill[1146]
# 0x1016: ADD 
add spill[1164], spill[1162], spill[1163]
# 0x1017: MSTORE 
sw spill[1164], 0(spill[1161])
# 0x1018: PUSH2 3245
li spill[1165], 3245
# 0x101b: DUP2 
mv spill[1166], spill[1158]
# 0x101c: PUSH2 3188
li spill[1167], 3188
# 0x101f: JUMP 
j L_101f
# 0x1020: JUMPDEST 
L_1020:
# 0x1021: SWAP1 
# 0x1022: POP 
# 0x1023: SWAP2 
# TODO: Implement SWAP2
# 0x1024: SWAP1 
# 0x1025: POP 
# 0x1026: JUMP 
j L_1026
# 0x1027: JUMPDEST 
L_1027:
# 0x1028: DUP0 
mv spill[1168], 0
# 0x1029: UNKNOWN_0x4e 
invalid
# 0x102a: BASEFEE 
invalid
# 0x102b: PUSH28 11900288958546962096864737128254758852035145780262049571737140461568
li spill[1169], 11900288958546962096864737128254758852035145780262049571737140461568
# 0x1048: STOP 
nop
# 0x1049: PUSH0 
li spill[1170], None
# 0x104a: MSTORE 
sw spill[1170], 0(spill[1169])
# 0x104b: PUSH1 50
li spill[1171], 50
# 0x104d: PUSH1 4
li spill[1172], 4
# 0x104f: MSTORE 
sw spill[1172], 0(spill[1171])
# 0x1050: PUSH1 36
li spill[1173], 36
# 0x1052: PUSH0 
li spill[1174], None
# 0x1053: REVERT 
# TODO: Implement REVERT
# 0x1054: JUMPDEST 
L_1054:
# 0x1055: DUP0 
mv spill[1175], 0
# 0x1056: UNKNOWN_0x4e 
invalid
# 0x1057: BASEFEE 
invalid
# 0x1058: PUSH28 11900288958546962096864737128254758852035145780262049571737140461568
li spill[1176], 11900288958546962096864737128254758852035145780262049571737140461568
# 0x1075: STOP 
nop
# 0x1076: PUSH0 
li spill[1177], None
# 0x1077: MSTORE 
sw spill[1177], 0(spill[1176])
# 0x1078: PUSH1 17
li spill[1178], 17
# 0x107a: PUSH1 4
li spill[1179], 4
# 0x107c: MSTORE 
sw spill[1179], 0(spill[1178])
# 0x107d: PUSH1 36
li spill[1180], 36
# 0x107f: PUSH0 
li spill[1181], None
# 0x1080: REVERT 
# TODO: Implement REVERT
# 0x1081: JUMPDEST 
L_1081:
# 0x1082: PUSH0 
li spill[1182], None
# 0x1083: PUSH2 3352
li spill[1183], 3352
# 0x1086: DUP3 
mv spill[1184], spill[1181]
# 0x1087: PUSH2 2540
li spill[1185], 2540
# 0x108a: JUMP 
j L_108a
# 0x108b: JUMPDEST 
L_108b:
# 0x108c: SWAP2 
# TODO: Implement SWAP2
# 0x108d: POP 
# 0x108e: PUSH2 3363
li spill[1186], 3363
# 0x1091: DUP4 
mv spill[1187], spill[1181]
# 0x1092: PUSH2 2540
li spill[1188], 2540
# 0x1095: JUMP 
j L_1095
# 0x1096: JUMPDEST 
L_1096:
# 0x1097: SWAP3 
# TODO: Implement SWAP3
# 0x1098: POP 
# 0x1099: DUP3 
mv spill[1189], spill[1182]
# 0x109a: DUP3 
mv spill[1190], spill[1183]
# 0x109b: ADD 
add spill[1191], spill[1189], spill[1190]
# 0x109c: SWAP1 
# 0x109d: POP 
# 0x109e: DUP1 
mv spill[1192], spill[1191]
# 0x109f: DUP3 
mv spill[1193], spill[1183]
# 0x10a0: GT 
sgtu
# 0x10a1: ISZERO 
seqz spill[1194], spill[1193]
# 0x10a2: PUSH2 3387
li spill[1195], 3387
# 0x10a5: JUMPI 
beq spill[1194], zero, L_10a5
# 0x10a6: PUSH2 3386
li spill[1196], 3386
# 0x10a9: PUSH2 3297
li spill[1197], 3297
# 0x10ac: JUMP 
j L_10ac
# 0x10ad: JUMPDEST 
L_10ad:
# 0x10ae: JUMPDEST 
L_10ae:
# 0x10af: SWAP3 
# TODO: Implement SWAP3
# 0x10b0: SWAP2 
# TODO: Implement SWAP2
# 0x10b1: POP 
# 0x10b2: POP 
# 0x10b3: JUMP 
j L_10b3
# 0x10b4: JUMPDEST 
L_10b4:
# 0x10b5: DUP0 
mv spill[1198], 0
# 0x10b6: MSIZE 
invalid
# 0x10b7: PUSH16 155687946098680301090799860550596064288
li spill[1199], 155687946098680301090799860550596064288
# 0x10c8: PUSH21 162412010645400758414705694290527588886855755914079
li spill[1200], 162412010645400758414705694290527588886855755914079
# 0x10de: PUSH2 3445
li spill[1201], 3445
# 0x10e1: PUSH1 25
li spill[1202], 25
# 0x10e3: DUP4 
mv spill[1203], spill[1199]
# 0x10e4: PUSH2 3028
li spill[1204], 3028
# 0x10e7: JUMP 
j L_10e7
# 0x10e8: JUMPDEST 
L_10e8:
# 0x10e9: SWAP2 
# TODO: Implement SWAP2
# 0x10ea: POP 
# 0x10eb: PUSH2 3456
li spill[1205], 3456
# 0x10ee: DUP3 
mv spill[1206], spill[1201]
# 0x10ef: PUSH2 3393
li spill[1207], 3393
# 0x10f2: JUMP 
j L_10f2
# 0x10f3: JUMPDEST 
L_10f3:
# 0x10f4: PUSH1 32
li spill[1208], 32
# 0x10f6: DUP3 
mv spill[1209], spill[1205]
# 0x10f7: ADD 
add spill[1210], spill[1208], spill[1209]
# 0x10f8: SWAP1 
# 0x10f9: POP 
# 0x10fa: SWAP2 
# TODO: Implement SWAP2
# 0x10fb: SWAP1 
# 0x10fc: POP 
# 0x10fd: JUMP 
j L_10fd
# 0x10fe: JUMPDEST 
L_10fe:
# 0x10ff: PUSH0 
li spill[1211], None
# 0x1100: PUSH1 32
li spill[1212], 32
# 0x1102: DUP3 
mv spill[1213], spill[1202]
# 0x1103: ADD 
add spill[1214], spill[1212], spill[1213]
# 0x1104: SWAP1 
# 0x1105: POP 
# 0x1106: DUP2 
mv spill[1215], spill[1202]
# 0x1107: DUP2 
mv spill[1216], spill[1214]
# 0x1108: SUB 
sub spill[1217], spill[1215], spill[1216]
# 0x1109: PUSH0 
li spill[1218], None
# 0x110a: DUP4 
mv spill[1219], spill[1202]
# 0x110b: ADD 
add spill[1220], spill[1218], spill[1219]
# 0x110c: MSTORE 
sw spill[1220], 0(spill[1217])
# 0x110d: PUSH2 3490
li spill[1221], 3490
# 0x1110: DUP2 
mv spill[1222], spill[1214]
# 0x1111: PUSH2 3433
li spill[1223], 3433
# 0x1114: JUMP 
j L_1114
# 0x1115: JUMPDEST 
L_1115:
# 0x1116: SWAP1 
# 0x1117: POP 
# 0x1118: SWAP2 
# TODO: Implement SWAP2
# 0x1119: SWAP1 
# 0x111a: POP 
# 0x111b: JUMP 
j L_111b
# 0x111c: JUMPDEST 
L_111c:
# 0x111d: DUP0 
mv spill[1224], 0
# 0x111e: MSIZE 
invalid
# 0x111f: PUSH16 155687804992085229916803752328178263086
li spill[1225], 155687804992085229916803752328178263086
# 0x1130: STOP 
nop
# 0x1131: STOP 
nop
# 0x1132: STOP 
nop
# 0x1133: STOP 
nop
# 0x1134: STOP 
nop
# 0x1135: STOP 
nop
# 0x1136: STOP 
nop
# 0x1137: STOP 
nop
# 0x1138: STOP 
nop
# 0x1139: STOP 
nop
# 0x113a: STOP 
nop
# 0x113b: STOP 
nop
# 0x113c: STOP 
nop
# 0x113d: STOP 
nop
# 0x113e: PUSH0 
li spill[1226], None
# 0x113f: DUP3 
mv spill[1227], spill[1224]
# 0x1140: ADD 
add spill[1228], spill[1226], spill[1227]
# 0x1141: MSTORE 
sw spill[1228], 0(spill[1225])
# 0x1142: POP 
# 0x1143: JUMP 
j L_1143
# 0x1144: JUMPDEST 
L_1144:
# 0x1145: PUSH0 
li spill[1229], None
# 0x1146: PUSH2 3549
li spill[1230], 3549
# 0x1149: PUSH1 18
li spill[1231], 18
# 0x114b: DUP4 
mv spill[1232], spill[1201]
# 0x114c: PUSH2 3028
li spill[1233], 3028
# 0x114f: JUMP 
j L_114f
# 0x1150: JUMPDEST 
L_1150:
# 0x1151: SWAP2 
# TODO: Implement SWAP2
# 0x1152: POP 
# 0x1153: PUSH2 3560
li spill[1234], 3560
# 0x1156: DUP3 
mv spill[1235], spill[1230]
# 0x1157: PUSH2 3497
li spill[1236], 3497
# 0x115a: JUMP 
j L_115a
# 0x115b: JUMPDEST 
L_115b:
# 0x115c: PUSH1 32
li spill[1237], 32
# 0x115e: DUP3 
mv spill[1238], spill[1234]
# 0x115f: ADD 
add spill[1239], spill[1237], spill[1238]
# 0x1160: SWAP1 
# 0x1161: POP 
# 0x1162: SWAP2 
# TODO: Implement SWAP2
# 0x1163: SWAP1 
# 0x1164: POP 
# 0x1165: JUMP 
j L_1165
# 0x1166: JUMPDEST 
L_1166:
# 0x1167: PUSH0 
li spill[1240], None
# 0x1168: PUSH1 32
li spill[1241], 32
# 0x116a: DUP3 
mv spill[1242], spill[1231]
# 0x116b: ADD 
add spill[1243], spill[1241], spill[1242]
# 0x116c: SWAP1 
# 0x116d: POP 
# 0x116e: DUP2 
mv spill[1244], spill[1231]
# 0x116f: DUP2 
mv spill[1245], spill[1243]
# 0x1170: SUB 
sub spill[1246], spill[1244], spill[1245]
# 0x1171: PUSH0 
li spill[1247], None
# 0x1172: DUP4 
mv spill[1248], spill[1231]
# 0x1173: ADD 
add spill[1249], spill[1247], spill[1248]
# 0x1174: MSTORE 
sw spill[1249], 0(spill[1246])
# 0x1175: PUSH2 3594
li spill[1250], 3594
# 0x1178: DUP2 
mv spill[1251], spill[1243]
# 0x1179: PUSH2 3537
li spill[1252], 3537
# 0x117c: JUMP 
j L_117c
# 0x117d: JUMPDEST 
L_117d:
# 0x117e: SWAP1 
# 0x117f: POP 
# 0x1180: SWAP2 
# TODO: Implement SWAP2
# 0x1181: SWAP1 
# 0x1182: POP 
# 0x1183: JUMP 
j L_1183
# 0x1184: JUMPDEST 
L_1184:
# 0x1185: DUP0 
mv spill[1253], 0
# 0x1186: MSTORE8 
# TODO: Implement MSTORE8
# 0x1187: PUSH6 119186104018284
li spill[1254], 119186104018284
# 0x118e: PUSH6 113668262555502
li spill[1255], 113668262555502
# 0x1195: SHA3 
# TODO: Implement SHA3
# 0x1196: PUSH10 543669676781506520706935
li spill[1256], 543669676781506520706935
# 0x11a1: PUSH6 110148731297666
li spill[1257], 110148731297666
# 0x11a8: ADD 
add spill[1258], spill[1256], spill[1257]
# 0x11a9: MSTORE 
sw spill[1258], 0(spill[1255])
# 0x11aa: POP 
# 0x11ab: JUMP 
j L_11ab
# 0x11ac: JUMPDEST 
L_11ac:
# 0x11ad: PUSH0 
li spill[1259], None
# 0x11ae: PUSH2 3653
li spill[1260], 3653
# 0x11b1: PUSH1 30
li spill[1261], 30
# 0x11b3: DUP4 
mv spill[1262], spill[1231]
# 0x11b4: PUSH2 3028
li spill[1263], 3028
# 0x11b7: JUMP 
j L_11b7
# 0x11b8: JUMPDEST 
L_11b8:
# 0x11b9: SWAP2 
# TODO: Implement SWAP2
# 0x11ba: POP 
# 0x11bb: PUSH2 3664
li spill[1264], 3664
# 0x11be: DUP3 
mv spill[1265], spill[1260]
# 0x11bf: PUSH2 3601
li spill[1266], 3601
# 0x11c2: JUMP 
j L_11c2
# 0x11c3: JUMPDEST 
L_11c3:
# 0x11c4: PUSH1 32
li spill[1267], 32
# 0x11c6: DUP3 
mv spill[1268], spill[1264]
# 0x11c7: ADD 
add spill[1269], spill[1267], spill[1268]
# 0x11c8: SWAP1 
# 0x11c9: POP 
# 0x11ca: SWAP2 
# TODO: Implement SWAP2
# 0x11cb: SWAP1 
# 0x11cc: POP 
# 0x11cd: JUMP 
j L_11cd
# 0x11ce: JUMPDEST 
L_11ce:
# 0x11cf: PUSH0 
li spill[1270], None
# 0x11d0: PUSH1 32
li spill[1271], 32
# 0x11d2: DUP3 
mv spill[1272], spill[1261]
# 0x11d3: ADD 
add spill[1273], spill[1271], spill[1272]
# 0x11d4: SWAP1 
# 0x11d5: POP 
# 0x11d6: DUP2 
mv spill[1274], spill[1261]
# 0x11d7: DUP2 
mv spill[1275], spill[1273]
# 0x11d8: SUB 
sub spill[1276], spill[1274], spill[1275]
# 0x11d9: PUSH0 
li spill[1277], None
# 0x11da: DUP4 
mv spill[1278], spill[1261]
# 0x11db: ADD 
add spill[1279], spill[1277], spill[1278]
# 0x11dc: MSTORE 
sw spill[1279], 0(spill[1276])
# 0x11dd: PUSH2 3698
li spill[1280], 3698
# 0x11e0: DUP2 
mv spill[1281], spill[1273]
# 0x11e1: PUSH2 3641
li spill[1282], 3641
# 0x11e4: JUMP 
j L_11e4
# 0x11e5: JUMPDEST 
L_11e5:
# 0x11e6: SWAP1 
# 0x11e7: POP 
# 0x11e8: SWAP2 
# TODO: Implement SWAP2
# 0x11e9: SWAP1 
# 0x11ea: POP 
# 0x11eb: JUMP 
j L_11eb
# 0x11ec: JUMPDEST 
L_11ec:
# 0x11ed: DUP0 
mv spill[1283], 0
# 0x11ee: CHAINID 
invalid
# 0x11ef: PUSH16 156092858971094651870117923381477469285
li spill[1284], 156092858971094651870117923381477469285
# 0x1200: PUSH8 7022353646288240640
li spill[1285], 7022353646288240640
# 0x1209: STOP 
nop
# 0x120a: STOP 
nop
# 0x120b: STOP 
nop
# 0x120c: STOP 
nop
# 0x120d: STOP 
nop
# 0x120e: PUSH0 
li spill[1286], None
# 0x120f: DUP3 
mv spill[1287], spill[1284]
# 0x1210: ADD 
add spill[1288], spill[1286], spill[1287]
# 0x1211: MSTORE 
sw spill[1288], 0(spill[1285])
# 0x1212: POP 
# 0x1213: JUMP 
j L_1213
# 0x1214: JUMPDEST 
L_1214:
# 0x1215: PUSH0 
li spill[1289], None
# 0x1216: PUSH2 3757
li spill[1290], 3757
# 0x1219: PUSH1 25
li spill[1291], 25
# 0x121b: DUP4 
mv spill[1292], spill[1261]
# 0x121c: PUSH2 3028
li spill[1293], 3028
# 0x121f: JUMP 
j L_121f
# 0x1220: JUMPDEST 
L_1220:
# 0x1221: SWAP2 
# TODO: Implement SWAP2
# 0x1222: POP 
# 0x1223: PUSH2 3768
li spill[1294], 3768
# 0x1226: DUP3 
mv spill[1295], spill[1290]
# 0x1227: PUSH2 3705
li spill[1296], 3705
# 0x122a: JUMP 
j L_122a
# 0x122b: JUMPDEST 
L_122b:
# 0x122c: PUSH1 32
li spill[1297], 32
# 0x122e: DUP3 
mv spill[1298], spill[1294]
# 0x122f: ADD 
add spill[1299], spill[1297], spill[1298]
# 0x1230: SWAP1 
# 0x1231: POP 
# 0x1232: SWAP2 
# TODO: Implement SWAP2
# 0x1233: SWAP1 
# 0x1234: POP 
# 0x1235: JUMP 
j L_1235
# 0x1236: JUMPDEST 
L_1236:
# 0x1237: PUSH0 
li spill[1300], None
# 0x1238: PUSH1 32
li spill[1301], 32
# 0x123a: DUP3 
mv spill[1302], spill[1291]
# 0x123b: ADD 
add spill[1303], spill[1301], spill[1302]
# 0x123c: SWAP1 
# 0x123d: POP 
# 0x123e: DUP2 
mv spill[1304], spill[1291]
# 0x123f: DUP2 
mv spill[1305], spill[1303]
# 0x1240: SUB 
sub spill[1306], spill[1304], spill[1305]
# 0x1241: PUSH0 
li spill[1307], None
# 0x1242: DUP4 
mv spill[1308], spill[1291]
# 0x1243: ADD 
add spill[1309], spill[1307], spill[1308]
# 0x1244: MSTORE 
sw spill[1309], 0(spill[1306])
# 0x1245: PUSH2 3802
li spill[1310], 3802
# 0x1248: DUP2 
mv spill[1311], spill[1303]
# 0x1249: PUSH2 3745
li spill[1312], 3745
# 0x124c: JUMP 
j L_124c
# 0x124d: JUMPDEST 
L_124d:
# 0x124e: SWAP1 
# 0x124f: POP 
# 0x1250: SWAP2 
# TODO: Implement SWAP2
# 0x1251: SWAP1 
# 0x1252: POP 
# 0x1253: JUMP 
j L_1253
# 0x1254: JUMPDEST 
L_1254:
# 0x1255: DUP0 
mv spill[1313], 0
# 0x1256: UNKNOWN_0x4f 
invalid
# 0x1257: PUSH15 563224798350207964717646007331941920
li spill[1314], 563224798350207964717646007331941920
# 0x1267: PUSH4 1634607207
li spill[1315], 1634607207
# 0x126c: PUSH10 559104704177112213626975
li spill[1316], 559104704177112213626975
# 0x1277: DUP3 
mv spill[1317], spill[1314]
# 0x1278: ADD 
add spill[1318], spill[1316], spill[1317]
# 0x1279: MSTORE 
sw spill[1318], 0(spill[1315])
# 0x127a: DUP0 
mv spill[1319], 0
# 0x127b: PUSH21 162412010645400997260361186892591619225053277716480
li spill[1320], 162412010645400997260361186892591619225053277716480
# 0x1291: STOP 
nop
# 0x1292: STOP 
nop
# 0x1293: STOP 
nop
# 0x1294: STOP 
nop
# 0x1295: STOP 
nop
# 0x1296: STOP 
nop
# 0x1297: STOP 
nop
# 0x1298: STOP 
nop
# 0x1299: STOP 
nop
# 0x129a: STOP 
nop
# 0x129b: PUSH1 32
li spill[1321], 32
# 0x129d: DUP3 
mv spill[1322], spill[1319]
# 0x129e: ADD 
add spill[1323], spill[1321], spill[1322]
# 0x129f: MSTORE 
sw spill[1323], 0(spill[1320])
# 0x12a0: POP 
# 0x12a1: JUMP 
j L_12a1
# 0x12a2: JUMPDEST 
L_12a2:
# 0x12a3: PUSH0 
li spill[1324], None
# 0x12a4: PUSH2 3899
li spill[1325], 3899
# 0x12a7: PUSH1 40
li spill[1326], 40
# 0x12a9: DUP4 
mv spill[1327], spill[1313]
# 0x12aa: PUSH2 3028
li spill[1328], 3028
# 0x12ad: JUMP 
j L_12ad
# 0x12ae: JUMPDEST 
L_12ae:
# 0x12af: SWAP2 
# TODO: Implement SWAP2
# 0x12b0: POP 
# 0x12b1: PUSH2 3910
li spill[1329], 3910
# 0x12b4: DUP3 
mv spill[1330], spill[1325]
# 0x12b5: PUSH2 3809
li spill[1331], 3809
# 0x12b8: JUMP 
j L_12b8
# 0x12b9: JUMPDEST 
L_12b9:
# 0x12ba: PUSH1 64
li spill[1332], 64
# 0x12bc: DUP3 
mv spill[1333], spill[1329]
# 0x12bd: ADD 
add spill[1334], spill[1332], spill[1333]
# 0x12be: SWAP1 
# 0x12bf: POP 
# 0x12c0: SWAP2 
# TODO: Implement SWAP2
# 0x12c1: SWAP1 
# 0x12c2: POP 
# 0x12c3: JUMP 
j L_12c3
# 0x12c4: JUMPDEST 
L_12c4:
# 0x12c5: PUSH0 
li spill[1335], None
# 0x12c6: PUSH1 32
li spill[1336], 32
# 0x12c8: DUP3 
mv spill[1337], spill[1326]
# 0x12c9: ADD 
add spill[1338], spill[1336], spill[1337]
# 0x12ca: SWAP1 
# 0x12cb: POP 
# 0x12cc: DUP2 
mv spill[1339], spill[1326]
# 0x12cd: DUP2 
mv spill[1340], spill[1338]
# 0x12ce: SUB 
sub spill[1341], spill[1339], spill[1340]
# 0x12cf: PUSH0 
li spill[1342], None
# 0x12d0: DUP4 
mv spill[1343], spill[1326]
# 0x12d1: ADD 
add spill[1344], spill[1342], spill[1343]
# 0x12d2: MSTORE 
sw spill[1344], 0(spill[1341])
# 0x12d3: PUSH2 3944
li spill[1345], 3944
# 0x12d6: DUP2 
mv spill[1346], spill[1338]
# 0x12d7: PUSH2 3887
li spill[1347], 3887
# 0x12da: JUMP 
j L_12da
# 0x12db: JUMPDEST 
L_12db:
# 0x12dc: SWAP1 
# 0x12dd: POP 
# 0x12de: SWAP2 
# TODO: Implement SWAP2
# 0x12df: SWAP1 
# 0x12e0: POP 
# 0x12e1: JUMP 
j L_12e1
# 0x12e2: JUMPDEST 
L_12e2:
# 0x12e3: DUP0 
mv spill[1348], 0
# 0x12e4: SLOAD 
# TODO: Implement SLOAD
# 0x12e5: PUSH9 1865460331046839132257
li spill[1349], 1865460331046839132257
# 0x12ef: PUSH13 9063386252893636456120710344192
li spill[1350], 9063386252893636456120710344192
# 0x12fd: STOP 
nop
# 0x12fe: STOP 
nop
# 0x12ff: STOP 
nop
# 0x1300: STOP 
nop
# 0x1301: STOP 
nop
# 0x1302: STOP 
nop
# 0x1303: STOP 
nop
# 0x1304: PUSH0 
li spill[1351], None
# 0x1305: DUP3 
mv spill[1352], spill[1349]
# 0x1306: ADD 
add spill[1353], spill[1351], spill[1352]
# 0x1307: MSTORE 
sw spill[1353], 0(spill[1350])
# 0x1308: POP 
# 0x1309: JUMP 
j L_1309
# 0x130a: JUMPDEST 
L_130a:
# 0x130b: PUSH0 
li spill[1354], None
# 0x130c: PUSH2 4003
li spill[1355], 4003
# 0x130f: PUSH1 24
li spill[1356], 24
# 0x1311: DUP4 
mv spill[1357], spill[1326]
# 0x1312: PUSH2 3028
li spill[1358], 3028
# 0x1315: JUMP 
j L_1315
# 0x1316: JUMPDEST 
L_1316:
# 0x1317: SWAP2 
# TODO: Implement SWAP2
# 0x1318: POP 
# 0x1319: PUSH2 4014
li spill[1359], 4014
# 0x131c: DUP3 
mv spill[1360], spill[1355]
# 0x131d: PUSH2 3951
li spill[1361], 3951
# 0x1320: JUMP 
j L_1320
# 0x1321: JUMPDEST 
L_1321:
# 0x1322: PUSH1 32
li spill[1362], 32
# 0x1324: DUP3 
mv spill[1363], spill[1359]
# 0x1325: ADD 
add spill[1364], spill[1362], spill[1363]
# 0x1326: SWAP1 
# 0x1327: POP 
# 0x1328: SWAP2 
# TODO: Implement SWAP2
# 0x1329: SWAP1 
# 0x132a: POP 
# 0x132b: JUMP 
j L_132b
# 0x132c: JUMPDEST 
L_132c:
# 0x132d: PUSH0 
li spill[1365], None
# 0x132e: PUSH1 32
li spill[1366], 32
# 0x1330: DUP3 
mv spill[1367], spill[1356]
# 0x1331: ADD 
add spill[1368], spill[1366], spill[1367]
# 0x1332: SWAP1 
# 0x1333: POP 
# 0x1334: DUP2 
mv spill[1369], spill[1356]
# 0x1335: DUP2 
mv spill[1370], spill[1368]
# 0x1336: SUB 
sub spill[1371], spill[1369], spill[1370]
# 0x1337: PUSH0 
li spill[1372], None
# 0x1338: DUP4 
mv spill[1373], spill[1356]
# 0x1339: ADD 
add spill[1374], spill[1372], spill[1373]
# 0x133a: MSTORE 
sw spill[1374], 0(spill[1371])
# 0x133b: PUSH2 4048
li spill[1375], 4048
# 0x133e: DUP2 
mv spill[1376], spill[1368]
# 0x133f: PUSH2 3991
li spill[1377], 3991
# 0x1342: JUMP 
j L_1342
# 0x1343: JUMPDEST 
L_1343:
# 0x1344: SWAP1 
# 0x1345: POP 
# 0x1346: SWAP2 
# TODO: Implement SWAP2
# 0x1347: SWAP1 
# 0x1348: POP 
# 0x1349: JUMP 
j L_1349
# 0x134a: JUMPDEST 
L_134a:
# 0x134b: DUP0 
mv spill[1378], 0
# 0x134c: JUMP 
j L_134c
# 0x134d: PUSH16 154717184253909425755317249602662527776
li spill[1379], 154717184253909425755317249602662527776
# 0x135e: PUSH21 152573501940781161850207939442151897744615874196581
li spill[1380], 152573501940781161850207939442151897744615874196581
# 0x1374: UNKNOWN_0x2e 
invalid
# 0x1375: STOP 
nop
# 0x1376: STOP 
nop
# 0x1377: STOP 
nop
# 0x1378: STOP 
nop
# 0x1379: STOP 
nop
# 0x137a: STOP 
nop
# 0x137b: STOP 
nop
# 0x137c: STOP 
nop
# 0x137d: STOP 
nop
# 0x137e: STOP 
nop
# 0x137f: STOP 
nop
# 0x1380: STOP 
nop
# 0x1381: STOP 
nop
# 0x1382: STOP 
nop
# 0x1383: STOP 
nop
# 0x1384: STOP 
nop
# 0x1385: STOP 
nop
# 0x1386: STOP 
nop
# 0x1387: STOP 
nop
# 0x1388: STOP 
nop
# 0x1389: STOP 
nop
# 0x138a: STOP 
nop
# 0x138b: STOP 
nop
# 0x138c: STOP 
nop
# 0x138d: STOP 
nop
# 0x138e: STOP 
nop
# 0x138f: STOP 
nop
# 0x1390: STOP 
nop
# 0x1391: PUSH1 32
li spill[1381], 32
# 0x1393: DUP3 
mv spill[1382], spill[1379]
# 0x1394: ADD 
add spill[1383], spill[1381], spill[1382]
# 0x1395: MSTORE 
sw spill[1383], 0(spill[1380])
# 0x1396: POP 
# 0x1397: JUMP 
j L_1397
# 0x1398: JUMPDEST 
L_1398:
# 0x1399: PUSH0 
li spill[1384], None
# 0x139a: PUSH2 4145
li spill[1385], 4145
# 0x139d: PUSH1 36
li spill[1386], 36
# 0x139f: DUP4 
mv spill[1387], spill[1355]
# 0x13a0: PUSH2 3028
li spill[1388], 3028
# 0x13a3: JUMP 
j L_13a3
# 0x13a4: JUMPDEST 
L_13a4:
# 0x13a5: SWAP2 
# TODO: Implement SWAP2
# 0x13a6: POP 
# 0x13a7: PUSH2 4156
li spill[1389], 4156
# 0x13aa: DUP3 
mv spill[1390], spill[1385]
# 0x13ab: PUSH2 4055
li spill[1391], 4055
# 0x13ae: JUMP 
j L_13ae
# 0x13af: JUMPDEST 
L_13af:
# 0x13b0: PUSH1 64
li spill[1392], 64
# 0x13b2: DUP3 
mv spill[1393], spill[1389]
# 0x13b3: ADD 
add spill[1394], spill[1392], spill[1393]
# 0x13b4: SWAP1 
# 0x13b5: POP 
# 0x13b6: SWAP2 
# TODO: Implement SWAP2
# 0x13b7: SWAP1 
# 0x13b8: POP 
# 0x13b9: JUMP 
j L_13b9
# 0x13ba: JUMPDEST 
L_13ba:
# 0x13bb: PUSH0 
li spill[1395], None
# 0x13bc: PUSH1 32
li spill[1396], 32
# 0x13be: DUP3 
mv spill[1397], spill[1386]
# 0x13bf: ADD 
add spill[1398], spill[1396], spill[1397]
# 0x13c0: SWAP1 
# 0x13c1: POP 
# 0x13c2: DUP2 
mv spill[1399], spill[1386]
# 0x13c3: DUP2 
mv spill[1400], spill[1398]
# 0x13c4: SUB 
sub spill[1401], spill[1399], spill[1400]
# 0x13c5: PUSH0 
li spill[1402], None
# 0x13c6: DUP4 
mv spill[1403], spill[1386]
# 0x13c7: ADD 
add spill[1404], spill[1402], spill[1403]
# 0x13c8: MSTORE 
sw spill[1404], 0(spill[1401])
# 0x13c9: PUSH2 4190
li spill[1405], 4190
# 0x13cc: DUP2 
mv spill[1406], spill[1398]
# 0x13cd: PUSH2 4133
li spill[1407], 4133
# 0x13d0: JUMP 
j L_13d0
# 0x13d1: JUMPDEST 
L_13d1:
# 0x13d2: SWAP1 
# 0x13d3: POP 
# 0x13d4: SWAP2 
# TODO: Implement SWAP2
# 0x13d5: SWAP1 
# 0x13d6: POP 
# 0x13d7: JUMP 
j L_13d7
# 0x13d8: INVALID 
invalid
# 0x13d9: LOG2 
# TODO: Implement LOG2
# 0x13da: PUSH5 452857328472
li spill[1408], 452857328472
# 0x13e0: UNKNOWN_0x22 
invalid
# 0x13e1: SLT 
slt
# 0x13e2: SHA3 
# TODO: Implement SHA3
# 0x13e3: UNKNOWN_0xde 
invalid
# 0x13e4: OR 
or spill[1409], spill[1386], spill[1408]
# 0x13e5: SWAP0 
invalid
# 0x13e6: UNKNOWN_0xdd 
invalid
# 0x13e7: SWAP13 
# TODO: Implement SWAP13
# 0x13e8: SMOD 
rem
# 0x13e9: UNKNOWN_0xed 
invalid
# 0x13ea: UNKNOWN_0xd5 
invalid
# 0x13eb: UNKNOWN_0x26 
invalid
# 0x13ec: EXP 
# TODO: Implement EXP
# 0x13ed: SWAP13 
# TODO: Implement SWAP13
# 0x13ee: UNKNOWN_0xb2 
invalid
# 0x13ef: UNKNOWN_0xb2 
invalid
# 0x13f0: PUSH28 22686382256412182050824620138046696052723204762004109374431183772160
li spill[1410], 22686382256412182050824620138046696052723204762004109374431183772160
# 0x140d: CALLER 
# TODO: Implement CALLER