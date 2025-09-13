# Verus Warehouse API

Микросервис для управления складским учетом комплектации.

## Технологический стек

- **Backend**: Laravel 10
- **База данных**: MySQL/SQLite
- **Контейнеризация**: Docker + Docker Compose
- **Веб-сервер**: Nginx

## Структура данных

### Equipment (Комплектация)

| Поле | Тип | Описание |
|------|-----|----------|
| id | integer | Уникальный идентификатор |
| title | string | Название комплектации |
| quantity | integer | Количество на складе |
| image | string | Путь к изображению |
| created_at | timestamp | Дата создания |
| updated_at | timestamp | Дата обновления |

## API Endpoints

### Базовый URL
```
http://localhost:8000/api
```

### 1. Получение всей комплектации
```http
GET /api/equipment
```

**Ответ:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Компьютер Dell",
      "quantity": 10,
      "image": "images/dell-computer.jpg",
      "created_at": "2024-01-01T10:00:00.000000Z",
      "updated_at": "2024-01-01T10:00:00.000000Z"
    }
  ]
}
```

### 2. Добавление итема комплектации
```http
POST /api/equipment
Content-Type: application/json

{
  "title": "Монитор Samsung",
  "quantity": 5,
  "image": "images/samsung-monitor.jpg"
}
```

**Ответ:**
```json
{
  "success": true,
  "message": "Equipment created successfully",
  "data": {
    "id": 2,
    "title": "Монитор Samsung",
    "quantity": 5,
    "image": "images/samsung-monitor.jpg",
    "created_at": "2024-01-01T11:00:00.000000Z",
    "updated_at": "2024-01-01T11:00:00.000000Z"
  }
}
```

### 3. Изменение остатков комплектации
```http
PATCH /api/equipment/{id}/quantity
Content-Type: application/json

{
  "quantity": 15
}
```

**Ответ:**
```json
{
  "success": true,
  "message": "Equipment quantity updated successfully",
  "data": {
    "id": 1,
    "title": "Компьютер Dell",
    "quantity": 15,
    "image": "images/dell-computer.jpg",
    "created_at": "2024-01-01T10:00:00.000000Z",
    "updated_at": "2024-01-01T12:00:00.000000Z"
  }
}
```

### 4. Получение конкретного итема
```http
GET /api/equipment/{id}
```

### 5. Обновление итема
```http
PUT /api/equipment/{id}
Content-Type: application/json

{
  "title": "Обновленное название",
  "quantity": 20,
  "image": "images/new-image.jpg"
}
```

### 6. Удаление итема
```http
DELETE /api/equipment/{id}
```

### 7. Health Check
```http
GET /api/health
```

**Ответ:**
```json
{
  "status": "healthy",
  "service": "verus-warehouse-api",
  "timestamp": "2024-01-01T12:00:00.000000Z"
}
```

## Валидация

### Создание итема (POST /api/equipment)
- `title`: обязательное, строка, максимум 255 символов
- `quantity`: обязательное, целое число, минимум 0
- `image`: обязательное, строка, максимум 255 символов

### Обновление количества (PATCH /api/equipment/{id}/quantity)
- `quantity`: обязательное, целое число, минимум 0

### Обновление итема (PUT /api/equipment/{id})
- `title`: опциональное, строка, максимум 255 символов
- `quantity`: опциональное, целое число, минимум 0
- `image`: опциональное, строка, максимум 255 символов

## Коды ответов

- `200` - Успешный запрос
- `201` - Ресурс создан
- `404` - Ресурс не найден
- `422` - Ошибка валидации
- `500` - Внутренняя ошибка сервера

## Запуск микросервиса

### Локальная разработка
```bash
# Установка зависимостей
composer install

# Запуск миграций
php artisan migrate

# Запуск сервера
php artisan serve
```

### Docker
```bash
# Сборка и запуск контейнеров
docker-compose up -d

# Выполнение миграций в контейнере
docker-compose exec app php artisan migrate

# Просмотр логов
docker-compose logs -f
```

## Структура проекта

```
verus-backend/
├── app/
│   ├── Http/Controllers/Api/
│   │   └── EquipmentController.php
│   └── Models/
│       └── Equipment.php
├── database/
│   ├── migrations/
│   └── database.sqlite
├── routes/
│   └── api.php
├── docker/
│   ├── nginx/
│   └── php/
├── Dockerfile
├── docker-compose.yml
└── API_DOCUMENTATION.md
```
