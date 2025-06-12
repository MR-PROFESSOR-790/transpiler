#include "cpu_state.hpp"
#include <stdexcept>

CPUState::CPUState() : pc(0) {
    // Initialize all registers to 0, especially x0 (zero register)
    regs.fill(0);
}

addr_t CPUState::get_pc() const {
    return pc;
}

void CPUState::set_pc(addr_t new_pc) {
    // PC should be aligned to 2 bytes for compressed instructions, or 4 bytes otherwise.
    // For simplicity now, we might enforce 4-byte alignment later or handle misalignment.
    pc = new_pc;
}

void CPUState::increment_pc() {
    pc += 4; // Standard instruction length is 4 bytes
}

word_t CPUState::get_reg(size_t index) const {
    if (index >= REG_COUNT) {
        throw std::out_of_range("Register index out of bounds");
    }
    // Reading x0 always returns 0, though we also store 0 there.
    return regs[index];
}

void CPUState::set_reg(size_t index, word_t value) {
    if (index >= REG_COUNT) {
        throw std::out_of_range("Register index out of bounds");
    }
    // Ensure x0 remains 0, writes to x0 are ignored.
    if (index != 0) {
        regs[index] = value;
    }
}

void CPUState::dump_registers() const {
    std::cout << "PC: 0x" << std::hex << std::setw(8) << std::setfill('0') << pc << std::dec << std::endl;
    for (size_t i = 0; i < REG_COUNT; ++i) {
        // Standard ABI names for registers (optional but helpful for debugging)
        const char* abi_name = nullptr;
        switch(i) {
            case 0: abi_name = "zero"; break;
            case 1: abi_name = "ra"; break;
            case 2: abi_name = "sp"; break;
            case 3: abi_name = "gp"; break;
            case 4: abi_name = "tp"; break;
            case 5: abi_name = "t0"; break;
            case 6: abi_name = "t1"; break;
            case 7: abi_name = "t2"; break;
            case 8: abi_name = "s0/fp"; break;
            case 9: abi_name = "s1"; break;
            case 10: abi_name = "a0"; break;
            case 11: abi_name = "a1"; break;
            case 12: abi_name = "a2"; break;
            case 13: abi_name = "a3"; break;
            case 14: abi_name = "a4"; break;
            case 15: abi_name = "a5"; break;
            case 16: abi_name = "a6"; break;
            case 17: abi_name = "a7"; break;
            case 18: abi_name = "s2"; break;
            case 19: abi_name = "s3"; break;
            case 20: abi_name = "s4"; break;
            case 21: abi_name = "s5"; break;
            case 22: abi_name = "s6"; break;
            case 23: abi_name = "s7"; break;
            case 24: abi_name = "s8"; break;
            case 25: abi_name = "s9"; break;
            case 26: abi_name = "s10"; break;
            case 27: abi_name = "s11"; break;
            case 28: abi_name = "t3"; break;
            case 29: abi_name = "t4"; break;
            case 30: abi_name = "t5"; break;
            case 31: abi_name = "t6"; break;
        }
        std::cout << "x" << std::setw(2) << std::setfill(' ') << i 
                  << " (" << std::setw(5) << std::setfill(' ') << (abi_name ? abi_name : "") << "): 0x"
                  << std::hex << std::setw(8) << std::setfill('0') << regs[i] << std::dec;
        if ((i + 1) % 4 == 0) {
            std::cout << std::endl;
        } else {
            std::cout << "  ";
        }
    }
}

