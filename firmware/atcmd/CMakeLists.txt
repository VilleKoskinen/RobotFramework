cmake_minimum_required(VERSION 3.13)

# Set the board before importing the SDK so it selects Pico W definitions.
set(PICO_BOARD pico_w CACHE STRING "Target board")
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(atcmd C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()

add_executable(atcmd atcmd.c)
target_compile_options(atcmd PRIVATE -Wall -Wextra)
target_link_libraries(atcmd pico_stdlib)

# Robot communicates through the target USB cable, not the probe UART port.
pico_enable_stdio_usb(atcmd 1)
pico_enable_stdio_uart(atcmd 0)
pico_add_extra_outputs(atcmd)
