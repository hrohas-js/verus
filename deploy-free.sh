#!/bin/bash

# Скрипт для быстрого развертывания на бесплатных хостингах
# Автор: AI Assistant

set -e

PLATFORM=""
REPO_URL=""

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -r|--repo)
            REPO_URL="$2"
            shift 2
            ;;
        -h|--help)
            echo "Использование: $0 [OPTIONS]"
            echo "Опции:"
            echo "  -p, --platform PLATFORM    Платформа (railway, render, heroku)"
            echo "  -r, --repo URL             URL GitHub репозитория"
            echo "  -h, --help                 Показать эту справку"
            echo ""
            echo "Примеры:"
            echo "  $0 -p railway -r https://github.com/user/repo.git"
            echo "  $0 -p render -r https://github.com/user/repo.git"
            exit 0
            ;;
        *)
            echo "Неизвестная опция: $1"
            exit 1
            ;;
    esac
done

# Проверка обязательных параметров
if [ -z "$PLATFORM" ] || [ -z "$REPO_URL" ]; then
    echo "❌ Необходимо указать платформу и URL репозитория"
    echo "Использование: $0 -p railway -r https://github.com/user/repo.git"
    exit 1
fi

echo "🚀 Подготовка к развертыванию на $PLATFORM..."

# Проверка Git
if ! command -v git &> /dev/null; then
    echo "❌ Git не найден. Установите Git"
    exit 1
fi

# Инициализация Git репозитория
if [ ! -d ".git" ]; then
    echo "Инициализация Git репозитория..."
    git init
    git add .
    git commit -m "Initial commit for deployment"
fi

# Добавление remote origin
echo "Настройка Git remote..."
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

# Создание .gitignore если не существует
if [ ! -f ".gitignore" ]; then
    echo "Создание .gitignore..."
    cat > .gitignore << EOF
/vendor/
/node_modules/
/public/hot
/public/storage
/storage/*.key
.env
.env.backup
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
/.fleet
/.idea
/.vscode
EOF
fi

# Подготовка файлов для развертывания
echo "Подготовка файлов для развертывания..."

# Создание .env.example если не существует
if [ ! -f ".env.example" ]; then
    echo "Создание .env.example..."
    cat > .env.example << EOF
APP_NAME="Verus Warehouse API"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=

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
EOF
fi

# Коммит изменений
echo "Коммит изменений..."
git add .
git commit -m "Prepare for deployment to $PLATFORM" || echo "Нет изменений для коммита"

# Push в репозиторий
echo "Загрузка в GitHub репозиторий..."
git push -u origin main

echo ""
echo "✅ Код загружен в GitHub репозиторий: $REPO_URL"
echo ""

# Инструкции для каждой платформы
case $PLATFORM in
    "railway")
        echo "🚂 Развертывание на Railway:"
        echo "1. Перейдите на https://railway.app"
        echo "2. Нажмите 'Deploy from GitHub repo'"
        echo "3. Выберите ваш репозиторий: $REPO_URL"
        echo "4. Railway автоматически определит PHP проект"
        echo "5. Добавьте переменные окружения в Dashboard:"
        echo "   - APP_ENV=production"
        echo "   - APP_DEBUG=false"
        echo "   - DB_CONNECTION=sqlite"
        echo "   - DB_DATABASE=database/database.sqlite"
        echo "6. Ваш API будет доступен по адресу: https://your-project.up.railway.app/api"
        ;;
    "render")
        echo "🎨 Развертывание на Render:"
        echo "1. Перейдите на https://render.com"
        echo "2. Нажмите 'New +' → 'Web Service'"
        echo "3. Подключите GitHub репозиторий: $REPO_URL"
        echo "4. Render автоматически использует render.yaml"
        echo "5. Ваш API будет доступен по адресу: https://your-service.onrender.com/api"
        ;;
    "heroku")
        echo "🟣 Развертывание на Heroku:"
        echo "1. Установите Heroku CLI: https://devcenter.heroku.com/articles/heroku-cli"
        echo "2. Выполните команды:"
        echo "   heroku login"
        echo "   heroku create your-app-name"
        echo "   heroku config:set APP_ENV=production"
        echo "   heroku config:set APP_DEBUG=false"
        echo "   heroku config:set DB_CONNECTION=sqlite"
        echo "   heroku config:set DB_DATABASE=database/database.sqlite"
        echo "   git push heroku main"
        echo "   heroku run php artisan migrate"
        echo "3. Ваш API будет доступен по адресу: https://your-app-name.herokuapp.com/api"
        ;;
    *)
        echo "❌ Неподдерживаемая платформа: $PLATFORM"
        echo "Поддерживаемые платформы: railway, render, heroku"
        exit 1
        ;;
esac

echo ""
echo "🎉 Подготовка завершена!"
echo "Следуйте инструкциям выше для завершения развертывания."
echo ""
echo "📚 Подробная документация: FREE_DEPLOYMENT.md"
