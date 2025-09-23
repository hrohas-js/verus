# Verus Warehouse API

Микросервис для управления складским учетом комплектации, построенный на Laravel 10.

## 🚀 Возможности

- ✅ Получение всей комплектации
- ✅ Добавление нового итема комплектации  
- ✅ Изменение остатков комплектации
- ✅ Обновление информации об итеме
- ✅ Удаление итема
- ✅ Health check endpoint
- ✅ Валидация данных
- ✅ CORS поддержка
- ✅ Docker контейнеризация

## 📋 Требования

- PHP 8.2+
- Composer
- SQLite (для разработки) или MySQL (для продакшена)
- Docker & Docker Compose (опционально)

## 🛠 Установка и запуск

### 🚀 Автоматическое развертывание

**Windows (PowerShell):**
```powershell
.\deploy-simple.ps1
```

**Linux/macOS (Bash):**
```bash
chmod +x deploy-dev.sh
./deploy-dev.sh
```

### 📋 Требования для автоматического развертывания

- **PHP 8.2+** - [Скачать](https://windows.php.net/download/) или установить через [Chocolatey](https://chocolatey.org/): `choco install php`
- **Composer** - [Скачать](https://getcomposer.org/download/) или установить через Chocolatey: `choco install composer`
- **Docker Desktop** (опционально) - [Скачать](https://www.docker.com/products/docker-desktop/)

### 🔧 Ручная установка

#### Локальная разработка

1. **Клонирование и установка зависимостей:**
```bash
git clone <repository-url>
cd verus-backend
composer install
```

2. **Настройка окружения:**
```bash
# Создайте .env файл (уже создан)
php artisan key:generate
```

3. **Настройка базы данных:**
```bash
# Для SQLite (по умолчанию)
touch database/database.sqlite

# Или для MySQL - обновите .env файл:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=verus_warehouse
# DB_USERNAME=your_username
# DB_PASSWORD=your_password
```

4. **Запуск миграций:**
```bash
php artisan migrate
```

5. **Запуск сервера:**
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

API будет доступен по адресу: `http://localhost:8000/api`

#### Docker

1. **Сборка и запуск:**
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

4. **Просмотр логов:**
```bash
docker compose logs -f
```

API будет доступен по адресу: `http://localhost:8000/api`

## 📚 API Документация

### Базовый URL
```
http://localhost:8000/api
```

### Endpoints

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/equipment` | Получение всей комплектации |
| POST | `/equipment` | Добавление итема комплектации |
| GET | `/equipment/{id}` | Получение конкретного итема |
| PUT | `/equipment/{id}` | Обновление итема |
| PATCH | `/equipment/{id}/quantity` | Изменение остатков |
| DELETE | `/equipment/{id}` | Удаление итема |
| GET | `/health` | Health check |

### Примеры запросов

**Получение всей комплектации:**
```bash
curl -X GET http://localhost:8000/api/equipment
```

**Добавление итема:**
```bash
curl -X POST http://localhost:8000/api/equipment \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Монитор Samsung",
    "quantity": 5,
    "image": "images/samsung-monitor.jpg"
  }'
```

**Изменение остатков:**
```bash
curl -X PATCH http://localhost:8000/api/equipment/1/quantity \
  -H "Content-Type: application/json" \
  -d '{"quantity": 15}'
```

## 🗄 Структура базы данных

### Таблица `equipment`

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| title | varchar(255) | Название комплектации |
| quantity | int | Количество на складе |
| image | varchar(255) | Путь к изображению |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

## 🔧 Конфигурация

### Переменные окружения (.env)

```env
APP_NAME="Verus Warehouse API"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=sqlite
DB_DATABASE=/path/to/database.sqlite

# Или для MySQL:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=verus_warehouse
# DB_USERNAME=root
# DB_PASSWORD=
```

## 🧪 Тестирование

```bash
# Запуск тестов
php artisan test

# Или с покрытием
php artisan test --coverage
```

## 📁 Структура проекта

```
verus-backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/Api/
│   │   │   └── EquipmentController.php
│   │   ├── Middleware/
│   │   │   └── CorsMiddleware.php
│   │   └── Resources/
│   │       └── EquipmentResource.php
│   └── Models/
│       └── Equipment.php
├── database/
│   ├── migrations/
│   │   └── 2025_09_12_192720_create_equipment_table.php
│   └── database.sqlite
├── routes/
│   └── api.php
├── docker/
│   ├── nginx/
│   │   └── default.conf
│   └── php/
│       └── local.ini
├── Dockerfile
├── docker-compose.yml
├── API_DOCUMENTATION.md
└── README.md
```

## 🚀 Развертывание

### Production

1. Обновите `.env` файл для продакшена:
```env
APP_ENV=production
APP_DEBUG=false
DB_CONNECTION=mysql
# ... другие настройки
```

2. Запустите миграции:
```bash
php artisan migrate --force
```

3. Оптимизируйте приложение:
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Docker Production

```bash
# Сборка production образа
docker build -t verus-warehouse-api .

# Запуск с production конфигурацией
docker run -d \
  --name verus-warehouse \
  -p 8000:80 \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  verus-warehouse-api
```

## 📝 Лицензия

Этот проект создан для демонстрации микросервисной архитектуры.

## 🤝 Поддержка

Для вопросов и предложений создавайте issues в репозитории.
