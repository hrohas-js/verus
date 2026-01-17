# Инструкция по развертыванию на Render.com

## Быстрое развертывание (5 минут)

### Шаг 1: Регистрация на Render
1. Перейдите на https://render.com
2. Нажмите "Get Started for Free"
3. Войдите через GitHub (рекомендуется) или создайте аккаунт

### Шаг 2: Создание нового Web Service
1. В Dashboard нажмите "New +" → "Web Service"
2. Выберите репозиторий: `hrohas-js/verus`
3. Настройки:
   - **Name**: `verus-warehouse-api` (или любое другое имя)
   - **Region**: выберите ближайший регион
   - **Branch**: `main`
   - **Root Directory**: оставьте пустым
   - **Runtime**: `PHP`
   - **Build Command**: оставьте пустым (используется render.yaml)
   - **Start Command**: оставьте пустым (используется render.yaml)
   - **Plan**: `Free`

### Шаг 3: Переменные окружения
Render автоматически использует настройки из `render.yaml`, но вы можете добавить дополнительные:
- `APP_URL`: будет установлен автоматически после развертывания
- `VITE_API_BASE_URL`: `/api` (уже в render.yaml)

### Шаг 4: Развертывание
1. Нажмите "Create Web Service"
2. Дождитесь завершения сборки (5-10 минут)
3. После успешного развертывания вы получите URL вида: `https://verus-warehouse-api.onrender.com`

### Шаг 5: Проверка
- Откройте полученный URL в браузере
- Проверьте API: `https://your-app.onrender.com/api/health`
- Проверьте каталог: `https://your-app.onrender.com/api/equipment`

## Важные замечания

⚠️ **Бесплатный план Render:**
- Приложение "засыпает" после 15 минут бездействия
- Первый запрос после простоя может занять 30-60 секунд
- Это нормально для бесплатного плана

✅ **Проект уже настроен:**
- `render.yaml` содержит все необходимые настройки
- Фронтенд будет собран автоматически
- База данных SQLite будет создана автоматически
- Миграции выполнятся автоматически

## Альтернативные варианты

### Railway.app
1. Перейдите на https://railway.app
2. Войдите через GitHub
3. Нажмите "New Project" → "Deploy from GitHub repo"
4. Выберите репозиторий `hrohas-js/verus`
5. Railway автоматически определит настройки из `railway.json`

### Fly.io
1. Установите Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Войдите: `flyctl auth login`
3. Установите пакет: `composer require fly-apps/fly-laravel`
4. Запустите: `vendor/bin/fly-laravel launch`
5. Разверните: `vendor/bin/fly-laravel deploy`

## Поддержка

Если возникнут проблемы:
1. Проверьте логи развертывания в Dashboard Render
2. Убедитесь, что репозиторий публичный или подключен к Render
3. Проверьте, что все файлы закоммичены и запушены в GitHub
