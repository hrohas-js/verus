# Скрипт автоматического развертывания Verus Backend на Dev сервере
# Автор: AI Assistant
# Дата: $(Get-Date -Format "yyyy-MM-dd")

Write-Host "🚀 Начинаем развертывание Verus Backend на Dev сервере..." -ForegroundColor Green

# Функция для проверки установки команды
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Проверка Docker
if (Test-Command "docker") {
    Write-Host "✅ Docker найден" -ForegroundColor Green
    $useDocker = $true
} else {
    Write-Host "❌ Docker не найден. Будем использовать локальную установку" -ForegroundColor Yellow
    $useDocker = $false
}

# Проверка PHP
if (-not (Test-Command "php")) {
    Write-Host "❌ PHP не найден. Необходимо установить PHP 8.2+" -ForegroundColor Red
    Write-Host "Инструкции по установке см. в файле DEV_SETUP.md" -ForegroundColor Yellow
    exit 1
}

# Проверка Composer
if (-not (Test-Command "composer")) {
    Write-Host "❌ Composer не найден. Необходимо установить Composer" -ForegroundColor Red
    Write-Host "Инструкции по установке см. в файле DEV_SETUP.md" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ PHP и Composer найдены" -ForegroundColor Green

# Проверка .env файла
if (-not (Test-Path ".env")) {
    Write-Host "❌ Файл .env не найден. Создаем..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env" -ErrorAction SilentlyContinue
    if (-not (Test-Path ".env")) {
        Write-Host "❌ Не удалось создать .env файл" -ForegroundColor Red
        exit 1
    }
}

if ($useDocker) {
    Write-Host "🐳 Используем Docker для развертывания..." -ForegroundColor Blue

    # Остановка существующих контейнеров
    Write-Host "Остановка существующих контейнеров..." -ForegroundColor Yellow
    docker compose down 2>$null

    # Сборка и запуск контейнеров
    Write-Host "Сборка и запуск контейнеров..." -ForegroundColor Yellow
    docker compose up -d --build

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Ошибка при запуске Docker контейнеров" -ForegroundColor Red
        exit 1
    }

    # Ожидание запуска контейнеров
    Write-Host "Ожидание запуска контейнеров..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10

    # Генерация ключа приложения
    Write-Host "Генерация ключа приложения..." -ForegroundColor Yellow
    docker compose exec -T app php artisan key:generate --force

    # Выполнение миграций
    Write-Host "Выполнение миграций базы данных..." -ForegroundColor Yellow
    docker compose exec -T app php artisan migrate --force

    $baseUrl = "http://localhost:8000"

} else {
    Write-Host "💻 Используем локальную установку..." -ForegroundColor Blue

    # Установка зависимостей
    Write-Host "Установка зависимостей..." -ForegroundColor Yellow
    composer install --no-dev --optimize-autoloader

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Ошибка при установке зависимостей" -ForegroundColor Red
        exit 1
    }

    # Настройка SQLite базы данных
    Write-Host "Настройка базы данных..." -ForegroundColor Yellow
    if (-not (Test-Path "database/database.sqlite")) {
        New-Item -Path "database/database.sqlite" -ItemType File -Force | Out-Null
    }

    # Обновление .env для SQLite
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "DB_CONNECTION=mysql", "DB_CONNECTION=sqlite"
    $envContent = $envContent -replace "DB_HOST=mysql", "# DB_HOST=mysql"
    $envContent = $envContent -replace "DB_PORT=3306", "# DB_PORT=3306"
    $envContent = $envContent -replace "DB_DATABASE=verus_warehouse", "DB_DATABASE=database/database.sqlite"
    $envContent = $envContent -replace "DB_USERNAME=verus_user", "# DB_USERNAME=verus_user"
    $envContent = $envContent -replace "DB_PASSWORD=verus_password", "# DB_PASSWORD=verus_password"
    $envContent | Set-Content ".env"

    # Генерация ключа приложения
    Write-Host "Генерация ключа приложения..." -ForegroundColor Yellow
    php artisan key:generate --force

    # Выполнение миграций
    Write-Host "Выполнение миграций базы данных..." -ForegroundColor Yellow
    php artisan migrate --force

    # Очистка и кеширование конфигурации
    Write-Host "Оптимизация приложения..." -ForegroundColor Yellow
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache

    # Запуск сервера разработки в фоновом режиме
    Write-Host "Запуск сервера разработки..." -ForegroundColor Yellow
    Start-Process -FilePath "php" -ArgumentList "artisan", "serve", "--host=0.0.0.0", "--port=8000" -WindowStyle Hidden

    $baseUrl = "http://localhost:8000"

    # Ожидание запуска сервера
    Start-Sleep -Seconds 3
}

# Проверка работоспособности API
Write-Host "Проверка работоспособности API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API успешно развернут и работает!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  API отвечает, но статус код: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Не удалось подключиться к API: $($_.Exception.Message)" -ForegroundColor Red
}

# Вывод информации о развертывании
Write-Host "`n🎉 Развертывание завершено!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "📍 API Base URL: $baseUrl/api" -ForegroundColor Cyan
Write-Host "🏥 Health Check: $baseUrl/api/health" -ForegroundColor Cyan
Write-Host "📚 API Documentation: См. файл API_DOCUMENTATION.md" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# Примеры тестовых запросов
Write-Host "`n🧪 Примеры тестовых запросов:" -ForegroundColor Blue
Write-Host "curl $baseUrl/api/health" -ForegroundColor White
Write-Host "curl $baseUrl/api/equipment" -ForegroundColor White
Write-Host "curl -X POST $baseUrl/api/equipment -H 'Content-Type: application/json' -d '{\"title\":\"Test Item\",\"quantity\":5,\"image\":\"test.jpg\"}'" -ForegroundColor White

if (-not $useDocker) {
    Write-Host "`n⚠️  Сервер запущен в фоновом режиме." -ForegroundColor Yellow
    Write-Host "Для остановки используйте: Get-Process php | Stop-Process" -ForegroundColor Yellow
}

Write-Host "`n📝 Логи можно найти в:" -ForegroundColor Blue
if ($useDocker) {
    Write-Host "docker compose logs -f" -ForegroundColor White
} else {
    Write-Host "storage/logs/laravel.log" -ForegroundColor White
}

Write-Host "`n✨ Dev сервер готов к работе!" -ForegroundColor Green
