# TODO: Production Improvements

## 🔧 API Keys & External Services
- [ ] Получить реальный API ключ от OpenExchangeRates для production
- [ ] Настроить fallback на другие бесплатные API (exchangerate-api.com)
- [ ] Добавить мониторинг доступности внешних API

## 📊 Monitoring & Logging  
- [ ] Настроить алерты при ошибках загрузки курсов
- [ ] Добавить метрики производительности API
- [ ] Настроить ротацию логов

## 🔒 Security
- [ ] Заменить демо-токены на реальные секреты
- [ ] Настроить HTTPS redirects
- [ ] Добавить rate limiting для API endpoints

## 🚀 Performance
- [ ] Настроить кэширование курсов в Redis
- [ ] Оптимизировать запросы к базе данных
- [ ] Добавить CDN для статических файлов

## 📱 iOS Integration
- [ ] Обновить iOS app для работы с production API
- [ ] Протестировать все endpoints на реальных данных
- [ ] Настроить push notifications
