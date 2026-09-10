# Adapted from exercise5_dist/pico-build-docker.zip for Pico W / SDK 2.1.0.
FROM alpine:3.20
RUN apk add --no-cache git python3 cmake ninja build-base \
    gcc-arm-none-eabi g++-arm-none-eabi newlib-arm-none-eabi
ARG PICO_SDK_VERSION=2.1.0
RUN git clone --depth 1 --branch ${PICO_SDK_VERSION} \
    https://github.com/raspberrypi/pico-sdk.git /opt/pico-sdk \
    && git -C /opt/pico-sdk submodule update --init --depth 1 lib/tinyusb
ENV PICO_SDK_PATH=/opt/pico-sdk
WORKDIR /workspace
