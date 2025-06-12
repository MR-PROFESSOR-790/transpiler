#include "memory.hpp"
#include <cstring> // For memcpy
#include <stdexcept>
#include <iostream> // For error reporting

Memory::Memory(size_t size_in_bytes) : mem(size_in_bytes, 0) { // Initialize memory with zeros
    if (size_in_bytes == 0) {
        throw std::invalid_argument("Memory size cannot be zero.");
    }
}

size_t Memory::size() const {
    return mem.size();
}

void Memory::check_bounds(addr_t addr, size_t access_size) const {
    if (addr > mem.size() || (addr + access_size) > mem.size()) {
        // Use cerr for error messages, similar to how exceptions might report.
        std::cerr << "Memory access violation: Address 0x" << std::hex << addr 
                  << " with size " << access_size << " out of bounds (Memory size: 0x" 
                  << mem.size() << ")" << std::dec << std::endl;
        throw std::out_of_range("Memory access out of bounds");
    }
}

void Memory::load_data(addr_t start_addr, const std::vector<byte_t>& data) {
    if (data.empty()) return;
    check_bounds(start_addr, data.size());
    std::memcpy(mem.data() + start_addr, data.data(), data.size());
}

// --- Read Operations --- //

byte_t Memory::read_byte(addr_t addr) const {
    check_bounds(addr, 1);
    return mem[addr];
}

half_t Memory::read_half(addr_t addr) const {
    check_bounds(addr, 2);
    // Assuming little-endian architecture for the host and target for simplicity
    // Real implementation might need to handle endianness conversion.
    half_t value = 0;
    value |= static_cast<half_t>(mem[addr + 1]) << 8;
    value |= static_cast<half_t>(mem[addr]);
    return value;
}

word_t Memory::read_word(addr_t addr) const {
    check_bounds(addr, 4);
    // Assuming little-endian
    word_t value = 0;
    value |= static_cast<word_t>(mem[addr + 3]) << 24;
    value |= static_cast<word_t>(mem[addr + 2]) << 16;
    value |= static_cast<word_t>(mem[addr + 1]) << 8;
    value |= static_cast<word_t>(mem[addr]);
    return value;
}

// --- Write Operations --- //

void Memory::write_byte(addr_t addr, byte_t value) {
    check_bounds(addr, 1);
    mem[addr] = value;
}

void Memory::write_half(addr_t addr, half_t value) {
    check_bounds(addr, 2);
    // Assuming little-endian
    mem[addr]     = static_cast<byte_t>(value & 0xFF);
    mem[addr + 1] = static_cast<byte_t>((value >> 8) & 0xFF);
}

void Memory::write_word(addr_t addr, word_t value) {
    check_bounds(addr, 4);
    // Assuming little-endian
    mem[addr]     = static_cast<byte_t>(value & 0xFF);
    mem[addr + 1] = static_cast<byte_t>((value >> 8) & 0xFF);
    mem[addr + 2] = static_cast<byte_t>((value >> 16) & 0xFF);
    mem[addr + 3] = static_cast<byte_t>((value >> 24) & 0xFF);
}

