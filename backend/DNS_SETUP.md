# 🌐 Настройка DNS для convertik.ponravilos.ru

## 📋 Инструкция по добавлению DNS записи

### 1. Вход в панель управления

1. Перейдите на https://hostkey.ru
2. Войдите с данными: yazydzhi@gmail.com
3. Найдите раздел "DNS управление" или "Управление доменами"

### 2. Добавление A-записи

В разделе управления DNS для домена `ponravilos.ru`:

1. **Нажмите "Добавить запись"**
2. **Заполните поля:**
   - **Тип записи:** A
   - **Имя (субдомен):** convertik
   - **Значение (IP):** 185.70.105.198
   - **TTL:** 3600 (по умолчанию)

3. **Сохраните изменения**

### 3. Результат

После добавления записи в DNS должно быть:

```
@            A    185.70.105.198  (ponravilos.ru)
n8n          A    185.70.105.198  (n8n.ponravilos.ru)
link         A    185.70.105.198  (link.ponravilos.ru)
convertik    A    185.70.105.198  (convertik.ponravilos.ru)  ← НОВАЯ ЗАПИСЬ
```

### 4. Проверка распространения DNS

```bash
# Проверка через dig
dig convertik.ponravilos.ru +short

# Ожидаемый результат: 185.70.105.198
```

**Время распространения:** обычно 5-30 минут

### 5. Альтернативные проверки

```bash
# Проверка через nslookup
nslookup convertik.ponravilos.ru

# Проверка через ping
ping convertik.ponravilos.ru

# Онлайн проверка DNS
# https://dnschecker.org/
# Введите: convertik.ponravilos.ru
```

## ⚠️ Troubleshooting

### DNS запись не работает

1. **Проверьте правильность:**
   - Имя: `convertik` (без точки в конце)
   - IP: `185.70.105.198` 
   - Тип: A

2. **Время распространения:**
   - Подождите 30-60 минут
   - DNS записи обновляются не мгновенно

3. **Очистка кеша DNS:**
   ```bash
   # macOS
   sudo dscacheutil -flushcache
   
   # Linux
   sudo systemctl restart systemd-resolved
   
   # Windows
   ipconfig /flushdns
   ```

### Если доступа к Hostkey.ru нет

Можно использовать любой другой DNS провайдер:

1. **Cloudflare** (бесплатно)
2. **Яндекс.DNS**
3. **Reg.ru**

Просто добавьте там такую же A-запись.

## ✅ Готово!

После настройки DNS домен `convertik.ponravilos.ru` будет указывать на сервер с IP `185.70.105.198`, и Caddy автоматически получит SSL сертификат для HTTPS.