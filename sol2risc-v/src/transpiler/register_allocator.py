import logging
from threading import Lock

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RegisterAllocator:
    def __init__(self, available_registers=None):
        if available_registers is None:
            available_registers = [
                "t0", "t1", "t2", "t3", "t4", "t5", "t6",
                "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11"
            ]
        self.available_registers = available_registers
        self.allocated_registers = set()
        self.spill_area = []
        self.lock = Lock()

    def allocate(self):
        with self.lock:
            for reg in self.available_registers:
                if reg not in self.allocated_registers:
                    self.allocated_registers.add(reg)
                    logger.debug(f"Allocated register: {reg}")
                    return reg

            # All registers are in use, spill to memory (simulate)
            spill_slot = len(self.spill_area)
            self.spill_area.append(f"spill[{spill_slot}]")
            logger.warning(f"No available registers. Spilled to memory slot spill[{spill_slot}].")
            return f"spill[{spill_slot}]"

    def free(self, reg):
        with self.lock:
            if reg in self.allocated_registers:
                self.allocated_registers.remove(reg)
                logger.debug(f"Freed register: {reg}")
            elif reg.startswith("spill[") and reg.endswith("]"):
                try:
                    spill_index = int(reg[6:-1])
                    if 0 <= spill_index < len(self.spill_area):
                        self.spill_area[spill_index] = None
                        logger.debug(f"Freed spill slot: {reg}")
                    else:
                        logger.warning(f"Tried to free invalid spill slot: {reg}")
                except ValueError:
                    logger.warning(f"Malformed spill slot: {reg}")
            else:
                logger.warning(f"Tried to free unallocated register or unknown spill reference: {reg}")

    def reset(self):
        with self.lock:
            self.allocated_registers.clear()
            self.spill_area.clear()
            logger.debug("Reset all allocated registers and cleared spill area.")

    def is_allocated(self, reg):
        return reg in self.allocated_registers

    def list_allocated(self):
        allocated_spills = [slot for slot in self.spill_area if slot is not None]
        return list(self.allocated_registers) + allocated_spills
