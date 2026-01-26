ARG BUILD_FROM=ghcr.io/home-assistant/home-assistant:stable
FROM ${BUILD_FROM}

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
        ntfy

COPY run.sh /
RUN chmod +x /run.sh

CMD [ "/run.sh" ]