#include "riscv_vm.hpp"
#include "syscall_handler.hpp"
#include <iostream>
#include <string>
#include <memory>
#include <stdexcept>

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <elf_file> [memory_size_mb] [max_instructions]" << std::endl;
        std::cerr << "  <elf_file>: Path to the RISC-V ELF executable." << std::endl;
        std::cerr << "  [memory_size_mb]: Optional memory size in MB (default: 64 MB)." << std::endl;
        std::cerr << "  [max_instructions]: Optional maximum number of instructions to execute (default: unlimited)." << std::endl;
        return 1;
    }

    std::string elf_filename = argv[1];
    size_t memory_size_bytes = 64 * 1024 * 1024; // Default 64 MB
    uint64_t max_instructions = UINT64_MAX; // Default unlimited

    if (argc >= 3) {
        try {
            size_t mem_mb = std::stoul(argv[2]);
            if (mem_mb == 0) {
                 std::cerr << "Error: Memory size must be greater than 0 MB." << std::endl;
                 return 1;
            }
            memory_size_bytes = mem_mb * 1024 * 1024;
        } catch (const std::exception& e) {
            std::cerr << "Error parsing memory size: " << e.what() << std::endl;
            return 1;
        }
    }

    if (argc >= 4) {
         try {
            max_instructions = std::stoull(argv[3]);
         } catch (const std::exception& e) {
            std::cerr << "Error parsing max instructions: " << e.what() << std::endl;
            return 1;
         }
    }

    try {
        // Instantiate the syscall handler for smart contracts
        auto syscall_handler = std::make_unique<SmartContractSyscallHandler>();

        // Instantiate the VM
        RISCV_VM vm(memory_size_bytes, std::move(syscall_handler));

        // Load the ELF file
        std::cout << "Loading ELF file: " << elf_filename << std::endl;
        std::cout << "VM Memory Size: " << (memory_size_bytes / (1024 * 1024)) << " MB" << std::endl;
        vm.load_elf(elf_filename);

        // Run the VM
        std::cout << "Running VM..." << std::endl;
        if (max_instructions != UINT64_MAX) {
            std::cout << "Instruction limit: " << max_instructions << std::endl;
        }
        vm.run(max_instructions);

    } catch (const std::exception& e) {
        std::cerr << "VM Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}

