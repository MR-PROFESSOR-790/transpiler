#pragma once

#include "types.hpp"
#include <string>
#include <vector>

// Forward declaration
class Memory;

class ELFLoader {
public:
    // Loads an ELF file into the provided Memory object.
    // Returns the entry point address of the program.
    // Throws exceptions on errors (file not found, invalid format, etc.)
    addr_t load(const std::string& filename, Memory& mem);

private:
    // Helper functions for ELF parsing (implementation details)
};
