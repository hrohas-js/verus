#!/bin/bash

# Скрипт автоматического развертывания Verus Backend на Dev сервере
# Автор: AI Assistant
# Дата: $(date +%Y-%m-%d)

echo "🚀 Начинаем развертывание Verus Backend на Dev сервере..."

# Функция для проверки установки команды
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Проверка Docker
if command_exists docker && command_exists docker-compose; then
    echo "✅ Docker и docker-compose найдены"
    USE_DOCKER=true
elif command_exists docker; then
    if docker compose version >/dev/null 2>&1; then
        echo "✅ Docker с встроенным compose найден"
        USE_DOCKER=true
        DOCKER_COMPOSE_CMD="docker compose"
    else
        echo "❌ Docker найден, но docker-compose отсутствует"
        USE_DOCKER=false
    fi
else
    echo "❌ Docker не найден. Будем использовать локальную установку"
    USE_DOCKER=false
fi

# Установка команды docker-compose по умолчанию
if [ "$USE_DOCKER" = true ] && [ -z "$DOCKER_COMPOSE_CMD" ]; then
    DOCKER_COMPOSE_CMD="docker-compose"
fi

# Проверка PHP
if ! command_exists php; then
    echo "❌ PHP не найден. Необходимо установить PHP 8.2+"
    echo "Инструкции по установке см. в файле DEV_SETUP.md"
    exit 1
fi

# Проверка Composer
if ! command_exists composer; then
    echo "❌ Composer не найден. Необходимо установить Composer"
    echo "Инструкции по установке см. в файле DEV_SETUP.md"
    exit 1
fi

echo "✅ PHP и Composer найдены"

# Проверка .env файла
if [ ! -f ".env" ]; then
    echo "❌ Файл .env не найден. Создаем..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
    else
        echo "❌ Файл .env.example также не найден"
        exit 1
    fi
fi

if [ "$USE_DOCKER" = true ]; then
    echo "🐳 Используем Docker для развертывания..."

    # Остановка существующих контейнеров
    echo "Остановка существующих контейнеров..."
    $DOCKER_COMPOSE_CMD down 2>/dev/null || true

    # Сборка и запуск контейнеров
    echo "Сборка и запуск контейнеров..."
    $DOCKER_COMPOSE_CMD up -d --build

    if [ $? -ne 0 ]; then
        echo "❌ Ошибка при запуске Docker контейнеров"
        exit 1
    fi

    # Ожидание запуска контейнеров
    echo "Ожидание запуска контейнеров..."
    sleep 10

    # Генерация ключа приложения
    echo "Генерация ключа приложения..."
    $DOCKER_COMPOSE_CMD exec -T app php artisan key:generate --force

    # Выполнение миграций
    echo "Выполнение миграций базы данных..."
    $DOCKER_COMPOSE_CMD exec -T app php artisan migrate --force

    BASE_URL="http://localhost:8000"

else
    echo "💻 Используем локальную установку..."

    # Установка зависимостей
    echo "Установка зависимостей..."
    composer install --no-dev --optimize-autoloader

    if [ $? -ne 0 ]; then
        echo "❌ Ошибка при установке зависимостей"
        exit 1
    fi

    # Настройка SQLite базы данных
    echo "Настройка базы данных..."
    if [ ! -f "database/database.sqlite" ]; then
        touch database/database.sqlite
    fi

    # Обновление .env для SQLite
    sed -i.bak 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/' .env
    sed -i.bak 's/DB_HOST=mysql/# DB_HOST=mysql/' .env
    sed -i.bak 's/DB_PORT=3306/# DB_PORT=3306/' .env
    sed -i.bak 's/DB_DATABASE=verus_warehouse/DB_DATABASE=database\/database.sqlite/' .env
    sed -i.bak 's/DB_USERNAME=verus_user/# DB_USERNAME=verus_user/' .env
    sed -i.bak 's/DB_PASSWORD=verus_password/# DB_PASSWORD=verus_password/' .env

    # Генерация ключа приложения
    echo "Генерация ключа приложения..."
    php artisan key:generate --force

    # Выполнение миграций
    echo "Выполнение миграций базы данных..."
    php artisan migrate --force

    # Очистка и кеширование конфигурации
    echo "Оптимизация приложения..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache

    # Запуск сервера разработки в фоновом режиме
    echo "Запуск сервера разработки..."
    nohup php artisan serve --host=0.0.0.0 --port=8000 > /dev/null 2>&1 &
    SERVER_PID=$!
    echo $SERVER_PID > .server.pid

    BASE_URL="http://localhost:8000"

    # Ожидание запуска сервера
    sleep 3
fi

# Проверка работоспособности API
echo "Проверка работоспособности API..."
if command_exists curl; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/health" || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ API успешно развернут и работает!"
    elif [ "$HTTP_CODE" != "000" ]; then
        echo "⚠️  API отвечает, но статус код: $HTTP_CODE"
    else
        echo "❌ Не удалось подключиться к API"
    fi
else
    echo "⚠️  curl не найден, пропускаем проверку API"
fi

# Вывод информации о развертывании
echo ""
echo "🎉 Развертывание завершено!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 API Base URL: $BASE_URL/api"
echo "🏥 Health Check: $BASE_URL/api/health"
echo "📚 API Documentation: См. файл API_DOCUMENTATION.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Примеры тестовых запросов
echo ""
echo "🧪 Примеры тестовых запросов:"
echo "curl $BASE_URL/api/health"
echo "curl $BASE_URL/api/equipment"
echo "curl -X POST $BASE_URL/api/equipment -H \"Content-Type: application/json\" -d '{\"title\":\"Test Item\",\"quantity\":5,\"image\":\"test.jpg\"}'"

if [ "$USE_DOCKER" != true ]; then
    echo ""
    echo "⚠️  Сервер запущен в фоновом режиме (PID: $SERVER_PID)."
    echo "Для остановки используйте: kill \$(cat .server.pid) && rm .server.pid"
fi

echo ""
echo "📝 Логи можно найти в:"
if [ "$USE_DOCKER" = true ]; then
    echo "$DOCKER_COMPOSE_CMD logs -f"
else
    echo "storage/logs/laravel.log"
fi

echo ""
echo "✨ Dev сервер готов к работе!"
