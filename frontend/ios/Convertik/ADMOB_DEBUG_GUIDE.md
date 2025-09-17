# Руководство по отладке AdMob

## Проблема
Тестовая реклама AdMob не загружается в iOS приложении, хотя в AdConfig прописаны тестовые коды.

## Внесенные исправления

### 1. Настройка тестовых устройств
В `ConvertikApp.swift` добавлена настройка тестовых устройств:
```swift
#if DEBUG
GADMobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
    "2077ef9a63d2b398840261c8221a0c9b", // Симулятор iOS
    kGADSimulatorID as String // Симулятор
]
#endif
```

### 2. Улучшенное логирование
Добавлено детальное логирование во всех компонентах AdMob:
- `ConvertikApp.swift` - инициализация SDK
- `AdService.swift` - настройка сервиса
- `AdBannerRepresentable.swift` - загрузка баннеров
- `InterstitialAdService.swift` - загрузка полноэкранной рекламы

### 3. Устранение дублирования инициализации
Убрана дублирующая инициализация AdMob из `AdService.swift`.

### 4. Добавлен отладчик AdMob
Создан `AdMobDebugger.swift` для диагностики проблем:
- Проверка формата Ad Unit IDs
- Вывод информации о конфигурации
- Тестирование запросов рекламы

## Как проверить работу

### 1. Запустите приложение в DEBUG режиме
Убедитесь, что приложение запускается в DEBUG конфигурации.

### 2. Проверьте логи в консоли Xcode
Ищите следующие сообщения:
- `🚀 Google Mobile Ads SDK initialization status:`
- `🎯 AdService: Setting up ads with Banner ID:`
- `📱 AdBannerRepresentable: Creating banner with Ad Unit ID:`
- `✅ Banner ad loaded successfully!` или `❌ Banner ad failed to load!`

### 3. Проверьте тестовые Ad Unit IDs
Убедитесь, что используются правильные тестовые ID:
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`
- App ID: `ca-app-pub-3940256099942544~1458002511`

## Возможные причины проблем

### 1. Сеть
- Убедитесь, что устройство/симулятор подключен к интернету
- Проверьте, что нет блокировки рекламных серверов

### 2. Настройки проекта
- Проверьте, что в Info.plist указан правильный `GADApplicationIdentifier`
- Убедитесь, что Google-Mobile-Ads-SDK добавлен в Podfile

### 3. Симулятор vs Реальное устройство
- На симуляторе используйте `kGADSimulatorID`
- На реальном устройстве добавьте его Device ID в тестовые устройства

### 4. Время инициализации
- AdMob SDK должен быть инициализирован до создания первого рекламного запроса
- Убедитесь, что инициализация происходит в `ConvertikApp.init()`

## Дополнительные проверки

### 1. Проверка Device ID
Для получения Device ID реального устройства добавьте в код:
```swift
print("Device ID: \(GADMobileAds.shared.requestConfiguration.testDeviceIdentifiers)")
```

### 2. Проверка статуса инициализации
```swift
print("AdMob initialized: \(MobileAds.shared.isInitialized)")
```

### 3. Проверка версии SDK
```swift
print("AdMob SDK version: \(GADMobileAds.shared.sdkVersion)")
```

## Следующие шаги

1. Запустите приложение и проверьте логи
2. Если реклама все еще не загружается, проверьте:
   - Подключение к интернету
   - Настройки файрвола/антивируса
   - Региональные ограничения AdMob
3. При необходимости обратитесь к документации AdMob для iOS

## Полезные ссылки
- [AdMob iOS Documentation](https://developers.google.com/admob/ios/quick-start)
- [AdMob Test Ads](https://developers.google.com/admob/ios/test-ads)
- [Troubleshooting AdMob](https://developers.google.com/admob/ios/troubleshooting)
