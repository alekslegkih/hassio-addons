# ntfy Server

[Русская версия](https://github.com/alekslegkih/hassio-addons/blob/main/ntfy-server/README_RU.md)

This add-on is a wrapper around the official [ntfy](https://ntfy.sh) server,
designed for convenient deployment of a local notification server
within the Home Assistant ecosystem.

> [!WARNING]
> This add-on does not modify ntfy logic, does not add custom APIs,
> and does not manage the internal server configuration.  
> User management, access control, and topic handling are performed using
> standard ntfy [tools](ntfy_com.md).

---

## Licensing

[![Addon License: MIT](https://img.shields.io/badge/Addon%20License-MIT-green.svg)](https://github.com/alekslegkih/hassio-addons/blob/main/LICENSE)  
[![ntfy License: Apache-2.0](https://img.shields.io/badge/ntfy%20License-Apache--2.0-blue.svg)](https://github.com/binwiederhier/ntfy/blob/main/LICENSE)

---

## How It Works

- On the first start, the add-on:
  - creates the **server.yml** configuration file,
  - creates cache and authentication databases,
  - starts the ntfy server.
- On subsequent starts, the existing configuration file is reused.

> [!TIP]
> You can manually edit the /config/config.yml file.  
> New settings will be applied automatically after restarting the add-on.

Example configuration:

```yaml
  # Logging
  # Possible values: trace, debug, info, warn, error
  log-level: warn

  ## Address to listen for HTTP requests
  listen-http: ":8080"

  ## Cache (required for since= and poll parameters)
  cache-file: "/config/cache.db"
  cache-duration: "72h"

  ## Authentication
  auth-file: "/config/auth.db"
  auth-default-access: "deny-all"  # deny everything by default

  ## Recommended for mobile clients
  keepalive-interval: "45s"

  ## Message size limit
  message-size-limit: "4k"

  ## Enable if the service is running behind a reverse proxy
  behind-proxy: true

  ## Public URL (required for iOS and attachments)
  ## Required when using a reverse proxy with the web UI
  # base-url: "https://ntfy.example.com"
```

---

## Acknowledgements

Thanks to the [ntfy](https://github.com/binwiederhier/ntfy) project for the push notification server!  
The project is distributed under the [Apache License 2.0](https://github.com/binwiederhier/ntfy/blob/main/LICENSE).
