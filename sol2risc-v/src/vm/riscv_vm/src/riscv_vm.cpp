#include "riscv_vm.hpp"
#include <iostream>
#include <stdexcept>
#include <chrono> // For potential timing/debugging

RISCV_VM::RISCV_VM(size_t memory_size, std::unique_ptr<SyscallHandler> handler)
    : memory(memory_size), syscall_handler(std::move(handler)) {
    if (!syscall_handler) {
        throw std::invalid_argument("Syscall handler cannot be null.");
    }
    // Initialize CPU state (constructor already does this)
}

void RISCV_VM::load_elf(const std::string& filename) {
    if (is_halted) {
        std::cerr << "Warning: Attempting to load ELF into a halted VM." << std::endl;
        // Optionally reset state here if desired
    }
    try {
        addr_t entry_point = loader.load(filename, memory);
        cpu_state.set_pc(entry_point);
        is_halted = false; // Ready to run
        instruction_count = 0;
        std::cout << "VM initialized. PC set to entry point: 0x" << std::hex << entry_point << std::dec << std::endl;
    } catch (const std::exception& e) {
        is_halted = true;
        std::cerr << "Error loading ELF file: " << e.what() << std::endl;
        throw; // Re-throw the exception
    }
}

bool RISCV_VM::step() {
    if (is_halted) {
        // std::cout << "VM is halted. Cannot step." << std::endl;
        return false; // Indicate VM cannot continue
    }

    try {
        // 1. Fetch
        addr_t current_pc = cpu_state.get_pc();
        word_t instruction_word = memory.read_word(current_pc);

        // 2. Decode
        DecodedInstruction decoded_instr = decoder.decode(instruction_word);

        // Optional: Print instruction being executed (for debugging)
        // std::cout << "[PC=0x" << std::hex << current_pc << "] Executing: 0x" << std::setw(8) << std::setfill("0") << instruction_word << std::dec << std::endl;

        // 3. Execute
        bool continue_execution = executor.execute(decoded_instr, cpu_state, memory, *syscall_handler);

        instruction_count++;

        if (!continue_execution) {
            std::cout << "Execution halted by instruction or syscall at PC=0x" << std::hex << current_pc << std::dec << std::endl;
            is_halted = true;
            return false; // Indicate VM halted
        }

    } catch (const std::exception& e) {
        std::cerr << "Runtime Error at PC=0x" << std::hex << cpu_state.get_pc() << std::dec << ": " << e.what() << std::endl;
        cpu_state.dump_registers(); // Dump state on error
        is_halted = true;
        return false; // Indicate VM halted due to error
    }
    
    return true; // Indicate successful step, VM can continue
}

void RISCV_VM::run(uint64_t max_instructions) {
    if (is_halted) {
        std::cout << "VM is already halted. Cannot run." << std::endl;
        return;
    }
    std::cout << "Starting VM execution..." << std::endl;
    auto start_time = std::chrono::high_resolution_clock::now();

    while (instruction_count < max_instructions) {
        if (!step()) { // Execute one instruction, break if halted
            break;
        }
    }

    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);

    if (instruction_count >= max_instructions) {
        std::cout << "Execution stopped: Maximum instruction count reached (" << max_instructions << ")." << std::endl;
        is_halted = true; // Consider it halted if max instructions reached
    }
    
    std::cout << "Execution finished. Total instructions executed: " << instruction_count << std::endl;
    std::cout << "Execution time: " << duration.count() << " ms" << std::endl;
    if (!is_halted) {
         std::cout << "Warning: Execution finished without explicit halt." << std::endl;
    }
    std::cout << "Final VM state:" << std::endl;
    cpu_state.dump_registers();
}

// Getters for internal state
const CPUState& RISCV_VM::get_cpu_state() const {
    return cpu_state;
}

const Memory& RISCV_VM::get_memory() const {
    return memory;
}

