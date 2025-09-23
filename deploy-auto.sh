#!/bin/bash

# 🚀 Автоматическое развертывание Verus Backend
# Этот скрипт настраивает автоматическое развертывание из Git

set -e

echo "🚀 Настройка автоматического развертывания Verus Backend"
echo "=================================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода цветного текста
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка наличия Git
if ! command -v git &> /dev/null; then
    print_error "Git не установлен. Установите Git и попробуйте снова."
    exit 1
fi

# Проверка наличия репозитория
if [ ! -d ".git" ]; then
    print_error "Это не Git репозиторий. Инициализируйте Git и добавьте remote."
    exit 1
fi

print_status "Проверка конфигурационных файлов..."

# Проверка наличия конфигурационных файлов
config_files=("render.yaml" "railway.json" "Procfile" ".github/workflows/deploy.yml")
missing_files=()

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file найден"
    else
        missing_files+=("$file")
        print_warning "⚠ $file не найден"
    fi
done

echo ""
print_status "Доступные платформы для развертывания:"
echo ""

# Render.com
if [ -f "render.yaml" ]; then
    echo "1. 🌐 Render.com (Рекомендуется)"
    echo "   - Бесплатный план"
    echo "   - Автоматическое развертывание"
    echo "   - SSL включен"
    echo "   - Настройка: https://render.com"
    echo ""
fi

# Railway.app
if [ -f "railway.json" ]; then
    echo "2. 🚂 Railway.app"
    echo "   - Простая настройка"
    echo "   - Автоматическое развертывание"
    echo "   - Настройка: https://railway.app"
    echo ""
fi

# Heroku
if [ -f "Procfile" ]; then
    echo "3. 🟣 Heroku"
    echo "   - Классическая платформа"
    echo "   - Настройка: https://heroku.com"
    echo ""
fi

# GitHub Actions
if [ -f ".github/workflows/deploy.yml" ]; then
    echo "4. ⚙️ GitHub Actions + собственный сервер"
    echo "   - Полный контроль"
    echo "   - Требует настройки SSH ключей"
    echo ""
fi

echo "=================================================="
print_status "Инструкции по настройке:"
echo ""

if [ -f "render.yaml" ]; then
    echo "🌐 Render.com:"
    echo "1. Перейдите на https://render.com"
    echo "2. Войдите через GitHub"
    echo "3. Нажмите 'New +' → 'Web Service'"
    echo "4. Подключите ваш репозиторий"
    echo "5. Render автоматически обнаружит render.yaml"
    echo ""
fi

if [ -f "railway.json" ]; then
    echo "🚂 Railway.app:"
    echo "1. Перейдите на https://railway.app"
    echo "2. Войдите через GitHub"
    echo "3. Нажмите 'New Project' → 'Deploy from GitHub repo'"
    echo "4. Выберите ваш репозиторий"
    echo ""
fi

if [ -f ".github/workflows/deploy.yml" ]; then
    echo "⚙️ GitHub Actions:"
    echo "1. Перейдите в Settings → Secrets and variables → Actions"
    echo "2. Добавьте секреты:"
    echo "   - HOST: IP адрес вашего сервера"
    echo "   - USERNAME: имя пользователя на сервере"
    echo "   - SSH_KEY: приватный SSH ключ"
    echo "3. Обновите путь в .github/workflows/deploy.yml"
    echo ""
fi

print_success "Настройка завершена!"
print_status "После настройки платформы, каждое изменение в main ветке будет автоматически развертываться."

echo ""
print_warning "Не забудьте:"
echo "- Настроить переменные окружения на выбранной платформе"
echo "- Добавить домен (если нужно)"
echo "- Настроить SSL сертификаты"
echo "- Протестировать развертывание"
