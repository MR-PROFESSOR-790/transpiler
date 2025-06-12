#include "instruction_decoder.hpp"

// Helper function for sign extension (from N bits)
template<unsigned N>
inline word_t sign_extend(word_t value) {
    static_assert(N > 0 && N <= 32, "Sign extension bit width must be between 1 and 32");
    word_t mask = 1U << (N - 1);
    return (value ^ mask) - mask; // Sign extend
}

// --- Field Extractors --- //

uint8_t InstructionDecoder::extract_opcode(word_t instruction) const {
    return instruction & 0x7F; // Opcode is bits 0-6
}

uint8_t InstructionDecoder::extract_rd(word_t instruction) const {
    return (instruction >> 7) & 0x1F; // rd is bits 7-11
}

uint8_t InstructionDecoder::extract_funct3(word_t instruction) const {
    return (instruction >> 12) & 0x07; // funct3 is bits 12-14
}

uint8_t InstructionDecoder::extract_rs1(word_t instruction) const {
    return (instruction >> 15) & 0x1F; // rs1 is bits 15-19
}

uint8_t InstructionDecoder::extract_rs2(word_t instruction) const {
    return (instruction >> 20) & 0x1F; // rs2 is bits 20-24
}

uint8_t InstructionDecoder::extract_funct7(word_t instruction) const {
    return (instruction >> 25) & 0x7F; // funct7 is bits 25-31
}

// --- Immediate Extractors --- //

// I-type immediate (bits 20-31)
word_t InstructionDecoder::extract_imm_i(word_t instruction) const {
    return sign_extend<12>(instruction >> 20);
}

// S-type immediate (bits 7-11 and 25-31)
word_t InstructionDecoder::extract_imm_s(word_t instruction) const {
    word_t imm_4_0  = (instruction >> 7) & 0x1F;
    word_t imm_11_5 = (instruction >> 25) & 0x7F;
    word_t imm = (imm_11_5 << 5) | imm_4_0;
    return sign_extend<12>(imm);
}

// B-type immediate (bits 7, 8-11, 25-30, 31)
word_t InstructionDecoder::extract_imm_b(word_t instruction) const {
    word_t imm_11   = (instruction >> 7) & 0x1;  // bit 11
    word_t imm_4_1  = (instruction >> 8) & 0xF;  // bits 1-4
    word_t imm_10_5 = (instruction >> 25) & 0x3F; // bits 5-10
    word_t imm_12   = (instruction >> 31) & 0x1;  // bit 12
    word_t imm = (imm_12 << 12) | (imm_11 << 11) | (imm_10_5 << 5) | (imm_4_1 << 1);
    return sign_extend<13>(imm); // B-immediate is 13 bits
}

// U-type immediate (bits 12-31)
word_t InstructionDecoder::extract_imm_u(word_t instruction) const {
    // Immediate is stored in bits 31:12, needs to be shifted left by 12
    // No sign extension needed for LUI/AUIPC, but the value occupies the upper 20 bits.
    return instruction & 0xFFFFF000; 
}

// J-type immediate (bits 12-19, 20, 21-30, 31)
word_t InstructionDecoder::extract_imm_j(word_t instruction) const {
    word_t imm_19_12 = (instruction >> 12) & 0xFF; // bits 12-19
    word_t imm_11    = (instruction >> 20) & 0x1;  // bit 11
    word_t imm_10_1  = (instruction >> 21) & 0x3FF;// bits 1-10
    word_t imm_20    = (instruction >> 31) & 0x1;  // bit 20
    word_t imm = (imm_20 << 20) | (imm_19_12 << 12) | (imm_11 << 11) | (imm_10_1 << 1);
    return sign_extend<21>(imm); // J-immediate is 21 bits
}

// --- Main Decode Function --- //

DecodedInstruction InstructionDecoder::decode(word_t instruction_word) const {
    DecodedInstruction decoded;
    decoded.instruction_word = instruction_word;
    decoded.opcode = extract_opcode(instruction_word);

    // Extract fields based on opcode (determines format)
    // Note: This is a simplified approach. A more robust decoder might use tables
    // or switch statements based on opcode to determine the format and extract accordingly.
    switch (decoded.opcode) {
        // R-type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
        case 0b0110011:
            decoded.rd = extract_rd(instruction_word);
            decoded.funct3 = extract_funct3(instruction_word);
            decoded.rs1 = extract_rs1(instruction_word);
            decoded.rs2 = extract_rs2(instruction_word);
            decoded.funct7 = extract_funct7(instruction_word);
            break;

        // I-type (Loads: LB, LH, LW, LBU, LHU)
        case 0b0000011:
        // I-type (ALU immediate: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
        case 0b0010011:
        // I-type (JALR)
        case 0b1100111:
        // I-type (ECALL/EBREAK/CSR)
        case 0b1110011: // Note: ECALL/EBREAK have funct3=0, CSR variants have others
            decoded.rd = extract_rd(instruction_word);
            decoded.funct3 = extract_funct3(instruction_word);
            decoded.rs1 = extract_rs1(instruction_word);
            decoded.imm = extract_imm_i(instruction_word);
            // Special case for SLLI, SRLI, SRAI immediate (shamt)
            if (decoded.opcode == 0b0010011 && (decoded.funct3 == 0b001 || decoded.funct3 == 0b101)) {
                 decoded.rs2 = extract_rs2(instruction_word); // Technically shamt is in rs2 field bits
                 decoded.funct7 = extract_funct7(instruction_word); // Used to distinguish SRAI/SRLI
                 decoded.imm = decoded.rs2; // For shift instructions, immediate is just the shamt
            }
            break;

        // S-type (Stores: SB, SH, SW)
        case 0b0100011:
            decoded.funct3 = extract_funct3(instruction_word);
            decoded.rs1 = extract_rs1(instruction_word);
            decoded.rs2 = extract_rs2(instruction_word);
            decoded.imm = extract_imm_s(instruction_word);
            break;

        // B-type (Branches: BEQ, BNE, BLT, BGE, BLTU, BGEU)
        case 0b1100011:
            decoded.funct3 = extract_funct3(instruction_word);
            decoded.rs1 = extract_rs1(instruction_word);
            decoded.rs2 = extract_rs2(instruction_word);
            decoded.imm = extract_imm_b(instruction_word);
            break;

        // U-type (LUI, AUIPC)
        case 0b0110111: // LUI
        case 0b0010111: // AUIPC
            decoded.rd = extract_rd(instruction_word);
            decoded.imm = extract_imm_u(instruction_word);
            break;

        // J-type (JAL)
        case 0b1101111:
            decoded.rd = extract_rd(instruction_word);
            decoded.imm = extract_imm_j(instruction_word);
            break;

        // FENCE (opcode 0b0001111) - Treat as I-type for field extraction if needed, though often ignored in simple emulators
        case 0b0001111:
             decoded.rd = extract_rd(instruction_word);
             decoded.funct3 = extract_funct3(instruction_word);
             decoded.rs1 = extract_rs1(instruction_word);
             decoded.imm = extract_imm_i(instruction_word);
             break;

        default:
            // Handle illegal/unknown opcode
            // For now, just mark opcode, other fields might be garbage
            break;
    }

    return decoded;
}

