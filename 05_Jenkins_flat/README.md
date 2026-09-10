# Exercise 5: course-aligned build, program, test

The pipeline builds in Docker, programs Pico W with the Debug Probe on Windows,
and runs all six tests from exercise 3. Jenkins and Gogs run as separate service
containers. The Windows agent needs Docker Desktop access, OpenOCD, Git and the
working `robot` command. It no longer needs a host Pico SDK/compiler for this job.

## Local validation (Git Bash, repository root)

Start Docker Desktop in Linux-container mode. Connect the probe to addon SWD and
connect target USB. Close serial terminals. Select your target port; COM6 below
is an example and must not be confused with the probe UART port.

```bash
export COM_PORT=COM6
docker compose -p pico-ex05-build -f docker-compose.yml up --build --abort-on-container-exit --exit-code-from pico
```

Expected: Pico W/RP2040 configuration, successful build, container exit code 0,
and `firmware/atcmd/build-docker/atcmd.elf`. This directory is separate from the
native Windows build cache. If the build fails, stop; do not flash an older ELF.
Clean up the completed build container/network (firmware output stays on disk):

```bash
docker compose -p pico-ex05-build -f docker-compose.yml down
```

After a successful build, flash the new ELF; this replaces target firmware:

```bash
test -s firmware/atcmd/build-docker/atcmd.elf &&
openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 1000" -c "program firmware/atcmd/build-docker/atcmd.elf verify reset exit"
```

Expected: `Verified OK`, then target reset. Only then run:

```bash
robot --outputdir results/05 03_Setup_and_teardown_and_resources/atcmd.robot
```

Expected: **6 tests passed**, including setup/teardown. The exercise 3 library
waits up to ten seconds for USB serial to reopen after flashing and closes it in
teardown. The three-test `atcmd5.robot` is preserved as an additional practice
suite, but it is not the PDF's final pipeline test target.

## Services and Jenkins job

See [controller/Gogs/agent setup](jenkins/README.md). The Jenkinsfile executes the
same steps directly, without a shell wrapper. Build failure stops later stages;
`--exit-code-from pico` passes the compiler container's failure back to Jenkins.
The build container is removed in a post action; test reports are archived even
when tests fail. Use a one-executor Windows hardware agent labelled
`pico-w-windows`, with `COM_PORT` configured. Do not run other jobs or manual tools
against the same target simultaneously.

## Original material and deliberate adaptations

- Root Dockerfile and Compose restore the pattern in
  `exercise5_dist/pico-build-docker.zip`: source bind mount and containerized build.
- Alpine 3.20 and SDK 2.1.0 replace the starter's Alpine 3.17 / SDK 1.5.1.
  The ARM C++ compiler is explicitly installed. SDK version is fixed; Alpine
  package revisions may change on a future image rebuild.
- `pico_w` replaces `pico`. USB stdio remains enabled and UART stdio disabled.
- ELF output is used directly with OpenOCD; unused picotool/UF2 generation and
  the starter's root password/SSH provisioning are omitted from the build image.
- `build-docker` replaces `cmake-build-debug` to distinguish Linux and Windows
  CMake caches. Source remains in `firmware/atcmd` to preserve exercise numbering.
- Gogs uses the course SSH-port adjustment, with 10022 both inside and outside
  Docker. Current pinned Gogs/Jenkins images replace the original floating tags.
- Direct CMSIS-DAP/RP2040 OpenOCD configuration replaces editing pico-debug.cfg;
  debugger flashing has been proven to work with this target.

## Completion evidence

The earlier native-Windows pipeline succeeded, but that alone does not validate
this revised course workflow. Keep evidence of: Gogs repository/SSH checkout,
containerized build, debugger programming/verification, six exercise 3 tests,
Jenkins successful console output and archived reports. Submit the source/config
files and demonstrate the pipeline to the instructor as required by the PDF.
