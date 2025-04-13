#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "custom_logger.h"

// Implementing the logger function
void log_message(enum log_level level, const char *message) {
    // Based on the log level, we print the appropriate prefix.
    switch (level) {
        case INFO:
            printf("[INFO] %s\n", message);
            break;
        case WARN:
            printf("[WARN] %s\n", message);
            break;
        case ERROR:
            printf("[ERROR] %s\n", message);
            break;
        default:
            printf("[UNKNOWN] %s\n", message); // For possible error
            break;
    }
}