# Jenkins controller and Windows hardware agent

Reconstructed exercise 5 setup. The original archive supplies Jenkins and Gogs
containers; this first step uses the existing GitHub repository and a controller
container. Gogs/hook work belongs to the later exercise 6 setup. No Docker socket
or target USB passthrough is needed: build, flash and Robot run on Windows.

## 1. Start the controller (Git Bash, repository root)

Start Docker Desktop in Linux-container mode first.

```bash
docker info
docker compose -f 05_Jenkins_flat/jenkins/compose.yml config --quiet
docker compose -f 05_Jenkins_flat/jenkins/compose.yml up -d
docker compose -f 05_Jenkins_flat/jenkins/compose.yml logs --tail=30 jenkins
```

The pinned controller image uses Jenkins 2.568.3 / Java 21. Expect Jenkins to
finish startup and serve http://localhost:8080. Settings live in a project-scoped
named volume. Stop with `docker compose -f 05_Jenkins_flat/jenkins/compose.yml down`;
do not add `-v` unless you intend to erase Jenkins configuration.

Read the initial password locally (do not paste it into chat):

```bash
MSYS_NO_PATHCONV=1 docker compose -f 05_Jenkins_flat/jenkins/compose.yml exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Unlock Jenkins, install suggested plugins (including Pipeline and Git), create
your own administrator account and set the URL to http://localhost:8080/.
Set the built-in node executor count to zero. Do not disable authentication.

## 2. Prepare Java on Windows

The container includes its own Java, but the Windows agent needs Java 21 or newer.
Java 17 found on this machine is not suitable for this controller version.
If Java 21 is not already installed, install it in a separate step, for example:

```bash
winget install --exact --id EclipseAdoptium.Temurin.21.JDK
```

Open a new Git Bash after installation and check:

```bash
java -version
robot --version
command -v git cmake ninja arm-none-eabi-gcc openocd robot
```

Do not substitute the unrelated Python 3.13 environment for the working `robot`.

## 3. Create the agent in Jenkins

Manage Jenkins → Nodes → New Node:

- Name and label: `pico-w-windows`.
- Type: permanent agent; executors: **1**.
- Remote root: `C:/Users/Ville/jenkins-agent` (dedicated agent directory).
- Usage: only build jobs with matching label expressions.
- Launch: connect agent to controller; enable **WebSocket**.
- Node environment: `GIT_BASH=C:\Program Files\Git\bin\bash.exe`,
  `PICO_SDK_PATH=C:/Users/Ville/pico-sdk`, `COM_PORT=COM6`.

Use the Windows/Git Bash connection instructions shown by that node's page to
download agent.jar and connect with its actual secret. Do not copy a made-up
secret or publish the node's secret. WebSocket uses port 8080, so this Compose file
does not expose inbound-agent TCP port 50000. Keep the agent terminal running.
Launch it under the same Windows user/environment that successfully runs the
local workflow. Expect the node to become Online.

## 4. Create the pipeline job

The current restored firmware and pipeline files must be committed and available
in the selected remote branch before Jenkins can check them out. This setup does
not commit or push automatically. Review the complete working-tree diff first,
especially existing UF2 deletions and generated-file changes.

Create a Pipeline job with Pipeline script from SCM, Git:

- Repository: https://github.com/VilleKoskinen/RobotFramework.git
- Branch: the remote branch containing the reviewed exercise 5 changes.
- Script path: `05_Jenkins_flat/Jenkinsfile`.
- Add read credentials only if the repository requires them.

Keep Pico target USB and Debug Probe connected, close serial terminals and avoid
other jobs/manual tests using the same hardware. Build Now will replace the target
application. Verify Build → Program Pico W → Robot tests succeed, OpenOCD reports
Verified OK, Robot reports 3 passed, and XML/HTML reports appear in artifacts.

The pipeline disables concurrent builds of this job; the single-executor agent
prevents two jobs on that agent from using the probe simultaneously. It cannot
prevent manual programs from opening COM6. Robot graphs and push triggers are
exercise 6 work. The controller and agent are not considered validated until a
real Jenkins build completes.

References: https://www.jenkins.io/doc/book/installing/docker/ and
https://www.jenkins.io/doc/book/platform-information/support-policy-java/
