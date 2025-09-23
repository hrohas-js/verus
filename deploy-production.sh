#!/bin/bash

# Скрипт развертывания Verus Backend для продакшена
# Автор: AI Assistant
# Дата: $(date +%Y-%m-%d)

set -e

DOMAIN=""
USE_SSL=false
SKIP_SSL=false

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        --ssl)
            USE_SSL=true
            shift
            ;;
        --skip-ssl)
            SKIP_SSL=true
            shift
            ;;
        -h|--help)
            echo "Использование: $0 [OPTIONS]"
            echo "Опции:"
            echo "  -d, --domain DOMAIN    Домен для развертывания"
            echo "  --ssl                  Использовать SSL"
            echo "  --skip-ssl             Пропустить настройку SSL"
            echo "  -h, --help             Показать эту справку"
            exit 0
            ;;
        *)
            echo "Неизвестная опция: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Развертывание Verus Backend для продакшена..."

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден. Необходимо установить Docker"
    echo "Инструкции: https://docs.docker.com/engine/install/"
    exit 1
fi

echo "✅ Docker найден"

# Проверка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не найден. Необходимо установить Docker Compose"
    echo "Инструкции: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker Compose найден"

# Создание .env файла для продакшена
echo "Создание .env файла для продакшена..."
cat > .env << EOF
APP_NAME="Verus Warehouse API"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://$DOMAIN

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
MAIL_FROM_ADDRESS="noreply@$DOMAIN"
MAIL_FROM_NAME="\${APP_NAME}"

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

VITE_PUSHER_APP_KEY="\${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="\${PUSHER_HOST}"
VITE_PUSHER_PORT="\${PUSHER_PORT}"
VITE_PUSHER_SCHEME="\${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="\${PUSHER_APP_CLUSTER}"
EOF

# Настройка SSL (если требуется)
if [ "$USE_SSL" = true ] && [ "$SKIP_SSL" = false ]; then
    echo "Настройка SSL сертификатов..."

    # Создание директории для SSL
    mkdir -p ssl

    # Проверка наличия сертификатов
    if [ ! -f "ssl/cert.pem" ] || [ ! -f "ssl/key.pem" ]; then
        echo "⚠️  SSL сертификаты не найдены в папке ssl/"
        echo "Для получения SSL сертификатов используйте Let's Encrypt:"
        echo "1. Установите certbot: https://certbot.eff.org/"
        echo "2. Получите сертификат: certbot certonly --standalone -d $DOMAIN"
        echo "3. Скопируйте сертификаты в папку ssl/"
        echo "   - cert.pem -> ssl/cert.pem"
        echo "   - private.key -> ssl/key.pem"
        echo ""
        echo "Или запустите скрипт с параметром --skip-ssl для пропуска SSL"
        exit 1
    fi

    echo "✅ SSL сертификаты найдены"
fi

# Остановка существующих контейнеров
echo "Остановка существующих контейнеров..."
docker-compose down 2>/dev/null || true

# Сборка и запуск контейнеров
echo "Сборка и запуск контейнеров..."
docker-compose up -d --build

# Ожидание запуска контейнеров
echo "Ожидание запуска контейнеров..."
sleep 15

# Генерация ключа приложения
echo "Генерация ключа приложения..."
docker-compose exec -T app php artisan key:generate --force

# Выполнение миграций
echo "Выполнение миграций базы данных..."
docker-compose exec -T app php artisan migrate --force

# Оптимизация приложения
echo "Оптимизация приложения..."
docker-compose exec -T app php artisan config:cache
docker-compose exec -T app php artisan route:cache
docker-compose exec -T app php artisan view:cache

# Проверка работоспособности API
echo "Проверка работоспособности API..."
protocol="http"
if [ "$USE_SSL" = true ]; then
    protocol="https"
fi
base_url="$protocol://$DOMAIN"

if curl -f -s "$base_url/api/health" > /dev/null; then
    echo "✅ API успешно развернут и работает!"
else
    echo "❌ Не удалось подключиться к API"
    echo "Проверьте настройки файрвола и DNS"
fi

# Вывод информации о развертывании
echo ""
echo "🎉 Развертывание завершено!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 API Base URL: $base_url/api"
echo "🏥 Health Check: $base_url/api/health"
echo "📚 API Documentation: См. файл API_DOCUMENTATION.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Примеры тестовых запросов
echo ""
echo "🧪 Примеры тестовых запросов:"
echo "curl $base_url/api/health"
echo "curl $base_url/api/equipment"
echo "curl -X POST $base_url/api/equipment -H 'Content-Type: application/json' -d '{\"title\":\"Test Item\",\"quantity\":5,\"image\":\"test.jpg\"}'"

echo ""
echo "📝 Полезные команды:"
echo "docker-compose logs -f          # Просмотр логов"
echo "docker-compose restart          # Перезапуск сервисов"
echo "docker-compose down             # Остановка сервисов"
echo "docker-compose exec app php artisan migrate  # Выполнение миграций"

echo ""
echo "✨ Продакшен сервер готов к работе!"
