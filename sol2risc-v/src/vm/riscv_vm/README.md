# RISC-V Smart Contract VM

This project provides a basic implementation of a RISC-V (RV32I) Virtual Machine in C++, specifically designed with the goal of executing smart contracts transpiled from other bytecode formats (like EVM).

## Project Structure

```
riscv_vm/
├── include/         # Header files (.hpp)
│   ├── cpu_state.hpp
│   ├── elf_loader.hpp
│   ├── executor.hpp
│   ├── instruction_decoder.hpp
│   ├── memory.hpp
│   ├── riscv_vm.hpp
│   ├── syscall_handler.hpp
│   └── types.hpp
├── src/             # Source files (.cpp)
│   ├── cpu_state.cpp
│   ├── elf_loader.cpp
│   ├── executor.cpp
│   ├── instruction_decoder.cpp
│   ├── main.cpp
│   ├── memory.cpp
│   ├── riscv_vm.cpp
│   └── syscall_handler.cpp
├── CMakeLists.txt   # Build configuration
└── README.md        # This file

# Supporting Documents (Outside riscv_vm directory)
research_summary.md  # Summary of initial research
vm_design.md         # VM architecture design document
todo.md              # Task checklist used during development
```

## Features

*   **RV32I Instruction Set:** Implements the base integer instruction set.
*   **Memory Model:** Simple byte-addressable memory with bounds checking.
*   **ELF Loading:** Loads 32-bit RISC-V ELF executables using `libelf`.
*   **Smart Contract Syscalls:** Includes a `SmartContractSyscallHandler` with placeholder implementations for common blockchain interactions (storage read/write, get caller, etc.) via the `ECALL` instruction.
*   **Modular Design:** Components (CPU, Memory, Decoder, Executor, Syscall Handler) are separated into classes.

## Dependencies

*   **C++ Compiler:** A compiler supporting C++17 (e.g., g++ 7 or later, clang++ 5 or later).
*   **CMake:** Version 3.10 or later.
*   **libelf:** The ELF library development files.
    *   On Debian/Ubuntu: `sudo apt-get update && sudo apt-get install libelf-dev`
    *   On Fedora/CentOS: `sudo dnf install elfutils-libelf-devel`
    *   On macOS (using Homebrew): `brew install libelf` (May require adjusting CMake find paths)

## Build Instructions

1.  **Navigate to the `riscv_vm` directory:**
    ```bash
    cd /path/to/riscv_vm 
    ```

2.  **Create a build directory:**
    ```bash
    mkdir build
    cd build
    ```

3.  **Run CMake:**
    ```bash
    cmake ..
    ```

4.  **Compile the project:**
    ```bash
    make
    ```
    This will create an executable named `riscv_vm` in the `build` directory.

## Usage

```bash
./riscv_vm <elf_file> [memory_size_mb] [max_instructions]
```

*   `<elf_file>`: (Required) Path to the RISC-V 32-bit ELF executable file you want to run.
*   `[memory_size_mb]`: (Optional) The amount of memory to allocate for the VM in Megabytes. Defaults to 64 MB.
*   `[max_instructions]`: (Optional) The maximum number of instructions to execute before halting. Defaults to unlimited.

**Example:**

```bash
# Run my_contract.elf with default 64MB memory, no instruction limit
./riscv_vm ../path/to/my_contract.elf 

# Run my_contract.elf with 128MB memory
./riscv_vm ../path/to/my_contract.elf 128

# Run my_contract.elf with 32MB memory and limit to 1,000,000 instructions
./riscv_vm ../path/to/my_contract.elf 32 1000000
```

## Smart Contract Syscall ABI (Example)

The `SmartContractSyscallHandler` uses the following convention (modify as needed):

*   **Syscall Number:** Passed in register `a7` (x17).
*   **Arguments:** Passed in registers `a0` (x10) through `a6` (x16).
*   **Return Value:** Typically returned in register `a0` (x10).

**Defined Syscalls (in `syscall_handler.hpp`):**

*   `1001` (`SYSCALL_READ_STORAGE`): Reads from storage. `a0`=key_addr -> `a0`=value.
*   `1002` (`SYSCALL_WRITE_STORAGE`): Writes to storage. `a0`=key_addr, `a1`=value_addr.
*   `1003` (`SYSCALL_GET_CALLER`): Gets caller address. -> `a0`=caller_addr.
*   `1004` (`SYSCALL_GET_BLOCK_NUMBER`): Gets block number. -> `a0`=block_num.
*   `1005` (`SYSCALL_LOG_EVENT`): Logs event data. `a0`=data_addr, `a1`=length.
*   `0` (`SYSCALL_HALT`): Halts VM execution cleanly.

**Note:** The actual blockchain interaction logic in `syscall_handler.cpp` is currently placeholder code. You will need to replace this with actual logic that interacts with your specific blockchain environment.

## Further Development

*   Implement actual blockchain interactions in `SmartContractSyscallHandler`.
*   Add Gas Metering: Instrument the `Executor` to track and limit computational cost.
*   Implement RV32M (Multiply/Divide) extension.
*   Add support for Floating Point extensions (RV32F/D) if needed.
*   Implement Control and Status Registers (CSRs).
*   Add more robust error handling and testing (e.g., using RISC-V compliance tests).
*   Consider performance optimizations (e.g., basic block caching or JIT compilation).

