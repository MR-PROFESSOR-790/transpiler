import os
from typing import Union, Optional
from utils.logger import logger

def read_file(filepath: str, binary: bool = False) -> Optional[Union[str, bytes]]:
    if not filepath or not isinstance(filepath, str):
        logger.error("Invalid file path provided.")
        return None

    mode = 'rb' if binary else 'r'
    try:
        with open(filepath, mode) as f:
            data = f.read()
            logger.info(f"Read {len(data)} bytes from {filepath}")
            return data
    except FileNotFoundError:
        logger.error(f"File not found: {filepath}")
    except PermissionError:
        logger.error(f"Permission denied: {filepath}")
    except Exception:
        logger.exception(f"Unexpected error reading file: {filepath}")
    return None


def write_file(filepath: str, data: Union[str, bytes], binary: bool = False) -> None:
    if not filepath or not isinstance(filepath, str):
        logger.error("Invalid file path provided.")
        return

    if data is None:
        logger.error("No data provided to write.")
        return

    # Handle data conversion
    if binary and isinstance(data, str):
        data = data.encode('utf-8')
    elif not binary and isinstance(data, bytes):
        data = data.decode('utf-8')

    mode = 'wb' if binary else 'w'
    try:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, mode) as f:
            f.write(data)
            logger.info(f"Wrote {len(data)} bytes to {filepath}")
    except PermissionError:
        logger.error(f"Permission denied while writing file: {filepath}")
    except Exception:
        logger.exception(f"Unexpected error writing file: {filepath}")


def append_file(filepath: str, data: Union[str, bytes], binary: bool = False) -> None:
    if not filepath or not isinstance(filepath, str):
        logger.error("Invalid file path provided.")
        return

    if data is None:
        logger.error("No data provided to append.")
        return

    # Handle data conversion
    if binary and isinstance(data, str):
        data = data.encode('utf-8')
    elif not binary and isinstance(data, bytes):
        data = data.decode('utf-8')

    mode = 'ab' if binary else 'a'
    try:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, mode) as f:
            f.write(data)
            logger.info(f"Appended {len(data)} bytes to {filepath}")
    except PermissionError:
        logger.error(f"Permission denied while appending file: {filepath}")
    except Exception:
        logger.exception(f"Unexpected error appending file: {filepath}")