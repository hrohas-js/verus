# Verus Warehouse Management System

Полнофункциональная система управления складским учетом с веб-интерфейсом, построенная на Laravel 10 (Backend) и Vue 3 (Frontend).

## 🚀 Возможности

### Backend (Laravel API)
- ✅ Управление складскими позициями (CRUD операции)
- ✅ Система заказов с сохранением в БД
- ✅ Генерация Excel отчетов (остатки и заказы)
- ✅ Интеграция с Telegram Bot для уведомлений
- ✅ Health check endpoint
- ✅ Валидация данных
- ✅ CORS поддержка
- ✅ Docker контейнеризация

### Frontend (Vue 3 + Vuetify)
- ✅ Каталог товаров с остатками
- ✅ Формирование заказов
- ✅ Редактирование остатков (для администраторов)
- ✅ Скачивание Excel отчетов
- ✅ Адаптивный интерфейс
- ✅ Поддержка парных экипажей для незамерзайки

## 📋 Требования

### Backend
- PHP 8.1+
- Composer
- SQLite (для разработки) или MySQL (для продакшена)
- Extensions: `php-xml`, `php-zip` (для генерации Excel)

### Frontend
- Node.js 20.19+ или 22.12+
- npm или yarn

### Опционально
- Docker & Docker Compose

## 🛠 Установка и запуск

### 🚀 Быстрый старт

#### 1. Клонирование репозитория
```bash
git clone <repository-url>
cd verus
```

#### 2. Установка Backend зависимостей
```bash
composer install
```

#### 3. Установка Frontend зависимостей
```bash
npm install
```

#### 4. Настройка окружения
```bash
# Создайте .env файл (если его нет)
cp .env.example .env

# Сгенерируйте ключ приложения
php artisan key:generate
```

#### 5. Настройка базы данных

**Для SQLite (по умолчанию):**
```bash
# Создайте файл базы данных
touch database/database.sqlite

# Убедитесь, что в .env указано:
# DB_CONNECTION=sqlite
# DB_DATABASE=database/database.sqlite
```

**Для MySQL:**
```bash
# Обновите .env файл:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=verus_warehouse
# DB_USERNAME=your_username
# DB_PASSWORD=your_password
```

#### 6. Выполнение миграций
```bash
php artisan migrate
```

Это создаст следующие таблицы:
- `equipment` - складские позиции
- `orders` - заказы
- `order_items` - позиции заказов

#### 7. Запуск серверов

**Backend (Laravel):**
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

**Frontend (Vite):**
```bash
npm run dev
```

Приложение будет доступно по адресу: `http://localhost:5173`
API будет доступен по адресу: `http://localhost:8000/api`

### 🐳 Docker развертывание

#### 1. Сборка и запуск
```bash
docker compose up -d --build
```

#### 2. Генерация ключа приложения
```bash
docker compose exec app php artisan key:generate
```

#### 3. Выполнение миграций
```bash
docker compose exec app php artisan migrate
```

#### 4. Установка Frontend зависимостей (в контейнере или локально)
```bash
npm install
npm run build
```

#### 5. Просмотр логов
```bash
docker compose logs -f
```

## 📚 API Документация

### Базовый URL
```
http://localhost:8000/api
```

### Endpoints

#### Equipment (Складские позиции)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/equipment` | Получение всей комплектации |
| POST | `/equipment` | Добавление итема комплектации |
| GET | `/equipment/{id}` | Получение конкретного итема |
| PUT | `/equipment/{id}` | Обновление итема |
| PATCH | `/equipment/{id}/quantity` | Изменение остатков |
| DELETE | `/equipment/{id}` | Удаление итема |

#### Orders (Заказы)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/orders` | Получение всех заказов |
| POST | `/orders` | Создание нового заказа |
| GET | `/orders/{id}` | Получение конкретного заказа |
| PUT | `/orders/{id}` | Обновление заказа |
| DELETE | `/orders/{id}` | Удаление заказа |

#### Reports (Отчеты)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/reports/excel` | Генерация и скачивание Excel отчета |

#### System

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/health` | Health check |

### Примеры запросов

**Получение всей комплектации:**
```bash
curl -X GET http://localhost:8000/api/equipment
```

**Создание заказа:**
```bash
curl -X POST http://localhost:8000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "car_number": "А123БВ",
    "status": "completed",
    "is_pair_crew": false,
    "items": [
      {
        "equipment_id": 1,
        "quantity": 2
      }
    ]
  }'
```

**Скачивание Excel отчета:**
```bash
curl -X GET http://localhost:8000/api/reports/excel \
  --output report.xlsx
```

## 🗄 Структура базы данных

### Таблица `equipment`

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| title | varchar(255) | Название комплектации |
| quantity | int | Количество на складе |
| image | varchar(255) | Путь к изображению или emoji |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

### Таблица `orders`

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| car_number | varchar(255) | Номер автомобиля |
| order_date | datetime | Дата заказа |
| status | varchar(255) | Статус (pending, completed, cancelled) |
| notes | text | Дополнительные заметки |
| is_pair_crew | boolean | Парный экипаж (для незамерзайки) |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

### Таблица `order_items`

| Поле | Тип | Описание |
|------|-----|----------|
| id | bigint | Первичный ключ |
| order_id | bigint | ID заказа (FK) |
| equipment_id | bigint | ID товара (FK) |
| quantity | int | Количество |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

## 🔧 Конфигурация

### Переменные окружения (.env)

```env
APP_NAME="Verus Warehouse"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# База данных (SQLite)
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

# Или для MySQL:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=verus_warehouse
# DB_USERNAME=root
# DB_PASSWORD=

# Telegram Bot (опционально)
VITE_TELEGRAM_BOT_TOKEN=your_bot_token
VITE_TELEGRAM_CHAT_ID=your_chat_id

# API Base URL (для фронтенда)
VITE_API_BASE_URL=/api
```

## 📦 Зависимости

### Backend (composer.json)
- `laravel/framework: ^10.10` - Laravel Framework
- `maatwebsite/excel: ^3.1` - Генерация Excel отчетов
- `laravel/sanctum: ^3.3` - API аутентификация
- `guzzlehttp/guzzle: ^7.2` - HTTP клиент

### Frontend (package.json)
- `vue: ^3.5.18` - Vue.js Framework
- `vuetify: ^3.10.0` - Material Design компоненты
- `pinia: ^3.0.3` - State management
- `vue-router: ^4.5.1` - Роутинг
- `vite: ^7.0.6` - Build tool
- `typescript: ~5.8.0` - TypeScript поддержка

## 🧪 Тестирование

```bash
# Запуск тестов Backend
php artisan test

# Запуск тестов с покрытием
php artisan test --coverage

# Type checking Frontend
npm run type-check

# Linting Frontend
npm run lint
```

## 📁 Структура проекта

```
verus/
├── app/
│   ├── Exports/                    # Excel экспорты
│   │   ├── StockReportExport.php
│   │   ├── StockSheet.php
│   │   └── OrdersSheet.php
│   ├── Http/
│   │   ├── Controllers/Api/
│   │   │   ├── EquipmentController.php
│   │   │   ├── OrderController.php
│   │   │   └── ReportController.php
│   │   ├── Resources/
│   │   │   ├── EquipmentResource.php
│   │   │   ├── OrderResource.php
│   │   │   └── OrderItemResource.php
│   │   └── Middleware/
│   │       └── CorsMiddleware.php
│   └── Models/
│       ├── Equipment.php
│       ├── Order.php
│       └── OrderItem.php
├── database/
│   ├── migrations/
│   │   ├── 2025_09_12_192720_create_equipment_table.php
│   │   ├── 2026_01_17_213205_create_orders_table.php
│   │   ├── 2026_01_17_213206_create_order_items_table.php
│   │   └── 2026_01_17_213300_add_pair_crew_to_orders_table.php
│   └── database.sqlite
├── resources/
│   ├── js/
│   │   ├── components/
│   │   │   ├── StockCatalog.vue
│   │   │   ├── OrderSummary.vue
│   │   │   └── StockItemForm.vue
│   │   ├── stores/
│   │   │   ├── stock.ts
│   │   │   └── user.ts
│   │   ├── services/
│   │   │   └── api.ts
│   │   ├── router/
│   │   │   └── index.ts
│   │   └── plugins/
│   │       └── vuetify.ts
│   └── views/
│       └── app.blade.php
├── routes/
│   └── api.php
├── docker/
│   ├── nginx/
│   │   └── default.conf
│   └── php/
│       └── local.ini
├── Dockerfile
├── docker-compose.yml
├── composer.json
├── package.json
├── vite.config.js
└── README.md
```

## 🚀 Развертывание

### Production

#### 1. Обновите `.env` файл:
```env
APP_ENV=production
APP_DEBUG=false
DB_CONNECTION=mysql
# ... другие настройки
```

#### 2. Установите зависимости:
```bash
composer install --no-dev --optimize-autoloader
npm install
npm run build
```

#### 3. Запустите миграции:
```bash
php artisan migrate --force
```

#### 4. Оптимизируйте приложение:
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Docker Production

```bash
# Сборка production образа
docker build -t verus-warehouse .

# Запуск с production конфигурацией
docker run -d \
  --name verus-warehouse \
  -p 8000:80 \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  verus-warehouse
```

## 📊 Excel Отчеты

Система генерирует Excel отчеты с двумя листами:

1. **Остатки** - текущие остатки всех товаров на складе
2. **Заказы** - список всех завершенных заказов с деталями

Отчет можно скачать через веб-интерфейс (кнопка "ПОЛУЧИТЬ ОТЧЕТ") или через API.

## 🔐 Роли пользователей

- **Механик (mech)** - может просматривать каталог и формировать заказы
- **Склад (warehouse/admin)** - может редактировать остатки и просматривать все заказы

## 📝 Лицензия

Этот проект создан для управления складским учетом.

## 🤝 Поддержка

Для вопросов и предложений создавайте issues в репозитории.
