#pragma once

#include "types.hpp"

// Forward declarations
class CPUState;
class Memory;

// Abstract base class or interface for handling ECALLs
// This allows different syscall implementations (e.g., standard OS vs. smart contract)
class SyscallHandler {
public:
    virtual ~SyscallHandler() = default;

    // Handles an ECALL instruction.
    // Modifies CPUState (e.g., return value in a0) and potentially Memory.
    // Returns true if execution should continue, false if the syscall requests a halt.
    virtual bool handle_ecall(CPUState& state, Memory& mem) = 0;
};

// Concrete implementation for Smart Contract specific syscalls
class SmartContractSyscallHandler : public SyscallHandler {
public:
    // Constructor could take context/interface to the blockchain environment
    SmartContractSyscallHandler(/* BlockchainInterface* blockchain */);

    bool handle_ecall(CPUState& state, Memory& mem) override;

private:
    // Placeholder for interface to the external environment
    // BlockchainInterface* blockchain_interface;

    // Define custom syscall numbers and their handlers
    // Example syscall numbers (these need to be defined based on your ABI)
    static constexpr word_t SYSCALL_READ_STORAGE = 1001;
    static constexpr word_t SYSCALL_WRITE_STORAGE = 1002;
    static constexpr word_t SYSCALL_GET_CALLER = 1003;
    static constexpr word_t SYSCALL_GET_BLOCK_NUMBER = 1004;
    static constexpr word_t SYSCALL_LOG_EVENT = 1005;
    static constexpr word_t SYSCALL_HALT = 0; // Example: Use syscall 0 for clean halt

    // Helper methods for specific syscall implementations
    void handle_read_storage(CPUState& state, Memory& mem);
    void handle_write_storage(CPUState& state, Memory& mem);
    void handle_get_caller(CPUState& state, Memory& mem);
    // ... other handlers
};

