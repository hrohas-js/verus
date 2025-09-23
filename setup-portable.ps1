# Портативная настройка Verus Backend без установки PHP
Write-Host "🚀 Настройка портативного окружения для Verus Backend..." -ForegroundColor Green

# Создание структуры папок
Write-Host "Создание структуры папок..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "portable-env" | Out-Null
New-Item -ItemType Directory -Force -Path "portable-env\php" | Out-Null
New-Item -ItemType Directory -Force -Path "portable-env\data" | Out-Null

# Создание SQLite базы данных
Write-Host "Создание SQLite базы данных..." -ForegroundColor Yellow
if (-not (Test-Path "database\database.sqlite")) {
    New-Item -Path "database\database.sqlite" -ItemType File -Force | Out-Null
}

# Создание .env файла для SQLite
Write-Host "Настройка окружения..." -ForegroundColor Yellow
$envContent = @"
APP_NAME="Verus Warehouse API"
APP_ENV=local
APP_KEY=base64:$(([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((1..32 | ForEach {[char](Get-Random -Minimum 65 -Maximum 91)}) -join ''))))
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

SANCTUM_STATEFUL_DOMAINS=localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8 -Force

# Создание простого SQL файла для инициализации базы данных
Write-Host "Создание схемы базы данных..." -ForegroundColor Yellow
$sqlSchema = @"
-- Создание таблицы equipment
CREATE TABLE IF NOT EXISTS equipment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание триггера для обновления updated_at
CREATE TRIGGER IF NOT EXISTS update_equipment_updated_at
    AFTER UPDATE ON equipment
    FOR EACH ROW
    BEGIN
        UPDATE equipment SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

-- Вставка тестовых данных
INSERT OR IGNORE INTO equipment (id, title, quantity, image) VALUES
(1, 'Монитор Samsung 24"', 15, 'samsung-monitor.jpg'),
(2, 'Клавиатура Logitech', 8, 'logitech-keyboard.jpg'),
(3, 'Мышь Razer', 12, 'razer-mouse.jpg'),
(4, 'Веб-камера HD', 5, 'webcam.jpg');
"@

$sqlSchema | Out-File -FilePath "portable-env\schema.sql" -Encoding UTF8

# Создание пакетного файла для запуска без PHP
Write-Host "Создание скрипта запуска..." -ForegroundColor Yellow
$batchScript = @"
@echo off
echo 🚀 Запуск Verus Backend API...
echo.
echo Проект настроен для работы с SQLite базой данных
echo База данных создана: database\database.sqlite
echo.
echo ✅ Конфигурация готова!
echo.
echo 📋 Для полного запуска необходимо:
echo 1. Установить PHP 8.2+ с https://windows.php.net/download/
echo 2. Добавить PHP в PATH
echo 3. Запустить: php artisan serve --host=0.0.0.0 --port=8000
echo.
echo 📍 API будет доступен по адресу: http://localhost:8000/api
echo 🏥 Health Check: http://localhost:8000/api/health
echo.
echo 🔧 Альтернативно можно использовать XAMPP или другой локальный сервер
echo.
pause
"@

$batchScript | Out-File -FilePath "start-server.bat" -Encoding ASCII

# Создание HTML файла с инструкциями
Write-Host "Создание веб-интерфейса с инструкциями..." -ForegroundColor Yellow
$htmlContent = @"
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verus Backend - Dev Setup</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 20px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .status { padding: 15px; border-radius: 5px; margin: 10px 0; }
        .success { background: #d4edda; border-left: 4px solid #28a745; color: #155724; }
        .warning { background: #fff3cd; border-left: 4px solid #ffc107; color: #856404; }
        .info { background: #d1ecf1; border-left: 4px solid #17a2b8; color: #0c5460; }
        code { background: #f8f9fa; padding: 2px 4px; border-radius: 3px; font-family: 'Courier New', monospace; }
        pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .btn { display: inline-block; padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 5px; margin: 5px; }
        .btn:hover { background: #2980b9; }
        .step { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Verus Backend API - Dev Setup</h1>

        <div class="status success">
            ✅ Проект настроен и готов к развертыванию!
        </div>

        <div class="status info">
            📁 Файл .env создан<br>
            🗄️ SQLite база данных готова<br>
            📋 Схема базы данных подготовлена
        </div>

        <h2>🛠 Следующие шаги</h2>

        <div class="step">
            <h3>1. Установка PHP</h3>
            <p>Скачайте PHP 8.2+ с официального сайта:</p>
            <a href="https://windows.php.net/download/" target="_blank" class="btn">Скачать PHP</a>
            <p>Или используйте XAMPP для простой установки:</p>
            <a href="https://www.apachefriends.org/download.html" target="_blank" class="btn">Скачать XAMPP</a>
        </div>

        <div class="step">
            <h3>2. Установка зависимостей</h3>
            <pre>php composer.phar install</pre>
        </div>

        <div class="step">
            <h3>3. Инициализация базы данных</h3>
            <pre>php artisan migrate</pre>
        </div>

        <div class="step">
            <h3>4. Запуск сервера</h3>
            <pre>php artisan serve --host=0.0.0.0 --port=8000</pre>
        </div>

        <h2>🧪 Тестирование API</h2>
        <div class="status warning">
            После запуска сервера API будет доступен по адресу: <strong>http://localhost:8000/api</strong>
        </div>

        <h3>Тестовые запросы:</h3>
        <pre>
# Health Check
curl http://localhost:8000/api/health

# Получить все оборудование
curl http://localhost:8000/api/equipment

# Добавить новое оборудование
curl -X POST http://localhost:8000/api/equipment \
  -H "Content-Type: application/json" \
  -d '{"title":"Новый монитор","quantity":3,"image":"monitor.jpg"}'
        </pre>

        <h2>📁 Структура проекта</h2>
        <ul>
            <li><code>.env</code> - Конфигурация окружения</li>
            <li><code>database/database.sqlite</code> - SQLite база данных</li>
            <li><code>composer.phar</code> - Composer для установки зависимостей</li>
            <li><code>portable-env/schema.sql</code> - SQL схема базы данных</li>
        </ul>

        <div class="status info">
            💡 <strong>Совет:</strong> Если у вас проблемы с сетевым подключением, используйте портативные версии PHP или локальные серверы типа XAMPP.
        </div>
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath "setup-guide.html" -Encoding UTF8

Write-Host "✅ Портативная настройка завершена!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Созданные файлы:" -ForegroundColor Cyan
Write-Host "  - .env (конфигурация)" -ForegroundColor White
Write-Host "  - database/database.sqlite (база данных)" -ForegroundColor White
Write-Host "  - portable-env/schema.sql (схема БД)" -ForegroundColor White
Write-Host "  - setup-guide.html (веб-инструкция)" -ForegroundColor White
Write-Host "  - start-server.bat (скрипт запуска)" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Откройте setup-guide.html в браузере для подробных инструкций" -ForegroundColor Yellow
Write-Host ""
Write-Host "🚀 Для продолжения установите PHP и выполните:" -ForegroundColor Green
Write-Host "  php composer.phar install" -ForegroundColor White
Write-Host "  php artisan migrate" -ForegroundColor White
Write-Host "  php artisan serve --host=0.0.0.0 --port=8000" -ForegroundColor White

# Открытие веб-инструкции
Start-Process "setup-guide.html"
