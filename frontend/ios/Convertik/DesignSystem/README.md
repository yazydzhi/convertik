# Дизайн-система Convertik

## Обзор

Дизайн-система Convertik создана для обеспечения консистентности и качества пользовательского интерфейса приложения для конвертации валют. Система основана на принципах iOS Human Interface Guidelines и современных трендах дизайна.

## Структура

```
DesignSystem/
├── DesignSystem.swift      # Основные цвета, типографика, отступы
├── Components.swift        # Переиспользуемые компоненты
└── README.md              # Документация
```

## Цветовая палитра

### Основные цвета

- **Primary** `#223355` - Глубокий синий, основной брендовый цвет
- **Accent** `#007AFF` - Яркий синий, для акцентов и кнопок
- **Secondary** `#00A5A5` - Бирюзовый, дополнительный акцент

### Семантические цвета

- **Success** `#33C759` - Зеленый для положительных изменений курса
- **Warning** `#FF9500` - Оранжевый для предупреждений
- **Error** `#EB3B3B` - Красный для ошибок и отрицательных изменений

### Нейтральные цвета

- **Text Primary** `#222222` - Основной текст
- **Text Secondary** `#777777` - Вторичный текст
- **Text Tertiary** `#999999` - Подсказки и вспомогательный текст
- **Separator** `#DDDDDD` - Разделители
- **Background** `#F9F9F9` - Основной фон приложения
- **Card Background** `#FFFFFF` - Фон карточек

### Темная тема

Все цвета адаптированы для темной темы с соответствующими контрастными значениями.

## Типографика

### Размеры шрифтов

- **Large Title** `34pt Bold` - Название приложения
- **Title 1** `28pt Semibold` - Заголовки экранов
- **Title 2** `22pt Semibold` - Заголовки секций
- **Title 3** `20pt Semibold` - Заголовки карточек
- **Headline** `17pt Semibold` - Заголовки списков
- **Body** `17pt Regular` - Основной текст
- **Callout** `16pt Regular` - Вторичный текст
- **Subheadline** `15pt Regular` - Подзаголовки
- **Footnote** `13pt Regular` - Мелкий текст
- **Caption 1** `12pt Regular` - Очень мелкий текст
- **Caption 2** `11pt Regular` - Микро текст

### Специальные шрифты для валют

- **Currency Amount** `24pt Medium Monospaced` - Суммы валют
- **Currency Code** `16pt Semibold` - Коды валют (USD, EUR)
- **Currency Name** `14pt Regular` - Названия валют

## Отступы

Система отступов основана на 4pt сетке:

- **xs** `4pt` - Очень маленький отступ
- **sm** `8pt` - Маленький отступ
- **md** `12pt` - Средний отступ
- **lg** `16pt` - Большой отступ
- **xl** `20pt` - Очень большой отступ
- **xxl** `24pt` - Огромный отступ
- **xxxl** `32pt` - Максимальный отступ

## Скругления

- **sm** `4pt` - Маленькое скругление
- **md** `8pt` - Среднее скругление
- **lg** `12pt` - Большое скругление
- **xl** `16pt` - Очень большое скругление
- **xxl** `24pt` - Максимальное скругление

## Компоненты

### Кнопки

```swift
ConvertikButton("Primary Button") { }
ConvertikButton("Secondary Button", style: .secondary) { }
ConvertikButton("Destructive Button", style: .destructive) { }
```

### Карточки валют

```swift
CurrencyCard(
    currencyCode: "USD",
    currencyName: "US Dollar",
    amount: "1,234.56",
    changePercent: 2.5,
    isSelected: false
) { }
```

### Поля ввода

```swift
AmountInputField(
    amount: $amount,
    placeholder: "Enter amount",
    currencyCode: "USD"
)
```

### Поиск

```swift
ConvertikSearchBar(
    text: $searchText,
    placeholder: "Search currencies"
)
```

### Состояния загрузки

```swift
ConvertikLoadingView(message: "Loading currencies...")
CurrencyCardSkeleton()
```

### Пустые состояния

```swift
EmptyStateView(
    icon: "plus.circle",
    title: "No Currencies",
    message: "Add your first currency to get started",
    actionTitle: "Add Currency"
) { }
```

## Использование

### 1. Импорт

```swift
import SwiftUI

// Все компоненты доступны автоматически
```

### 2. Применение цветов

```swift
Text("Hello")
    .foregroundColor(ConvertikColors.primary)
    .background(ConvertikColors.background)
```

### 3. Применение типографики

```swift
Text("Title")
    .font(ConvertikTypography.title1)
```

### 4. Применение отступов

```swift
VStack(spacing: ConvertikSpacing.lg) {
    // content
}
.padding(ConvertikSpacing.xl)
```

### 5. Применение компонентов

```swift
VStack {
    ConvertikButton("Action") { }
    CurrencyCard(...) { }
    AmountInputField(...)
}
```

## Темная тема

Дизайн-система автоматически поддерживает темную тему:

```swift
@Environment(\.colorScheme) var colorScheme
@StateObject private var designSystem = DesignSystem()

// Автоматическое переключение цветов
Text("Hello")
    .foregroundColor(designSystem.textPrimary)
```

## Принципы использования

### 1. Консистентность
- Всегда используйте компоненты дизайн-системы
- Не создавайте собственные цвета или отступы
- Следуйте установленным паттернам

### 2. Доступность
- Все компоненты поддерживают Dynamic Type
- Обеспечивается достаточный контраст
- Поддерживается VoiceOver

### 3. Производительность
- Компоненты оптимизированы для SwiftUI
- Минимальное количество перерисовок
- Эффективное использование памяти

## Расширение системы

### Добавление нового цвета

```swift
// В ConvertikColors
static let newColor = Color(red: 0.5, green: 0.5, blue: 0.5)
```

### Добавление нового компонента

```swift
// В Components.swift
struct NewComponent: View {
    var body: some View {
        // implementation
    }
}
```

### Добавление нового размера шрифта

```swift
// В ConvertikTypography
static let newFont = Font.system(size: 18, weight: .medium, design: .default)
```

## Тестирование

Все компоненты включают превью для быстрого тестирования:

```swift
#if DEBUG
struct Component_Previews: PreviewProvider {
    static var previews: some View {
        Component()
            .previewLayout(.sizeThatFits)
    }
}
#endif
```

## Версионирование

Дизайн-система следует семантическому версионированию:
- **Major** - Несовместимые изменения
- **Minor** - Новые функции
- **Patch** - Исправления ошибок

Текущая версия: **1.0.0** 