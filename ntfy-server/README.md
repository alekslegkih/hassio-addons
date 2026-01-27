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

- При первом запуске аддон:
  - создаёт файл конфигурации **server.yml**,
  - создаёт базы данных кэша и аутентификации,
  - запускает сервер ntfy.
- При последующих запусках используется существующий конфигурационный файл

> [!TIP]
> Вы можете изменить конфигурацию сервера в файле /config/server.yml  
> При перезапуске новые настройки применятся автоматически.  

**По умолчанию создаётся следующий конфигурационный файл:**

```yaml
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

## Мобильные клиенты

- Android и iOS клиенты полностью поддерживаются
- Для iOS обязательно указать параметр **base-url**
- Размер сообщений ограничен 4 KB для совместимости с FCM/APNS

---

## Благодарности

binwiederhier — за проект [ntfy](https://github.com/binwiederhier/ntfy)
