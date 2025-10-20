# Changelog

## [0.2.0] - 2025-10-18
### Changes
- **Configuration refactoring**: All settings moved to `settings.yaml`
- **Universal notifications**: Support for any notification services (not just Telegram)
- **Config validation**: Structure and typo checking in settings
- **Improved UX**: Clear error messages with hints

### Technical Improvements
- Structured config sections: `general`, `storage`, `power`, `notifications`
- Boolean values and path validation
- Dynamic path detection for local and repository addons

## [0.1.0] - 2025-10-18
### Added
- Automatic backup of Nextcloud user files
- Support for external USB drives for backups
- Disk power management via smart switches
- Telegram notifications for backup results
- Home Assistant integration via long-lived token
- Supported architectures: amd64, aarch64, armv7

### Technical Features
- Rsync backup with incremental approach
- Automatic disk mounting/unmounting
- Permission and disk availability checks
- Backup process logging with timestamps
- Test mode for safe debugging

# История изменений

## [0.2.0] - 2025-10-18
### Изменения
- **Рефакторинг конфигурации**: Вынесены все настройки в `settings.yaml`
- **Универсальные уведомления**: Поддержка любых сервисов уведомлений (не только Telegram)
- **Валидация конфига**: Проверка структуры и опечаток в настройках
- **Улучшенный UX**: Понятные сообщения об ошибках с подсказками

### Технические улучшения
- Структурированные секции конфига: `general`, `storage`, `power`, `notifications`
- Валидация boolean значений и путей
- Динамическое определение путей для локальных и репозиторных аддонов

## [0.1.0] - 2025-10-18
### Добавлено
- Автоматическое резервное копирование файлов пользователей Nextcloud
- Поддержка внешних USB-дисков для бэкапов
- Управление питанием дисков через умные выключатели
- Уведомления в Telegram о результатах бэкапа
- Интеграция с Home Assistant через long-lived токен
- Поддержка архитектур: amd64, aarch64, armv7

### Технические особенности
- Резервное копирование через rsync с инкрементальным подходом
- Автоматическое монтирование/размонтирование дисков
- Проверка прав доступа и доступности дисков
- Логирование процесса бэкапа с временными метками
- Режим тестирования для безопасной отладки