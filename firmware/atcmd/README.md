# Pico W AT-command baseline

Source: `Exercises.zip` -> `Exercises/exercise5_dist.zip` ->
`exercise5_dist/atcmd.zip` -> `atcmd/atcmd.c`. Restored with normalized line
endings and one C fix: initialize `rcv` before its first possible `strlen`.
CMake is simplified to select Pico W before SDK import, link `pico_stdlib`,
and enable USB stdio with UART stdio disabled. No addon LEDs, motors, buttons,
Wi-Fi or display are driven. The course parser and its limitations remain.

This is the echo-control variant for exercises 3–6, not the basic exercise 2
image or the unfinished Ceedling exercise 9 firmware. Echo starts ON.
It is not claimed to be binary-identical to the supplied UF2 images.

The SDK example below assumes an installation at `$HOME/pico-sdk`; adjust it
if your SDK is installed elsewhere. `cygpath` converts the path for Windows CMake.

## Build in Git Bash

From the repository root, with the installed Pico SDK 2.1.0, ARM GCC 13.3.1,
CMake and Ninja on PATH:

```bash
export PICO_SDK_PATH="$(cygpath -m "$HOME/pico-sdk")"
cmake -S firmware/atcmd -B firmware/atcmd/build -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DPICO_BOARD=pico_w -DPICO_NO_PICOTOOL=1
cmake --build firmware/atcmd/build --parallel 4
```

Expected: `firmware/atcmd/build/atcmd.elf`. The local build directory is ignored.
`PICO_NO_PICOTOOL=1` avoids fetching/building picotool and disables UF2 generation;
ELF is sufficient for SWD programming. SDK/toolchain are external prerequisites,
not downloaded automatically by these instructions. Configure output must show
Pico W, RP2040, Debug, and TinyUSB support.

## Flash via official Raspberry Pi Debug Probe

This replaces the application on the target. Keep the probe connected to the
addon SWD signals and connect the Pico W directly to USB for power and serial.
From the repository root in Git Bash:

```bash
test -s firmware/atcmd/build/atcmd.elf && \
openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg \
  -c "adapter speed 1000" \
  -c "program firmware/atcmd/build/atcmd.elf verify reset exit"
```

Expected: programming and verification succeed, followed by reset. The existence
check prevents the earlier missing-file mistake. No BOOTSEL is needed.

## Identify target serial and verify protocol

```bash
./.venv/Scripts/python.exe -m serial.tools.list_ports -v
```

The probe UART uses VID:PID 2E8A:000C; use the separate target USB serial port.
The exact target COM number is not yet known. Select it in a serial terminal at
115200 baud, disable terminal local echo, and send commands with LF endings.

1. Send `ATE0`: its own text may be echoed, then `OK`.
2. Send `AT`: expect `OK`.
3. Send `ATE`: expect `OFF` and `OK` on separate lines.
4. Send `AT+SEND="hello, world!"`: expect `SENT="HELLOX WORLDX"` and `OK`.
5. Send `ATE1`: expect `OK`, restoring echo for exercise 3 suite setup.

Close the terminal before Robot opens the target port. Build success only verifies
compilation/linking; flashing and USB/AT behavior must be checked on the hardware.
The firmware does not blink an LED to indicate readiness.
