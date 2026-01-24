ARG BUILD_FROM=ghcr.io/home-assistant/home-assistant:stable
FROM ${BUILD_FROM}

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
        gotify \
        mc

# RUN mkdir -p /config /data /addon_configs /var/lib/gotify

COPY run.sh /
RUN chmod +x /run.sh

CMD [ "/run.sh" ]