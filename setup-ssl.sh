#!/bin/bash

# Скрипт для настройки SSL сертификатов с Let's Encrypt
# Автор: AI Assistant

set -e

DOMAIN=""
EMAIL=""
STAGING=false

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -e|--email)
            EMAIL="$2"
            shift 2
            ;;
        --staging)
            STAGING=true
            shift
            ;;
        -h|--help)
            echo "Использование: $0 [OPTIONS]"
            echo "Опции:"
            echo "  -d, --domain DOMAIN    Домен для сертификата"
            echo "  -e, --email EMAIL      Email для Let's Encrypt"
            echo "  --staging              Использовать staging сервер Let's Encrypt"
            echo "  -h, --help             Показать эту справку"
            exit 0
            ;;
        *)
            echo "Неизвестная опция: $1"
            exit 1
            ;;
    esac
done

# Проверка обязательных параметров
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "❌ Необходимо указать домен и email"
    echo "Использование: $0 -d your-domain.com -e your-email@example.com"
    exit 1
fi

echo "🔐 Настройка SSL сертификатов для домена: $DOMAIN"

# Проверка установки certbot
if ! command -v certbot &> /dev/null; then
    echo "Установка Certbot..."

    # Определение дистрибутива
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y certbot
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        sudo yum install -y certbot
    else
        echo "❌ Неподдерживаемый дистрибутив. Установите certbot вручную."
        echo "Инструкции: https://certbot.eff.org/"
        exit 1
    fi
fi

echo "✅ Certbot установлен"

# Остановка nginx для получения сертификата
echo "Остановка nginx..."
sudo systemctl stop nginx 2>/dev/null || true
docker-compose stop nginx 2>/dev/null || true

# Создание директории для SSL сертификатов
mkdir -p ssl

# Получение сертификата
echo "Получение SSL сертификата..."

if [ "$STAGING" = true ]; then
    echo "⚠️  Используется staging сервер Let's Encrypt"
    certbot_command="sudo certbot certonly --standalone --staging -d $DOMAIN -m $EMAIL --agree-tos --non-interactive"
else
    certbot_command="sudo certbot certonly --standalone -d $DOMAIN -m $EMAIL --agree-tos --non-interactive"
fi

if eval $certbot_command; then
    echo "✅ SSL сертификат успешно получен"
else
    echo "❌ Ошибка при получении SSL сертификата"
    exit 1
fi

# Копирование сертификатов
echo "Копирование сертификатов..."
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/key.pem

# Установка правильных прав доступа
sudo chown $USER:$USER ssl/cert.pem ssl/key.pem
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem

echo "✅ Сертификаты скопированы в папку ssl/"

# Настройка автоматического обновления
echo "Настройка автоматического обновления сертификатов..."

# Создание скрипта обновления
cat > update-ssl.sh << EOF
#!/bin/bash
# Автоматическое обновление SSL сертификатов

# Обновление сертификатов
sudo certbot renew --quiet

# Копирование обновленных сертификатов
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/key.pem

# Установка прав доступа
sudo chown $USER:$USER ssl/cert.pem ssl/key.pem
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem

# Перезапуск nginx
if command -v docker-compose &> /dev/null; then
    docker-compose restart nginx
else
    sudo systemctl reload nginx
fi

echo "SSL сертификаты обновлены: \$(date)"
EOF

chmod +x update-ssl.sh

# Добавление задачи в crontab
echo "Добавление задачи автоматического обновления в crontab..."
(crontab -l 2>/dev/null; echo "0 3 * * * $(pwd)/update-ssl.sh") | crontab -

echo "✅ Автоматическое обновление настроено"

# Запуск nginx
echo "Запуск nginx..."
if command -v docker-compose &> /dev/null; then
    docker-compose start nginx
else
    sudo systemctl start nginx
fi

# Проверка SSL сертификата
echo "Проверка SSL сертификата..."
if command -v openssl &> /dev/null; then
    echo "Информация о сертификате:"
    openssl x509 -in ssl/cert.pem -text -noout | grep -E "(Subject:|Not Before|Not After)"
fi

echo ""
echo "🎉 SSL сертификат успешно настроен!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Домен: $DOMAIN"
echo "🔐 Сертификат: ssl/cert.pem"
echo "🔑 Приватный ключ: ssl/key.pem"
echo "🔄 Автообновление: Настроено (ежедневно в 3:00)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$STAGING" = true ]; then
    echo ""
    echo "⚠️  ВНИМАНИЕ: Использовался staging сервер Let's Encrypt"
    echo "Для получения реального сертификата запустите:"
    echo "$0 -d $DOMAIN -e $EMAIL"
fi

echo ""
echo "Теперь вы можете запустить развертывание с SSL:"
echo "./deploy-production.sh --domain $DOMAIN --ssl"
