# Скрипт развертывания Verus Backend для продакшена
# Автор: AI Assistant
# Дата: $(Get-Date -Format "yyyy-MM-dd")

param(
    [string]$Domain = "",
    [switch]$UseSSL = $false,
    [switch]$SkipSSL = $false
)

Write-Host "🚀 Развертывание Verus Backend для продакшена..." -ForegroundColor Green

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
if (-not (Test-Command "docker")) {
    Write-Host "❌ Docker не найден. Необходимо установить Docker" -ForegroundColor Red
    Write-Host "Скачайте с https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Docker найден" -ForegroundColor Green

# Проверка Docker Compose
if (-not (Test-Command "docker-compose")) {
    Write-Host "❌ Docker Compose не найден. Необходимо установить Docker Compose" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker Compose найден" -ForegroundColor Green

# Создание .env файла для продакшена
Write-Host "Создание .env файла для продакшена..." -ForegroundColor Yellow
$envContent = @"
APP_NAME="Verus Warehouse API"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://$Domain

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="noreply@$Domain"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8

# Настройка SSL (если требуется)
if ($UseSSL -and -not $SkipSSL) {
    Write-Host "Настройка SSL сертификатов..." -ForegroundColor Yellow

    # Создание директории для SSL
    if (-not (Test-Path "ssl")) {
        New-Item -Path "ssl" -ItemType Directory -Force | Out-Null
    }

    # Проверка наличия сертификатов
    if (-not (Test-Path "ssl/cert.pem") -or -not (Test-Path "ssl/key.pem")) {
        Write-Host "⚠️  SSL сертификаты не найдены в папке ssl/" -ForegroundColor Yellow
        Write-Host "Для получения SSL сертификатов используйте Let's Encrypt:" -ForegroundColor Cyan
        Write-Host "1. Установите certbot: https://certbot.eff.org/" -ForegroundColor White
        Write-Host "2. Получите сертификат: certbot certonly --standalone -d $Domain" -ForegroundColor White
        Write-Host "3. Скопируйте сертификаты в папку ssl/" -ForegroundColor White
        Write-Host "   - cert.pem -> ssl/cert.pem" -ForegroundColor White
        Write-Host "   - private.key -> ssl/key.pem" -ForegroundColor White
        Write-Host ""
        Write-Host "Или запустите скрипт с параметром -SkipSSL для пропуска SSL" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "✅ SSL сертификаты найдены" -ForegroundColor Green
}

# Остановка существующих контейнеров
Write-Host "Остановка существующих контейнеров..." -ForegroundColor Yellow
docker-compose down 2>$null

# Сборка и запуск контейнеров
Write-Host "Сборка и запуск контейнеров..." -ForegroundColor Yellow
docker-compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка при запуске Docker контейнеров" -ForegroundColor Red
    exit 1
}

# Ожидание запуска контейнеров
Write-Host "Ожидание запуска контейнеров..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Генерация ключа приложения
Write-Host "Генерация ключа приложения..." -ForegroundColor Yellow
docker-compose exec -T app php artisan key:generate --force

# Выполнение миграций
Write-Host "Выполнение миграций базы данных..." -ForegroundColor Yellow
docker-compose exec -T app php artisan migrate --force

# Оптимизация приложения
Write-Host "Оптимизация приложения..." -ForegroundColor Yellow
docker-compose exec -T app php artisan config:cache
docker-compose exec -T app php artisan route:cache
docker-compose exec -T app php artisan view:cache

# Проверка работоспособности API
Write-Host "Проверка работоспособности API..." -ForegroundColor Yellow
$protocol = if ($UseSSL) { "https" } else { "http" }
$baseUrl = "$protocol://$Domain"

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API успешно развернут и работает!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  API отвечает, но статус код: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Не удалось подключиться к API: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Проверьте настройки файрвола и DNS" -ForegroundColor Yellow
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

Write-Host "`n📝 Полезные команды:" -ForegroundColor Blue
Write-Host "docker-compose logs -f          # Просмотр логов" -ForegroundColor White
Write-Host "docker-compose restart          # Перезапуск сервисов" -ForegroundColor White
Write-Host "docker-compose down             # Остановка сервисов" -ForegroundColor White
Write-Host "docker-compose exec app php artisan migrate  # Выполнение миграций" -ForegroundColor White

Write-Host "`n✨ Продакшен сервер готов к работе!" -ForegroundColor Green
