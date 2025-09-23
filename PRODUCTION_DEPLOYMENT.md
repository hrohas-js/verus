# 🌐 Развертывание Verus Backend для продакшена

## Обзор

Этот документ описывает процесс развертывания Verus Backend API для доступа из интернета. Проект поддерживает развертывание как с Docker, так и без него.

## Требования к серверу

### Минимальные требования:
- **ОС**: Ubuntu 20.04+ / CentOS 8+ / Windows Server 2019+
- **RAM**: 2GB (рекомендуется 4GB+)
- **CPU**: 2 ядра (рекомендуется 4+)
- **Диск**: 20GB свободного места
- **Сеть**: Статический IP адрес или домен

### Необходимое ПО:
- Docker & Docker Compose (рекомендуется)
- Или PHP 8.2+ + Composer (альтернатива)

## Варианты развертывания

### 1. 🐳 Docker развертывание (рекомендуется)

#### Шаг 1: Подготовка сервера
```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Перезагрузка для применения изменений
sudo reboot
```

#### Шаг 2: Клонирование проекта
```bash
# Клонирование репозитория
git clone <your-repo-url> verus-backend
cd verus-backend

# Или загрузка файлов проекта
```

#### Шаг 3: Настройка домена
```bash
# Для Linux/macOS
chmod +x deploy-production.sh
./deploy-production.sh --domain your-domain.com

# Для Windows
.\deploy-production.ps1 -Domain "your-domain.com"
```

#### Шаг 4: Настройка SSL (опционально)
```bash
# Установка Certbot
sudo apt install certbot

# Получение SSL сертификата
sudo certbot certonly --standalone -d your-domain.com

# Копирование сертификатов
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/key.pem
sudo chown $USER:$USER ssl/*.pem

# Перезапуск с SSL
./deploy-production.sh --domain your-domain.com --ssl
```

### 2. 💻 Локальное развертывание (без Docker)

#### Шаг 1: Установка PHP и Composer
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install php8.2 php8.2-fpm php8.2-mysql php8.2-sqlite3 php8.2-curl php8.2-zip php8.2-mbstring php8.2-xml php8.2-gd nginx

# Установка Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

#### Шаг 2: Настройка Nginx
```bash
# Создание конфигурации сайта
sudo nano /etc/nginx/sites-available/verus-api

# Содержимое файла:
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/verus-backend/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}

# Активация сайта
sudo ln -s /etc/nginx/sites-available/verus-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### Шаг 3: Развертывание приложения
```bash
cd /path/to/verus-backend

# Установка зависимостей
composer install --no-dev --optimize-autoloader

# Настройка окружения
cp .env.example .env
nano .env  # Настройте параметры

# Генерация ключа
php artisan key:generate

# Настройка базы данных
touch database/database.sqlite
php artisan migrate

# Оптимизация
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Настройка прав доступа
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

## Настройка файрвола

### Ubuntu/Debian (UFW)
```bash
# Разрешение HTTP и HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Разрешение SSH (если нужно)
sudo ufw allow 22/tcp

# Включение файрвола
sudo ufw enable
```

### CentOS/RHEL (firewalld)
```bash
# Разрешение HTTP и HTTPS
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Применение изменений
sudo firewall-cmd --reload
```

## Настройка DNS

### A-запись
```
your-domain.com    A    YOUR_SERVER_IP
www.your-domain.com A   YOUR_SERVER_IP
```

### CNAME (альтернатива)
```
api.your-domain.com CNAME your-domain.com
```

## Мониторинг и логи

### Docker развертывание
```bash
# Просмотр логов
docker-compose logs -f

# Просмотр логов конкретного сервиса
docker-compose logs -f app
docker-compose logs -f nginx

# Мониторинг ресурсов
docker stats
```

### Локальное развертывание
```bash
# Логи Laravel
tail -f storage/logs/laravel.log

# Логи Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Логи PHP-FPM
sudo tail -f /var/log/php8.2-fpm.log
```

## Резервное копирование

### Автоматическое резервное копирование
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/verus-api"

# Создание директории для бэкапов
mkdir -p $BACKUP_DIR

# Бэкап базы данных
if [ -f "database/database.sqlite" ]; then
    cp database/database.sqlite $BACKUP_DIR/database_$DATE.sqlite
fi

# Бэкап файлов приложения
tar -czf $BACKUP_DIR/app_$DATE.tar.gz --exclude=node_modules --exclude=vendor .

# Удаление старых бэкапов (старше 30 дней)
find $BACKUP_DIR -name "*.sqlite" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Бэкап завершен: $DATE"
```

### Настройка cron для автоматических бэкапов
```bash
# Редактирование crontab
crontab -e

# Добавление задачи (ежедневно в 2:00)
0 2 * * * /path/to/backup.sh
```

## Обновление приложения

### Docker развертывание
```bash
# Остановка сервисов
docker-compose down

# Обновление кода
git pull origin main

# Пересборка и запуск
docker-compose up -d --build

# Выполнение миграций (если есть)
docker-compose exec app php artisan migrate
```

### Локальное развертывание
```bash
# Обновление кода
git pull origin main

# Обновление зависимостей
composer install --no-dev --optimize-autoloader

# Выполнение миграций
php artisan migrate

# Очистка кеша
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Пересоздание кеша
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Устранение неполадок

### Проблемы с Docker
```bash
# Проверка статуса контейнеров
docker-compose ps

# Перезапуск сервисов
docker-compose restart

# Просмотр логов
docker-compose logs

# Очистка Docker
docker system prune -a
```

### Проблемы с правами доступа
```bash
# Исправление прав доступа
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### Проблемы с базой данных
```bash
# Пересоздание базы данных
rm database/database.sqlite
touch database/database.sqlite
php artisan migrate:fresh
```

### Проблемы с SSL
```bash
# Обновление сертификатов Let's Encrypt
sudo certbot renew

# Проверка сертификата
openssl x509 -in ssl/cert.pem -text -noout
```

## Безопасность

### Рекомендации по безопасности:
1. **Регулярно обновляйте систему и зависимости**
2. **Используйте сильные пароли**
3. **Настройте fail2ban для защиты от брутфорса**
4. **Ограничьте доступ к административным портам**
5. **Используйте SSL/TLS сертификаты**
6. **Настройте мониторинг и алерты**

### Настройка fail2ban
```bash
# Установка fail2ban
sudo apt install fail2ban

# Создание конфигурации
sudo nano /etc/fail2ban/jail.local

# Содержимое:
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
```

## Производительность

### Оптимизация Nginx
```nginx
# Добавьте в конфигурацию Nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

# Кеширование статических файлов
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Оптимизация PHP
```ini
; В php.ini
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
```

## Поддержка

При возникновении проблем:
1. Проверьте логи приложения
2. Убедитесь в правильности настроек DNS
3. Проверьте настройки файрвола
4. Обратитесь к документации Laravel
5. Создайте issue в репозитории проекта

---

**Готово!** 🎉 Ваш API сервер теперь доступен из интернета.
