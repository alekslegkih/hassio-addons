ARG BUILD_FROM=ghcr.io/home-assistant/home-assistant:stable
FROM $BUILD_FROM

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

LABEL \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}"

RUN apk add --no-cache \
    minidlna \
    mc  # <-- Это временно для тестирования

COPY run.sh /
COPY rootfs/etc/minidlna/ /etc/minidlna/

RUN chmod a+x /run.sh /

CMD [ "/run.sh" ]


