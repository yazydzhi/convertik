# **Шпаргалка по серверу ponravilos\.ru — v2025**
## **🖥** **Общее описание сервера**
```warp-runnable-command
СЕРВЕРНАЯ ПЛАТФОРМА

IP сервера: 185.70.105.198  
ОС: Ubuntu 22.04 LTS  
Все сервисы полностью развернуты через Docker + Caddy.

---

СОСТАВ ПРОЕКТА

- Docker (контейнерная инфраструктура)
- docker-compose v2.24.7 (управление сборками)
- Caddy (обеспечение HTTPS и обратный прокси)
- n8n (основное приложение)
- PostgreSQL (база данных n8n)
- MySQL (дополнительная БД для внутренних сервисов)
- Telegram Channel Creator (скрипты автосоздания каналов)
```
### **📂  Структура каталогов**
```warp-runnable-command
/opt/n8n-docker-caddy/             - основная директория docker-compose
/opt/n8n-docker-caddy/docker-compose.yml - конфиг docker
/opt/n8n-docker-caddy/caddy_config/Caddyfile - конфиг Caddy
/opt/www/                          - статический сайт ponravilos.ru
/opt/tg_channel_creator_postgres/  - Telegram-скрипты
/opt/backups/                      - бэкапы (если активны)
```
## **⚙ Docker volumes**
```warp-runnable-command
n8n_data    - хранит данные n8n
caddy_data  - хранит SSL-сертификаты Caddy

```
## 🌍Домен ponravilos\.ru
https\:\/\/nic\.ru
login 509861\/NIC\-D
## 💾 Хостинг \- VPS
[https\:\/\/hostkey\.ru](https://hostkey.ru)
yazydzhi\@gmail\.com
## **⚙ DNS**
```warp-runnable-command
DNS обслуживается через Hostkey:

NS-сервера:
- ns1.hostkey.ru
- ns2.hostkey.ru

A-записи:

@            A 185.70.105.198
n8n          A 185.70.105.198
link         A 185.70.105.198
```
## **🔧 Базовые команды управления**
```warp-runnable-command
# Перейти в рабочую директорию
cd /opt/n8n-docker-caddy

# Запуск всего проекта
docker-compose up -d

# Перезапуск всех сервисов
docker-compose restart

# Перезапуск только Caddy
docker-compose restart caddy

# Перезапуск только n8n
docker-compose restart n8n

# Просмотр логов
docker-compose logs -f

# Проверить запущенные контейнеры
docker ps

# Проверить общий статус docker
systemctl status docker
```
## **🔧 Работа с Caddy**
```warp-runnable-command
# Caddyconfig
vim /opt/n8n-docker-caddy/caddy_config/Caddyfile

# Проверка логов Caddy
docker logs n8n-docker-caddy-caddy-1

# Проверка получения сертификатов (если внутри контейнера)
docker exec -it n8n-docker-caddy-caddy-1 sh
ls /data/caddy/certificates/
```
## **🔐 Cron задачи**
```warp-runnable-command
# Просмотр текущего crontab
crontab -l

# Редактирование
crontab -e
```
Содержимое\:
```warp-runnable-command
0 2 * * * /opt/tg_channel_creator_postgres/run_create_channels.sh
8 5 * * * /opt/tg_channel_creator_postgres/run_create_text_post.sh
7 11 * * * /opt/tg_channel_creator_postgres/run_create_img_post.sh
0 3 * * * /opt/backup.sh
```
## **🔐  Firewall \(если включен UFW\)**
```warp-runnable-command
# Проверка статуса
ufw status verbose

# Основные открытые порты:
22 - SSH
80 - HTTP
443 - HTTPS
```
## **🔬 Диагностика DNS**
```warp-runnable-command
# Проверка A-записи домена
dig ponravilos.ru +short
dig n8n.ponravilos.ru +short
```
## **🛠  Как выключить сервер полностью**
```warp-runnable-command
# Остановить все контейнеры
docker stop $(docker ps -q)

# Остановить сам docker (если нужно полностью остановить платформу)
systemctl stop docker
```
## **🚀 Обновление docker\-compose \(если потребуется в будущем\)**
```warp-runnable-command
# Удалить старую версию:
apt remove docker-compose

# Установить свежую:
sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
## **📝 Обновление Caddy \(если потребуется\)**
```warp-runnable-command
# Просто обновить docker-образ:
docker pull caddy:latest
docker-compose up -d

```
## 🗄 Проверка PostgreSQL
```warp-runnable-command
# Быстрая проверка что Postgres работает:
sudo -u postgres psql -c '\l'

# Альтернативно (если настроен пароль):
psql -U postgres -h 127.0.0.1

# Список баз:
\l

# Выход:
\q
```
## 🗄 Проверка MySQL
```warp-runnable-command
# Проверка соединения:
mysql -u root -p

# Список баз:
SHOW DATABASES;

# Выход:
exit
```
## 🗄 Перенос MySQL баз
### Создание дампа на старом сервере\:
```warp-runnable-command
mysqldump -u root -p --databases bot convertik > mysql_backup.sql`
```
### Перенос файла на новый сервер\:
```warp-runnable-command
scp mysql_backup.sql root@185.70.105.198:/root/
```
### Восстановление на новом сервере\:
```warp-runnable-command
mysql -u root -p < /root/mysql_backup.sql
```
### Проверка\:
```warp-runnable-command
mysql -u root -p
SHOW DATABASES;
```
# VPN
```warp-runnable-command
curl -sS https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh | bash
```
Получить строку подключения 
```warp-runnable-command
{
  "apiUrl": "https://185.70.105.198:30869/sMUBQ5SkuLElCN-03zQn7g",
  "certSha256": "8A966F1224CBA7FC151BDE288BD7F4A12671E8D6D9BDA8502AC656CBFA350D84"
}
```
Проверить порты

Добавить исключения в фаервол \(проверь порты в выводе после установки
```warp-runnable-command
sudo ufw status
sudo ufw allow 30869/tcp
sudo ufw allow 64686/tcp
sudo ufw allow 64686/udp
```
Добавить перенапрпавление в caddy
```warp-runnable-command
vpn.ponravilos.ru {
  reverse_proxy 171.18.0.1:30869
}
```
подгрузить новый конфиг в caddy
```warp-runnable-command
docker exec -it n8n-docker-caddy-caddy-1 caddy reload --config /etc/caddy/Caddyfile
```
Новая строка подключени будет выглядеть так
```warp-runnable-command
{
  "apiUrl": "https://vpn.ponravilos.ru/sMUBQ5SkuLElCN-03zQn7g",
  "certSha256": "8A966F1224CBA7FC151BDE288BD7F4A12671E8D6D9BDA8502AC656CBFA350D84"
}
```
## **🔥 Резюме архитектуры**
* Абсолютно чистая docker\-инфраструктура\.
* Нет apache\, nginx\, лишних слоёв\.
* Полностью централизованное управление конфигами\.
* Все обновления — 100\% контролируемы\.
* Сертификаты — автоматом Caddy через Let’s Encrypt\.
