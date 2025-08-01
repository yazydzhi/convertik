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

1. Откройте проект в Xcode
2. Выберите симулятор iPhone
3. Нажмите Cmd+R для запуска

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