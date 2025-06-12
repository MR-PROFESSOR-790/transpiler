#pragma once

#include "types.hpp"
#include "cpu_state.hpp"
#include "memory.hpp"
#include "instruction_decoder.hpp"

// Forward declaration
class SyscallHandler;

class Executor {
public:
    // Executes a single decoded instruction
    // Returns true if execution should continue, false if VM should halt (e.g., EBREAK)
    bool execute(const DecodedInstruction& instr, CPUState& state, Memory& mem, SyscallHandler& syscall_handler);

private:
    // Potentially add helper methods for specific instruction types if needed
};
