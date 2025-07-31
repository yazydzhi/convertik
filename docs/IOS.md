

# IOS.md  
> 📱 Подробная спецификация клиентского приложения «Конвертик» для iOS  

Версия документа: 1.0 (31 июля 2025)  

---

## 1. Цели приложения

* **Мгновенный расчёт валют** даже оф‑лайн.  
* **Минимальный UX‑шаг** — открыть → ввести сумму → увидеть результат.  
* **Монетизация**: реклама AdMob для free‑пользователей и подписка Premium без рекламы.  
* **Сбор анонимной аналитики** (DAU/MAU, конверсии) с уважением к приватности.  

---

## 2. Пользовательские сценарии (User Stories)

| ID | Как пользователь, я хочу … | Чтобы … | Путь (Happy Path) |
|----|---------------------------|---------|-------------------|
| US‑01 | мгновенно видеть список моих валют | быстро оценить стоимость | открываю приложение → сразу вижу список → ввожу сумму |
| US‑02 | добавить новую валюту | конвертировать редкие валюты | тап `+` → поиск → тап по валюте → она в списке |
| US‑03 | удалить валюту | держать список коротким | свайп влево по карточке → «Удалить» |
| US‑04 | обновить курсы вручную | быть уверенным в актуальности | тяну список вниз → вижу спиннер → дата «обновлено: сейчас» |
| US‑05 | оф‑лайн посчитать курс | нет сети в роуминге | запускаю оф‑лайн → вижу курсы, сохранённые ранее |
| US‑06 | купить Premium | убрать рекламу | открываю «Премиум» → нажимаю «Подписаться» → Face ID → реклама исчезла |
| US‑07 | восстановить покупку | переустановил приложение | «Премиум» → «Восстановить» → статус Premium восстановлен |
| US‑08 | сменить тему | комфортно использовать ночью | «Настройки» → переключатель «Тёмная тема» |
| US‑09 | получить push «курс EUR вырос» | вовремя реагировать | разрешаю уведомления → получаю push → тап → открываю приложение |

---

## 3. Навигационная карта экранов

```
LaunchScreen
   ↓
┌──────────────┐       «+»        ┌────────────────┐
│ MainListView │ ───────────────► │ AddCurrencyView │
└──────────────┘◄───────────────  └────────────────┘
   │  │Settings                ↑ SearchBar
   │  └───────────┐
   │  «Premium»   │
   ▼              │
┌─────────────────┐
│   SettingsView  │
│  • Theme        │
│  • Premium ⟶────┼──► PaywallView (StoreKit2)
└─────────────────┘
```

* **MainListView** (root)  
  - Нав‑бар: заголовок «Конвертик» + дата обновления.  
  - Body: `List` валютных карточек.  
  - Toolbar: `+` (AddCurrency), шестерёнка (Settings).  
  - Bottom: `BannerAdView` (если `!isPremium`).

* **AddCurrencyView**  
  - SearchBar (Combine debounce).  
  - Section «Популярные» (USD, EUR, GBP…).  
  - Section «Все валюты» (алфавит).  

* **SettingsView**  
  - Toggle «Тёмная тема» (ColorScheme).  
  - «Premium» → Paywall.  
  - Ссылки: Политика, Условия.  
  - Версия приложения.

* **PaywallView**  
  - Короткий список преимуществ.  
  - Кнопка `Подписаться за 199 ₽/мес`.  
  - `StoreKit2.ProductView`.  
  - Кнопка `Восстановить`.

---

## 4. Архитектура приложения

### 4.1 Стек

| Уровень              | Технологии                   |
|----------------------|------------------------------|
| UI                   | SwiftUI 5, Declarative UI    |
| Состояние            | MVVM + Combine (`@StateObject`/`@Published`) |
| Хранилище оф‑лайн    | CoreData (`RateEntity`)      |
| Сеть                 | `URLSession` + async/await   |
| Фоновые задачи       | BackgroundTasks (`BGAppRefreshTask`) |
| Монетизация          | Google Mobile Ads SDK, StoreKit2 |
| Push                 | `UNUserNotificationCenter`, APNs |
| Аналитика            | AppMetrica SDK               |
| DI (минимализм)      | `@Environment(\.inject)` — lightweight |

### 4.2 Слои / Каталоги

```
Sources/
 ├ App/                  # App entry, SceneDelegate
 ├ Modules/
 │   ├ MainCurrencyList/
 │   │   ├ Views/
 │   │   ├ ViewModel/
 │   │   └ Tests/
 │   ├ AddCurrency/
 │   ├ Settings/
 │   └ Paywall/
 ├ Services/
 │   ├ RatesService.swift      # fetch /rates
 │   ├ ConversionService.swift # math operations
 │   ├ AnalyticsService.swift  # AppMetrica wrappers
 │   ├ IAPService.swift        # StoreKit2 helpers
 │   └ AdService.swift         # AdMob wrappers
 ├ Persistence/
 │   ├ CoreDataStack.swift
 │   └ RateEntity+Ext.swift
 └ Resources/                 # Assets, Localizable.strings
```

### 4.3 Основные классы

* `RatesRepository`  
  - `func localRates() -> [Rate]` (CoreData)  
  - `func syncRemote() async throws` (GET /rates)  
  - кеширует дату обновления, отправляет `Notification` при обновлении.

* `MainListViewModel`  
  - `@Published var items: [CurrencyRowModel]`  
  - Binding к TextField: onChange пересчитывает.

* `ConversionService`  
  - `func convert(_ amount: Double, from: Rate, to: Rate) -> Double`.

* `BackgroundScheduler`  
  - регистрирует `BGAppRefreshTask` («com.azg.convertik.refresh») каждые 6 ч.

---

## 5. Бизнес‑логика

### 5.1 Расчёт

```swift
func convert(_ amount: Double, from: Rate, to: Rate) -> Double {
    guard from.value > 0 else { return 0 }
    let rub = amount * from.value     // amount → рубли
    return rub / to.value             // → целевая валюта
}
```

### 5.2 Работа оф‑лайн

1. При `AppDelegate.application(_:didFinishLaunching)` CoreData грузит `RateEntity`.  
2. Если записи пусты → показываем placeholder «Нужен интернет для первого запуска».  
3. `RatesService.syncRemote()` запускается, но UI не блокируется.  
4. В оф‑лайн режиме поле даты подсвечено серым, курсив: _«Курсы на 29.07»_.  

### 5.3 Обновление в фоне

```swift
BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.azg.convertik.refresh", using: nil) { task in
    await RatesService.shared.syncRemote()
    task.setTaskCompleted(success: true)
}
```

и планирование при уходе в background.

---

## 6. Монетизация

### 6.1 Реклама

* Блок‑ид: `ca-app-pub‑xxx/banner_main_bottom`.  
* Показывается только если `!Premium`.  
* При переключении Premium → баннер скрывается анимированным `opacity`.

### 6.2 Подписка

* `ProductID`: `convertik_premium_month`.  
* Цена: 199 ₽ в RU, Tier 3 в übrigen Regionen.  
* Один бесплатный Trial 7 дней.  
* Проверка статуса: `Transaction.currentEntitlements`.  
* Сервер отправляет `/iap/verify` для доп.валидации (anti‑fraud).  

---

## 7. Analytics events

| Event            | Параметры            | Триггер                     |
|------------------|----------------------|-----------------------------|
| app_open         | none                 | `onAppear` MainListView     |
| conversion       | from,to,amount       | `onCommit` TextField        |
| ad_impression    | ad_unit_id           | delegate AdMob              |
| subscribe_start  | plan_id              | Tap кнопки «Подписаться»    |
| subscribe_success| plan_id, price       | `Transaction` success       |
| subscribe_cancel | plan_id              | S2S notification            |

---

## 8. Локализация

* **Языки**: ru, en (Base).  
* Используется `String(localized:)`, таблицы `Localizable.strings`.  
* Числа форматируются через `NumberFormatter` с учётом `Locale.current`.

---

## 9. Accessibility (A11y)

* Поддержка **Dynamic Type** – шрифты `font(.body)` и т.п.  
* Все интерактивные элементы имеют `accessibilityLabel`.  
* Баннер AdMob помечается `accessibilityHidden = true`.  
* Контраст цветов — проверка через Xcode Accessibility Inspector.

---

## 10. Тестирование

| Тип        | Что проверяем                         |
|------------|---------------------------------------|
| Unit       | `ConversionService`, `RatesRepository` |
| Snapshot   | MainListView (с и без Premium)        |
| UI‑тесты   | Сценарий добавления валюты            |
| StoreKit   | Sandbox‑подписка + restore            |
| Перфоманс  | Cold‑start (measure block)            |

---

## 11. Build & Run

```bash
# Предустановки
brew install swiftlint
# Зависимости
xcodebuild -resolvePackageDependencies
# Линт
swiftlint
# Тесты
xcodebuild test -scheme Convertik -destination "platform=iOS Simulator,name=iPhone 15"
```

---

## 12. Будущие улучшения (Backlog)

* Виджет на Home Screen (iOS 17 WidgetBundle).  
* Watch OS‑приложение с быстрым конвертером.  
* История курсов (Storage + график).  
* Локальное уведомление «Обновить курсы?» при оф‑лайн > 7 дней.  

---