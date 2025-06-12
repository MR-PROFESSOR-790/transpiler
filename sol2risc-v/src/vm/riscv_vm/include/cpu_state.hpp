#pragma once

#include "types.hpp"
#include <array>
#include <iostream>
#include <iomanip>

class CPUState {
public:
    CPUState();

    // Program Counter
    addr_t get_pc() const;
    void set_pc(addr_t new_pc);
    void increment_pc(); // Default increment by 4

    // General Purpose Registers (x0-x31)
    word_t get_reg(size_t index) const;
    void set_reg(size_t index, word_t value);

    // Dump state for debugging
    void dump_registers() const;

private:
    addr_t pc; // Program Counter
    std::array<word_t, REG_COUNT> regs; // Register file (x0-x31)
};
