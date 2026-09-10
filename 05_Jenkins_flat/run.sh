#!/usr/bin/env bash
# Reconstructed local workflow; run with Git Bash on Windows.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

stage=${1:-all}
case "$stage" in all|build|flash|test) ;; *) echo 'Usage: bash 05_Jenkins_flat/run.sh [all|build|flash|test]' >&2; exit 2 ;; esac
export COM_PORT=${COM_PORT:-COM6}
build_dir=firmware/atcmd/build
elf=$build_dir/atcmd.elf

require() { command -v "$1" >/dev/null || { echo "Missing command: $1" >&2; exit 2; }; }
if [[ $stage == all || $stage == build ]]; then
    require cmake
    require ninja
    require arm-none-eabi-gcc
    : "${PICO_SDK_PATH:?Set PICO_SDK_PATH to your installed Pico SDK}"
fi
if [[ $stage == all || $stage == flash ]]; then require openocd; fi
if [[ $stage == all || $stage == test ]]; then require robot; fi

build() {
    cmake -S firmware/atcmd -B "$build_dir" -G Ninja \
        -DCMAKE_BUILD_TYPE=Debug -DPICO_BOARD=pico_w -DPICO_NO_PICOTOOL=1
    cmake --build "$build_dir" --parallel 4
}
flash() {
    [[ -s $elf ]] || { echo "Missing firmware: $elf. Run the build stage first." >&2; return 2; }
    openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg \
        -c "adapter speed 1000" -c "program $elf verify reset exit"
}
test_target() {
    robot --variable "COM_PORT:$COM_PORT" --outputdir results/05 05_Jenkins_flat/atcmd5.robot
}

case "$stage" in
    all) build; flash; test_target ;;
    build) build ;;
    flash) flash ;;
    test) test_target ;;
esac
