# Рекламная интеграция в Convertik

## Обзор

Приложение использует Google AdMob для монетизации через рекламу. Реализованы три типа рекламы:

1. **Баннерная реклама** - отображается внизу главного экрана
2. **Полноэкранная реклама** - показывается при определенных действиях пользователя
3. **Вознаграждаемая реклама** - для получения дополнительных функций

## Архитектура

### Сервисы

- `AdService` - основной сервис для баннерной рекламы
- `InterstitialAdService` - управление полноэкранной рекламой
- `RewardedAdService` - управление вознаграждаемой рекламой
- `AdConfig` - конфигурация рекламных ID

### Компоненты

- `AdBannerRepresentable` - UIKit wrapper для GADBannerView
- `AdBannerContainerView` - контейнер баннерной рекламы
- `InterstitialAdView` - компонент для полноэкранной рекламы
- `RewardedAdView` - компонент для вознаграждаемой рекламы

## Конфигурация

### Тестовые ID (DEBUG)

```swift
// Баннерная реклама
"ca-app-pub-3940256099942544/2934735716"

// Полноэкранная реклама
"ca-app-pub-3940256099942544/4411468910"

// Вознаграждаемая реклама
"ca-app-pub-3940256099942544/1712485313"

// App ID
"ca-app-pub-3940256099942544~1458002511"
```

### Продакшн ID (RELEASE)

Замените `xxx` на реальные ID из AdMob консоли:

```swift
// Баннерная реклама
"ca-app-pub-xxx/banner_main_bottom"

// Полноэкранная реклама
"ca-app-pub-xxx/interstitial_main"

// Вознаграждаемая реклама
"ca-app-pub-xxx/rewarded_main"

// App ID
"ca-app-pub-xxx~app_id"
```

## Использование

### Баннерная реклама

Автоматически отображается в `MainListView` для не-Premium пользователей:

```swift
if !storeService.isPremium {
    AdBannerContainerView()
}
```

### Полноэкранная реклама

Показывается каждые 3 действия пользователя:

```swift
private func triggerAdIfNeeded(action: @escaping () -> Void) {
    adTriggerCount += 1
    
    if !storeService.isPremium && adTriggerCount % 3 == 0 && interstitialService.isReady {
        interstitialService.showAd(from: rootViewController) {
            action()
        }
    } else {
        action()
    }
}
```

### Вознаграждаемая реклама

Используется для получения дополнительных функций:

```swift
Button("Получить бонус") {
    // Показать вознаграждаемую рекламу
}
.rewardedAd { success in
    if success {
        // Пользователь получил награду
        giveBonus()
    }
}
```

## Аналитика

Отслеживаются следующие события:

- `ad_impression` - показ баннерной рекламы
- `ad_click` - клик по рекламе
- `interstitial_ad_shown` - показ полноэкранной рекламы
- `rewarded_ad_completed` - завершение вознаграждаемой рекламы

## Настройка в AdMob

1. Создайте приложение в AdMob консоли
2. Добавьте рекламные блоки:
   - Banner Ad Unit
   - Interstitial Ad Unit
   - Rewarded Ad Unit
3. Скопируйте ID в `AdConfig.swift`
4. Настройте таргетинг и ограничения

## Тестирование

### Тестовые устройства

Добавьте тестовые устройства в AdMob консоль или используйте:

```swift
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
    "2077ef9a63d2b398840261c8221a0c9b"
]
```

### Проверка загрузки

Логи показывают статус загрузки рекламы:

```
Google Mobile Ads SDK initialization status: GADInitializationStatus
Interstitial ad loaded successfully
Rewarded ad loaded successfully
```

## Ограничения

- Реклама не показывается Premium пользователям
- Полноэкранная реклама показывается не чаще чем каждые 3 действия
- Минимальный интервал между рекламой: 60 секунд
- Реклама скрыта от accessibility для лучшего UX

## Мониторинг

### Метрики для отслеживания

- Fill Rate (процент успешных загрузок)
- eCPM (эффективная стоимость за 1000 показов)
- CTR (Click-Through Rate)
- Revenue (доход от рекламы)

### Алерты

Настройте алерты на:
- Fill Rate < 50%
- eCPM < ожидаемого значения
- Ошибки загрузки рекламы

## Политики и правила

### App Store

- Соблюдайте [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Не показывайте рекламу детям младше 13 лет
- Предоставьте возможность отключить персонализированную рекламу

### AdMob

- Соблюдайте [AdMob Program Policies](https://support.google.com/admob/answer/6128543)
- Не размещайте рекламу рядом с кнопками
- Не используйте автоматические клики

## Troubleshooting

### Реклама не загружается

1. Проверьте интернет соединение
2. Убедитесь что ID правильные
3. Проверьте статус аккаунта AdMob
4. Посмотрите логи на ошибки

### Низкий Fill Rate

1. Проверьте настройки таргетинга
2. Убедитесь что приложение не в тестовом режиме
3. Проверьте ограничения по возрасту и контенту
4. Рассмотрите добавление резервных рекламных сетей

### Высокий eCPM

1. Оптимизируйте таргетинг
2. Улучшите качество трафика
3. Добавьте больше рекламных блоков
4. Рассмотрите A/B тестирование 