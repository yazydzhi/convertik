# Настройка рекламы в Convertik

## Быстрый старт

### 1. Добавление Google Mobile Ads SDK

Убедитесь что в `project.yml` добавлена зависимость:

```yaml
dependencies:
  - sdk: GoogleMobileAds
```

### 2. Инициализация в ConvertikApp.swift

```swift
import GoogleMobileAds

@main
struct ConvertikApp: App {
    init() {
        // Инициализация Google Mobile Ads
        GADMobileAds.sharedInstance().start { status in
            print("Google Mobile Ads SDK initialization status: \(status)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. Настройка рекламных ID

Откройте `AdConfig.swift` и замените тестовые ID на продакшн:

```swift
#if DEBUG
// Оставьте тестовые ID для разработки
#else
// Замените на реальные ID из AdMob консоли
static let mainBottom = "ca-app-pub-REAL_ID/banner_main_bottom"
static let main = "ca-app-pub-REAL_ID/interstitial_main"
static let rewarded = "ca-app-pub-REAL_ID/rewarded_main"
static let appID = "ca-app-pub-REAL_ID~app_id"
#endif
```

## Пошаговая настройка AdMob

### 1. Создание аккаунта

1. Перейдите на [AdMob Console](https://admob.google.com/)
2. Создайте аккаунт или войдите в существующий
3. Подтвердите email и настройте платежную информацию

### 2. Создание приложения

1. Нажмите "Apps" → "Add App"
2. Выберите "iOS"
3. Введите название: "Convertik"
4. Выберите категорию: "Finance"
5. Нажмите "Add"

### 3. Создание рекламных блоков

#### Баннерная реклама
1. В приложении нажмите "Ad units" → "Create ad unit"
2. Выберите "Banner"
3. Название: "Main Bottom Banner"
4. Скопируйте Ad Unit ID

#### Полноэкранная реклама
1. "Create ad unit" → "Interstitial"
2. Название: "Main Interstitial"
3. Скопируйте Ad Unit ID

#### Вознаграждаемая реклама
1. "Create ad unit" → "Rewarded"
2. Название: "Main Rewarded"
3. Настройте награду (например, "Bonus Currency")
4. Скопируйте Ad Unit ID

### 4. Настройка App ID

1. В приложении найдите "App ID"
2. Скопируйте ID
3. Добавьте в `AdConfig.swift`

## Тестирование

### Тестовые устройства

Добавьте ваше устройство в тестовые:

```swift
// В ConvertikApp.swift
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
    "YOUR_DEVICE_ID" // Получите через GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers
]
```

### Проверка работы

1. Запустите приложение
2. Проверьте логи:
   ```
   Google Mobile Ads SDK initialization status: GADInitializationStatus
   Interstitial ad loaded successfully
   ```
3. Убедитесь что реклама загружается и показывается

## Продакшн настройка

### 1. Замена ID

Замените все тестовые ID на продакшн в `AdConfig.swift`

### 2. Настройка таргетинга

В AdMob консоли:
1. Выберите рекламный блок
2. "Settings" → "Targeting"
3. Настройте:
   - Географию (Россия, СНГ)
   - Возраст (18+)
   - Интересы (Финансы, Путешествия)

### 3. Оптимизация

1. "Settings" → "Optimization"
2. Включите автоматическую оптимизацию
3. Установите минимальный eCPM

## Мониторинг

### Дашборд AdMob

Отслеживайте:
- **Fill Rate** - должен быть > 80%
- **eCPM** - эффективная стоимость за 1000 показов
- **Revenue** - доход от рекламы
- **CTR** - Click-Through Rate

### Аналитика в приложении

Проверяйте события в AnalyticsService:
- `ad_impression`
- `ad_click`
- `interstitial_ad_shown`
- `rewarded_ad_completed`

## Troubleshooting

### Реклама не загружается

1. **Проверьте интернет**
   ```swift
   // Добавьте в AdService
   print("Network status: \(NetworkMonitor.shared.isConnected)")
   ```

2. **Проверьте ID**
   - Убедитесь что ID правильные
   - Проверьте что приложение одобрено в AdMob

3. **Проверьте логи**
   ```
   Failed to load interstitial ad: No ad to show
   ```

### Низкий Fill Rate

1. **Проверьте настройки**
   - Географический таргетинг
   - Возрастные ограничения
   - Категории контента

2. **Добавьте резервные сети**
   - Facebook Audience Network
   - Unity Ads
   - AppLovin

### Высокий eCPM

1. **Оптимизируйте таргетинг**
   - Уточните географию
   - Добавьте интересы
   - Настройте демографию

2. **A/B тестирование**
   - Тестируйте разные форматы
   - Экспериментируйте с размещением
   - Оптимизируйте частоту показа

## Политики и правила

### App Store Guidelines

- Не показывайте рекламу детям < 13 лет
- Предоставьте возможность отключить персонализированную рекламу
- Не размещайте рекламу рядом с кнопками навигации

### AdMob Policies

- Соблюдайте [AdMob Program Policies](https://support.google.com/admob/answer/6128543)
- Не используйте автоматические клики
- Не размещайте рекламу в неподходящих местах

## Полезные ссылки

- [AdMob Documentation](https://developers.google.com/admob/ios/quick-start)
- [iOS Integration Guide](https://developers.google.com/admob/ios/ios14)
- [Best Practices](https://developers.google.com/admob/ios/best-practices)
- [Policy Center](https://support.google.com/admob/answer/6128543) 