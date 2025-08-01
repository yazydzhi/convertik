# Convertik iOS App

Нативное iOS приложение для конвертации валют с поддержкой оффлайн режима.

**🎉 Текущая версия: 1.2**  
**🌐 Production API:** https://convertik.ponravilos.ru

## 🚀 Возможности

- **Мгновенная конвертация** валют в оффлайн режиме
- **Автоматическое обновление** курсов в фоне каждые 6 часов  
- **Premium подписка** с отключением рекламы через StoreKit2
- **Тёмная/светлая тема** с автоматическим переключением
- **Аналитика** с отправкой на backend для улучшения UX
- **Локализация** на русском и английском языках
- **Базовые валюты** доступны сразу при первом запуске

## 🛠 Технологии

- **UI**: SwiftUI 5 + Combine
- **Архитектура**: MVVM 
- **Хранение**: CoreData для оффлайн кэша курсов
- **Сеть**: URLSession + async/await для API интеграции
- **Монетизация**: StoreKit2 + AdMob SDK
- **Фон**: BackgroundTasks для обновления курсов
- **Минимальная версия**: iOS 15.0
- **Сборка**: xcodegen для генерации проекта

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
frontend/ios/
├── Convertik/              # Исходный код приложения
│   ├── App/                # Точка входа приложения
│   │   ├── ConvertikApp.swift
│   │   └── ContentView.swift
│   ├── Models/             # Модели данных
│   │   ├── Rate.swift
│   │   ├── UserCurrency.swift
│   │   └── APIModels.swift
│   ├── Services/           # Бизнес-логика
│   │   ├── RatesRepository.swift
│   │   ├── APIService.swift
│   │   ├── ConversionService.swift
│   │   ├── SettingsService.swift
│   │   ├── AnalyticsService.swift
│   │   ├── StoreService.swift
│   │   └── BackgroundService.swift
│   ├── Persistence/        # CoreData стек
│   │   ├── CoreDataStack.swift
│   │   ├── RateEntity+CoreDataClass.swift
│   │   └── ConvertikDataModel.xcdatamodeld
│   ├── Modules/            # UI модули
│   │   ├── MainCurrencyList/
│   │   ├── AddCurrency/
│   │   ├── Settings/
│   │   └── Paywall/
│   └── Components/         # Переиспользуемые компоненты
│       └── AdBannerView.swift
├── project.yml             # Конфигурация xcodegen
├── Info.plist              # Настройки приложения
└── Convertik.xcodeproj/    # Сгенерированный проект Xcode
```

## 🔄 Поток данных

1. **Запуск**: Загрузка курсов из CoreData → UI готов < 0.3с
2. **Фон**: Запрос fresh курсов с API → сохранение в CoreData
3. **Конвертация**: Локальные вычисления без сети
4. **Аналитика**: Батчинг событий → отправка на `/stats` API
5. **Premium**: StoreKit2 покупка → валидация на `/iap/verify`
6. **Оффлайн**: Базовые валюты доступны сразу при первом запуске

## 🛠 Сборка и запуск

### Требования
- Xcode 15.0+
- iOS 15.0+ (device/simulator)
- Swift 5.9+
- xcodegen (установка: `brew install xcodegen`)

### Локальная разработка

1. **Установите зависимости**:
```bash
# Установка xcodegen
brew install xcodegen

# Установка iOS runtime (если нужно)
xcodebuild -downloadPlatform iOS
```

2. **Сгенерируйте проект**:
```bash
cd frontend/ios
xcodegen generate
```

3. **Соберите и установите на симулятор**:
```bash
# Сборка
xcodebuild -project Convertik.xcodeproj -scheme Convertik -destination "platform=iOS Simulator,name=iPhone 16 Pro" -derivedDataPath ./build build

# Установка
xcodebuild -project Convertik.xcodeproj -scheme Convertik -destination "platform=iOS Simulator,name=iPhone 16 Pro" -derivedDataPath ./build install

# Запуск
xcrun simctl launch <SIMULATOR_UDID> com.azg.Convertik
```

4. **Откройте симулятор**:
```bash
open -a Simulator
```

### Конфигурация

Основные настройки в `Info.plist`:
- `BGTaskSchedulerPermittedIdentifiers` для фоновых задач
- `NSAppTransportSecurity` для HTTPS соединений
- Bundle Identifier: `com.azg.Convertik`
- Версия: 1.2 (CFBundleShortVersionString)

### API Endpoint

В `APIService.swift` настроен базовый URL:
- **Production**: `https://convertik.ponravilos.ru/api/v1`

## 🧪 Тестирование

```bash
# Unit тесты
xcodebuild test -scheme Convertik -destination "platform=iOS Simulator,name=iPhone 16 Pro"

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

## 🔧 Устранение неполадок

### Приложение не обновляется на симуляторе
```bash
# Принудительная переустановка
xcrun simctl uninstall <SIMULATOR_UDID> com.azg.Convertik
xcodebuild -project Convertik.xcodeproj -scheme Convertik -destination "platform=iOS Simulator,name=iPhone 16 Pro" -derivedDataPath ./build install
```

### Проверка версии установленного приложения
```bash
plutil -p "/Users/azg/Library/Developer/CoreSimulator/Devices/<SIMULATOR_UDID>/data/Containers/Bundle/Application/*/Convertik.app/Info.plist" | grep -E "(CFBundleShortVersionString|CFBundleVersion)"
```

## 🤝 Contributing

1. Fork репозиторий
2. Создайте feature branch
3. Commit изменения
4. Push в branch  
5. Создайте Pull Request

Следуйте Swift Style Guide и используйте SwiftLint для проверки кода.