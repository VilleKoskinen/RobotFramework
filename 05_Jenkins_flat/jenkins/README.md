# Course Jenkins, Gogs and Windows agent

The controller and Git server run in containers; the Windows hardware agent
invokes a separate Linux build container, then OpenOCD and Robot locally.

## 1. Service hostnames and startup

The course requires these Windows hosts-file entries (administrator edit only
if missing). They were already present during inspection:

```text
127.0.0.1 jenkins
127.0.0.1 gogs
```

From the repository root in Git Bash:

```bash
docker compose -f 05_Jenkins_flat/jenkins/compose.yml up -d --build
```

URLs: http://jenkins:8080/ and http://gogs:3000/. Gogs occupies port 3000; stop Gogs
before later Selenium exercises that use the same port. Existing Jenkins named
volume/settings are retained. `down` preserves volumes; do not use `down -v` unless
you intend to erase accounts/configuration/repositories.

## 2. Gogs initial setup

Use SQLite3 with its default database path and keep the service user/repository
path defaults. Domain: `gogs`; SSH port: `10022`; application URL:
`http://gogs:3000/`. Set default branch `main` if offered. Create your own admin
account privately, then an empty `RobotFramework` repository (no README).
Do not copy personal account names, local home paths or secrets into repository docs.

Gogs' derived Dockerfile reproduces the course's SSH listener change to 10022,
so one SSH clone URL works from Windows and the Jenkins controller container.
The services resolve each other by Compose service name; Windows uses hosts entries.

## 3. Repository and SSH credentials

Use the SSH clone URL from your own Gogs repository. Keep `origin` pointing to
GitHub and add a separate `gogs` remote. Do not run a placeholder URL as a command.
After reviewing/committing the course workflow, push `main` to that remote.
This publishes committed files only; never add agent.jar, secret-file or SSH keys.

Follow the course credential flow: generate a dedicated keypair for Jenkins,
register the public key in Gogs, and store the private key only in Jenkins
Credentials as 'SSH Username with private key' (SSH username `git`). The agent's
connection secret is unrelated to this Git credential. Do not paste either secret
into chat or repository files. A separate user SSH key can be registered in Gogs
for your local push. Configure Jenkins Git host-key verification for Gogs; do not
turn verification off. The course uses Accept first connection; verify the server
fingerprint before trusting its first connection when possible.

## 4. Existing Windows hardware agent

Keep the agent terminal connected using Java 21 and WebSocket. Label:
`pico-w-windows`; executors: 1. Built-in controller executors: 0. Set agent
`COM_PORT` to the actual target USB port. The agent account needs `docker`,
`openocd`, `robot` and Git on PATH, and access to Docker Desktop and both USB devices.
`PICO_SDK_PATH` and `GIT_BASH` are no longer used by this pipeline, although they
may remain useful for other jobs. Refresh/reconnect the agent after PATH changes.
Set Jenkins' configured URL to http://jenkins:8080/ for the course hostname.
An existing localhost WebSocket agent connection may keep working on the same PC.

## 5. Pipeline from Gogs

Configure the job to use Git with the actual Gogs SSH clone URL, its dedicated
Jenkins credential, branch `*/main`, and script path `05_Jenkins_flat/Jenkinsfile`.
Both controller and agent must be able to clone this URL. Build Now replaces the
target application. Verify the log checks out the intended Gogs commit, builds
inside the pico service, flashes `build-docker/atcmd.elf`, and runs six tests.

This completes the exercise 5 workflow only after that real build succeeds.
Push hooks and Robot report graphs remain exercise 6. The instructor demo and
submission cannot be completed by a local build alone.

## Current versus original service configuration

Jenkins 2.568.3/Java 21 and Gogs 0.14.3 are pinned. Named volumes are project-scoped
rather than global to avoid overwriting unrelated installations. Web interfaces
and SSH bind to localhost. We use WebSocket agents instead of exposing TCP 50000.
The source build is a separate root Compose project so finishing/stopping it does
not stop Jenkins/Gogs. No container gets the Docker socket or Pico USB device.

References:
- https://www.jenkins.io/doc/book/installing/docker/
- https://gogs.io/getting-started/installation
- https://github.com/gogs/gogs/blob/main/docker/README.md
