import sys
import logging
import re
from .memory_model import MemoryModel
from .riscv_emitter import RISCVEmitter
from .register_allocator import RegisterAllocator
from .stack_emulator import StackEmulator
from .opcode_mapping import OpcodeMapping
from .evm_parser import EVMAssemblyParser

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class EVMTranspiler:
    def __init__(self):
        self.memory_model = MemoryModel()
        self.register_allocator = RegisterAllocator()
        self.stack_manager = StackEmulator(self.register_allocator)
        self.opcode_mapping = OpcodeMapping()
        self.riscv_emitter = RISCVEmitter(self.register_allocator, self.memory_model)
        self.evm_parser = EVMAssemblyParser()
        self.labels = {}
        self.basic_blocks = {}
        self.jumpdests = set()
        self.current_address = 0

    def transpile(self, input_file: str, output_file: str):
        """Main transpilation process"""
        try:
            # Parse EVM assembly
            logger.info(f"Parsing EVM assembly from {input_file}")
            instructions = self.evm_parser.parse_file(input_file)
            
            # Initialize runtime
            self._initialize_runtime()
            
            # First pass: analyze code structure
            self._analyze_code_structure(instructions)
            
            # Second pass: generate RISC-V code
            for instr in instructions:
                addr = instr['address']
                opcode = instr['opcode']
                value = instr['value']
                
                # Handle labels
                if addr in self.labels:
                    self.riscv_emitter.emit_label(f"L_{addr:x}")
                
                # Track gas costs
                gas_cost = self._get_gas_cost(opcode)
                if gas_cost > 0:
                    self._emit_gas_check(gas_cost)
                
                # Process instruction
                self._process_instruction(addr, opcode, value)

            # Finalize code generation
            assembly = self._generate_final_assembly()
            
            # Write output
            with open(output_file, 'w') as f:
                f.write(assembly)
            logger.info(f"Successfully generated RISC-V assembly: {output_file}")
            
        except Exception as e:
            logger.error(f"Transpilation failed: {str(e)}")
            raise

    def _initialize_runtime(self):
        """Initialize RISC-V runtime environment with all required components"""
        self.riscv_emitter.emit("""
        .section .data
            .align 3
        memory_area:     .space 65536    # EVM memory
        storage_area:    .space 65536    # Storage
        calldata_area:   .space 4096     # Calldata
        returndata:      .space 4096     # Return data
        event_buffer:    .space 8192     # Event logs
        
        .section .text
            .align 2
            .global _start
            
        _start:
            # Runtime setup
            addi sp, sp, -1024
            sd ra, 1016(sp)
            sd s0, 1008(sp)
            addi s0, sp, 1024
            
            # Initialize pointers and counters
            la s1, memory_area      # s1 = memory base
            la s2, storage_area     # s2 = storage base
            la s3, calldata_area    # s3 = calldata base
            la s4, returndata       # s4 = return data
            la s5, event_buffer     # s5 = event buffer
            li s11, 1000000        # Initial gas limit
            
        # Error handlers and common operations
        """)
        
        # Add arithmetic operations
        self._emit_runtime_operations()

    def _emit_runtime_operations(self):
        """Emit common runtime operations"""
        self.riscv_emitter.emit("""
        # Memory operations
        mstore_impl:
            add t0, s1, a0        # memory base + offset
            sd a1, 0(t0)          # store value
            ret
            
        mload_impl:
            add t0, s1, a0        # memory base + offset
            ld a0, 0(t0)          # load value
            ret
            
        # Storage operations
        sstore_impl:
            slli t0, a0, 3        # multiply key by 8
            add t0, s2, t0        # storage base + offset
            ld t1, 0(t0)          # load old value
            beq t1, a1, skip_store # skip if unchanged
            sd a1, 0(t0)          # store new value
        skip_store:
            ret
            
        sload_impl:
            slli t0, a0, 3        # multiply key by 8
            add t0, s2, t0        # storage base + offset
            ld a0, 0(t0)          # load value
            ret
            
        # Gas checking
        check_gas:
            sub t0, s11, a0       # subtract required gas
            bltz t0, out_of_gas   # branch if negative
            mv s11, t0            # update gas counter
            ret
            
        # Error handlers
        out_of_gas:
            li a0, 2              # out of gas error code
            j revert_handler
            
        revert_handler:
            li a7, 93             # exit syscall
            ecall
        """)

    def _analyze_code_structure(self, instructions):
        """Analyze code structure and collect labels"""
        for instr in instructions:
            addr = instr['address']
            opcode = instr['opcode']
            value = instr['value']
            
            if opcode == 'JUMPDEST':
                self.labels[addr] = f"L_{addr:x}"
                self.basic_blocks[addr] = []
            elif opcode in ['JUMP', 'JUMPI']:
                if value is not None:
                    self.labels[value] = f"L_{value:x}"

    def _get_gas_cost(self, opcode: str) -> int:
        """Get gas cost for an opcode"""
        return 3  # Default gas cost

    def _emit_gas_check(self, cost: int):
        """Emit gas checking code"""
        self.riscv_emitter.emit(f"""
            li a0, {cost}         # gas cost
            jal check_gas
        """)

    def _process_instruction(self, addr: int, opcode: str, value: any):
        """Process EVM instruction with enhanced handling"""
        try:
            # Handle unknown opcodes
            if opcode.startswith("UNKNOWN_"):
                self.riscv_emitter.emit(f"    # Unknown opcode at {addr:x}: {opcode}")
                return

            # Regular instruction handling
            if opcode.startswith('PUSH'):
                self._handle_push(value)
            elif opcode in ['JUMP', 'JUMPI']:
                self._handle_jump(opcode, addr)
            elif opcode in ['ADD', 'SUB', 'MUL', 'DIV', 'AND', 'OR', 'XOR', 'EQ', 'LT', 'GT', 'SHL', 'SHR', 'SAR']:
                self._handle_arithmetic(opcode)
            elif opcode in ['SLOAD', 'SSTORE']:
                self._handle_storage(opcode)
            elif opcode in ['MLOAD', 'MSTORE']:
                self._handle_memory(opcode)
            elif opcode.startswith('LOG'):
                self._handle_log(opcode)
            elif opcode in ['CREATE', 'CREATE2']:
                self._handle_create(opcode)
            elif opcode == 'SHA3':
                self._handle_sha3()
            elif opcode == 'JUMPDEST':
                self.jumpdests.add(addr)
            else:
                self._handle_basic_opcode(opcode)
        except Exception as e:
            logger.warning(f"Error processing instruction at {addr:x}: {opcode} - {str(e)}")
            self.riscv_emitter.emit(f"    # Failed to process: {opcode} at {addr:x}")

    def _handle_push(self, value):
        """Handle PUSH operations"""
        self.riscv_emitter.emit(f"""
            li t0, {value}        # load immediate value
            addi sp, sp, -8       # adjust stack pointer
            sd t0, 0(sp)          # store value on stack
        """)

    def _handle_jump(self, opcode, addr):
        """Handle JUMP and JUMPI instructions"""
        if opcode == 'JUMPI':
            self.riscv_emitter.emit(f"""
                # Conditional jump
                ld t1, 0(sp)          # condition
                addi sp, sp, 8
                ld t0, 0(sp)          # destination
                addi sp, sp, 8
                beqz t1, skip_{addr:x}   # if condition is 0, skip jump
                j L_{addr:x}           # jump to destination
            skip_{addr:x}:
            """)
        else:  # JUMP
            self.riscv_emitter.emit("""
                # Unconditional jump
                ld t0, 0(sp)          # destination
                addi sp, sp, 8
                j L_{t0:x}           # jump to destination
            """)

    def _handle_arithmetic(self, opcode):
        """Handle arithmetic operations"""
        op_map = {
            'ADD': 'add',
            'SUB': 'sub',
            'MUL': 'mul',
            'DIV': 'div',
            'AND': 'and',
            'OR': 'or',
            'XOR': 'xor',
            'EQ': 'sub t0, zero, t0; seqz t0, t0',  # Special case for equality
            'LT': 'slt',
            'GT': 'sgt',
            'SHL': 'sll',
            'SHR': 'srl',
            'SAR': 'sra'
        }

        if opcode in op_map:
            self.riscv_emitter.emit(f"""
                ld t1, 0(sp)          # second operand
                addi sp, sp, 8
                ld t0, 0(sp)          # first operand
                addi sp, sp, 8
                {op_map[opcode]} t0, t0, t1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            """)

    def _handle_sha3(self):
        """Handle SHA3 (Keccak) operation"""
        self.riscv_emitter.emit("""
            ld a1, 0(sp)          # size
            addi sp, sp, 8
            ld a0, 0(sp)          # offset
            addi sp, sp, 8
            jal ra, sha3_impl     # call SHA3 implementation
            addi sp, sp, -8
            sd a0, 0(sp)          # push result
        """)

    def _handle_log(self, opcode):
        """Handle LOG operations"""
        topics = int(opcode[3]) if len(opcode) > 3 else 0
        self.riscv_emitter.emit(f"""
            # LOG{topics} operation
            mv a2, {topics}       # number of topics
            ld a1, 0(sp)         # size
            addi sp, sp, 8
            ld a0, 0(sp)         # offset
            addi sp, sp, 8
            jal log_impl         # call log implementation
        """)

    def _handle_create(self, opcode):
        """Handle CREATE/CREATE2 operations"""
        self.riscv_emitter.emit(f"""
            # {opcode} operation
            ld a2, 0(sp)         # value
            addi sp, sp, 8
            ld a1, 0(sp)         # offset
            addi sp, sp, 8
            ld a0, 0(sp)         # size
            addi sp, sp, 8
            jal create_impl      # call create implementation
            addi sp, sp, -8
            sd a0, 0(sp)        # push created address
        """)

    def _handle_storage(self, opcode):
        """Handle storage operations"""
        if opcode == 'SSTORE':
            self.riscv_emitter.emit("""
                ld a1, 0(sp)          # value
                addi sp, sp, 8
                ld a0, 0(sp)          # key
                addi sp, sp, 8
                jal sstore_impl
            """)
        else:  # SLOAD
            self.riscv_emitter.emit("""
                ld a0, 0(sp)          # key
                addi sp, sp, 8
                jal sload_impl
                addi sp, sp, -8
                sd a0, 0(sp)          # push result
            """)

    def _handle_memory(self, opcode):
        """Handle memory operations"""
        if opcode == 'MSTORE':
            self.riscv_emitter.emit("""
                ld a1, 0(sp)          # value
                addi sp, sp, 8
                ld a0, 0(sp)          # offset
                addi sp, sp, 8
                jal mstore_impl
            """)
        else:  # MLOAD
            self.riscv_emitter.emit("""
                ld a0, 0(sp)          # offset
                addi sp, sp, 8
                jal mload_impl
                addi sp, sp, -8
                sd a0, 0(sp)          # push result
            """)

    def _handle_basic_opcode(self, opcode):
        """Handle basic arithmetic and logic operations"""
        mapping = self.opcode_mapping.get_riscv_mapping(opcode)
        if mapping:
            self.riscv_emitter.emit(f"""
                ld a1, 0(sp)          # second operand
                addi sp, sp, 8
                ld a0, 0(sp)          # first operand
                addi sp, sp, 8
                {mapping['instr']} t0, a0, a1
                addi sp, sp, -8
                sd t0, 0(sp)          # push result
            """)

    def _generate_final_assembly(self):
        """Generate final optimized RISC-V assembly"""
        return self.riscv_emitter.get_assembly()

def main():
    if len(sys.argv) != 3:
        print("Usage: python -m transpiler.main <input.asm> <output.s>")
        sys.exit(1)

    try:
        transpiler = EVMTranspiler()
        transpiler.transpile(sys.argv[1], sys.argv[2])
    except Exception as e:
        logger.error(f"Transpilation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()