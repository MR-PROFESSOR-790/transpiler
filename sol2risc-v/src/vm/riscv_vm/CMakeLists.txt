cmake_minimum_required(VERSION 3.10)

project(riscv_vm_project CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Find libelf
find_package(LibElf REQUIRED)

# Include directories
include_directories(include)

# Source files
set(SOURCES
    src/cpu_state.cpp
    src/memory.cpp
    src/instruction_decoder.cpp
    src/executor.cpp
    src/syscall_handler.cpp
    src/elf_loader.cpp
    src/riscv_vm.cpp
    src/main.cpp # Will create this next
)

# Executable
add_executable(riscv_vm ${SOURCES})

# Link libraries
target_link_libraries(riscv_vm PRIVATE LibElf::LibElf)

# Optional: Add compiler flags for optimization or debugging
# target_compile_options(riscv_vm PRIVATE -O3)
# target_compile_options(riscv_vm PRIVATE -g)

message(STATUS "Configuring RISC-V VM project...")
message(STATUS "Include directory: ${CMAKE_SOURCE_DIR}/include")
message(STATUS "Sources: ${SOURCES}")
message(STATUS "Found LibElf: ${LibElf_FOUND}")
message(STATUS "LibElf include dirs: ${LibElf_INCLUDE_DIRS}")
message(STATUS "LibElf libraries: ${LibElf_LIBRARIES}")

