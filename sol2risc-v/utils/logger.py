import logging
import os
import sys
from datetime import datetime

DEFAULT_LOG_FILE_PATH = "output/test.log"

LOG_COLORS = {
    "DEBUG": "\033[94m",  # Blue
    "INFO": "\033[92m",   # Green
    "WARNING": "\033[93m",  # Yellow
    "ERROR": "\033[91m",  # Red
    "CRITICAL": "\033[95m",  # Magenta
    "RESET": "\033[0m",   # Reset to default color
}


class ColoredFormatter(logging.Formatter):
    def __init__(self, fmt, datefmt=None, use_colors=True):
        super().__init__(fmt, datefmt)
        self.use_colors = use_colors

    def format(self, record):
        if self.use_colors:
            log_color = LOG_COLORS.get(record.levelname, LOG_COLORS["RESET"])
            message = super().format(record)
            return f"{log_color}{message}{LOG_COLORS['RESET']}"
        else:
            return super().format(record)


def setup_logger(name="EVM_RISCV_LOGGER", log_file=DEFAULT_LOG_FILE_PATH, level=logging.DEBUG, use_colors=True):
    logger = logging.getLogger(name)
    logger.setLevel(level)

    if not logger.handlers:
        # File handler
        file_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        os.makedirs(os.path.dirname(log_file), exist_ok=True)
        file_handler = logging.FileHandler(log_file, mode='a')
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)

        # Console handler
        console_formatter = ColoredFormatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S',
            use_colors=use_colors and sys.stdout.isatty()
        )
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(console_formatter)
        logger.addHandler(console_handler)

    return logger


logger = setup_logger()