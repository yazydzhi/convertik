# Convertik iOS App

Конвертер валют для iOS с возможностью ввода в любую выбранную валюту.

## Основные возможности

### Ввод валют
- **Ввод в любую валюту**: Пользователь может вводить сумму в любую из выбранных валют
- **Автоматический пересчет**: При вводе в одну валюту автоматически пересчитываются все остальные
- **Очистка при фокусе**: При фокусе на поле ввода значения очищаются для удобства ввода
- **Реальное время**: Пересчет происходит по мере ввода

### Интерфейс
- **Поля ввода в каждой строке**: Каждая валюта имеет свое поле для ввода
- **Курсы валют**: Отображение текущих курсов валют к рублю
- **Добавление/удаление валют**: Возможность настройки списка валют
- **Настройки**: Управление премиум-функциями

## Архитектура

### Основные компоненты

#### MainListView
Главный экран приложения, содержащий:
- Список валют с полями ввода
- Навигационную панель с кнопками добавления валют и настроек
- Информацию о времени последнего обновления курсов

#### MainListViewModel
ViewModel для управления логикой конвертации:
- Отслеживание активной валюты ввода
- Пересчет всех валют при изменении одной
- Управление отображаемыми валютами

#### CurrencyRowView
Компонент строки валюты:
- Поле ввода суммы
- Отображение кода и названия валюты
- Показ курса к рублю
- Обработка фокуса и ввода

#### ConversionService
Сервис для конвертации валют:
- Конвертация между валютами через рубли
- Форматирование сумм с/без символов валют
- Форматирование курсов валют

### Поток данных

1. **Ввод пользователя**: Пользователь вводит сумму в поле валюты
2. **Обработка ввода**: CurrencyRowView передает введенное значение в ViewModel
3. **Установка активной валюты**: ViewModel устанавливает валюту как активную для ввода
4. **Пересчет**: ViewModel конвертирует сумму во все остальные валюты
5. **Обновление UI**: Все поля ввода обновляются с новыми значениями

### Особенности реализации

#### Очистка при фокусе
```swift
.onChange(of: isFocused) { focused in
    onFocusChange(focused)
    if focused {
        // При фокусе очищаем поле
        amountText = ""
    }
}
```

#### Пересчет валют
```swift
private func recalculateAllCurrencies(baseCurrencyCode: String, baseAmount: Double) {
    guard let baseRate = ratesRepository.rate(for: baseCurrencyCode) else { return }
    
    for i in 0..<displayedCurrencies.count {
        let targetCurrency = displayedCurrencies[i]
        
        // Пропускаем базовую валюту
        if targetCurrency.rate.code == baseCurrencyCode {
            continue
        }
        
        // Конвертируем из базовой валюты в целевую
        let convertedAmount = conversionService.convert(baseAmount, from: baseRate, to: targetCurrency.rate)
        displayedCurrencies[i].inputAmount = convertedAmount
    }
}
```

## Установка и запуск

### Быстрый старт

1. Установите зависимости:
   ```bash
   cd frontend/ios
   pod install
   ```

2. Откройте проект в Xcode:
   ```bash
   open Convertik.xcworkspace
   ```
   ⚠️ **Важно**: Открывайте `.xcworkspace`, а не `.xcodeproj`!

3. Выберите симулятор iPhone
4. Нажмите Cmd+R для запуска

### Сборка из командной строки

Используйте скрипт для автоматической сборки (рекомендуется):

```bash
cd frontend/ios
./build.sh                    # Обычная сборка
./build.sh --clean            # Очистка кэша и сборка (рекомендуется при проблемах)
```

Скрипт автоматически:
- Собирает Pods перед основной сборкой
- Решает проблему "Unable to find module dependency: 'GoogleMobileAds'"
- Показывает понятные сообщения об ошибках

**Опция `--clean`** очищает:
- DerivedData для проекта Convertik
- Swift module cache
- Build folder через xcodebuild clean

Используйте `--clean` если:
- Возникают ошибки "Unable to find module dependency"
- Xcode показывает устаревшие ошибки
- После обновления Pods или зависимостей

### Решение проблем со сборкой

Если возникает ошибка `Unable to find module dependency: 'GoogleMobileAds'`:

1. **Используйте скрипт сборки** (см. выше)
2. Или соберите Pods вручную:
   ```bash
   xcodebuild -workspace Convertik.xcworkspace \
       -scheme Pods-Convertik \
       -configuration Debug \
       -destination 'generic/platform=iOS Simulator' \
       build
   ```
3. Подробнее: см. [GOOGLEMOBILEADS_BUILD_FIX.md](GOOGLEMOBILEADS_BUILD_FIX.md)

## Требования

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Структура проекта

```
Convertik/
├── App/
│   ├── ContentView.swift
│   └── ConvertikApp.swift
├── Modules/
│   ├── MainCurrencyList/
│   │   ├── Views/
│   │   │   ├── MainListView.swift
│   │   │   └── CurrencyRowView.swift
│   │   └── ViewModel/
│   │       └── MainListViewModel.swift
│   ├── AddCurrency/
│   ├── Settings/
│   └── Paywall/
├── Services/
│   ├── ConversionService.swift
│   ├── RatesRepository.swift
│   └── SettingsService.swift
└── Components/
    └── AdBannerView.swift
```