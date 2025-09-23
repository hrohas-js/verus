# Инструкция по развертыванию Verus Backend на Dev сервере

## 🛠 Установка необходимых инструментов

### 1. Установка PHP 8.2+

**Вариант A: Использование Chocolatey (рекомендуется)**
```powershell
# Установка Chocolatey (если не установлен)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Установка PHP
choco install php

# Включение необходимых расширений
# Отредактируйте php.ini и раскомментируйте:
# extension=pdo_mysql
# extension=pdo_sqlite
# extension=mbstring
# extension=openssl
# extension=curl
```

**Вариант B: Ручная установка**
1. Скачайте PHP 8.2+ с https://windows.php.net/download/
2. Распакуйте в папку (например, C:\php)
3. Добавьте путь к PHP в переменную PATH
4. Скопируйте php.ini-development в php.ini
5. Включите необходимые расширения

### 2. Установка Composer
```powershell
# Скачайте Composer с https://getcomposer.org/download/
# Или используйте Chocolatey:
choco install composer
```

### 3. Установка Docker Desktop (опционально, но рекомендуется)
```powershell
# Скачайте Docker Desktop с https://www.docker.com/products/docker-desktop/
# Или используйте Chocolatey:
choco install docker-desktop
```

## 🚀 Развертывание приложения

### Вариант 1: С Docker (рекомендуется)

1. **Запуск контейнеров:**
```bash
docker compose up -d --build
```

2. **Генерация ключа приложения:**
```bash
docker compose exec app php artisan key:generate
```

3. **Выполнение миграций:**
```bash
docker compose exec app php artisan migrate
```

4. **Проверка работы:**
```bash
curl http://localhost:8000/api/health
```

### Вариант 2: Локальная разработка

1. **Установка зависимостей:**
```bash
composer install
```

2. **Настройка базы данных (SQLite):**
```bash
# Обновите .env файл:
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

# Создайте файл базы данных:
touch database/database.sqlite
```

3. **Генерация ключа:**
```bash
php artisan key:generate
```

4. **Выполнение миграций:**
```bash
php artisan migrate
```

5. **Запуск сервера:**
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

## 🔧 Настройка .env файла

Файл `.env` уже создан с базовыми настройками:

```env
APP_NAME="Verus Warehouse API"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Для Docker (MySQL)
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=verus_warehouse
DB_USERNAME=verus_user
DB_PASSWORD=verus_password

# Для локальной разработки (SQLite)
# DB_CONNECTION=sqlite
# DB_DATABASE=database/database.sqlite
```

## 🧪 Тестирование API

После успешного развертывания, API будет доступен по адресу:
- **Docker:** http://localhost:8000/api
- **Локально:** http://localhost:8000/api

### Тестовые запросы:

**Health Check:**
```bash
curl http://localhost:8000/api/health
```

**Получение всего оборудования:**
```bash
curl http://localhost:8000/api/equipment
```

**Добавление нового оборудования:**
```bash
curl -X POST http://localhost:8000/api/equipment \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Тестовый монитор",
    "quantity": 10,
    "image": "test-monitor.jpg"
  }'
```

## 🐛 Устранение неполадок

### Проблемы с правами доступа
```bash
# Для Windows (в PowerShell как администратор):
icacls "storage" /grant Everyone:(OI)(CI)F /T
icacls "bootstrap/cache" /grant Everyone:(OI)(CI)F /T
```

### Проблемы с базой данных
```bash
# Пересоздание базы данных:
php artisan migrate:fresh

# Или для Docker:
docker compose exec app php artisan migrate:fresh
```

### Очистка кеша
```bash
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Или для Docker:
docker compose exec app php artisan config:clear
docker compose exec app php artisan route:clear
docker compose exec app php artisan view:clear
docker compose exec app php artisan cache:clear
```

## 📝 Логи

### Просмотр логов приложения:
```bash
# Локально:
tail -f storage/logs/laravel.log

# Docker:
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f mysql
```

## 🔄 Обновление приложения

```bash
# Получение последних изменений:
git pull origin main

# Обновление зависимостей:
composer install --no-dev --optimize-autoloader

# Выполнение миграций:
php artisan migrate

# Очистка кеша:
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 🌐 Доступ к приложению

После успешного развертывания:
- **Frontend URL:** http://localhost:8000
- **API Base URL:** http://localhost:8000/api
- **Health Check:** http://localhost:8000/api/health

## 📊 Мониторинг

### Проверка статуса контейнеров:
```bash
docker compose ps
```

### Проверка использования ресурсов:
```bash
docker compose top
```

### Проверка логов в реальном времени:
```bash
docker compose logs -f
```
