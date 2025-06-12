#pragma once

#include "types.hpp"
#include "cpu_state.hpp"
#include "memory.hpp"
#include "instruction_decoder.hpp"
#include "executor.hpp"
#include "elf_loader.hpp"
#include "syscall_handler.hpp"
#include <string>
#include <memory>

class RISCV_VM {
public:
    // Constructor: Initializes the VM with a specific memory size and a syscall handler
    RISCV_VM(size_t memory_size, std::unique_ptr<SyscallHandler> syscall_handler);

    // Load an ELF executable file into memory
    void load_elf(const std::string& filename);

    // Run the loaded program until halt or error
    // max_instructions: Optional limit on the number of instructions to execute
    void run(uint64_t max_instructions = UINT64_MAX);

    // Step through a single instruction (for debugging)
    bool step();

    // Getters for internal state (useful for testing/debugging)
    const CPUState& get_cpu_state() const;
    const Memory& get_memory() const;

private:
    CPUState cpu_state;
    Memory memory;
    InstructionDecoder decoder;
    Executor executor;
    ELFLoader loader;
    std::unique_ptr<SyscallHandler> syscall_handler; // Use the provided handler

    bool is_halted = false;
    uint64_t instruction_count = 0;
};
