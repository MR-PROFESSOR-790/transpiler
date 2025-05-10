from collections import deque

class Stack:
    """Stack management for register allocation."""
    def __init__(self):
        self.stack = deque()
        self.next_reg = 0
        self.max_depth = 0

    def push(self) -> str:
        """Push a new register onto the stack."""
        reg = f"t{self.next_reg}"
        self.next_reg = (self.next_reg + 1) % 6  # t0-t5
        self.stack.append(reg)
        self.max_depth = max(self.max_depth, len(self.stack))
        return reg

    def pop(self) -> str:
        """Pop a register from the stack."""
        if not self.stack:
            raise ValueError("Stack underflow")
        return self.stack.pop()

    def peek(self) -> str:
        """Look at the top register without popping."""
        if not self.stack:
            raise ValueError("Stack underflow")
        return self.stack[-1]

    def get_nth_from_top(self, n: int) -> str:
        """Get nth register from top of stack."""
        if n >= len(self.stack):
            raise ValueError("Stack underflow")
        return self.stack[-(n+1)]

class OpcodeMapper:
    def __init__(self, emitter, memory_handler, arithmetic_handler):
        self.emitter = emitter
        self.memory = memory_handler
        self.arithmetic = arithmetic_handler
        self.stack = Stack()  # Add stack management
        self.memory_model = memory_handler
        self.riscv_emitter = emitter
        self.jump_destinations = set()
        self.temp_reg_counter = 0

        # Register opcode handlers
        self.handlers = {
            # Stack operations
            'PUSH': self._handle_push,
            'POP': self._handle_pop,
            'DUP': self._handle_dup,
            'SWAP': self._handle_swap,
            
            # Arithmetic operations
            'ADD': self._handle_arithmetic('add'),
            'SUB': self._handle_arithmetic('sub'),
            'MUL': self._handle_arithmetic('mul'),
            'DIV': self._handle_arithmetic('div'),
            'SDIV': self._handle_arithmetic('div'),  # Signed division
            'MOD': self._handle_arithmetic('rem'),
            'SMOD': self._handle_arithmetic('rem'),  # Signed remainder
            'ADDMOD': self._handle_add_mod,
            'MULMOD': self._handle_mul_mod,
            'EXP': self._handle_exp,
            
            # Comparison operations
            'LT': self._handle_comparison('lt'),
            'GT': self._handle_comparison('gt'),
            'SLT': self._handle_comparison('lt', signed=True),
            'SGT': self._handle_comparison('gt', signed=True),
            'EQ': self._handle_comparison('eq'),
            'ISZERO': self._handle_is_zero,
            
            # Bitwise operations
            'AND': self._handle_bitwise('and'),
            'OR': self._handle_bitwise('or'),
            'XOR': self._handle_bitwise('xor'),
            'NOT': self._handle_bitwise_not,
            'BYTE': self._handle_byte,
            'SHL': self._handle_shift('sll'),
            'SHR': self._handle_shift('srl'),
            'SAR': self._handle_shift('sra'),
            
            # Memory operations
            'MLOAD': self._handle_mload,
            'MSTORE': self._handle_mstore,
            'MSTORE8': self._handle_mstore8,
            'MSIZE': self._handle_msize,
            
            # Storage operations
            'SLOAD': self._handle_sload,
            'SSTORE': self._handle_sstore,
            
            # Control flow
            'JUMP': self._handle_jump,
            'JUMPI': self._handle_jumpi,
            'JUMPDEST': self._handle_jumpdest,
            'PC': self._handle_pc,
            'STOP': self._handle_stop,
            'RETURN': self._handle_return,
            'REVERT': self._handle_revert,
            
            # Environment operations
            'ADDRESS': self._handle_env_op('address'),
            'BALANCE': self._handle_env_op('balance'),
            'ORIGIN': self._handle_env_op('origin'),
            'CALLER': self._handle_env_op('caller'),
            'CALLVALUE': self._handle_env_op('callvalue'),
            'CALLDATALOAD': self._handle_calldata_load,
            'CALLDATASIZE': self._handle_env_op('calldatasize'),
            'CALLDATACOPY': self._handle_calldata_copy,
            'CODESIZE': self._handle_env_op('codesize'),
            'CODECOPY': self._handle_code_copy,
            'GASPRICE': self._handle_env_op('gasprice'),
            'RETURNDATASIZE': self._handle_env_op('returndatasize'),
            'RETURNDATACOPY': self._handle_returndata_copy,
            'EXTCODESIZE': self._handle_env_op('extcodesize'),
            'EXTCODECOPY': self._handle_extcode_copy,
            
            # Block operations
            'BLOCKHASH': self._handle_env_op('blockhash'),
            'COINBASE': self._handle_env_op('coinbase'),
            'TIMESTAMP': self._handle_env_op('timestamp'),
            'NUMBER': self._handle_env_op('number'),
            'DIFFICULTY': self._handle_env_op('difficulty'),
            'GASLIMIT': self._handle_env_op('gaslimit'),
            
            # Cryptographic operations
            'SHA3': self._handle_sha3,
            
            # Contract creation/calling
            'CREATE': self._handle_create,
            'CALL': self._handle_call,
            'CALLCODE': self._handle_callcode,
            'DELEGATECALL': self._handle_delegatecall,
            'STATICCALL': self._handle_staticcall,
            'CREATE2': self._handle_create2,
            
            # Logging operations
            'LOG0': self._handle_log(0),
            'LOG1': self._handle_log(1),
            'LOG2': self._handle_log(2),
            'LOG3': self._handle_log(3),
            'LOG4': self._handle_log(4),
            
            # Misc operations
            'GAS': self._handle_gas,
            'SELFDESTRUCT': self._handle_selfdestruct,
        }
        
    def map_opcode(self, opcode, args=None):
            if opcode in self.handlers:
                self.handlers[opcode](args)
            else:
                raise ValueError(f"Opcode {opcode} not recognized")
            
    def get_temp_reg(self) -> str:
        """Get next temporary register."""
        reg = f"t{self.temp_reg_counter}"
        self.temp_reg_counter = (self.temp_reg_counter + 1) % 6  # t0-t5
        return reg

    def _handle_push(self, value):
        # Allocate register for the value
        reg = self.stack.push()
        # Load immediate value into register
        self.emitter.emit(f"li {reg}, {value}")
    
    def _handle_pop(self, _):
        """Handle POP operation"""
        self.stack.pop()
    
    def _handle_dup(self, position):
        """Handle DUP<n> operation"""
        # Get the register holding the value to duplicate
        src_reg = self.stack.get_nth_from_top(position)
        # Push a new register on the stack
        dest_reg = self.stack.push()
        # Copy the value
        self.emitter.emit(f"mv {dest_reg}, {src_reg}")
    
    def _handle_swap(self, position):
        """Handle SWAP<n> operation"""
        # Get registers to swap
        top_reg = self.stack.get_top()
        other_reg = self.stack.get_nth_from_top(position)
        # Swap values using a temporary register
        self.emitter.emit(f"mv t0, {top_reg}")
        self.emitter.emit(f"mv {top_reg}, {other_reg}")
        self.emitter.emit(f"mv {other_reg}, t0")
    
    def _handle_arithmetic(self, op):
        """Create a handler for arithmetic operations"""
        def handler(_):
            b_reg = self.stack.pop()
            a_reg = self.stack.pop()
            result_reg = self.stack.push()
            
            # Handle 256-bit arithmetic
            # For simplicity, this example only shows 32-bit operations
            # In practice, you'd need multiple instructions for 256-bit values
            
            if op == 'add':
                self.emitter.emit(f"add {result_reg}, {a_reg}, {b_reg}")
            elif op == 'sub':
                self.emitter.emit(f"sub {result_reg}, {a_reg}, {b_reg}")
            elif op == 'mul':
                self.emitter.emit(f"mul {result_reg}, {a_reg}, {b_reg}")
            elif op == 'div':
                # Check for division by zero
                self.emitter.emit(f"beqz {b_reg}, div_by_zero")
                self.emitter.emit(f"div {result_reg}, {a_reg}, {b_reg}")
                self.emitter.emit(f"j div_done")
                self.emitter.emit(f"div_by_zero:")
                self.emitter.emit(f"li {result_reg}, 0")
                self.emitter.emit(f"div_done:")
            elif op == 'rem':
                # Check for division by zero
                self.emitter.emit(f"beqz {b_reg}, mod_by_zero")
                self.emitter.emit(f"rem {result_reg}, {a_reg}, {b_reg}")
                self.emitter.emit(f"j mod_done")
                self.emitter.emit(f"mod_by_zero:")
                self.emitter.emit(f"li {result_reg}, 0")
                self.emitter.emit(f"mod_done:")
        
        return handler
    
    def _handle_add_mod(self, _):
        """Handle ADDMOD operation"""
        mod_reg = self.stack.pop()
        b_reg = self.stack.pop()
        a_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Check for mod by zero
        self.emitter.emit(f"beqz {mod_reg}, addmod_zero")
        
        # addmod requires 512-bit intermediate results
        # For brevity, simplified to 32-bit operations
        self.emitter.emit(f"add t0, {a_reg}, {b_reg}")
        self.emitter.emit(f"rem {result_reg}, t0, {mod_reg}")
        
        self.emitter.emit(f"j addmod_done")
        self.emitter.emit(f"addmod_zero:")
        self.emitter.emit(f"li {result_reg}, 0")
        self.emitter.emit(f"addmod_done:")
    
    def _handle_mul_mod(self, _):
        """Handle MULMOD operation"""
        mod_reg = self.stack.pop()
        b_reg = self.stack.pop()
        a_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Check for mod by zero
        self.emitter.emit(f"beqz {mod_reg}, mulmod_zero")
        
        # mulmod requires 512-bit intermediate results
        # For brevity, simplified to 32-bit operations
        self.emitter.emit(f"mul t0, {a_reg}, {b_reg}")
        self.emitter.emit(f"rem {result_reg}, t0, {mod_reg}")
        
        self.emitter.emit(f"j mulmod_done")
        self.emitter.emit(f"mulmod_zero:")
        self.emitter.emit(f"li {result_reg}, 0")
        self.emitter.emit(f"mulmod_done:")
    
    def _handle_exp(self, _):
        """Handle EXP operation"""
        # Exponentiation - call runtime helper
        exponent_reg = self.stack.pop()
        base_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        self.emitter.emit(f"mv a0, {base_reg}")
        self.emitter.emit(f"mv a1, {exponent_reg}")
        self.emitter.emit(f"call __evm_exp")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_comparison(self, op, signed=False):
        """Create a handler for comparison operations"""
        def handler(_):
            b_reg = self.stack.pop()
            a_reg = self.stack.pop()
            result_reg = self.stack.push()
            
            if op == 'lt':
                if signed:
                    self.emitter.emit(f"slt {result_reg}, {a_reg}, {b_reg}")
                else:
                    self.emitter.emit(f"sltu {result_reg}, {a_reg}, {b_reg}")
            elif op == 'gt':
                if signed:
                    self.emitter.emit(f"slt {result_reg}, {b_reg}, {a_reg}")
                else:
                    self.emitter.emit(f"sltu {result_reg}, {b_reg}, {a_reg}")
            elif op == 'eq':
                self.emitter.emit(f"xor {result_reg}, {a_reg}, {b_reg}")
                self.emitter.emit(f"seqz {result_reg}, {result_reg}")
        
        return handler
    
    def _handle_is_zero(self, _):
        """Handle ISZERO operation"""
        val_reg = self.stack.pop()
        result_reg = self.stack.push()
        self.emitter.emit(f"seqz {result_reg}, {val_reg}")
    
    def _handle_bitwise(self, op):
        """Create a handler for bitwise operations"""
        def handler(_):
            b_reg = self.stack.pop()
            a_reg = self.stack.pop()
            result_reg = self.stack.push()
            
            self.emitter.emit(f"{op} {result_reg}, {a_reg}, {b_reg}")
        
        return handler
    
    def _handle_bitwise_not(self, _):
        """Handle NOT operation"""
        val_reg = self.stack.pop()
        result_reg = self.stack.push()
        # In RISC-V, NOT is implemented as XOR with -1
        self.emitter.emit(f"li t0, -1")
        self.emitter.emit(f"xor {result_reg}, {val_reg}, t0")
    
    def _handle_byte(self, _):
        """Handle BYTE operation"""
        pos_reg = self.stack.pop()
        val_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Extract byte at position pos_reg from val_reg
        # Complex for 256-bit values, simplified here
        self.emitter.emit(f"li t0, 31")
        self.emitter.emit(f"slt t1, {pos_reg}, t0")  # Check if pos < 32
        self.emitter.emit(f"beqz t1, byte_out_of_range")
        
        self.emitter.emit(f"li t0, 8")
        self.emitter.emit(f"mul t0, {pos_reg}, t0")  # t0 = pos * 8
        self.emitter.emit(f"li t1, 31")
        self.emitter.emit(f"sub t0, t1, t0")  # t0 = 31*8 - pos*8 (for big endian)
        self.emitter.emit(f"srl t1, {val_reg}, t0")  # t1 = val >> t0
        self.emitter.emit(f"andi {result_reg}, t1, 0xFF")  # result = t1 & 0xFF
        
        self.emitter.emit(f"j byte_done")
        self.emitter.emit(f"byte_out_of_range:")
        self.emitter.emit(f"li {result_reg}, 0")
        self.emitter.emit(f"byte_done:")
    
    def _handle_shift(self, op):
        """Create a handler for shift operations"""
        def handler(_):
            shift_reg = self.stack.pop()
            val_reg = self.stack.pop()
            result_reg = self.stack.push()
            
            # Check if shift amount >= 256, which gives 0 or -1 depending on op
            self.emitter.emit(f"li t0, 256")
            self.emitter.emit(f"sltu t1, {shift_reg}, t0")  # t1 = (shift < 256)
            self.emitter.emit(f"beqz t1, shift_overflow")
            
            # Normal shift
            self.emitter.emit(f"{op} {result_reg}, {val_reg}, {shift_reg}")
            self.emitter.emit(f"j shift_done")
            
            # Handle shift >= 256
            self.emitter.emit(f"shift_overflow:")
            if op == 'sra':  # arithmetic right shift preserves sign
                self.emitter.emit(f"srai {result_reg}, {val_reg}, 31")  # All 0s or all 1s
            else:
                self.emitter.emit(f"li {result_reg}, 0")
            self.emitter.emit(f"shift_done:")
        
        return handler
    
    def _handle_mload(self, _):
        """Handle MLOAD operation"""
        offset_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call memory model to handle the load
        self.memory.mload(offset_reg, result_reg)
    
    def _handle_mstore(self, _):
        """Handle MSTORE operation"""
        value_reg = self.stack.pop()
        offset_reg = self.stack.pop()
        
        # Call memory model to handle the store
        self.memory.mstore(offset_reg, value_reg)
    
    def _handle_mstore8(self, _):
        """Handle MSTORE8 operation"""
        value_reg = self.stack.pop()
        offset_reg = self.stack.pop()
        
        # Call memory model to handle the byte store
        self.memory.mstore8(offset_reg, value_reg)
    
    def _handle_msize(self, _):
        """Handle MSIZE operation"""
        result_reg = self.stack.push()
        
        # Get current memory size from memory model
        self.memory.get_size(result_reg)
    
    def _handle_sload(self, _):
        """Handle SLOAD operation"""
        key_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call storage runtime
        self.emitter.emit(f"mv a0, {key_reg}")
        self.emitter.emit(f"call __evm_sload")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_sstore(self, _):
        """Handle SSTORE operation"""
        value_reg = self.stack.pop()
        key_reg = self.stack.pop()
        
        # Call storage runtime
        self.emitter.emit(f"mv a0, {key_reg}")
        self.emitter.emit(f"mv a1, {value_reg}")
        self.emitter.emit(f"call __evm_sstore")
    
    def _handle_jump(self, _):
        """Handle JUMP operation"""
        dest_reg = self.stack.pop()
        
        # Check if jump destination is valid (should be a JUMPDEST)
        self.emitter.emit(f"mv a0, {dest_reg}")
        self.emitter.emit(f"call __evm_validate_jump")
        
        # Jump to the destination
        self.emitter.emit(f"jr {dest_reg}")
    
    def _handle_jumpi(self, _):
        """Handle JUMPI operation"""
        cond_reg = self.stack.pop()
        dest_reg = self.stack.pop()
        
        # Check if condition is non-zero
        self.emitter.emit(f"beqz {cond_reg}, jumpi_skip")
        
        # If true, validate jump destination
        self.emitter.emit(f"mv a0, {dest_reg}")
        self.emitter.emit(f"call __evm_validate_jump")
        
        # Jump to the destination
        self.emitter.emit(f"jr {dest_reg}")
        
        # Skip target
        self.emitter.emit(f"jumpi_skip:")
    
    def _handle_jumpdest(self, _):
        """Handle JUMPDEST operation"""
        # Just emit a label, actual registration happens during parsing
        pass
    
    def _handle_pc(self, _):
        """Handle PC operation - gets current program counter"""
        result_reg = self.stack.push()
        
        # Call runtime function to get PC
        self.emitter.emit(f"call __evm_get_pc")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_stop(self, _):
        """Handle STOP operation"""
        self.emitter.emit(f"j evm_exit")
    
    def _handle_return(self, _):
        """Handle RETURN operation"""
        size_reg = self.stack.pop()
        offset_reg = self.stack.pop()
        
        # Call return runtime function
        self.emitter.emit(f"mv a0, {offset_reg}")
        self.emitter.emit(f"mv a1, {size_reg}")
        self.emitter.emit(f"call __evm_return")
        self.emitter.emit(f"j evm_exit")
    
    def _handle_revert(self, _):
        """Handle REVERT operation"""
        size_reg = self.stack.pop()
        offset_reg = self.stack.pop()
        
        # Call revert runtime function
        self.emitter.emit(f"mv a0, {offset_reg}")
        self.emitter.emit(f"mv a1, {size_reg}")
        self.emitter.emit(f"call __evm_revert")
        self.emitter.emit(f"j evm_exit")
    
    def _handle_env_op(self, operation):
        """Create a handler for environment operations"""
        def handler(_):
            result_reg = self.stack.push()
            
            # Call appropriate runtime function
            self.emitter.emit(f"call __evm_{operation}")
            self.emitter.emit(f"mv {result_reg}, a0")
        
        return handler
    
    def _handle_calldata_load(self, _):
        """Handle CALLDATALOAD operation"""
        index_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {index_reg}")
        self.emitter.emit(f"call __evm_calldataload")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_calldata_copy(self, _):
        """Handle CALLDATACOPY operation"""
        size_reg = self.stack.pop()
        dataOffset_reg = self.stack.pop()
        memOffset_reg = self.stack.pop()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {memOffset_reg}")
        self.emitter.emit(f"mv a1, {dataOffset_reg}")
        self.emitter.emit(f"mv a2, {size_reg}")
        self.emitter.emit(f"call __evm_calldatacopy")
    
    def _handle_code_copy(self, _):
        """Handle CODECOPY operation"""
        size_reg = self.stack.pop()
        codeOffset_reg = self.stack.pop()
        memOffset_reg = self.stack.pop()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {memOffset_reg}")
        self.emitter.emit(f"mv a1, {codeOffset_reg}")
        self.emitter.emit(f"mv a2, {size_reg}")
        self.emitter.emit(f"call __evm_codecopy")
    
    def _handle_returndata_copy(self, _):
        """Handle RETURNDATACOPY operation"""
        size_reg = self.stack.pop()
        returnOffset_reg = self.stack.pop()
        memOffset_reg = self.stack.pop()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {memOffset_reg}")
        self.emitter.emit(f"mv a1, {returnOffset_reg}")
        self.emitter.emit(f"mv a2, {size_reg}")
        self.emitter.emit(f"call __evm_returndatacopy")
    
    def _handle_extcode_copy(self, _):
        """Handle EXTCODECOPY operation"""
        size_reg = self.stack.pop()
        codeOffset_reg = self.stack.pop()
        memOffset_reg = self.stack.pop()
        address_reg = self.stack.pop()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {address_reg}")
        self.emitter.emit(f"mv a1, {memOffset_reg}")
        self.emitter.emit(f"mv a2, {codeOffset_reg}")
        self.emitter.emit(f"mv a3, {size_reg}")
        self.emitter.emit(f"call __evm_extcodecopy")
    
    def _handle_sha3(self, _):
        """Handle SHA3 operation"""
        size_reg = self.stack.pop()
        offset_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {offset_reg}")
        self.emitter.emit(f"mv a1, {size_reg}")
        self.emitter.emit(f"call __evm_sha3")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_create(self, _):
        """Handle CREATE operation"""
        value_reg = self.stack.pop()
        offset_reg = self.stack.pop()
        size_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {value_reg}")
        self.emitter.emit(f"mv a1, {offset_reg}")
        self.emitter.emit(f"mv a2, {size_reg}")
        self.emitter.emit(f"call __evm_create")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_create2(self, _):
        """Handle CREATE2 operation"""
        value_reg = self.stack.pop()
        offset_reg = self.stack.pop()
        size_reg = self.stack.pop()
        salt_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {value_reg}")
        self.emitter.emit(f"mv a1, {offset_reg}")
        self.emitter.emit(f"mv a2, {size_reg}")
        self.emitter.emit(f"mv a3, {salt_reg}")
        self.emitter.emit(f"call __evm_create2")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_call(self, _):
        """Handle CALL operation"""
        # Pop all the arguments
        gas_reg = self.stack.pop()
        address_reg = self.stack.pop()
        value_reg = self.stack.pop()
        argsOffset_reg = self.stack.pop()
        argsSize_reg = self.stack.pop()
        retOffset_reg = self.stack.pop()
        retSize_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {gas_reg}")
        self.emitter.emit(f"mv a1, {address_reg}")
        self.emitter.emit(f"mv a2, {value_reg}")
        self.emitter.emit(f"mv a3, {argsOffset_reg}")
        self.emitter.emit(f"mv a4, {argsSize_reg}")
        self.emitter.emit(f"mv a5, {retOffset_reg}")
        self.emitter.emit(f"mv a6, {retSize_reg}")
        self.emitter.emit(f"call __evm_call")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_callcode(self, _):
        """Handle CALLCODE operation"""
        # Similar to CALL but different semantics in runtime
        gas_reg = self.stack.pop()
        address_reg = self.stack.pop()
        value_reg = self.stack.pop()
        argsOffset_reg = self.stack.pop()
        argsSize_reg = self.stack.pop()
        retOffset_reg = self.stack.pop()
        retSize_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {gas_reg}")
        self.emitter.emit(f"mv a1, {address_reg}")
        self.emitter.emit(f"mv a2, {value_reg}")
        self.emitter.emit(f"mv a3, {argsOffset_reg}")
        self.emitter.emit(f"mv a4, {argsSize_reg}")
        self.emitter.emit(f"mv a5, {retOffset_reg}")
        self.emitter.emit(f"mv a6, {retSize_reg}")
        self.emitter.emit(f"call __evm_callcode")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_delegatecall(self, _):
        """Handle DELEGATECALL operation"""
        gas_reg = self.stack.pop()
        address_reg = self.stack.pop()
        argsOffset_reg = self.stack.pop()
        argsSize_reg = self.stack.pop()
        retOffset_reg = self.stack.pop()
        retSize_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {gas_reg}")
        self.emitter.emit(f"mv a1, {address_reg}")
        self.emitter.emit(f"mv a2, {argsOffset_reg}")
        self.emitter.emit(f"mv a3, {argsSize_reg}")
        self.emitter.emit(f"mv a4, {retOffset_reg}")
        self.emitter.emit(f"mv a5, {retSize_reg}")
        self.emitter.emit(f"call __evm_delegatecall")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_staticcall(self, _):
        """Handle STATICCALL operation"""
        gas_reg = self.stack.pop()
        address_reg = self.stack.pop()
        argsOffset_reg = self.stack.pop()
        argsSize_reg = self.stack.pop()
        retOffset_reg = self.stack.pop()
        retSize_reg = self.stack.pop()
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {gas_reg}")
        self.emitter.emit(f"mv a1, {address_reg}")
        self.emitter.emit(f"mv a2, {argsOffset_reg}")
        self.emitter.emit(f"mv a3, {argsSize_reg}")
        self.emitter.emit(f"mv a4, {retOffset_reg}")
        self.emitter.emit(f"mv a5, {retSize_reg}")
        self.emitter.emit(f"call __evm_staticcall")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_log(self, topics):
        """Create a handler for LOG operations"""
        def handler(_):
            # Always pop size and offset
            size_reg = self.stack.pop()
            offset_reg = self.stack.pop()
            
            # Pop topic registers based on LOG type
            topic_regs = []
            for i in range(topics):
                topic_regs.append(self.stack.pop())
            
            # Call runtime function
            self.emitter.emit(f"mv a0, {offset_reg}")
            self.emitter.emit(f"mv a1, {size_reg}")
            
            # Pass topic registers
            for i, reg in enumerate(topic_regs):
                self.emitter.emit(f"mv a{i+2}, {reg}")
            
            self.emitter.emit(f"call __evm_log{topics}")
        
        return handler
    
    def _handle_gas(self, _):
        """Handle GAS operation"""
        result_reg = self.stack.push()
        
        # Call runtime function
        self.emitter.emit(f"call __evm_gas")
        self.emitter.emit(f"mv {result_reg}, a0")
    
    def _handle_selfdestruct(self, _):
        """Handle SELFDESTRUCT operation"""
        address_reg = self.stack.pop()
        
        # Call runtime function
        self.emitter.emit(f"mv a0, {address_reg}")
        self.emitter.emit(f"call __evm_selfdestruct")
        self.emitter.emit(f"j evm_exit")