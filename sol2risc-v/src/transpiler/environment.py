class EVMEnvironment:
    def __init__(self):
        self.blockchain_state = {
            'block_number': 0,
            'timestamp': 0,
            'difficulty': 0,
            'gaslimit': 0,
            'coinbase': 0
        }
        
    def get_block_info(self, info_type):
        return self.blockchain_state.get(info_type, 0)

    def update_block_info(self, info_type, value):
        self.blockchain_state[info_type] = value
