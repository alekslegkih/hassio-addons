ARG BUILD_FROM=ghcr.io/home-assistant/home-assistant:stable
FROM $BUILD_FROM

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

LABEL \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}"

RUN apk add --no-cache \
    minidlna
    
COPY run.sh /

RUN chmod a+x /run.sh /

CMD [ "/run.sh" ]


