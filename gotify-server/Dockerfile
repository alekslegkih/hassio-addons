ARG BUILD_FROM=ghcr.io/home-assistant/home-assistant:stable
FROM ${BUILD_FROM}

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

LABEL \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}"
  
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache \
        gotify

COPY run.sh /
RUN chmod +x /run.sh

CMD [ "/run.sh" ]