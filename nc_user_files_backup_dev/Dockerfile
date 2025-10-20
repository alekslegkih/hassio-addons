ARG BUILD_FROM=ghcr.io/home-assistant/home-assistant:stable
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache curl python3 jq rsync yq

# Create directory structure
RUN mkdir -p /etc/nc_backup /usr/local/bin

# Copy scripts - пути ОТНОСИТЕЛЬНО контекста (./nc_user_files_backup_dev)
COPY run.sh /
COPY rootfs/usr/local/bin/backup.sh /usr/local/bin/backup.sh
COPY rootfs/etc/cont-init.d/ /etc/cont-init.d/
COPY rootfs/etc/nc_backup/ /etc/nc_backup/

# Make scripts executable
RUN chmod a+x /run.sh /usr/local/bin/backup.sh /etc/cont-init.d/* /etc/nc_backup/*.sh

CMD [ "/run.sh" ]