
"""
environment.py - EVM execution environment for EVM to RISC-V transpiler
Manages EVM execution context, memory, storage, and other state elements
"""

import struct
from .riscv_emitter import RISCVEmitter


class EVMEnvironment:
    """
    Manages the EVM execution environment and state for the transpiler
    Handles memory operations, storage, and other environmental aspects
    """
    
    def __init__(self, emitter):
        """
        Initialize the EVM environment
        
        Args:
            emitter (RISCVEmitter): The RISC-V code emitter
        """
        self.emitter = emitter
        self._setup_memory_management()
        self._setup_storage_management()
        self._setup_context_management()

    def _setup_memory_management(self):
        """Setup memory management structures and functions"""
        # Generate memory section in the data segment
        self.emitter.section(".data")
        self.emitter.align(8)
        self.emitter.label("evm_memory_size")
        self.emitter.emit(".word 0")  # Current size of EVM memory (in 32-byte words)
        self.emitter.label("evm_memory")
        # Allocate initial 64KB memory space (can grow as needed)
        self.emitter.emit(".space 65536, 0")
        self.emitter.section(".text")
    
    def _setup_storage_management(self):
        """Setup storage management structures and functions"""
        # Generate storage section in the data segment
        self.emitter.section(".data")
        self.emitter.align(8)
        self.emitter.label("evm_storage_keys")
        # Pre-allocate space for 256 storage slots (can be expanded)
        self.emitter.emit(".space 8192, 0")  # 256 keys * 32 bytes
        self.emitter.label("evm_storage_values")
        self.emitter.emit(".space 8192, 0")  # 256 values * 32 bytes
        self.emitter.label("evm_storage_size")
        self.emitter.emit(".word 0")  # Number of used storage slots
        self.emitter.section(".text")
        
        # Generate hash table lookup function for storage
        self._generate_storage_lookup_function()
    
    def _setup_context_management(self):
        """Setup execution context management"""
        # Generate context section in the data segment
        self.emitter.section(".data")
        self.emitter.align(8)
        
        # EVM context variables
        self.emitter.label("evm_address")
        self.emitter.emit(".space 20, 0")  # Current contract address (20 bytes)
        
        self.emitter.label("evm_caller")
        self.emitter.emit(".space 20, 0")  # Caller address (20 bytes)
        
        self.emitter.label("evm_callvalue")
        self.emitter.emit(".space 32, 0")  # Call value (32 bytes)
        
        self.emitter.label("evm_calldata")
        self.emitter.emit(".space 1024, 0")  # Initial calldata buffer (1KB)
        
        self.emitter.label("evm_calldata_size")
        self.emitter.emit(".word 0")  # Size of calldata
        
        self.emitter.label("evm_return_data")
        self.emitter.emit(".space 1024, 0")  # Return data buffer (1KB)
        
        self.emitter.label("evm_return_size")
        self.emitter.emit(".word 0")  # Size of return data
        
        self.emitter.label("evm_gas_left")
        self.emitter.emit(".word 0")  # Gas left
        
        self.emitter.section(".text")
    
    def handle_mload(self):
        """
        Handles EVM MLOAD operation (0x51)
        Load a 32-byte word from memory at the given offset
        """
        self.emitter.comment("MLOAD operation")
        self.emitter.pop_to_register("a0")  # Pop offset from stack
        
        # Ensure memory is expanded to include this offset
        self._ensure_memory_size("a0")
        
        # Calculate memory address: evm_memory + offset
        self.emitter.emit("la t0, evm_memory")
        self.emitter.emit("add t0, t0, a0")  # t0 = evm_memory + offset
        
        # Load 32 bytes (word) from memory
        # RISC-V is typically 32-bit or 64-bit, so we need multiple loads
        for i in range(4):  # 4 * 8 bytes = 32 bytes
            self.emitter.emit(f"ld t{i+1}, {i*8}(t0)")
        
        # Push result to stack (need to save to memory temporarily)
        self.emitter.emit("la a0, evm_return_data")  # Use return data as temp
        for i in range(4):
            self.emitter.emit(f"sd t{i+1}, {i*8}(a0)")
        
        # Load full 32 bytes to a0-a4 and push to stack
        self.emitter.emit("ld a0, 0(a0)")
        self.emitter.push_from_register("a0")
    
    def handle_mstore(self):
        """
        Handles EVM MSTORE operation (0x52)
        Store a 32-byte word to memory at the given offset
        """
        self.emitter.comment("MSTORE operation")
        self.emitter.pop_to_register("a1")  # Pop value from stack
        self.emitter.pop_to_register("a0")  # Pop offset from stack
        
        # Ensure memory is expanded to include this offset
        self._ensure_memory_size("a0")
        
        # Calculate memory address: evm_memory + offset
        self.emitter.emit("la t0, evm_memory")
        self.emitter.emit("add t0, t0, a0")  # t0 = evm_memory + offset
        
        # Store 32-byte word to memory
        # Store the value (in a1) to memory (at t0)
        self.emitter.emit("sd a1, 0(t0)")  # Store lower 8 bytes
        
        # For a full 32-byte (256-bit) store, we would need more registers and operations
        # This is simplified - in a real implementation, we'd need to handle the full 32 bytes
        self.emitter.emit("li t1, 0")  # Upper bytes are zeros for now
        self.emitter.emit("sd t1, 8(t0)")
        self.emitter.emit("sd t1, 16(t0)")
        self.emitter.emit("sd t1, 24(t0)")
    
    def handle_mstore8(self):
        """
        Handles EVM MSTORE8 operation (0x53)
        Store a single byte to memory at the given offset
        """
        self.emitter.comment("MSTORE8 operation")
        self.emitter.pop_to_register("a1")  # Pop value from stack
        self.emitter.pop_to_register("a0")  # Pop offset from stack
        
        # Ensure memory is expanded to include this offset
        self._ensure_memory_size("a0")
        
        # Calculate memory address: evm_memory + offset
        self.emitter.emit("la t0, evm_memory")
        self.emitter.emit("add t0, t0, a0")  # t0 = evm_memory + offset
        
        # Extract lowest byte from value and store it
        self.emitter.emit("andi a1, a1, 0xFF")  # Keep only lowest byte
        self.emitter.emit("sb a1, 0(t0)")  # Store byte to memory
    
    def handle_sload(self):
        """
        Handles EVM SLOAD operation (0x54)
        Load a 32-byte word from storage at the given key
        """
        self.emitter.comment("SLOAD operation")
        self.emitter.pop_to_register("a0")  # Pop key from stack
        
        # Call the storage lookup function
        self.emitter.emit("call storage_lookup")
        
        # Result is in a0, push it to stack
        self.emitter.push_from_register("a0")
    
    def handle_sstore(self):
        """
        Handles EVM SSTORE operation (0x55)
        Store a 32-byte word to storage at the given key
        """
        self.emitter.comment("SSTORE operation")
        self.emitter.pop_to_register("a1")  # Pop value from stack
        self.emitter.pop_to_register("a0")  # Pop key from stack
        
        # Call the storage update function
        self.emitter.emit("call storage_update")
    
    def handle_address(self):
        """
        Handles EVM ADDRESS operation (0x30)
        Get the current contract address
        """
        self.emitter.comment("ADDRESS operation")
        
        # Load contract address to a0
        self.emitter.emit("la t0, evm_address")
        self.emitter.emit("ld a0, 0(t0)")
        # For a full 20-byte address, we would need more loads
        
        # Push address to stack
        self.emitter.push_from_register("a0")
    
    def handle_balance(self):
        """
        Handles EVM BALANCE operation (0x31)
        Get balance of the given address
        """
        self.emitter.comment("BALANCE operation")
        self.emitter.pop_to_register("a0")  # Pop address from stack
        
        # In a real implementation, this would call to the host environment
        # For now, just return a placeholder value
        self.emitter.emit("li a0, 1000000")  # Placeholder balance
        
        # Push balance to stack
        self.emitter.push_from_register("a0")
    
    def handle_origin(self):
        """
        Handles EVM ORIGIN operation (0x32)
        Get the transaction origin address
        """
        self.emitter.comment("ORIGIN operation")
        
        # In a real implementation, this would get the transaction origin
        # For now, just use caller as a placeholder
        self.emitter.emit("la t0, evm_caller")
        self.emitter.emit("ld a0, 0(t0)")
        
        # Push origin to stack
        self.emitter.push_from_register("a0")
    
    def handle_caller(self):
        """
        Handles EVM CALLER operation (0x33)
        Get the caller address
        """
        self.emitter.comment("CALLER operation")
        
        # Load caller address to a0
        self.emitter.emit("la t0, evm_caller")
        self.emitter.emit("ld a0, 0(t0)")
        
        # Push caller to stack
        self.emitter.push_from_register("a0")
    
    def handle_callvalue(self):
        """
        Handles EVM CALLVALUE operation (0x34)
        Get the call value (in wei)
        """
        self.emitter.comment("CALLVALUE operation")
        
        # Load call value to a0
        self.emitter.emit("la t0, evm_callvalue")
        self.emitter.emit("ld a0, 0(t0)")
        
        # Push call value to stack
        self.emitter.push_from_register("a0")
    
    def handle_calldataload(self):
        """
        Handles EVM CALLDATALOAD operation (0x35)
        Load 32 bytes from call data at the given offset
        """
        self.emitter.comment("CALLDATALOAD operation")
        self.emitter.pop_to_register("a0")  # Pop offset from stack
        
        # Bound check offset
        self.emitter.emit("la t0, evm_calldata_size")
        self.emitter.emit("lw t0, 0(t0)")
        self.emitter.emit("bge a0, t0, calldataload_outofbounds")
        
        # Calculate calldata address: evm_calldata + offset
        self.emitter.emit("la t0, evm_calldata")
        self.emitter.emit("add t0, t0, a0")
        
        # Load 32 bytes (word) from calldata
        # For a real implementation, need to handle end-of-calldata padding with zeros
        self.emitter.emit("ld a0, 0(t0)")
        self.emitter.emit("j calldataload_end")
        
        # Out of bounds case - return 0
        self.emitter.label("calldataload_outofbounds")
        self.emitter.emit("li a0, 0")
        
        self.emitter.label("calldataload_end")
        # Push result to stack
        self.emitter.push_from_register("a0")
    
    def handle_calldatasize(self):
        """
        Handles EVM CALLDATASIZE operation (0x36)
        Get the size of call data
        """
        self.emitter.comment("CALLDATASIZE operation")
        
        # Load calldata size to a0
        self.emitter.emit("la t0, evm_calldata_size")
        self.emitter.emit("lw a0, 0(t0)")
        
        # Push calldata size to stack
        self.emitter.push_from_register("a0")
    
    def handle_calldatacopy(self):
        """
        Handles EVM CALLDATACOPY operation (0x37)
        Copy calldata to memory
        """
        self.emitter.comment("CALLDATACOPY operation")
        self.emitter.pop_to_register("a2")  # Pop size from stack
        self.emitter.pop_to_register("a1")  # Pop calldata offset from stack
        self.emitter.pop_to_register("a0")  # Pop memory offset from stack
        
        # Ensure memory is expanded to include this operation
        self._ensure_memory_size_range("a0", "a2")
        
        # Calculate memory address: evm_memory + memOffset
        self.emitter.emit("la t0, evm_memory")
        self.emitter.emit("add t0, t0, a0")  # t0 = evm_memory + memOffset
        
        # Calculate calldata address: evm_calldata + calldataOffset
        self.emitter.emit("la t1, evm_calldata")
        self.emitter.emit("add t1, t1, a1")  # t1 = evm_calldata + calldataOffset
        
        # Get calldata size for bounds checking
        self.emitter.emit("la t2, evm_calldata_size")
        self.emitter.emit("lw t2, 0(t2)")
        
        # Copy loop
        self.emitter.label("calldatacopy_loop")
        self.emitter.emit("beqz a2, calldatacopy_end")  # Exit if size == 0
        
        # Bounds check
        self.emitter.emit("bge a1, t2, calldatacopy_outofbounds")
        
        # Copy byte
        self.emitter.emit("lb t3, 0(t1)")
        self.emitter.emit("sb t3, 0(t0)")
        
        # Update pointers and counters
        self.emitter.emit("addi t0, t0, 1")
        self.emitter.emit("addi t1, t1, 1")
        self.emitter.emit("addi a1, a1, 1")
        self.emitter.emit("addi a2, a2, -1")
        self.emitter.emit("j calldatacopy_loop")
        
        # Out of bounds case - pad with zeros
        self.emitter.label("calldatacopy_outofbounds")
        self.emitter.emit("li t3, 0")
        self.emitter.emit("sb t3, 0(t0)")
        self.emitter.emit("addi t0, t0, 1")
        self.emitter.emit("addi a2, a2, -1")
        self.emitter.emit("j calldatacopy_loop")
        
        self.emitter.label("calldatacopy_end")
    
    def handle_codesize(self):
        """
        Handles EVM CODESIZE operation (0x38)
        Get the code size of the current contract
        """
        self.emitter.comment("CODESIZE operation")
        
        # In a real implementation, this would be determined at transpile time
        # For now, just use a placeholder value
        self.emitter.emit("li a0, 100")  # Placeholder code size
        
        # Push code size to stack
        self.emitter.push_from_register("a0")
    
    def handle_return(self):
        """
        Handles EVM RETURN operation (0xF3)
        Return data from the current execution context
        """
        self.emitter.comment("RETURN operation")
        self.emitter.pop_to_register("a1")  # Pop size from stack
        self.emitter.pop_to_register("a0")  # Pop offset from stack
        
        # Calculate memory address: evm_memory + offset
        self.emitter.emit("la t0, evm_memory")
        self.emitter.emit("add t0, t0, a0")  # t0 = evm_memory + offset
        
        # Save return size
        self.emitter.emit("la t1, evm_return_size")
        self.emitter.emit("sw a1, 0(t1)")
        
        # Copy data to return buffer
        self.emitter.emit("la t1, evm_return_data")
        
        # Copy loop (would need bounds checking in practice)
        self.emitter.label("return_copy_loop")
        self.emitter.emit("beqz a1, return_copy_end")  # Exit if size == 0
        
        # Copy byte
        self.emitter.emit("lb t2, 0(t0)")
        self.emitter.emit("sb t2, 0(t1)")
        
        # Update pointers and counter
        self.emitter.emit("addi t0, t0, 1")
        self.emitter.emit("addi t1, t1, 1")
        self.emitter.emit("addi a1, a1, -1")
        self.emitter.emit("j return_copy_loop")
        
        self.emitter.label("return_copy_end")
        
        # End program execution
        self.emitter.emit("li a0, 0")  # Success status
        self.emitter.emit("j evm_exit")
    
    def handle_revert(self):
        """
        Handles EVM REVERT operation (0xFD)
        Revert state changes and return data
        """
        self.emitter.comment("REVERT operation")
        self.emitter.pop_to_register("a1")  # Pop size from stack
        self.emitter.pop_to_register("a0")  # Pop offset from stack
        
        # Copy logic similar to RETURN
        # Calculate memory address: evm_memory + offset
        self.emitter.emit("la t0, evm_memory")
        self.emitter.emit("add t0, t0, a0")  # t0 = evm_memory + offset
        
        # Save return size
        self.emitter.emit("la t1, evm_return_size")
        self.emitter.emit("sw a1, 0(t1)")
        
        # Copy data to return buffer
        self.emitter.emit("la t1, evm_return_data")
        
        # Copy loop (would need bounds checking in practice)
        self.emitter.label("revert_copy_loop")
        self.emitter.emit("beqz a1, revert_copy_end")  # Exit if size == 0
        
        # Copy byte
        self.emitter.emit("lb t2, 0(t0)")
        self.emitter.emit("sb t2, 0(t1)")
        
        # Update pointers and counter
        self.emitter.emit("addi t0, t0, 1")
        self.emitter.emit("addi t1, t1, 1")
        self.emitter.emit("addi a1, a1, -1")
        self.emitter.emit("j revert_copy_loop")
        
        self.emitter.label("revert_copy_end")
        
        # End program execution with error status
        self.emitter.emit("li a0, 1")  # Error status
        self.emitter.emit("j evm_exit")
    
    def _ensure_memory_size(self, offset_reg):
        """
        Ensure memory is expanded to include the given offset
        
        Args:
            offset_reg (str): Register containing the offset
        """
        self.emitter.comment("Ensure memory size includes offset")
        
        # Calculate word index (divide by 32)
        self.emitter.emit(f"srli t0, {offset_reg}, 5")  # t0 = offset / 32
        self.emitter.emit("addi t0, t0, 1")  # Add 1 to include the word containing the offset
        
        # Get current memory size
        self.emitter.emit("la t1, evm_memory_size")
        self.emitter.emit("lw t1, 0(t1)")
        
        # If current size is sufficient, skip expansion
        self.emitter.emit("bgeu t1, t0, memory_size_ok")
        
        # Update memory size if needed
        self.emitter.emit("la t1, evm_memory_size")
        self.emitter.emit("sw t0, 0(t1)")
        
        self.emitter.label("memory_size_ok")
    
    def _ensure_memory_size_range(self, offset_reg, size_reg):
        """
        Ensure memory is expanded to include a range from offset to offset+size
        
        Args:
            offset_reg (str): Register containing the offset
            size_reg (str): Register containing the size
        """
        self.emitter.comment("Ensure memory size includes offset+size range")
        
        # Calculate end offset
        self.emitter.emit(f"add t0, {offset_reg}, {size_reg}")
        
        # Calculate word index (divide by 32)
        self.emitter.emit("srli t0, t0, 5")  # t0 = (offset+size) / 32
        self.emitter.emit("addi t0, t0, 1")  # Add 1 to include the word containing the end offset
        
        # Get current memory size
        self.emitter.emit("la t1, evm_memory_size")
        self.emitter.emit("lw t1, 0(t1)")
        
        # If current size is sufficient, skip expansion
        self.emitter.emit("bgeu t1, t0, memory_range_size_ok")
        
        # Update memory size if needed
        self.emitter.emit("la t1, evm_memory_size")
        self.emitter.emit("sw t0, 0(t1)")
        
        self.emitter.label("memory_range_size_ok")
    
    def _generate_storage_lookup_function(self):
        """Generate helper function for storage lookup"""
        self.emitter.section(".text")
        
        # Storage lookup function
        self.emitter.comment("Storage lookup function")
        self.emitter.label("storage_lookup")
        
        # Function prologue
        self.emitter.emit("addi sp, sp, -16")
        self.emitter.emit("sw ra, 12(sp)")
        self.emitter.emit("sw s0, 8(sp)")
        self.emitter.emit("sw s1, 4(sp)")
        self.emitter.emit("sw s2, 0(sp)")
        
        # s0 = key, s1 = storage_size, s2 = index
        self.emitter.emit("mv s0, a0")    # Save key
        
        # Get storage size
        self.emitter.emit("la t0, evm_storage_size")
        self.emitter.emit("lw s1, 0(t0)")
        
        # Initialize index
        self.emitter.emit("li s2, 0")
        
        # Start of lookup loop
        self.emitter.label("storage_lookup_loop")
        self.emitter.emit("bge s2, s1, storage_lookup_not_found")  # If index >= size, key not found
        
        # Get key at current index
        self.emitter.emit("la t0, evm_storage_keys")
        self.emitter.emit("slli t1, s2, 5")  # t1 = s2 * 32 (each key is 32 bytes)
        self.emitter.emit("add t0, t0, t1")  # t0 = evm_storage_keys + (index * 32)
        self.emitter.emit("ld t2, 0(t0)")    # Load key
        
        # Compare keys
        self.emitter.emit("bne t2, s0, storage_lookup_next")  # If keys don't match, try next
        
        # Key found, load value
        self.emitter.emit("la t0, evm_storage_values")
        self.emitter.emit("add t0, t0, t1")  # t0 = evm_storage_values + (index * 32)
        self.emitter.emit("ld a0, 0(t0)")    # Load value
        self.emitter.emit("j storage_lookup_end")
        
        # Try next index
        self.emitter.label("storage_lookup_next")
        self.emitter.emit("addi s2, s2, 1")
        self.emitter.emit("j storage_lookup_loop")
        
        # Key not found, return 0
        self.emitter.label("storage_lookup_not_found")
        self.emitter.emit("li a0, 0")
        
        # Function epilogue
        self.emitter.label("storage_lookup_end")
        self.emitter.emit("lw ra, 12(sp)")
        self.emitter.emit("lw s0, 8(sp)")
        self.emitter.emit("lw s1, 4(sp)")
        self.emitter.emit("lw s2, 0(sp)")
        self.emitter.emit("addi sp, sp, 16")
        self.emitter.emit("ret")
        
        # Storage update function
        self.emitter.comment("Storage update function")
        self.emitter.label("storage_update")
        
        # Function prologue
        self.emitter.emit("addi sp, sp, -16")
        self.emitter.emit("sw ra, 12(sp)")
        self.emitter.emit("sw s0, 8(sp)")
        self.emitter.emit("sw s1, 4(sp)")
        self.emitter.emit("sw s2, 0(sp)")
        
        # s0 = key, s1 = value, s2 = storage_size
        self.emitter.emit("mv s0, a0")    # Save key
        self.emitter.emit("mv s1, a1")    # Save value
        
        # Get storage size
        self.emitter.emit("la t0, evm_storage_size")
        self.emitter.emit("lw s2, 0(t0)")
        
        # Initialize index
        self.emitter.emit("li t1, 0")
        
        # Start of lookup loop
        self.emitter.label("storage_update_loop")
        self.emitter.emit("bge t1, s2, storage_update_not_found")  # If index >= size, key not found
        
        # Get key at current index
        self.emitter.emit("la t0, evm_storage_keys")
        self.emitter.emit("slli t2, t1, 5")  # t2 = t1 * 32 (each key is 32 bytes)
        self.emitter.emit("add t0, t0, t2")  # t0 = evm_storage_keys + (index * 32)
        self.emitter.emit("ld t3, 0(t0)")    # Load key
        
        # Compare keys
        self.emitter.emit("bne t3, s0, storage_update_next")  # If keys don't match, try next
        
        # Key found, update value
        self.emitter.emit("la t0, evm_storage_values")
        self.emitter.emit("add t0, t0, t2")  # t0 = evm_storage_values + (index * 32)
        self.emitter.emit("sd s1, 0(t0)")    # Store value
        self.emitter.emit("j storage_update_end")
        
        # Try next index
        self.emitter.label("storage_update_next")
        self.emitter.emit("addi t1, t1, 1")
        self.emitter.emit("j storage_update_loop")
        
        # Key not found, add new entry
        self.emitter.label("storage_update_not_found")
        
        # Store key
        self.emitter.emit("la t0, evm_storage_keys")
        self.emitter.emit("slli t1, s2, 5")  # t1 = s2 * 32 (each key is 32 bytes)
        self.emitter.emit("add t0, t0, t1")  # t0 = evm_storage_keys + (size * 32)
        self.emitter.emit("sd s0, 0(t0)")    # Store key
        
        # Store value
        self.emitter.emit("la t0, evm_storage_values")
        self.emitter.emit("add t0, t0, t1")  # t0 = evm_storage_values + (size * 32)
        self.emitter.emit("sd s1, 0(t0)")    # Store value
        
        # Increment storage size
        self.emitter.emit("addi s2, s2, 1")
        self.emitter.emit("la t0, evm_storage_size")
        self.emitter.emit("sw s2, 0(t0)")
        
        # Function epilogue
        self.emitter.label("storage_update_end")
        self.emitter.emit("lw ra, 12(sp)")
        self.emitter.emit("lw s0, 8(sp)")
        self.emitter.emit("lw s1, 4(sp)")
        self.emitter.emit("lw s2, 0(sp)")
        self.emitter.emit("addi sp, sp, 16")
        self.emitter.emit("ret")

    def handle_gas_remaining(self):
        """Handle EVM GAS operation (0x5A)"""
        self.emitter.comment("GAS operation")
        self.emitter.emit("la t0, evm_gas_left")
        self.emitter.emit("lw a0, 0(t0)")
        self.emitter.push_from_register("a0")

    def handle_create(self):
        """Handle EVM CREATE operation (0xF0)"""
        self.emitter.comment("CREATE operation - placeholder")
        self.emitter.emit("li a0, 0")  # Return 0 address for now
        self.emitter.push_from_register("a0")
    
    def handle_create2(self):
        """Handle EVM CREATE2 operation (0xF5)"""
        self.emitter.comment("CREATE2 operation - placeholder")
        self.emitter.emit("li a0, 0")  # Return 0 address for now
        self.emitter.push_from_register("a0")

    def handle_selfdestruct(self):
        """Handle EVM SELFDESTRUCT operation (0xFF)"""
        self.emitter.comment("SELFDESTRUCT operation")
        self.emitter.pop_to_register("a0")  # Pop beneficiary address
        self.emitter.emit("j evm_exit")  # Exit program

    def initialize_context(self, caller, value, calldata, calldata_size):
        """Initialize the EVM execution context with given parameters"""
        self.emitter.comment("Initialize EVM context")
        
        # Set caller
        self.emitter.emit("la t0, evm_caller")
        self.emitter.emit(f"li t1, {caller}")
        self.emitter.emit("sd t1, 0(t0)")
        
        # Set call value
        self.emitter.emit("la t0, evm_callvalue")
        self.emitter.emit(f"li t1, {value}")
        self.emitter.emit("sd t1, 0(t0)")
        
        # Set call data and size
        self.emitter.emit("la t0, evm_calldata_size")
        self.emitter.emit(f"li t1, {calldata_size}")
        self.emitter.emit("sw t1, 0(t0)")
        
        if calldata and calldata_size > 0:
            self.emitter.emit("la t0, evm_calldata")
            for i, byte in enumerate(calldata[:calldata_size]):
                self.emitter.emit(f"li t1, {byte}")
                self.emitter.emit(f"sb t1, {i}(t0)")

    def cleanup(self):
        """Cleanup resources before exit"""
        self.emitter.comment("Cleanup EVM environment")
        # Add any necessary cleanup code here
        pass