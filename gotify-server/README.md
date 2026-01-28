# Gotify Server

Этот аддон — обёртка над сервером [Gotify](https://github.com/gotify/server), предназначенная для удобного развёртывания
локального сервера push-уведомлений в Home Assistant.

> [!WARNING]
> Аддон не модифицирует Gotify и не управляет пользователями, приложениями или токенами.  
> Все настройки и управление выполняются стандартными средствами Gotify через Web UI или API.  
> HTTPS и SSL в аддоне не настраиваются намеренно.  
> TLS-терминация выполняется Home Assistant или внешним прокси.

---

## Лицензирование

[![Addon License: MIT](https://img.shields.io/badge/Addon%20License-MIT-green.svg)](https://github.com/alekslegkih/hassio-addons/blob/main/LICENSE)
[![Gotify License: MIT](https://img.shields.io/badge/Gotify%20License-MIT-green.svg)](https://github.com/gotify/server/blob/master/LICENSE)

---

## Установка

### Автоматическая установка (рекомендуется)

Чтобы добавить этот репозиторий в Home Assistant, нажмите кнопку ниже:

[![Добавить в Home Assistant](https://img.shields.io/badge/Добавить%20в-Home%20Assistant-blue?logo=home-assistant&logoColor=white&labelColor=41B3A3)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/alekslegkih/hassio-addons)

> [!TIP]
> Если автоматическая кнопка не работает,
> используйте официальную документацию по установке сторонних аддонов.

[![Официальная документация](https://img.shields.io/badge/Официальная%20документация-Home%20Assistant-blue?logo=home-assistant&logoColor=white&labelColor=41B3A3)](https://www.home-assistant.io/common-tasks/os#installing-a-third-party-add-on-repository)

---

### Ручная установка

В веб-интерфейсе Home Assistant перейдите в:
**Settings → Add-ons → Add-on Store**

В правом верхнем углу нажмите на меню с тремя точками и выберите пункт Repositories.  
Вставьте ссылку на репозиторий:

```htm
https://github.com/alekslegkih/hassio-addons
```

После добавления репозитория установите аддон **ntfy Server** из списка.

---

## Как это работает

При первом запуске аддон:

- создаёт файл конфигурации /config,/config.yml,
- инициализирует базу данных SQLite,
- запускает сервер Gotify.

При последующих запусках:

- используется существующий конфигурационный файл,
- все данные сохраняются между перезапусками.

> [!TIP]
> Вы можете вручную изменить файл /config/config.yml  
> После перезапуска аддона новые настройки применятся автоматически.

---

## Конфигурация по умолчанию

При первом запуске создаётся следующий конфигурационный файл:

```yaml
server:
  listenaddr: 0.0.0.0
  port: 80
  uploadedimagesdir: /config/images

database:
  dialect: sqlite3
  connection: /config/gotify.db
```

Аддон использует SQLite и не требует внешней базы данных.

---

## Веб-интерфейс

- Веб-интерфейс Gotify доступен через кнопку Web UI в Home Assistant
- По умолчанию используется порт 8486

---

## Благодарности

Спасибо проекту [Gotify](https://github.com/gotify/server) за простой сервер push-уведомлений!  
Проект распространяется под лицензией [MIT License](https://github.com/gotify/server/blob/master/LICENSE).

