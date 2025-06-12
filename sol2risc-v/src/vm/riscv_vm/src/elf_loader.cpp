#include "elf_loader.hpp"
#include "memory.hpp"
#include <fcntl.h>    // For open
#include <unistd.h>   // For close, read
#include <libelf.h>   // Main libelf header
#include <gelf.h>     // Generic ELF header
#include <stdexcept>  // For exceptions
#include <iostream>   // For error messages
#include <vector>
#include <cstring>    // For strerror
#include <cerrno>     // For errno

addr_t ELFLoader::load(const std::string& filename, Memory& mem) {
    // 1. Initialize libelf
    if (elf_version(EV_CURRENT) == EV_NONE) {
        throw std::runtime_error("Failed to initialize libelf library: " + std::string(elf_errmsg(-1)));
    }

    // 2. Open the ELF file
    int fd = open(filename.c_str(), O_RDONLY);
    if (fd < 0) {
        throw std::runtime_error("Failed to open ELF file '" + filename + "': " + std::strerror(errno));
    }

    // 3. Begin processing the ELF file
    Elf* elf = elf_begin(fd, ELF_C_READ, nullptr);
    if (!elf) {
        close(fd);
        throw std::runtime_error("elf_begin() failed: " + std::string(elf_errmsg(-1)));
    }

    // 4. Check ELF kind (must be an executable)
    if (elf_kind(elf) != ELF_K_ELF) {
        elf_end(elf);
        close(fd);
        throw std::runtime_error("File '" + filename + "' is not an ELF file.");
    }

    // 5. Get the ELF header
    GElf_Ehdr ehdr;
    if (gelf_getehdr(elf, &ehdr) == nullptr) {
        elf_end(elf);
        close(fd);
        throw std::runtime_error("gelf_getehdr() failed: " + std::string(elf_errmsg(-1)));
    }

    // 6. Validate ELF header (check for RISC-V 32-bit)
    if (ehdr.e_machine != EM_RISCV || ehdr.e_ident[EI_CLASS] != ELFCLASS32) {
        elf_end(elf);
        close(fd);
        throw std::runtime_error("ELF file is not for RISC-V 32-bit architecture.");
    }
    if (ehdr.e_type != ET_EXEC) {
         std::cerr << "Warning: ELF file is not ET_EXEC type (it's " << ehdr.e_type << "). Loading anyway." << std::endl;
         // Allow loading non-executables for some testing scenarios, but warn.
    }

    // 7. Get Program Header information
    size_t phnum;
    if (elf_getphdrnum(elf, &phnum) != 0) {
        elf_end(elf);
        close(fd);
        throw std::runtime_error("elf_getphdrnum() failed: " + std::string(elf_errmsg(-1)));
    }

    // 8. Iterate through Program Headers and load segments
    for (size_t i = 0; i < phnum; ++i) {
        GElf_Phdr phdr;
        if (gelf_getphdr(elf, i, &phdr) == nullptr) {
            elf_end(elf);
            close(fd);
            throw std::runtime_error("gelf_getphdr() failed for segment " + std::to_string(i) + ": " + std::string(elf_errmsg(-1)));
        }

        // Load only PT_LOAD segments
        if (phdr.p_type == PT_LOAD) {
            if (phdr.p_filesz > 0) { // Only load if there's data in the file
                // Check if segment fits in VM memory
                if (phdr.p_vaddr + phdr.p_filesz > mem.size()) {
                    elf_end(elf);
                    close(fd);
                    throw std::runtime_error("ELF segment " + std::to_string(i) + " exceeds VM memory bounds.");
                }

                // Read segment data from file
                std::vector<byte_t> segment_data(phdr.p_filesz);
                // Seek to the segment offset in the file
                if (lseek(fd, phdr.p_offset, SEEK_SET) == -1) {
                     elf_end(elf);
                     close(fd);
                     throw std::runtime_error("lseek failed for segment " + std::to_string(i) + ": " + std::strerror(errno));
                }
                // Read the segment data
                ssize_t bytes_read = read(fd, segment_data.data(), phdr.p_filesz);
                if (bytes_read < 0 || static_cast<size_t>(bytes_read) != phdr.p_filesz) {
                    elf_end(elf);
                    close(fd);
                    throw std::runtime_error("Failed to read segment " + std::to_string(i) + " data from ELF file: " + (bytes_read < 0 ? std::strerror(errno) : "Incomplete read"));
                }

                // Load data into VM memory
                std::cout << "Loading segment " << i << " at 0x" << std::hex << phdr.p_vaddr 
                          << " (size: " << std::dec << phdr.p_filesz << " bytes)" << std::endl;
                mem.load_data(phdr.p_vaddr, segment_data);
            }

            // Handle .bss section (zero-initialized data)
            // If memory size (p_memsz) is larger than file size (p_filesz),
            // the difference needs to be zero-initialized in VM memory.
            if (phdr.p_memsz > phdr.p_filesz) {
                size_t bss_size = phdr.p_memsz - phdr.p_filesz;
                addr_t bss_start = phdr.p_vaddr + phdr.p_filesz;
                if (bss_start + bss_size > mem.size()) {
                     elf_end(elf);
                     close(fd);
                     throw std::runtime_error("ELF segment " + std::to_string(i) + " .bss section exceeds VM memory bounds.");
                }
                std::cout << "Zeroing .bss for segment " << i << " at 0x" << std::hex << bss_start 
                          << " (size: " << std::dec << bss_size << " bytes)" << std::endl;
                // Memory is already zero-initialized by constructor, but explicit zeroing is safer
                // if memory could be reused.
                for(size_t j = 0; j < bss_size; ++j) {
                    mem.write_byte(bss_start + j, 0);
                }
            }
        }
    }

    // 9. Get the entry point address
    addr_t entry_point = ehdr.e_entry;

    // 10. Clean up
    elf_end(elf);
    close(fd);

    std::cout << "ELF loaded successfully. Entry point: 0x" << std::hex << entry_point << std::dec << std::endl;
    return entry_point;
}

