#pragma once

#include "types.hpp"

// Structure to hold decoded instruction fields
struct DecodedInstruction {
    word_t instruction_word; // The raw instruction word
    // Common fields (extracted based on format)
    uint8_t opcode;
    uint8_t rd = 0;     // Destination register index
    uint8_t rs1 = 0;    // Source register 1 index
    uint8_t rs2 = 0;    // Source register 2 index
    uint8_t funct3 = 0;
    uint8_t funct7 = 0;
    word_t imm = 0;    // Immediate value (sign-extended where necessary)

    // TODO: Add fields specific to instruction types (R, I, S, B, U, J) if needed
    //       or handle extraction within the executor based on opcode/funct3/funct7.
};

class InstructionDecoder {
public:
    // Decodes a raw 32-bit instruction word
    DecodedInstruction decode(word_t instruction_word) const;

private:
    // Helper functions for extracting fields based on format
    uint8_t extract_opcode(word_t instruction) const;
    uint8_t extract_rd(word_t instruction) const;
    uint8_t extract_funct3(word_t instruction) const;
    uint8_t extract_rs1(word_t instruction) const;
    uint8_t extract_rs2(word_t instruction) const;
    uint8_t extract_funct7(word_t instruction) const;

    // Helper functions for extracting and sign-extending immediates
    word_t extract_imm_i(word_t instruction) const;
    word_t extract_imm_s(word_t instruction) const;
    word_t extract_imm_b(word_t instruction) const;
    word_t extract_imm_u(word_t instruction) const;
    word_t extract_imm_j(word_t instruction) const;
};
