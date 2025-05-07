class GasCosts:
    # Storage operations
    SLOAD = 200
    SSTORE_NEW = 20000
    SSTORE_UPDATE = 5000
    SSTORE_CLEAR = 5000
    
    # Memory operations
    MLOAD = 3
    MSTORE = 3
    MSTORE8 = 3
    
    # Cryptographic operations
    SHA3 = 30
    SHA3_WORD = 6
    
    # Contract creation
    CREATE = 32000
    CREATE2 = 32000
    
    # Calls
    CALL = 700
    CALLCODE = 700
    DELEGATECALL = 700
    STATICCALL = 700
    
    # Logging
    LOG_BASE = 375
    LOG_TOPIC = 375
    LOG_DATA = 8
    
    # Memory expansion
    MEMORY_BASE = 3
    MEMORY_WORD = 3
    
    @staticmethod
    def calculate_memory_cost(size):
        words = (size + 31) // 32
        return GasCosts.MEMORY_BASE + (words * GasCosts.MEMORY_WORD)
