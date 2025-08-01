# Convertik iOS App

Нативное iOS приложение для конвертации валют с поддержкой оффлайн режима.

## 🚀 Возможности

- **Мгновенная конвертация** валют в оффлайн режиме
- **Автоматическое обновление** курсов в фоне каждые 6 часов  
- **Premium подписка** с отключением рекламы через StoreKit2
- **Тёмная/светлая тема** с автоматическим переключением
- **Аналитика** с отправкой на backend для улучшения UX
- **Локализация** на русском и английском языках

## 🛠 Технологии

- **UI**: SwiftUI 5 + Combine
- **Архитектура**: MVVM 
- **Хранение**: CoreData для оффлайн кэша курсов
- **Сеть**: URLSession + async/await для API интеграции
- **Монетизация**: StoreKit2 + AdMob SDK
- **Фон**: BackgroundTasks для обновления курсов
- **Минимальная версия**: iOS 15.0

## 📱 Экраны

### MainListView
- Список валют с текущими курсами
- Поле ввода суммы для конвертации
- Pull-to-refresh для обновления курсов
- AdMob баннер (скрывается для Premium)

### AddCurrencyView  
- Поиск валют с debounce
- Секции "Популярные" и "Все валюты"
- Добавление валют в пользовательский список

### SettingsView
- Переключатель темы оформления
- Переход к Premium подписке
- Ссылки на политику и условия

### PaywallView
- Список преимуществ Premium
- Интеграция StoreKit2 для покупки
- Кнопка восстановления покупок

## 🏗 Архитектура

```
Sources/Convertik/
├── App/                    # Точка входа приложения
│   ├── ConvertikApp.swift
│   └── ContentView.swift
├── Models/                 # Модели данных
│   ├── Rate.swift
│   ├── UserCurrency.swift
│   └── APIModels.swift
├── Services/               # Бизнес-логика
│   ├── RatesRepository.swift
│   ├── APIService.swift
│   ├── ConversionService.swift
│   ├── SettingsService.swift
│   ├── AnalyticsService.swift
│   ├── StoreService.swift
│   └── BackgroundService.swift
├── Persistence/           # CoreData стек
│   ├── CoreDataStack.swift
│   ├── RateEntity+CoreDataClass.swift
│   └── ConvertikDataModel.xcdatamodeld
├── Modules/              # UI модули
│   ├── MainCurrencyList/
│   ├── AddCurrency/
│   ├── Settings/
│   └── Paywall/
└── Components/           # Переиспользуемые компоненты
    └── AdBannerView.swift
```

## 🔄 Поток данных

1. **Запуск**: Загрузка курсов из CoreData → UI готов < 0.3с
2. **Фон**: Запрос fresh курсов с API → сохранение в CoreData
3. **Конвертация**: Локальные вычисления без сети
4. **Аналитика**: Батчинг событий → отправка на `/stats` API
5. **Premium**: StoreKit2 покупка → валидация на `/iap/verify`

## 🛠 Сборка и запуск

### Требования
- Xcode 15.0+
- iOS 15.0+ (device/simulator)
- Swift 5.9+

### Локальная разработка

1. **Запустите backend сервер**:
```bash
cd ../../backend
docker-compose up -d
```

2. **Откройте проект в Xcode**:
```bash
open ConvertikApp.xcodeproj
```

3. **Выберите target и устройство, нажмите Run**

### Конфигурация

Основные настройки в `Info.plist`:
- `BGTaskSchedulerPermittedIdentifiers` для фоновых задач
- `NSAppTransportSecurity` для HTTP localhost в DEBUG
- Bundle Identifier: `com.azg.convertik`

### API Endpoint

В `APIService.swift` настроен базовый URL:
- **Development**: `http://localhost:8000/api/v1`
- **Production**: `https://api.convertik.app/api/v1` (будет изменено)

## 🧪 Тестирование

```bash
# Unit тесты
xcodebuild test -scheme Convertik -destination "platform=iOS Simulator,name=iPhone 15"

# SwiftLint проверка кода
swiftlint

# Snapshot тесты UI
xcodebuild test -scheme ConvertikSnapshotTests
```

## 🚀 Деплой

### TestFlight (Beta)
1. Archive в Xcode
2. Upload to App Store Connect
3. Processing → TestFlight Beta Testing

### App Store
1. Версия готова в TestFlight
2. Create App Store Version
3. Submit for Review
4. Release после одобрения

## 🔒 Privacy & Security

- **Анонимная аналитика**: только Device UUID, без персональных данных
- **App Transport Security**: HTTPS обязателен для продакшн API
- **StoreKit**: валидация покупок на стороне сервера
- **Keychain**: безопасное хранение Premium статуса

## 🎯 Roadmap

- [ ] **Widget для iOS 17**: курсы на Home Screen
- [ ] **Apple Watch**: компаньон приложение
- [ ] **Spotlight интеграция**: поиск курсов через Spotlight
- [ ] **Shortcuts**: автоматизация через Siri Shortcuts
- [ ] **CarPlay**: поддержка в автомобиле

## 📈 Аналитика

Отслеживаемые события:
- `app_open` - запуск приложения  
- `conversion` - конвертация валют
- `currency_added/removed` - управление списком
- `subscribe_start/success` - воронка подписки
- `ad_impression` - показы рекламы

События батчатся и отправляются на backend при наличии сети.

## 🤝 Contributing

1. Fork репозиторий
2. Создайте feature branch
3. Commit изменения
4. Push в branch  
5. Создайте Pull Request

Следуйте Swift Style Guide и используйте SwiftLint для проверки кода.