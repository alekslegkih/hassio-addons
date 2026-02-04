# Simple DLNA

Этот аддон — обёртка над лёгким сервером **ReadyMedia (minidlna)**, предназначенная для
быстрого развёртывания DLNA-сервера в среде Home Assistant OS.

Аддон предоставляет базовый DLNA-сервер для трансляции видео, аудио и изображений
из каталогов Home Assistant (включая USB-накопители и сетевые хранилища).

> [!WARNING]
> Аддон не изменяет логику работы minidlna, не добавляет собственных API
> и не управляет внутренними механизмами DLNA.
> Поведение сервера полностью соответствует стандартному ReadyMedia.

---

## Лицензирование

[![Addon License: MIT](https://img.shields.io/badge/Addon%20License-MIT-green.svg)](https://github.com/alekslegkih/hassio-addons/blob/main/LICENSE)
[![ReadyMedia License: GPL--2.0](https://img.shields.io/badge/ReadyMedia%20License-GPL--2.0-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

---

## Как это работает

- При первом запуске аддон:
  - создаёт конфигурационный файл **minidlna.conf**,
  - инициализирует базу данных медиафайлов,
  - запускает DLNA-сервер в foreground-режиме.
- При последующих запусках используется существующая база и конфигурация.
- Сервер автоматически отслеживает изменения файловой системы
  и обновляет медиатеку.

Каталоги с медиафайлами подключаются через стандартный механизм Home Assistant
(`/media`, USB-накопители, сетевые шары).

---

## Конфигурация

Конфигурационный файл **minidlna.conf** создаётся автоматически в каталоге аддона
и сохраняется между перезапусками.

Пример используемой конфигурации:

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
> Вы можете вручную изменить файл minidlna.conf в каталоге аддона.
> После перезапуска аддона изменения будут применены автоматически.

---

## Сеть и доступ

- DLNA использует широковещательные протоколы (SSDP),
  поэтому аддон работает в режиме `host_network`.
- Веб-интерфейс сервера статистики доступен по TCP-порту **8200**.
- Внутренний порт сервера фиксирован, внешний порт может быть изменён
  в настройках аддона Home Assistant.

---

## Особенности и ограничения

- Аддон предназначен для локальной сети.
- Аутентификация и шифрование не поддерживаются (ограничение DLNA).
- Производительность и возможности зависят от используемых DLNA-клиентов.

---

## Благодарности

Спасибо проекту **ReadyMedia (minidlna)** за простой и надёжный DLNA-сервер.  
Проект распространяется под лицензией [GNU General Public License v2](https://sourceforge.net/projects/minidlna/)
