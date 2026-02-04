# Gotify Server

[Русская версия](https://github.com/alekslegkih/hassio-addons/blob/main/gotify-server/README_RU.md)

This add-on is a wrapper around the [Gotify](https://github.com/gotify/server) server,
designed for convenient deployment of a local push notification server
in Home Assistant.

> [!WARNING]
> This add-on does not modify Gotify and does not manage users, applications, or tokens.  
> All configuration and management is performed using standard Gotify tools
> via the Web UI or API.  
> HTTPS and SSL are intentionally not configured in this add-on.  
> TLS termination is expected to be handled by Home Assistant or an external reverse proxy.

---

## Licensing

[![Addon License: MIT](https://img.shields.io/badge/Addon%20License-MIT-green.svg)](https://github.com/alekslegkih/hassio-addons/blob/main/LICENSE)  
[![Gotify License: MIT](https://img.shields.io/badge/Gotify%20License-MIT-green.svg)](https://github.com/gotify/server/blob/master/LICENSE)

---

## How It Works

On the first start, the add-on:

- creates the configuration file at /config/config.yml,
- initializes the SQLite database,
- starts the Gotify server.

On subsequent starts:

- the existing configuration file is reused,
- all data is preserved between restarts.

> [!TIP]
> You can manually edit the /config/config.yml file.  
> New settings will be applied automatically after restarting the add-on.

---

## Default Configuration

On the first start, the following configuration file is created:

```yaml
    server:
      listenaddr: 0.0.0.0
      port: 80
      uploadedimagesdir: /config/images

    database:
      dialect: sqlite3
      connection: /config/gotify.db
```

The add-on uses SQLite and does not require an external database.

---

## Web Interface

- The Gotify web interface is available via the Web UI button in Home Assistant.
- By default, port **8486** is used.

---

## Acknowledgements

Thanks to the [Gotify](https://github.com/gotify/server) project for the simple push notification server!  
The project is distributed under the [MIT License](https://github.com/gotify/server/blob/master/LICENSE).
