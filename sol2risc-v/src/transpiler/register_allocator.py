from typing import Dict, List, Set, Optional, Tuple

class RegisterAllocator:
    """
    Register allocator for EVM to RISC-V transpilation.
    Handles register allocation, spilling, and management.
    """

    def __init__(self):
        # Define RISC-V register sets
        self.argument_regs = [f"a{i}" for i in range(8)]  # a0-a7
        self.temp_regs = [f"t{i}" for i in range(7)]      # t0-t6
        self.saved_regs = [f"s{i}" for i in range(12)]    # s0-s11

        # Register state tracking
        self.allocated_regs: Dict[str, str] = {}  # Maps virtual regs to physical regs
        self.reg_contents: Dict[str, str] = {}    # Maps physical regs to their contents
        self.spilled_vars: Dict[str, int] = {}    # Maps variables to stack offsets
        self.current_stack_offset = 0

        # Register liveness tracking
        self.live_ranges: Dict[str, Tuple[int, int]] = {}
        self.next_virtual_reg = 0

        # Reserved registers
        self.reserved_regs = {
            'sp': 'stack pointer',
            'ra': 'return address',
            'a0': 'primary return value',
            'a1': 'secondary return value',
            's0': 'frame pointer'
        }

    def new_virtual_reg(self) -> str:
        """Create a new virtual register name."""
        reg = f"v{self.next_virtual_reg}"
        self.next_virtual_reg += 1
        return reg

    def allocate_reg(self, virtual_reg: str, preferred_regs: List[str] = None) -> str:
        """
        Allocate a physical register for a virtual register.
        
        Args:
            virtual_reg: The virtual register name
            preferred_regs: List of preferred physical registers
            
        Returns:
            The allocated physical register name
        """
        # Check if already allocated
        if virtual_reg in self.allocated_regs:
            return self.allocated_regs[virtual_reg]

        # Try preferred registers first
        if preferred_regs:
            for reg in preferred_regs:
                if reg not in self.reg_contents and reg not in self.reserved_regs:
                    self.allocated_regs[virtual_reg] = reg
                    self.reg_contents[reg] = virtual_reg
                    return reg

        # Try saved registers first (s1-s11)
        for reg in self.saved_regs[1:]:  # Skip s0 (frame pointer)
            if reg not in self.reg_contents:
                self.allocated_regs[virtual_reg] = reg
                self.reg_contents[reg] = virtual_reg
                return reg

        # Try temporary registers
        for reg in self.temp_regs:
            if reg not in self.reg_contents:
                self.allocated_regs[virtual_reg] = reg
                self.reg_contents[reg] = virtual_reg
                return reg

        # Need to spill a register
        return self._spill_and_allocate(virtual_reg)

    def _spill_and_allocate(self, virtual_reg: str) -> str:
        """
        Spill a register to memory and allocate it to a new variable.
        
        Args:
            virtual_reg: The virtual register needing allocation
            
        Returns:
            The physical register name after spilling
        """
        # Choose a register to spill (prefer temporary registers)
        spill_reg = self._choose_spill_candidate()
        spill_var = self.reg_contents[spill_reg]

        # Generate spill location
        if spill_var not in self.spilled_vars:
            self.current_stack_offset += 8
            self.spilled_vars[spill_var] = self.current_stack_offset

        # Update mappings
        del self.allocated_regs[spill_var]
        del self.reg_contents[spill_reg]
        self.allocated_regs[virtual_reg] = spill_reg
        self.reg_contents[spill_reg] = virtual_reg

        return spill_reg

    def _choose_spill_candidate(self) -> str:
        """Choose a register to spill based on usage patterns."""
        # Prefer spilling temporary registers first
        for reg in self.temp_regs:
            if reg in self.reg_contents:
                return reg

        # Then spill saved registers if necessary
        for reg in self.saved_regs[1:]:  # Skip s0 (frame pointer)
            if reg in self.reg_contents:
                return reg

        raise RuntimeError("No registers available for spilling")

    def free_reg(self, virtual_reg: str) -> None:
        """
        Free a virtual register's physical register allocation.
        
        Args:
            virtual_reg: The virtual register to free
        """
        if virtual_reg in self.allocated_regs:
            physical_reg = self.allocated_regs[virtual_reg]
            del self.reg_contents[physical_reg]
            del self.allocated_regs[virtual_reg]

    def get_reg(self, virtual_reg: str) -> str:
        """
        Get the physical register for a virtual register.
        
        Args:
            virtual_reg: The virtual register name
            
        Returns:
            The physical register name or None if not allocated
        """
        return self.allocated_regs.get(virtual_reg)

    def get_spill_location(self, virtual_reg: str) -> Optional[int]:
        """
        Get the stack offset for a spilled variable.
        
        Args:
            virtual_reg: The virtual register name
            
        Returns:
            Stack offset or None if not spilled
        """
        return self.spilled_vars.get(virtual_reg)

    def generate_stack_frame(self) -> List[str]:
        """
        Generate RISC-V assembly for stack frame setup.
        
        Returns:
            List of assembly instructions
        """
        frame_size = self.current_stack_offset + 16  # +16 for ra and s0
        frame_size = (frame_size + 15) & ~15  # Align to 16 bytes
        
        return [
            "    # Stack frame setup",
            f"    addi sp, sp, -{frame_size}",
            "    sd ra, {frame_size-8}(sp)  # Save return address",
            "    sd s0, {frame_size-16}(sp) # Save frame pointer",
            f"    addi s0, sp, {frame_size}  # Set up frame pointer"
        ]

    def generate_stack_cleanup(self) -> List[str]:
        """
        Generate RISC-V assembly for stack frame cleanup.
        
        Returns:
            List of assembly instructions
        """
        frame_size = self.current_stack_offset + 16  # +16 for ra and s0
        frame_size = (frame_size + 15) & ~15  # Align to 16 bytes
        
        return [
            "    # Stack frame cleanup",
            f"    ld ra, {frame_size-8}(sp)  # Restore return address",
            f"    ld s0, {frame_size-16}(sp) # Restore frame pointer",
            f"    addi sp, sp, {frame_size}  # Restore stack pointer"
        ]

    def mark_live_range(self, virtual_reg: str, start: int, end: int) -> None:
        """
        Mark the live range of a virtual register.
        
        Args:
            virtual_reg: The virtual register name
            start: Start instruction index
            end: End instruction index
        """
        self.live_ranges[virtual_reg] = (start, end)

    def get_interference_graph(self) -> Dict[str, Set[str]]:
        """
        Generate interference graph for register allocation.
        
        Returns:
            Dictionary mapping virtual registers to sets of interfering registers
        """
        interference: Dict[str, Set[str]] = {}
        
        for reg1 in self.live_ranges:
            if reg1 not in interference:
                interference[reg1] = set()
            
            range1 = self.live_ranges[reg1]
            for reg2 in self.live_ranges:
                if reg1 != reg2:
                    range2 = self.live_ranges[reg2]
                    # Check if ranges overlap
                    if not (range1[1] < range2[0] or range2[1] < range1[0]):
                        interference[reg1].add(reg2)
                        if reg2 not in interference:
                            interference[reg2] = set()
                        interference[reg2].add(reg1)
        
        return interference
