class Context:
    """Shared compilation context between different modules"""
    def __init__(self):
        self.gas_meter = {"total": 0}
        self.function_info = {}
        self.stack_height = 0
        self.memory_map = {}
        self.labels = {}
        self.runtime_calls = set()

class GasConfig:
    """Gas cost configuration"""
    BASE_COSTS = {
        "PUSH": 3,
        "POP": 2,
        "ADD": 3,
        "MUL": 5,
        "MSTORE": 3,
        "MLOAD": 3,
    }

    @staticmethod
    def get_base_cost(opcode: str) -> int:
        return GasConfig.BASE_COSTS.get(opcode, 0)
