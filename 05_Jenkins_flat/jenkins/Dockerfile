# Restored pattern from exercise5_dist/Dockerfile: same SSH port on host/container.
FROM gogs/gogs:0.14.3
RUN sed -i 's/^Port 22$/Port 10022/' /app/gogs/docker/sshd_config
