#ifndef CUSTOM_LOGGER_H
#define CUSTOM_LOGGER_H

//ENUM definition for log levels
enum log_level {
    INFO = 0,
    WARN = 1,
    ERROR = 2
};

//Logger function prototype
void log_message(enum log_level level, const char *message);

#endif