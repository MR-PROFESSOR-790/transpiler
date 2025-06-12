#include "syscall_handler.hpp"
#include "cpu_state.hpp"
#include "memory.hpp"
#include <iostream>
#include <stdexcept>

// Placeholder for actual blockchain interaction logic
// In a real scenario, this would interact with the node's state database, etc.
namespace BlockchainInterface {
    word_t read_storage(addr_t key_addr, Memory& mem) {
        // Placeholder: Read key from VM memory, simulate storage read
        // word_t key = mem.read_word(key_addr);
        std::cout << "[Syscall] Placeholder: Reading storage for key at addr 0x" << std::hex << key_addr << std::dec << std::endl;
        // Simulate returning a value
        return 0xDEADBEEF; 
    }

    void write_storage(addr_t key_addr, addr_t value_addr, Memory& mem) {
        // Placeholder: Read key and value from VM memory, simulate storage write
        // word_t key = mem.read_word(key_addr);
        // word_t value = mem.read_word(value_addr);
        std::cout << "[Syscall] Placeholder: Writing storage for key at 0x" << std::hex << key_addr 
                  << " with value at 0x" << value_addr << std::dec << std::endl;
    }

    word_t get_caller() {
        // Placeholder: Simulate returning a caller address
        std::cout << "[Syscall] Placeholder: Getting caller address" << std::endl;
        return 0xCAFEBABE;
    }

    word_t get_block_number() {
        // Placeholder: Simulate returning block number
        std::cout << "[Syscall] Placeholder: Getting block number" << std::endl;
        return 123456;
    }
    
    void log_event(addr_t data_addr, size_t length, Memory& mem) {
         // Placeholder: Read event data from VM memory
         std::cout << "[Syscall] Placeholder: Logging event from addr 0x" << std::hex << data_addr 
                   << " with length " << std::dec << length << std::endl;
    }

} // namespace BlockchainInterface


SmartContractSyscallHandler::SmartContractSyscallHandler(/* BlockchainInterface* blockchain */) {
    // Initialize blockchain interface if provided
    // this->blockchain_interface = blockchain;
}

bool SmartContractSyscallHandler::handle_ecall(CPUState& state, Memory& mem) {
    // Syscall number is typically passed in register a7 (x17)
    word_t syscall_num = state.get_reg(17); 

    // Arguments are typically passed in a0-a6 (x10-x16)
    word_t arg0 = state.get_reg(10);
    word_t arg1 = state.get_reg(11);
    // word_t arg2 = state.get_reg(12);
    // ... up to arg6 (x16)

    word_t return_val = 0; // Default return value (often indicates success/failure or result)
    bool continue_exec = true;

    // std::cout << "[Syscall] ECALL triggered. Syscall number (a7): " << syscall_num << std::endl;

    try {
        switch (syscall_num) {
            case SYSCALL_READ_STORAGE: // Read from storage
                // Args: a0 = key address
                // Return: a0 = value read
                return_val = BlockchainInterface::read_storage(arg0, mem);
                state.set_reg(10, return_val); // Set return value in a0
                break;

            case SYSCALL_WRITE_STORAGE: // Write to storage
                // Args: a0 = key address, a1 = value address
                BlockchainInterface::write_storage(arg0, arg1, mem);
                // No return value needed, or use a0 for status
                state.set_reg(10, 0); // Indicate success
                break;

            case SYSCALL_GET_CALLER: // Get caller address
                // Return: a0 = caller address
                return_val = BlockchainInterface::get_caller();
                state.set_reg(10, return_val);
                break;

            case SYSCALL_GET_BLOCK_NUMBER: // Get current block number
                 // Return: a0 = block number
                 return_val = BlockchainInterface::get_block_number();
                 state.set_reg(10, return_val);
                 break;
                 
            case SYSCALL_LOG_EVENT: // Log an event
                 // Args: a0 = data address, a1 = data length
                 BlockchainInterface::log_event(arg0, arg1, mem);
                 state.set_reg(10, 0); // Indicate success
                 break;

            case SYSCALL_HALT: // Halt execution cleanly
                std::cout << "[Syscall] Clean halt requested via ECALL." << std::endl;
                continue_exec = false;
                state.set_reg(10, 0); // Indicate successful halt
                break;

            // Add cases for other custom smart contract syscalls here...

            default:
                std::cerr << "[Syscall] Error: Unknown syscall number: " << syscall_num << std::endl;
                state.set_reg(10, -1); // Indicate error in a0 (convention)
                // Optionally, throw an exception or halt execution on unknown syscall
                // throw std::runtime_error("Unknown syscall number");
                continue_exec = false; // Halt on unknown syscall for safety
                break;
        }
    } catch (const std::exception& e) {
        std::cerr << "[Syscall] Error during syscall " << syscall_num << ": " << e.what() << std::endl;
        state.set_reg(10, -1); // Indicate error
        continue_exec = false; // Halt on error during syscall
    }

    return continue_exec;
}

