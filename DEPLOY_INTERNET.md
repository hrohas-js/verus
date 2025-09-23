# 🌐 Быстрое развертывание API для доступа из интернета

## 🚀 Быстрый старт (5 минут)

### Вариант 1: Docker (рекомендуется)

```bash
# 1. Клонируйте проект на сервер
git clone <your-repo> verus-backend
cd verus-backend

# 2. Запустите развертывание
chmod +x deploy-production.sh
./deploy-production.sh --domain your-domain.com

# 3. API будет доступен по адресу: http://your-domain.com/api
```

### Вариант 2: С SSL сертификатом

```bash
# 1. Настройте SSL сертификат
chmod +x setup-ssl.sh
./setup-ssl.sh -d your-domain.com -e your-email@example.com

# 2. Запустите развертывание с SSL
./deploy-production.sh --domain your-domain.com --ssl

# 3. API будет доступен по адресу: https://your-domain.com/api
```

## 📋 Что нужно подготовить

### На сервере:
- ✅ Домен или IP адрес
- ✅ Docker и Docker Compose
- ✅ Открытые порты 80 и 443

### DNS настройки:
```
your-domain.com    A    YOUR_SERVER_IP
www.your-domain.com A   YOUR_SERVER_IP
```

## 🔧 Проверка работы

```bash
# Проверка здоровья API
curl http://your-domain.com/api/health

# Получение списка оборудования
curl http://your-domain.com/api/equipment

# Добавление нового оборудования
curl -X POST http://your-domain.com/api/equipment \
  -H "Content-Type: application/json" \
  -d '{"title":"Монитор Samsung","quantity":5,"image":"monitor.jpg"}'
```

## 📝 Полезные команды

```bash
# Просмотр логов
docker-compose logs -f

# Перезапуск сервисов
docker-compose restart

# Остановка сервисов
docker-compose down

# Обновление приложения
git pull && docker-compose up -d --build
```

## 🛠️ Устранение проблем

### API не отвечает:
1. Проверьте статус контейнеров: `docker-compose ps`
2. Проверьте логи: `docker-compose logs`
3. Проверьте файрвол: `sudo ufw status`

### Проблемы с SSL:
1. Проверьте сертификаты: `ls -la ssl/`
2. Обновите сертификаты: `./update-ssl.sh`
3. Проверьте DNS: `nslookup your-domain.com`

### Проблемы с базой данных:
```bash
# Пересоздание базы данных
docker-compose exec app php artisan migrate:fresh
```

## 📚 Подробная документация

Для детальной настройки см. файл `PRODUCTION_DEPLOYMENT.md`

---

**Готово!** 🎉 Ваш API теперь доступен из интернета!
