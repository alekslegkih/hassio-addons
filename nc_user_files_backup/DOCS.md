# Аддон Nextcloud User Files Backup

Аддон предназначен для автоматического создания резервных копий
файлов пользователей Nextcloud на внешний USB-диск.
Для работы требуется предварительная настройка монтирования дисков
через правила udev и наличие долгоживущего токена доступа Home Assistant.

- ✅ **Автоматическое управление дисками**
- ✅ **Управление питанием через умные выключатели**
- ✅ **Инкрементное резервное копирование через rsync**
- ✅ **Гибкие уведомления** (Telegram, Signal, мобильные и т.д.)
- ✅ **Валидация конфигурации**
- ✅ **Тестовый режим для безопасной проверки**

## Установка

### Автоматическая установка (рекомендуется)

Чтобы добавить этот репозиторий в Home Assistant, нажмите кнопку ниже:

[![Добавить в Home Assistant](https://img.shields.io/badge/Добавить%20в-Home%20Assistant-blue?logo=home-assistant&logoColor=white&labelColor=41B3A3)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/alekslegkih/nc_user_files_backup)

> [!TIP]
> Если автоматическая кнопка не работает,
> следуйте официальной документации по установке сторонних аддонов.

[![Официальная документация](https://img.shields.io/badge/Официальная%20документация-Home%20Assistant-blue?logo=home-assistant&logoColor=white&labelColor=41B3A3)](https://www.home-assistant.io/common-tasks/os#installing-a-third-party-add-on-repository)

### Ручная установка

В веб-интерфейсе Home Assistant перейдите в раздел <kbd>Супервизор</kbd> ->
<kbd>Магазин дополнений</kbd>.  
В правом верхнем углу нажмите на меню с тремя точками <kbd>...</kbd>
и выберите пункт <kbd>Репозитории</kbd>.  
В появившемся окне вставьте ссылку на этот репозиторий и нажмите <kbd>Добавить</kbd>:

```htm
https://github.com/alekslegkih/nc_user_files_backup
```

## Конфигурация

> [!WARNING]
> Так как HAOS не позволяет работать с USB дисками напрямую,
> вы должны примонтировать их к системе.  
> Так же необходимо присвоить метки примонтированным разделам.
> Метки используются в конфигурации.

Для копирования правила для монтирвоания дисков в систему супервизора,
вам необходимо получить доступ по ssh.
Проще всего это сделать с помощью дополнения «HassOS SSH port 22222» от Adam Outler.

[![Добавить "HassOS SSH port 22222" в Home Assistant](https://img.shields.io/badge/Добавить%20%22HassOS%20SSH%20port%2022222%22%20в-Home%20Assistant-blue?logo=home-assistant&logoColor=white&labelColor=41B3A3)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/adamoutler/HassOSConfigurator)  
После получения доступа к системе, подключите диски и присвойте им метки.
В дальнейшем вам необходимо будет указать эти метки в конфигурации.  
Пример:

```console
sudo e2label /dev/sdb2 NC_backup
```

Диски можнно примонтировать к системе при помощи
[решения по автоматическому монтированию дисков](https://gist.github.com/microraptor/be170ea642abeb937fc030175ae89c0c)
от автора [microraptor](https://gist.github.com/microraptor)  
Следуйте настройке указаном в правиле, по монтированию при помощи меток.

### Настройки аддона

- **Токен доступа HA** - Долгосрочный токен доступа из Home Assistant.

> [!NOTE] Для работы аддона необходимо предварительно создать
> долгосрочный токен доступа в Home Assistant  
> Долгоживущие токены доступа можно создать с помощью
> «Долгоживущие токены доступа» раздел внизу страницы профиля
> Home Assistant пользователя.  
> Выберите <kbd>Профиль пользователя</kbd>, перейдите на вкладку
> <kbd>Безопасность</kbd>, внизу страницы нажмите кнопку <kbd>Создать токен</kbd>

### Файл конфигурации (settings.yaml)

После первого запуска аддон создаст файл конфигурации.
Отредактируйте его в соотвествии с вашими параметрами.
Обычно он расположен в папке `/addon_configs/b0df0280_nc_user_files_backup/settings.yaml`.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `general.` | | | Общая секция|
| `timezone` | str | | Часовой пояс (например., `Europe/Moscow`) |
| `rsync_options` | str | `-aHAX --delete` | Опции rsync Не изменяйте, если не знаете что это |
| `test_mode` | bool | `false` | Тестовый режим  |
| `storage.` | | | Секция управления путями диска|
| `mount_path` | str | `media` | Родительская директория для монтирования |
| `label_backup` | str | `NC_backup` | Метка диска для бэкапов |
| `label_data` | str | `Data` | Метка диска с данными |
| `data_dir` | str | `data` | Директория данных Nextcloud |
| `power.` | | | Секция управления питанием диска|
| `enable_power` | bool | `true` | Включить управление питанием диска |
| `disc_switch` | str | `usb_disk_power` | Сущность выключателя питания диска без указания домена switch |
| `notifications.` | | | Секция управления сообщениями|
| `enable_notifications` | bool | `true` | Включить отправку сообщений |
| `notification_service` | str | `notify.send_message` | Значение сервиса отправки |
| `success_message` | str | `Nextcloud user files backup completed successfully!` | Сообщение об успехе |
| `error_message` | str | `Nextcloud backup completed with errors!` | Сообщение об ошибке |

### Примерная конфигурация

```yaml
general:
  timezone: "Europe/Moscow"
  rsync_options: "-aHAX --delete" 
  test_mode: false
storage:
  mount_path: "media"
  label_backup: "NC_backup"
  label_data: "Data"
  data_dir: "data"
power:
  enable_power: false
  disc_switch: "usb_disk_power"
notifications:
  enable_notifications: true 
  notification_service: "telegram_cannel_system"
  success_message: "Nextcloud user files backup completed successfully!"
  error_message: "Nextcloud backup completed with errors!"
```

> [!TIP]
> Изменения конфигурации "поодхватятся на лету" при следующем запуске аддона

## Принцип работы

- Включение питания диска для бэкапов через указанный выключатель (если включено)**
- Монтирование диска для бэкапов в систему**
- Выполнение инкрементного резервного копирования с помощью rsync**
- Отмонтирование диска от системы**
- Отключение питания диска после завершения операции (если включено)**
- Отправка уведомления с результатами**

### Частые проблемы

- "Configuration validation failed" - Проверьте опечатки в `settings.yaml`  
- "Backup disk not mounted" - Проверьте метки дисков и правила udev  
- "Home Assistant API connection failed" - Проверьте корректность токена HA
