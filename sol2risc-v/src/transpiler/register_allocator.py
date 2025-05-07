import logging
from threading import Lock

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RegisterAllocator:
    def __init__(self):
        # Temporary registers t0-t6
        self.temp_regs = [f"x{i}" for i in range(5, 32) if i not in [8, 9]]  # Exclude s0,s1
        self.used_regs = set()
        self.reg_usage = {}
        self.usage_counter = 0
        self.lock = Lock()

    def allocate(self) -> str:
        """Allocate a register, return None if none available"""
        with self.lock:
            if not self.temp_regs:
                return None
            reg = self.temp_regs.pop(0)
            self.used_regs.add(reg)
            self.reg_usage[reg] = self.usage_counter
            self.usage_counter += 1
            logger.debug(f"Allocated register: {reg}")
            return reg

    def free(self, reg: str):
        """Free a register"""
        with self.lock:
            if reg in self.used_regs:
                self.used_regs.remove(reg)
                self.temp_regs.append(reg)
                del self.reg_usage[reg]
                logger.debug(f"Freed register: {reg}")
            else:
                logger.warning(f"Tried to free unallocated register: {reg}")

    def get_least_used(self) -> str:
        """Get least recently used register"""
        with self.lock:
            if not self.reg_usage:
                logger.warning("No registers are currently in use.")
                return None
            least_used = min(self.reg_usage.items(), key=lambda x: x[1])[0]
            logger.debug(f"Least recently used register: {least_used}")
            return least_used
