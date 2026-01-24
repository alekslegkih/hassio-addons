ARG BUILD_FROM=ghcr.io/home-assistant/home-assistant:stable
FROM $BUILD_FROM

# Install dependencies. mc for testing
RUN apk add --no-cache minidlna

# Create directory structure
# RUN mkdir -p /etc/minidlna

# Copy scripts and configs
COPY run.sh /
COPY rootfs/etc/minidlna/ /etc/minidlna/

# Make scripts executable
RUN chmod a+x /run.sh /

CMD [ "/run.sh" ]


