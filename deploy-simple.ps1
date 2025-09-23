# Простой скрипт развертывания Verus Backend
Write-Host "Запуск развертывания Verus Backend..." -ForegroundColor Green

# Проверка PHP
try {
    php --version | Out-Null
    Write-Host "PHP найден" -ForegroundColor Green
} catch {
    Write-Host "PHP не найден. Установите PHP 8.2+" -ForegroundColor Red
    exit 1
}

# Проверка Composer
try {
    composer --version | Out-Null
    Write-Host "Composer найден" -ForegroundColor Green
} catch {
    Write-Host "Composer не найден. Установите Composer" -ForegroundColor Red
    exit 1
}

# Установка зависимостей
Write-Host "Установка зависимостей..." -ForegroundColor Yellow
composer install

# Создание SQLite базы данных
Write-Host "Создание базы данных..." -ForegroundColor Yellow
if (-not (Test-Path "database\database.sqlite")) {
    New-Item -Path "database\database.sqlite" -ItemType File
}

# Настройка .env для SQLite
Write-Host "Настройка окружения..." -ForegroundColor Yellow
$envContent = @"
APP_NAME="Verus Warehouse API"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

LOG_CHANNEL=stack
LOG_LEVEL=debug

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8

# Генерация ключа
Write-Host "Генерация ключа приложения..." -ForegroundColor Yellow
php artisan key:generate

# Выполнение миграций
Write-Host "Выполнение миграций..." -ForegroundColor Yellow
php artisan migrate

# Запуск сервера
Write-Host "Запуск сервера на порту 8000..." -ForegroundColor Yellow
Write-Host "API будет доступен по адресу: http://localhost:8000/api" -ForegroundColor Cyan
Write-Host "Для остановки нажмите Ctrl+C" -ForegroundColor Yellow

php artisan serve --host=0.0.0.0 --port=8000
