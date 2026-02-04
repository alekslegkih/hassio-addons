# Simple DLNA

[Русская версия](https://github.com/alekslegkih/hassio-addons/blob/main/simple-dlna/README_RU.md)

This add-on is a wrapper around the lightweight **ReadyMedia (minidlna)** server,
designed for quick and easy deployment of a DLNA server in the Home Assistant OS environment.

The add-on provides a basic DLNA server for streaming video, audio, and images
from Home Assistant directories, including USB storage devices and network shares.

> [!WARNING]
> This add-on does not modify the internal logic of minidlna, does not add custom APIs,
> and does not manage DLNA internals.  
> The server behavior fully matches the standard ReadyMedia implementation.

---

## Licensing

[![Addon License: MIT](https://img.shields.io/badge/Addon%20License-MIT-green.svg)](https://github.com/alekslegkih/hassio-addons/blob/main/LICENSE)  
[![ReadyMedia License: GPL--2.0](https://img.shields.io/badge/ReadyMedia%20License-GPL--2.0-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

---

## How It Works

- On the first start, the add-on:
  - creates the minidlna.conf configuration file,
  - initializes the media database,
  - starts the DLNA server in foreground mode.
- On subsequent starts, the existing configuration and database are reused.
- The server automatically monitors file system changes
  and updates the media library.

Media directories are mounted using standard Home Assistant mechanisms
(/media, USB drives, and network shares).

---

## Configuration

The minidlna.conf configuration file is created automatically inside the add-on directory
and is preserved between restarts.

Example configuration used by the add-on:

```conf
friendly_name=Simple DLNA
media_dir=/media

db_dir=/config/db

port=8200
inotify=yes
notify_interval=900
strict_dlna=no

album_art_names=Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg/AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg

log_dir=/config/log
log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn
```

> [!TIP]
> You can manually edit the minidlna.conf file in the add-on directory.  
> Changes will be applied automatically after restarting the add-on.

---

## Network and Access

- DLNA uses broadcast protocols (SSDP),
  therefore the add-on operates in host_network mode.
- The server statistics web interface is available on TCP port **8200**.
- The internal service port is fixed, but the external port
  can be changed in the Home Assistant add-on settings.

---

## Features and Limitations

- The add-on is intended for use within a local network.
- Authentication and encryption are not supported (DLNA limitation).
- Performance and capabilities depend on the DLNA clients in use.

---

## Acknowledgements

Thanks to the **ReadyMedia (minidlna)** project for a simple and reliable DLNA server.  
The project is distributed under the  [GNU General Public License v2](https://sourceforge.net/projects/minidlna/)
