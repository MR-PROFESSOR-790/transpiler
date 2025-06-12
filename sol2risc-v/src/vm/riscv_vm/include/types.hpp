#pragma once

#include <cstdint>

using addr_t = uint32_t; // Address type (32-bit for RV32)
using word_t = uint32_t; // Word type (32-bit for RV32)
using s_word_t = int32_t; // Signed word type
using half_t = uint16_t; // Half-word type
using s_half_t = int16_t; // Signed half-word type
using byte_t = uint8_t;  // Byte type
using s_byte_t = int8_t;  // Signed byte type

constexpr size_t REG_COUNT = 32; // Number of general-purpose registers

