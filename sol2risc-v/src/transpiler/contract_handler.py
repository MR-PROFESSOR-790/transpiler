from typing import Dict, List
import logging

logger = logging.getLogger(__name__)

class ContractHandler:
    def __init__(self):
        self.functions: Dict[str, List[str]] = {}
        self.storage_layout: Dict[str, int] = {}
        self.events: Dict[str, List[str]] = {}
        
    def parse_contract_abi(self, abi_data: dict):
        """Parse contract ABI to extract function signatures and events"""
        for item in abi_data:
            if item['type'] == 'function':
                signature = self._create_function_signature(item)
                self.functions[signature] = self._process_function(item)
            elif item['type'] == 'event':
                self.events[item['name']] = self._process_event(item)
                
    def _create_function_signature(self, func_data: dict) -> str:
        """Create function signature from ABI data"""
        params = ','.join([input['type'] for input in func_data['inputs']])
        return f"{func_data['name']}({params})"
