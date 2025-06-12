#include "executor.hpp"
#include "syscall_handler.hpp" // Include necessary headers
#include <stdexcept>
#include <iostream> // For potential debugging/error output

// Helper function for sign extension (already defined in decoder, maybe move to types.hpp?)
// For now, assume it's accessible or redefine if necessary.
template<unsigned N>
inline word_t sign_extend_exec(word_t value) {
    static_assert(N > 0 && N <= 32, "Sign extension bit width must be between 1 and 32");
    if constexpr (N == 32) return value; // No extension needed for 32 bits
    word_t mask = 1U << (N - 1);
    // Check if the sign bit is set
    if (value & mask) {
        // Negative number, extend with 1s
        return value | (~((1U << N) - 1)); 
    } else {
        // Positive number, extend with 0s (implicitly done)
        return value & ((1U << N) - 1);
    }
}

bool Executor::execute(const DecodedInstruction& instr, CPUState& state, Memory& mem, SyscallHandler& syscall_handler) {
    bool continue_execution = true;
    addr_t current_pc = state.get_pc();
    addr_t next_pc = current_pc + 4; // Default next PC

    try {
        switch (instr.opcode) {
            // --- RV32I Base Instruction Set --- //

            // LUI (Load Upper Immediate) - U-type
            case 0b0110111:
                state.set_reg(instr.rd, instr.imm); // imm already contains the upper 20 bits shifted
                break;

            // AUIPC (Add Upper Immediate to PC) - U-type
            case 0b0010111:
                state.set_reg(instr.rd, current_pc + instr.imm); // imm already contains the upper 20 bits shifted
                break;

            // JAL (Jump and Link) - J-type
            case 0b1101111:
                state.set_reg(instr.rd, next_pc); // Save return address (pc + 4)
                next_pc = current_pc + instr.imm; // Jump to target address
                break;

            // JALR (Jump and Link Register) - I-type
            case 0b1100111:
                {
                    addr_t target_addr = (state.get_reg(instr.rs1) + instr.imm) & ~1; // Calculate target, ensure LSB is 0
                    state.set_reg(instr.rd, next_pc); // Save return address (pc + 4)
                    next_pc = target_addr;
                }
                break;

            // Branch Instructions - B-type
            case 0b1100011:
                {
                    word_t val1 = state.get_reg(instr.rs1);
                    word_t val2 = state.get_reg(instr.rs2);
                    bool take_branch = false;
                    switch (instr.funct3) {
                        case 0b000: // BEQ (Branch if Equal)
                            take_branch = (val1 == val2);
                            break;
                        case 0b001: // BNE (Branch if Not Equal)
                            take_branch = (val1 != val2);
                            break;
                        case 0b100: // BLT (Branch if Less Than, signed)
                            take_branch = (static_cast<s_word_t>(val1) < static_cast<s_word_t>(val2));
                            break;
                        case 0b101: // BGE (Branch if Greater Than or Equal, signed)
                            take_branch = (static_cast<s_word_t>(val1) >= static_cast<s_word_t>(val2));
                            break;
                        case 0b110: // BLTU (Branch if Less Than, unsigned)
                            take_branch = (val1 < val2);
                            break;
                        case 0b111: // BGEU (Branch if Greater Than or Equal, unsigned)
                            take_branch = (val1 >= val2);
                            break;
                        default:
                            throw std::runtime_error("Illegal branch instruction (funct3)");
                    }
                    if (take_branch) {
                        next_pc = current_pc + instr.imm;
                    }
                }
                break;

            // Load Instructions - I-type
            case 0b0000011:
                {
                    addr_t mem_addr = state.get_reg(instr.rs1) + instr.imm;
                    word_t loaded_value = 0;
                    switch (instr.funct3) {
                        case 0b000: // LB (Load Byte, signed)
                            loaded_value = sign_extend_exec<8>(mem.read_byte(mem_addr));
                            break;
                        case 0b001: // LH (Load Halfword, signed)
                            loaded_value = sign_extend_exec<16>(mem.read_half(mem_addr));
                            break;
                        case 0b010: // LW (Load Word)
                            loaded_value = mem.read_word(mem_addr);
                            break;
                        case 0b100: // LBU (Load Byte, unsigned)
                            loaded_value = mem.read_byte(mem_addr);
                            break;
                        case 0b101: // LHU (Load Halfword, unsigned)
                            loaded_value = mem.read_half(mem_addr);
                            break;
                        default:
                            throw std::runtime_error("Illegal load instruction (funct3)");
                    }
                    state.set_reg(instr.rd, loaded_value);
                }
                break;

            // Store Instructions - S-type
            case 0b0100011:
                {
                    addr_t mem_addr = state.get_reg(instr.rs1) + instr.imm;
                    word_t store_value = state.get_reg(instr.rs2);
                    switch (instr.funct3) {
                        case 0b000: // SB (Store Byte)
                            mem.write_byte(mem_addr, static_cast<byte_t>(store_value));
                            break;
                        case 0b001: // SH (Store Halfword)
                            mem.write_half(mem_addr, static_cast<half_t>(store_value));
                            break;
                        case 0b010: // SW (Store Word)
                            mem.write_word(mem_addr, store_value);
                            break;
                        default:
                            throw std::runtime_error("Illegal store instruction (funct3)");
                    }
                }
                break;

            // ALU Immediate Instructions - I-type
            case 0b0010011:
                {
                    word_t val1 = state.get_reg(instr.rs1);
                    word_t result = 0;
                    switch (instr.funct3) {
                        case 0b000: // ADDI
                            result = val1 + instr.imm;
                            break;
                        case 0b010: // SLTI (Set Less Than Immediate, signed)
                            result = (static_cast<s_word_t>(val1) < static_cast<s_word_t>(instr.imm)) ? 1 : 0;
                            break;
                        case 0b011: // SLTIU (Set Less Than Immediate, unsigned)
                            result = (val1 < instr.imm) ? 1 : 0;
                            break;
                        case 0b100: // XORI
                            result = val1 ^ instr.imm;
                            break;
                        case 0b110: // ORI
                            result = val1 | instr.imm;
                            break;
                        case 0b111: // ANDI
                            result = val1 & instr.imm;
                            break;
                        case 0b001: // SLLI (Shift Left Logical Immediate)
                            // Shift amount is lower 5 bits of immediate (instr.imm & 0x1F)
                            result = val1 << (instr.imm & 0x1F);
                            break;
                        case 0b101: // SRLI / SRAI (Shift Right Logical/Arithmetic Immediate)
                            {
                                uint8_t shamt = instr.imm & 0x1F;
                                uint8_t funct7_bit5 = (instr.instruction_word >> 30) & 0x1; // Bit 30 distinguishes SRAI/SRLI
                                if (funct7_bit5 == 0) { // SRLI
                                    result = val1 >> shamt;
                                } else { // SRAI
                                    result = static_cast<s_word_t>(val1) >> shamt;
                                }
                            }
                            break;
                        default:
                            throw std::runtime_error("Illegal ALU immediate instruction (funct3)");
                    }
                    state.set_reg(instr.rd, result);
                }
                break;

            // ALU Register Instructions - R-type
            case 0b0110011:
                {
                    word_t val1 = state.get_reg(instr.rs1);
                    word_t val2 = state.get_reg(instr.rs2);
                    word_t result = 0;
                    bool use_alt_funct7 = (instr.funct7 == 0b0100000); // Used for SUB and SRA

                    switch (instr.funct3) {
                        case 0b000: // ADD / SUB
                            result = use_alt_funct7 ? (val1 - val2) : (val1 + val2);
                            break;
                        case 0b001: // SLL (Shift Left Logical)
                            result = val1 << (val2 & 0x1F); // Shift amount is lower 5 bits of rs2
                            break;
                        case 0b010: // SLT (Set Less Than, signed)
                            result = (static_cast<s_word_t>(val1) < static_cast<s_word_t>(val2)) ? 1 : 0;
                            break;
                        case 0b011: // SLTU (Set Less Than, unsigned)
                            result = (val1 < val2) ? 1 : 0;
                            break;
                        case 0b100: // XOR
                            result = val1 ^ val2;
                            break;
                        case 0b101: // SRL / SRA (Shift Right Logical/Arithmetic)
                            {
                                uint8_t shamt = val2 & 0x1F;
                                if (use_alt_funct7) { // SRA
                                    result = static_cast<s_word_t>(val1) >> shamt;
                                } else { // SRL
                                    result = val1 >> shamt;
                                }
                            }
                            break;
                        case 0b110: // OR
                            result = val1 | val2;
                            break;
                        case 0b111: // AND
                            result = val1 & val2;
                            break;
                        default:
                            throw std::runtime_error("Illegal ALU register instruction (funct3)");
                    }
                    state.set_reg(instr.rd, result);
                }
                break;

            // System Instructions - I-type (ECALL/EBREAK)
            case 0b1110011:
                if (instr.funct3 == 0b000) {
                    if (instr.imm == 0b000000000000) { // ECALL
                        continue_execution = syscall_handler.handle_ecall(state, mem);
                    } else if (instr.imm == 0b000000000001) { // EBREAK
                        std::cout << "EBREAK encountered at PC=0x" << std::hex << current_pc << std::dec << std::endl;
                        continue_execution = false; // Halt execution
                        // Optionally trigger debugger or specific halt behavior
                    } else {
                        throw std::runtime_error("Illegal system instruction (imm)");
                    }
                } else {
                    // Potentially CSR instructions if implemented later
                    throw std::runtime_error("Illegal system instruction (funct3) - CSRs not implemented");
                }
                break;

            // FENCE Instruction - I-type (Memory Ordering)
            case 0b0001111:
                // FENCE, FENCE.I - For a simple single-core VM without complex memory models or caches,
                // these can often be treated as NOPs (No Operations).
                // A real implementation might need cache flushing or memory barrier logic.
                // std::cout << "Warning: FENCE instruction encountered (treated as NOP) at PC=0x" << std::hex << current_pc << std::dec << std::endl;
                break;

            default:
                std::cerr << "Illegal instruction encountered! Opcode: 0b" << std::bitset<7>(instr.opcode) 
                          << " at PC=0x" << std::hex << current_pc << std::dec << std::endl;
                throw std::runtime_error("Illegal instruction opcode");
        }

        // Update PC for the next instruction
        state.set_pc(next_pc);

    } catch (const std::exception& e) {
        std::cerr << "Execution Error at PC=0x" << std::hex << current_pc << std::dec << ": " << e.what() << std::endl;
        state.dump_registers(); // Dump state on error
        return false; // Halt execution on error
    }

    return continue_execution;
}

