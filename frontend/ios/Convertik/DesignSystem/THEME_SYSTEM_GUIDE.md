# Система тем Convertik

## Обзор

Система тем Convertik обеспечивает полную поддержку светлой и темной тем для всех компонентов приложения. Система построена на основе централизованного управления темами с автоматическим сохранением пользовательских предпочтений.

**Палитра Velvet Sunset** - футуристичная палитра, вдохновлённая закатными оттенками, предназначена для современного и удобного восприятия пользователями 20–40 лет.

## Архитектура

### 1. ThemeService
Центральный сервис для управления темами приложения.

**Основные возможности:**
- Автоматическое сохранение/загрузка предпочтений темы
- Переключение между светлой и темной темами
- Интеграция с системными настройками
- Отслеживание изменений темы

**Использование:**
```swift
@EnvironmentObject private var themeService: ThemeService

// Переключение темы
themeService.toggleTheme()

// Установка конкретной темы
themeService.setLightTheme()
themeService.setDarkTheme()
```

### 2. ThemeManager
Менеджер для получения цветов с учетом текущей темы.

**Основные свойства:**
- `textPrimary` - основной цвет текста
- `textSecondary` - вторичный цвет текста
- `textTertiary` - третичный цвет текста
- `background` - основной фон
- `cardBackground` - фон карточек
- `cardHover` - фон карточек при наведении
- `separator` - цвет разделителей
- `interactiveBackground` - фон интерактивных элементов
- `accentGradient` - основной акцентный градиент
- `amberAccent` - янтарный акцент
- `lilacHighlight` - сиреневый акцент для выделения

**Использование:**
```swift
@Environment(\.themeManager) private var themeManager

Text("Пример текста")
    .foregroundColor(themeManager.textPrimary)
    .background(themeManager.cardBackground)
```

### Палитра Velvet Sunset

Ниже приведены цвета для светлой и тёмной версий новой футуристичной палитры, вдохновлённой закатными оттенками. Она предназначена для современного и удобного восприятия пользователями 20–40 лет.

#### Акцентные цвета (одинаковые для обеих тем)
- **Accent Gradient:** `#FF7E5F → #FD3A84` — плавный градиент от кораллового к розовому для кнопок и активных элементов
- **Amber Accent:** `#F8B400` — дополнительный акцент для выделения важных действий
- **Lilac Highlight:** `#C084FC` — оттенок для маркеров и выбранных карточек

#### Светлая тема
- **Main Background:** `#FDF9F9` — основа светлой темы, мягкий тон, напоминающий рассвет
- **Card Background:** `#FFFFFF` — нейтральная поверхность для карточек
- **Separator:** `#EAE2EF` — цвет для разделителей, гармонично контрастирует с фоном
- **Text Primary:** `#443C4C` — основной цвет текста
- **Text Secondary:** `#6C566E` — вторичный текст

#### Тёмная тема
- **Main Background:** `#1B1525` — глубокий тёмный фон для комфортного использования в условиях низкой освещённости
- **Card Background:** `#282032` — фон карточек
- **Card Hover:** `#342C44` — цвет карточек при наведении или выборе
- **Separator:** `#3A3244` — тонкие разделители между элементами
- **Text Primary:** `#E4DCE8` — светлый текст на тёмном фоне
- **Text Secondary:** `#B5AFC0` — приглушённый вторичный текст

## Компоненты с поддержкой тем

### 1. ConvertikButton
Кнопка с автоматической адаптацией под тему и поддержкой градиентов.

```swift
ConvertikButton("Нажми меня") {
    // действие
}
```

**Стили:**
- `.primary` - использует акцентный градиент
- `.secondary` - использует янтарный акцент
- `.destructive` - использует красный цвет ошибки
- `.outline` - прозрачный фон с янтарной рамкой

### 2. CurrencyCard
Карточка валюты с поддержкой тем и эффектами наведения.

```swift
CurrencyCard(
    currencyCode: "USD",
    currencyName: "US Dollar",
    amount: "1,234.56",
    changePercent: 2.5,
    isSelected: false
) {
    // действие при нажатии
}
```

**Особенности:**
- Автоматическое изменение фона при выборе
- Сиреневая рамка для выбранных карточек
- Адаптивные тени под тему

### 3. AmountInputField
Поле ввода с адаптивным дизайном.

```swift
AmountInputField(
    amount: $amount,
    placeholder: "Введите сумму",
    currencyCode: "RUB"
)
```

### 4. ConvertikSearchBar
Поисковая строка с поддержкой тем.

```swift
ConvertikSearchBar(
    text: $searchText,
    placeholder: "Поиск валют"
)
```

### 5. ThemeToggleView
Переключатель темы с визуальной индикацией.

```swift
ThemeToggleView()
```

## Интеграция в приложение

### 1. Настройка главного приложения
```swift
@main
struct ConvertikApp: App {
    @StateObject private var themeService = ThemeService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeService)
                .withTheme(themeService)
        }
    }
}
```

### 2. Использование в представлениях
```swift
struct MyView: View {
    @EnvironmentObject private var themeService: ThemeService
    @Environment(\.themeManager) private var themeManager
    
    var body: some View {
        VStack {
            Text("Пример")
                .foregroundColor(themeManager.textPrimary)
                .background(themeManager.cardBackground)
        }
        .background(themeManager.background)
    }
}
```

## Тени

Система теней адаптируется под текущую тему:

### Светлая тема
- **Light**: `black.opacity(0.05)` - легкая тень
- **Medium**: `black.opacity(0.1)` - средняя тень
- **Heavy**: `black.opacity(0.15)` - сильная тень

### Темная тема
- **Light**: `white.opacity(0.05)` - легкая тень
- **Medium**: `white.opacity(0.1)` - средняя тень
- **Heavy**: `white.opacity(0.15)` - сильная тень

## Анимации

Все переходы между темами анимированы с использованием стандартных анимаций SwiftUI:

```swift
.animation(ConvertikAnimation.medium, value: themeManager.isDarkMode)
```

## Лучшие практики

### 1. Всегда используйте ThemeManager
```swift
// ✅ Правильно
.foregroundColor(themeManager.textPrimary)

// ❌ Неправильно
.foregroundColor(.primary)
```

### 2. Используйте семантические цвета
```swift
// ✅ Правильно
.foregroundColor(ConvertikColors.success)

// ❌ Неправильно
.foregroundColor(.green)
```

### 3. Используйте градиенты для акцентов
```swift
// ✅ Правильно
.background(themeManager.accentGradient)

// ❌ Неправильно
.background(ConvertikColors.primary)
```

### 4. Адаптируйте тени под тему
```swift
// ✅ Правильно
.shadow(
    color: themeManager.isDarkMode ? ConvertikShadows.lightDark.color : ConvertikShadows.light.color,
    radius: themeManager.isDarkMode ? ConvertikShadows.lightDark.radius : ConvertikShadows.light.radius,
    x: themeManager.isDarkMode ? ConvertikShadows.lightDark.x : ConvertikShadows.light.x,
    y: themeManager.isDarkMode ? ConvertikShadows.lightDark.y : ConvertikShadows.light.y
)
```

### 5. Тестируйте обе темы
Всегда проверяйте, как компоненты выглядят в обеих темах.

## Демонстрация

Для просмотра всех тем используйте `ThemePreviewView`:

```swift
ThemePreviewView()
```

Для просмотра цветовой палитры используйте `ColorPalettePreviewView`:

```swift
ColorPalettePreviewView()
```

Для просмотра цветовой палитры в статическом виде используйте `ColorPaletteView`:

```swift
ColorPaletteView()
```

## Миграция с старой системы

### 1. Замена прямых цветов
```swift
// Старый код
.foregroundColor(ConvertikColors.textPrimary)

// Новый код
.foregroundColor(themeManager.textPrimary)
```

### 2. Обновление фонов
```swift
// Старый код
.background(ConvertikColors.background)

// Новый код
.background(themeManager.background)
```

### 3. Использование градиентов
```swift
// Старый код
.background(ConvertikColors.primary)

// Новый код
.background(themeManager.accentGradient)
```

### 4. Добавление ThemeManager
```swift
struct MyView: View {
    @Environment(\.themeManager) private var themeManager
    // ...
}
```

## Изменения в версии 3.0

### Новая палитра Velvet Sunset
- Заменены основные цвета на акцентные градиенты
- Добавлены новые цвета: `amberAccent`, `lilacHighlight`
- Обновлены цвета фонов для обеих тем
- Улучшена контрастность и читаемость

### Новые возможности
- Поддержка градиентов в компонентах
- Эффекты наведения для карточек
- Улучшенная система теней
- Более современный внешний вид

### Обратная совместимость
- Старые цвета сохранены как legacy для обратной совместимости
- Все существующие компоненты продолжают работать
- Постепенная миграция на новую систему

## Заключение

Система тем Convertik обеспечивает:
- ✅ Полную поддержку светлой и темной тем
- ✅ Автоматическое сохранение предпочтений
- ✅ Консистентный дизайн во всем приложении
- ✅ Легкую интеграцию в новые компоненты
- ✅ Обратную совместимость
- ✅ Демонстрационные экраны для тестирования
- ✅ Современную палитру Velvet Sunset
- ✅ Поддержку градиентов и эффектов

Система готова к использованию и может быть легко расширена для поддержки дополнительных тем в будущем. 