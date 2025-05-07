class GasEstimator:
    def __init__(self):
        self.total_gas = 0
        self.operations = {
            'SLOAD': 200,
            'SSTORE': {'cold': 20000, 'warm': 5000},
            'CALL': 700,
            'LOG': {'base': 375, 'topic': 375, 'byte': 8},
            'SHA3': {'base': 30, 'word': 6},
            'CREATE': 32000,
            'CREATE2': 32000
        }
        
    def estimate_opcode(self, opcode: str, params: dict = None) -> int:
        """Estimate gas cost for an opcode"""
        if opcode not in self.operations:
            return 0
            
        cost = self.operations[opcode]
        if isinstance(cost, dict):
            return self._calculate_complex_cost(opcode, cost, params)
        return cost
