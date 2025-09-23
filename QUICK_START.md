# 🚀 Быстрый старт Verus Backend

## Текущий статус

✅ Проект настроен и готов к развертыванию  
✅ .env файл создан  
✅ Docker конфигурация готова  
✅ Скрипты развертывания созданы  

## Что нужно установить

Для запуска проекта на dev сервере необходимо установить:

### 1. PHP 8.2+ 
```powershell
# Через Chocolatey (рекомендуется)
choco i

# Или скачать с https://windows.php.net/download/
```

### 2. Composer
```powershell
# Через Chocolatey
choco install composer

# Или скачать с https://getcomposer.org/download/
```

### 3. Docker Desktop (опционально)
```powershell
# Через Chocolatey
choco install docker-desktop

# Или скачать с https://www.docker.com/products/docker-desktop/
```

## Варианты запуска

### Вариант 1: Автоматический (рекомендуется)

После установки PHP и Composer:

```powershell
.\deploy-simple.ps1
```

Этот скрипт:
- Проверит наличие PHP и Composer
- Установит зависимости Laravel
- Настроит SQLite базу данных
- Выполнит миграции
- Запустит dev сервер на порту 8000

### Вариант 2: Docker (если установлен Docker)

```bash
docker compose up -d --build
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate
```

### Вариант 3: Ручной запуск

```bash
composer install
php artisan key:generate
touch database/database.sqlite
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

## После запуска

API будет доступен по адресу: **http://localhost:8000/api**

### Проверка работы:
```bash
curl http://localhost:8000/api/health
```

### Тестовые запросы:
```bash
# Получить все оборудование
curl http://localhost:8000/api/equipment

# Добавить новое оборудование
curl -X POST http://localhost:8000/api/equipment \
  -H "Content-Type: application/json" \
  -d '{"title":"Монитор Samsung","quantity":5,"image":"monitor.jpg"}'
```

## Устранение проблем

### PHP не найден
- Установите PHP 8.2+ через Chocolatey: `choco install php`
- Или скачайте с https://windows.php.net/download/
- Добавьте PHP в PATH

### Composer не найден
- Установите через Chocolatey: `choco install composer`
- Или скачайте с https://getcomposer.org/download/

### Ошибки прав доступа
```powershell
# В PowerShell как администратор:
icacls "storage" /grant Everyone:(OI)(CI)F /T
icacls "bootstrap/cache" /grant Everyone:(OI)(CI)F /T
```

### Проблемы с базой данных
```bash
# Пересоздать базу данных:
php artisan migrate:fresh
```

## Полезные команды

```bash
# Просмотр логов
tail -f storage/logs/laravel.log

# Очистка кеша
php artisan config:clear
php artisan route:clear
php artisan cache:clear

# Остановка сервера (если запущен в фоне)
Get-Process php | Stop-Process
```

## Файлы проекта

- `deploy-simple.ps1` - Простой скрипт развертывания для Windows
- `deploy-dev.sh` - Полный скрипт развертывания для Linux/macOS
- `DEV_SETUP.md` - Подробная инструкция по настройке
- `docker-compose.yml` - Docker конфигурация
- `.env` - Файл настроек окружения (уже создан)

## Готово! 🎉

Теперь у вас есть рабочий dev сервер Verus Backend API.

Для получения полной документации API смотрите файл `API_DOCUMENTATION.md`.
