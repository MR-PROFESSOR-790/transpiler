import logging

class TranspilerLogger:
    def __init__(self):
        self.context = None
        self.logger = logging.getLogger('transpiler')
        self.setup_logger()
        
    def setup_logger(self):
        """Configure basic logging settings."""
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler = logging.StreamHandler()
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)
        
    def set_context(self, context):
        """Set compilation context for logging."""
        self.context = context
        return self
        
    def set_log_level(self, level):
        """Set logging level."""
        self.logger.setLevel(level)
        
    def debug(self, message):
        """Log debug message."""
        self.logger.debug(message)
        
    def info(self, message):
        """Log info message."""
        self.logger.info(message)
        
    def warning(self, message):
        """Log warning message."""
        self.logger.warning(message)
        
    def error(self, message):
        """Log error message."""
        self.logger.error(message)