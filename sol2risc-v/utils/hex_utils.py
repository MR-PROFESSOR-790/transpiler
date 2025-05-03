def read_bytecode(file_path):
    with open(file_path, 'r') as f:
        content = f.read().strip()
        
    if content.startswith('0x'):
        content = content[2:]

    return ''.join(content.split()).lower()

def hex_to_bytes(hex_str):
    return bytes.fromhex(hex_str)

def bytes_to_hex(byte_data):
    return byte_data.hex()

def hex_to_int(hex_str):
    return int(hex_str, 16)

def int_to_hex(val, byte_length = 4):
    return val.to_bytes(byte_length, byteorder='big').hex()

def reverse_endian(hex_str):
    
    bytes_list = [hex_str[i:i+2] for i in range(0, len(hex_str), 2)]
    return ''.join(reversed(bytes_list))

def pad_hex(hex_str, length):
    return  hex_str.rjust(length, '0')
