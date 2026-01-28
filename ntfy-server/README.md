# ntfy Server

Этот аддон — обёртка над официальным сервером [ntfy](https://ntfy.sh), предназначенная для удобного развёртывания локального сервера уведомлений
в экосистеме Home Assistant.

> [!WARNING]
> Аддон не изменяет логику ntfy, не добавляет собственных API и не управляет внутренней конфигурацией сервера.  
> Управление пользователями, доступами и топиками выполняется стандартными средствами ntfy.

---

## Лицензирование

Аддон: [MIT License](https://github.com/alekslegkih/hassio-addons/tree/main/LICENSE)  
ntfy: [Apache License 2.0](https://github.com/binwiederhier/ntfy/blob/main/LICENSE)

[![License][license-shield]](https://github.com/alekslegkih/hassio-addons/tree/main/LICENSE)
[![License][license-shield]](https://github.com/binwiederhier/ntfy/blob/main/LICENSE)



## Как это работает

- При первом запуске аддон:
  - создаёт файл конфигурации **server.yml**,
  - создаёт базы данных кэша и аутентификации,
  - запускает сервер ntfy.
- При последующих запусках используется существующий конфигурационный файл

> [!TIP]
> Вы можете вручную изменить файл /config/config.yml.
> После перезапуска аддона новые настройки применятся автоматически.  

```yaml
# Logging
# Возможные значения: trace, debug, info, warn, error
log-level: warn

## Адрес для прослушивания HTTP-запросов
listen-http: ":8080"

## Кэш (требуется для параметров since= и poll)
cache-file: "/config/cache.db"
cache-duration: "72h"

## Аутентификация
auth-file: "/config/auth.db"
auth-default-access: "deny-all"  # по умолчанию — запретить всё

## Рекомендуется для мобильных клиентов
keepalive-interval: "45s"

## Ограничения на размерс ообщения
message-size-limit: "4k"

## Включите, если сервис работает за обратным прокси
behind-proxy: true

## Публичный URL (обязателен для iOS, вложений)
## Необходим при использовании обратного прокси с UI
# base-url: "https://ntfy.example.com"
```
---

## Благодарности

binwiederhier — за проект [ntfy](https://github.com/binwiederhier/ntfy)
Home Assistant — за инфраструктуру аддонов

[license-shield]: https://img.shields.io/github/license/alekslegkih/hassio-addons.svg