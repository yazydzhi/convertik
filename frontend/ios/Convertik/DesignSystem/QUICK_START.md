# Быстрый старт с дизайн-системой Convertik

## 🚀 Начало работы

### 1. Импорт
Все компоненты доступны автоматически после добавления файлов в проект:

```swift
import SwiftUI
// Дизайн-система уже доступна
```

### 2. Основные цвета

```swift
// Основные цвета
ConvertikColors.primary      // #223355 - Основной брендовый цвет
ConvertikColors.accent       // #007AFF - Акцентный цвет
ConvertikColors.secondary    // #00A5A5 - Дополнительный акцент

// Семантические цвета
ConvertikColors.success      // #33C759 - Успех
ConvertikColors.warning      // #FF9500 - Предупреждение
ConvertikColors.error        // #EB3B3B - Ошибка

// Нейтральные цвета
ConvertikColors.textPrimary  // #222222 - Основной текст
ConvertikColors.background   // #F9F9F9 - Фон приложения
```

### 3. Типографика

```swift
// Заголовки
ConvertikTypography.largeTitle   // 34pt Bold
ConvertikTypography.title1       // 28pt Semibold
ConvertikTypography.title2       // 22pt Semibold

// Основной текст
ConvertikTypography.body         // 17pt Regular
ConvertikTypography.callout      // 16pt Regular

// Специальные шрифты для валют
ConvertikTypography.currencyAmount   // 24pt Medium Monospaced
ConvertikTypography.currencyCode     // 16pt Semibold
```

### 4. Отступы

```swift
ConvertikSpacing.xs    // 4pt
ConvertikSpacing.sm    // 8pt
ConvertikSpacing.md    // 12pt
ConvertikSpacing.lg    // 16pt
ConvertikSpacing.xl    // 20pt
ConvertikSpacing.xxl   // 24pt
```

## 🧩 Готовые компоненты

### Кнопки

```swift
// Основная кнопка
ConvertikButton("Добавить валюту") {
    // действие
}

// Вторичная кнопка
ConvertikButton("Отмена", style: .secondary) {
    // действие
}

// Кнопка удаления
ConvertikButton("Удалить", style: .destructive) {
    // действие
}
```

### Карточки валют

```swift
CurrencyCard(
    currencyCode: "USD",
    currencyName: "US Dollar",
    amount: "1,234.56",
    changePercent: 2.5,
    isSelected: false
) {
    // действие при тапе
}
```

### Поля ввода

```swift
// Поле для суммы
AmountInputField(
    amount: $amount,
    placeholder: "Введите сумму",
    currencyCode: "USD"
)

// Поисковая строка
ConvertikSearchBar(
    text: $searchText,
    placeholder: "Поиск валют"
)
```

### Состояния

```swift
// Загрузка
ConvertikLoadingView(message: "Загрузка курсов...")

// Пустое состояние
EmptyStateView(
    icon: "plus.circle",
    title: "Нет валют",
    message: "Добавьте первую валюту",
    actionTitle: "Добавить валюту"
) {
    // действие
}
```

## 🎨 Примеры использования

### Простой экран

```swift
struct SimpleScreen: View {
    @State private var amount = ""
    
    var body: some View {
        VStack(spacing: ConvertikSpacing.lg) {
            Text("Конвертер валют")
                .font(ConvertikTypography.title1)
                .foregroundColor(ConvertikColors.textPrimary)
            
            AmountInputField(
                amount: $amount,
                placeholder: "Введите сумму",
                currencyCode: "USD"
            )
            
            ConvertikButton("Конвертировать") {
                // логика конвертации
            }
        }
        .padding(ConvertikSpacing.xl)
        .background(ConvertikColors.background)
    }
}
```

### Список валют

```swift
struct CurrencyList: View {
    let currencies = [
        ("USD", "US Dollar", "1,234.56", 2.5),
        ("EUR", "Euro", "987.65", -1.2),
        ("GBP", "British Pound", "1,567.89", 0.8)
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: ConvertikSpacing.md) {
                ForEach(currencies, id: \.0) { currency in
                    CurrencyCard(
                        currencyCode: currency.0,
                        currencyName: currency.1,
                        amount: currency.2,
                        changePercent: currency.3,
                        isSelected: false
                    ) {
                        // действие при выборе валюты
                    }
                }
            }
            .padding(ConvertikSpacing.lg)
        }
        .background(ConvertikColors.background)
    }
}
```

## 🔧 Темная тема

Дизайн-система автоматически поддерживает темную тему:

```swift
@Environment(\.colorScheme) var colorScheme
@StateObject private var designSystem = DesignSystem()

// Автоматическое переключение цветов
Text("Привет")
    .foregroundColor(designSystem.textPrimary)
    .background(designSystem.background)
```

## 📱 Адаптивность

Все компоненты автоматически адаптируются к различным размерам экранов:

```swift
// Поддержка Dynamic Type
Text("Текст")
    .font(ConvertikTypography.body)
    .dynamicTypeSize(...DynamicTypeSize.accessibility3)

// Адаптивные отступы
.padding(ConvertikSpacing.lg)
```

## 🚨 Частые ошибки

### ❌ Неправильно
```swift
// Не используйте системные цвета
Text("Текст")
    .foregroundColor(.blue)
    .font(.title)

// Не создавайте собственные отступы
.padding(10)
```

### ✅ Правильно
```swift
// Используйте цвета дизайн-системы
Text("Текст")
    .foregroundColor(ConvertikColors.primary)
    .font(ConvertikTypography.title1)

// Используйте стандартные отступы
.padding(ConvertikSpacing.lg)
```

## 📚 Дополнительные ресурсы

- **Полная документация**: `README.md`
- **Визуальные примеры**: `ColorPalette.swift`
- **Все компоненты**: `Components.swift`
- **Основная система**: `DesignSystem.swift`

## 🆘 Поддержка

При возникновении вопросов:
1. Проверьте документацию в `README.md`
2. Посмотрите примеры в `ColorPalette.swift`
3. Изучите превью компонентов в Xcode

---

**Удачной разработки с дизайн-системой Convertik! 🎉** 