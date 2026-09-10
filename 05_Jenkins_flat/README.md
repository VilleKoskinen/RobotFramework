# Exercise 5: build, program, test

The original exercise asks for a Jenkins build → debugger programming → Robot
pipeline. `run.sh` and `Jenkinsfile` are reconstructed integration files; the
firmware source provenance is documented in `../firmware/atcmd/README.md`.
The local workflow is the first milestone. No Jenkins server is installed here.

## Git Bash (from repository root)

```bash
export PICO_SDK_PATH='C:/Users/Ville/pico-sdk'
export COM_PORT=COM6
bash 05_Jenkins_flat/run.sh
```

This builds the Pico W AT application, replaces the target firmware over SWD,
verifies flash, resets the target, then executes three serial tests. Connect both
the Debug Probe and target USB; connect probe D to addon SWD and close serial
terminals. COM6 is the previously verified target; COM5 belongs to the probe UART.

Prerequisites on PATH: cmake, ninja, arm-none-eabi-gcc, openocd, robot. Tested SDK
2.1.0 and ARM GCC 13.3.1; active Robot 7.1.1/Python 3.12.6. No `.venv` is required.
Build uses `pico_w`, USB stdio and Debug; picotool/UF2 generation is disabled because
SWD programs the ELF. See firmware README for toolchain details.

Stages can also run separately:

```bash
bash 05_Jenkins_flat/run.sh build
bash 05_Jenkins_flat/run.sh flash
bash 05_Jenkins_flat/run.sh test
```

Only `flash` and the default `all` replace firmware. Tests alone assume compatible
firmware is already installed. The runner resolves its root from its own location,
so from this exercise folder you can use `bash run.sh test`.

Expected: successful CMake/Ninja build, OpenOCD `Verified OK`, and **3 tests passed**.
Reports: `results/05/output.xml`, `log.html`, `report.html`. The runner returns a
nonzero status on failure and does not proceed to later stages. It checks that an
ELF exists before flashing. USB-port opening retries for up to ten seconds after
reset; this does not hide a permanently wrong/busy COM port. Suite teardown restores
echo and closes the port even if the echo check fails.

Direct test command (repository root):

```bash
robot --variable COM_PORT:COM6 --outputdir results/05 05_Jenkins_flat/atcmd5.robot
```

Port priority: CLI variable, environment COM_PORT, COM6 convenience fallback.
From this folder, `robot atcmd5.robot` works. No duplicate library import or invalid
`${ENV:COM_PORT}` expression remains.

## Jenkins preparation (not yet server-validated)

Use the reconstructed `05_Jenkins_flat/Jenkinsfile` as the Pipeline script path
in a Pipeline-from-SCM job. Configure a Windows agent labelled `pico-w-windows`
with one executor, physically connected to this target and probe. Do not share the
target with other jobs or manual tests. The pipeline disables concurrent runs of
this job; it does not lock hardware across unrelated jobs.

Set agent environment variables:

- `GIT_BASH`: absolute executable path, e.g. `C:\Program Files\Git\bin\bash.exe`.
  This avoids accidentally invoking Windows' WSL `bash.exe`.
- `PICO_SDK_PATH`: installed SDK location, e.g. `C:/Users/Ville/pico-sdk`.
- `COM_PORT`: actual target port (currently COM6).
- PATH: working Robot, OpenOCD, CMake, Ninja and ARM GCC for the agent account.

The pipeline checks out the repo through Jenkins' standard SCM checkout and runs
Build, Program Pico W, Robot tests in order. Reports are archived even if the test
stage fails. Robot exit codes determine failure. Robot plugin graphs and Git hooks
are exercise 6 follow-up work; this draft uses standard artifact archiving only.

The agent still needs a controller, compatible Java, repository credentials and
USB access. Services and credentials must be configured and checked before calling
this a working Jenkins pipeline. Ensure the new firmware source and runner are
committed before a clean agent checkout can use them.
