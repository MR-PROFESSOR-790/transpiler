#pragma once

#include "types.hpp"
#include <vector>
#include <stdexcept>

class Memory {
public:
    // Constructor: Initializes memory with a given size (in bytes)
    explicit Memory(size_t size_in_bytes);

    // Load data into memory (e.g., from ELF loader)
    void load_data(addr_t start_addr, const std::vector<byte_t>& data);

    // Memory access methods
    byte_t read_byte(addr_t addr) const;
    half_t read_half(addr_t addr) const;
    word_t read_word(addr_t addr) const;

    void write_byte(addr_t addr, byte_t value);
    void write_half(addr_t addr, half_t value);
    void write_word(addr_t addr, word_t value);

    // Get memory size
    size_t size() const;

private:
    std::vector<byte_t> mem; // The actual memory storage

    // Helper for bounds checking
    void check_bounds(addr_t addr, size_t access_size) const;
};
