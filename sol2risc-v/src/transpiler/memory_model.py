class EVMMemoryModel:
    
    def __init__(self, riscv_emitter):
        self.emitter = riscv_emitter
        self.memory_base_reg = "s0"  # Register containing base address of EVM memory
        self.memory_size_reg = "s1"  # Register tracking current memory size in bytes
        self.max_memory_size = "s2"  # Track max allowed memory size
        self.memory_snapshots = "s3"  # Base register for memory snapshots
        self.stats_base = "s4"       # Base register for memory statistics
        
    def init_memory(self):
        
        # Initialize memory size to 0
        self.emitter.emit(f"li {self.memory_size_reg}, 0")
        self.emitter.emit(f"li {self.max_memory_size}, 0x40000000")  # 1GB max memory
        self.emitter.emit(f"li {self.stats_base}, 0")
        self._init_stats()
    
    def _init_stats(self):
        """Initialize memory statistics tracking"""
        self.emitter.emit(f"# Initialize memory stats")
        self.emitter.emit(f"sw zero, 0({self.stats_base})  # Total allocations")
        self.emitter.emit(f"sw zero, 4({self.stats_base})  # Peak memory usage")
        self.emitter.emit(f"sw zero, 8({self.stats_base})  # Number of expansions")
    
    def create_snapshot(self, snapshot_id_reg):
        """Create a memory snapshot for reverting"""
        self.emitter.emit(f"# Save current memory state")
        self.emitter.emit(f"slli t0, {snapshot_id_reg}, 3")  # Multiply by 8 for offset
        self.emitter.emit(f"add t0, {self.memory_snapshots}, t0")
        self.emitter.emit(f"sw {self.memory_size_reg}, 0(t0)")
        self.emitter.emit(f"sw {self.memory_base_reg}, 4(t0)")
    
    def revert_to_snapshot(self, snapshot_id_reg):
        """Revert memory to a previous snapshot"""
        self.emitter.emit(f"# Restore memory state")
        self.emitter.emit(f"slli t0, {snapshot_id_reg}, 3")
        self.emitter.emit(f"add t0, {self.memory_snapshots}, t0")
        self.emitter.emit(f"lw {self.memory_size_reg}, 0(t0)")
        self.emitter.emit(f"lw {self.memory_base_reg}, 4(t0)")
    
    def ensure_memory_size(self, offset_reg=None, size_reg=None, end_offset_reg=None):
       
        if end_offset_reg is None and (offset_reg is not None and size_reg is not None):
            # Calculate end offset
            self.emitter.emit(f"add t0, {offset_reg}, {size_reg}")
            end_offset_reg = "t0"
        elif end_offset_reg is None:
            raise ValueError("Must provide either end_offset_reg or both offset_reg and size_reg")
        
        # Check if we need to expand memory
        self.emitter.emit(f"bgeu {self.memory_size_reg}, {end_offset_reg}, memory_size_ok")
        
        # Need to expand memory - round up to word size (32 bytes in EVM)
        self.emitter.emit(f"addi t0, {end_offset_reg}, 31")  # t0 = end_offset + 31
        self.emitter.emit(f"andi t0, t0, -32")              # t0 = (end_offset + 31) & ~31
        
        # Add bounds checking
        self.emitter.emit(f"bgeu t0, {self.max_memory_size}, memory_out_of_bounds")
        
        # Track peak memory usage
        self.emitter.emit(f"lw t1, 4({self.stats_base})")
        self.emitter.emit(f"bgeu t1, t0, skip_peak_update")
        self.emitter.emit(f"sw t0, 4({self.stats_base})")
        self.emitter.emit(f"skip_peak_update:")
        
        # Zero new memory
        self._zero_new_memory(self.memory_size_reg, "t0")
        
        # Update memory size
        self.emitter.emit(f"mv {self.memory_size_reg}, t0")
        
        self.emitter.emit(f"memory_size_ok:")
    
    def _zero_new_memory(self, start_reg, end_reg):
        """Zero newly allocated memory"""
        self.emitter.emit(f"mv t5, {start_reg}")
        self.emitter.emit(f"zero_mem_loop:")
        self.emitter.emit(f"bgeu t5, {end_reg}, zero_mem_done")
        self.emitter.emit(f"sw zero, 0(t5)")
        self.emitter.emit(f"addi t5, t5, 4")
        self.emitter.emit(f"j zero_mem_loop")
        self.emitter.emit(f"zero_mem_done:")
    
    def validate_offset(self, offset_reg):
        """Validate memory offset is non-negative"""
        # Check for negative offset
        self.emitter.emit(f"bgez {offset_reg}, offset_valid")
        self.emitter.emit(f"li a0, 1")  # Error code 1: negative offset
        self.emitter.emit(f"j memory_error")
        self.emitter.emit(f"offset_valid:")
    
    def mload(self, offset_reg, dest_reg):
        """
        Implement MLOAD operation
        
        Loads 32 bytes (256 bits) from memory at the given offset into dest_reg
        """
        self.validate_offset(offset_reg)
        
        # Calculate end offset for memory expansion check
        self.emitter.emit(f"addi t0, {offset_reg}, 32")
        self.ensure_memory_size(end_offset_reg="t0")
        
        # In a real implementation, we'd need to handle loading 256-bit values
        # This simplified version assumes 32-bit registers and only loads one word
        
        # Load from memory
        self.emitter.emit(f"add t0, {self.memory_base_reg}, {offset_reg}")
        self.emitter.emit(f"lw {dest_reg}, 0(t0)")
        
        # Real implementation would need multiple loads for 256-bit value
        self.emitter.emit(f"# NOTE: Full implementation would load all 32 bytes")
    
    def mstore(self, offset_reg, value_reg):
        """
        Implement MSTORE operation
        
        Stores 32 bytes (256 bits) to memory at the given offset
        """
        self.validate_offset(offset_reg)
        
        # Calculate end offset for memory expansion check
        self.emitter.emit(f"addi t0, {offset_reg}, 32")
        self.ensure_memory_size(end_offset_reg="t0")
        
        # In a real implementation, we'd need to handle storing 256-bit values
        # This simplified version assumes 32-bit registers and only stores one word
        
        # Store to memory
        self.emitter.emit(f"add t0, {self.memory_base_reg}, {offset_reg}")
        self.emitter.emit(f"sw {value_reg}, 0(t0)")
        
        # Real implementation would need multiple stores for 256-bit value
        self.emitter.emit(f"# NOTE: Full implementation would store all 32 bytes")
    
    def mstore8(self, offset_reg, value_reg):
        """
        Implement MSTORE8 operation
        
        Stores a single byte to memory at the given offset
        """
        self.validate_offset(offset_reg)
        
        # Calculate end offset for memory expansion check
        self.emitter.emit(f"addi t0, {offset_reg}, 1")
        self.ensure_memory_size(end_offset_reg="t0")
        
        # Store single byte to memory
        self.emitter.emit(f"andi t0, {value_reg}, 0xFF")  # Get lowest byte
        self.emitter.emit(f"add t1, {self.memory_base_reg}, {offset_reg}")
        self.emitter.emit(f"sb t0, 0(t1)")
    
    def mcopy(self, dest_offset_reg, src_offset_reg, size_reg):
        """
        Implement memory copy operation
        
        Copies `size` bytes from `src_offset` to `dest_offset`
        """
        self.validate_offset(dest_offset_reg)
        self.validate_offset(src_offset_reg)
        
        # Validate size is non-negative
        self.emitter.emit(f"bgez {size_reg}, size_valid")
        self.emitter.emit(f"li a0, 2")  # Error code 2: negative size
        self.emitter.emit(f"j memory_error")
        self.emitter.emit(f"size_valid:")
        
        # Ensure memory is large enough for both source and destination
        self.emitter.emit(f"add t0, {dest_offset_reg}, {size_reg}")
        self.ensure_memory_size(end_offset_reg="t0")
        
        self.emitter.emit(f"add t0, {src_offset_reg}, {size_reg}")
        self.ensure_memory_size(end_offset_reg="t0")
        
        # Set up pointers
        self.emitter.emit(f"add t0, {self.memory_base_reg}, {dest_offset_reg}")  # t0 = dest pointer
        self.emitter.emit(f"add t1, {self.memory_base_reg}, {src_offset_reg}")   # t1 = src pointer
        
        # Check for zero size
        self.emitter.emit(f"beqz {size_reg}, mcopy_done")
        
        # Check word alignment
        self.emitter.emit(f"andi t3, {dest_offset_reg}, 3")
        self.emitter.emit(f"andi t4, {src_offset_reg}, 3")
        self.emitter.emit(f"or t3, t3, t4")
        self.emitter.emit(f"bnez t3, mcopy_byte")  # Not aligned, use byte copy
        
        # Word-aligned copy
        self.emitter.emit(f"srli t3, {size_reg}, 2")  # Size in words
        self.emitter.emit(f"mcopy_word_loop:")
        self.emitter.emit(f"beqz t3, mcopy_remainder")
        self.emitter.emit(f"lw t4, 0(t1)")
        self.emitter.emit(f"sw t4, 0(t0)")
        self.emitter.emit(f"addi t0, t0, 4")
        self.emitter.emit(f"addi t1, t1, 4")
        self.emitter.emit(f"addi t3, t3, -1")
        self.emitter.emit(f"j mcopy_word_loop")
        
        self.emitter.emit(f"mcopy_remainder:")
        self.emitter.emit(f"andi t3, {size_reg}, 3")  # Remaining bytes
        self.emitter.emit(f"beqz t3, mcopy_done")
        
        self.emitter.emit(f"mcopy_byte:")
        self.emitter.emit(f"li t2, 0")  # t2 = index
        
        self.emitter.emit(f"mcopy_forward_loop:")
        self.emitter.emit(f"bgeu t2, {size_reg}, mcopy_done")
        self.emitter.emit(f"add t3, t1, t2")
        self.emitter.emit(f"lb t4, 0(t3)")
        self.emitter.emit(f"add t3, t0, t2")
        self.emitter.emit(f"sb t4, 0(t3)")
        self.emitter.emit(f"addi t2, t2, 1")
        self.emitter.emit(f"j mcopy_forward_loop")
        
        self.emitter.emit(f"mcopy_done:")
    
    def memory_error(self):
        """Generate error handling code"""
        self.emitter.emit(f"memory_error:")
        self.emitter.emit(f"# Handle memory error based on error code in a0")
        self.emitter.emit(f"j revert")  # Jump to EVM revert handler
        self.emitter.emit(f"memory_out_of_bounds:")
        self.emitter.emit(f"li a0, 3")  # Error code 3: memory limit exceeded
        self.emitter.emit(f"j memory_error")
    
    def get_size(self, dest_reg):
        
        self.emitter.emit(f"mv {dest_reg}, {self.memory_size_reg}")
    
    def get_stats(self, stat_type_reg, dest_reg):
        """Get memory statistics"""
        self.emitter.emit(f"slli t0, {stat_type_reg}, 2")
        self.emitter.emit(f"add t0, {self.stats_base}, t0")
        self.emitter.emit(f"lw {dest_reg}, 0(t0)")