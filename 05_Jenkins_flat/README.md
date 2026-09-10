# Exercise 5: build, program, test

The course asks for a Jenkins build, debugger programming and Robot test pipeline.
`Jenkinsfile` is reconstructed integration code. The restored firmware's provenance
is documented in `../firmware/atcmd/README.md`.

## Local commands in Git Bash

Run from the repository root. The SDK example assumes `$HOME/pico-sdk`; adjust it
for your installation. COM6 is an example target USB port, not the probe UART port.

```bash
export PICO_SDK_PATH="$(cygpath -m "$HOME/pico-sdk")"
export COM_PORT=COM6
```

1. Build the Pico W firmware:

```bash
cmake -S firmware/atcmd -B firmware/atcmd/build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DPICO_BOARD=pico_w -DPICO_NO_PICOTOOL=1 &&
cmake --build firmware/atcmd/build --parallel 4
```

Expected: a successful build and `firmware/atcmd/build/atcmd.elf`. Do not proceed
if either command fails. SDK 2.1.0 and ARM GCC 13.3.1 were used for local validation.
The build enables USB serial and disables UART and UF2 generation. SWD uses ELF.

2. Flash only after the build succeeds:

```bash
test -s firmware/atcmd/build/atcmd.elf &&
openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 1000" -c "program firmware/atcmd/build/atcmd.elf verify reset exit"
```

This replaces the target application. Connect the probe D port to addon SWD and
connect target USB for power/serial. Close serial terminals. Expected: `Verified OK`
and target reset. Stop if programming or verification fails.

3. Run the tests:

```bash
robot --outputdir results/05 05_Jenkins_flat/atcmd5.robot
```

Expected: **3 tests passed**. Reports are under `results/05`. Testing alone assumes
compatible AT firmware is installed; it does not flash the target. From the exercise
folder, `robot atcmd5.robot` also works. Port priority: CLI `--variable COM_PORT:...`,
then environment `COM_PORT`, then COM6 fallback. No local `.venv` is required.

Serial opening retries for up to ten seconds after reset. Setup handles echo ON
or OFF; teardown restores ON and closes the port even if the echo check fails.

## Jenkins

Use `05_Jenkins_flat/Jenkinsfile` in a Pipeline-from-SCM job on a Windows agent
labelled `pico-w-windows`, with one executor and physical USB access. The pipeline
runs the same tools directly through Jenkins `bat` steps; Git Bash is for local
interactive commands and is not required by the pipeline.

Set node environment variables `PICO_SDK_PATH` (absolute Windows SDK path) and
`COM_PORT` (target USB port). Ensure cmake, ninja, arm-none-eabi-gcc, openocd and
robot are on the agent account's PATH. A previously configured `GIT_BASH` variable
can be removed; it is no longer used.

Each failed command fails its stage and prevents later normal stages from running.
Reports are archived from the test stage even when Robot fails. The pipeline
disables concurrent runs of this job; avoid unrelated jobs/manual tests using the
same probe and target. Robot plugin graphs and Git triggers are exercise 6 work.

See `jenkins/README.md` for controller and agent setup. Local build/flash/tests
have passed; a complete Jenkins execution still needs validation. Commit/push the
pipeline and firmware source before a clean Jenkins checkout can use them.
