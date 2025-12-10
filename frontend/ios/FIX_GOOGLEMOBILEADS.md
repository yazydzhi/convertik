# Исправление ошибки "No such module 'GoogleMobileAds'"

## Проблема
После изменений в `project.yml` и регенерации проекта через `xcodegen`, CocoaPods нужно переустановить.

## Решение

### Шаг 1: Переустановите CocoaPods

В терминале выполните:

```bash
cd frontend/ios
pod deintegrate
pod install
```

### Шаг 2: Убедитесь, что открыт правильный файл

**ВАЖНО:** Откройте `Convertik.xcworkspace`, а НЕ `Convertik.xcodeproj`!

CocoaPods работает только через `.xcworkspace`.

### Шаг 3: Очистите и пересоберите

1. В Xcode: **Product → Clean Build Folder** (⇧⌘K)
2. Закройте Xcode
3. Откройте `Convertik.xcworkspace`
4. Выберите схему **Convertik-Old**
5. Соберите проект (⌘B)

## Если проблема сохраняется

Проверьте в Build Settings:
1. Откройте **Build Settings**
2. Найдите **"Framework Search Paths"**
3. Должны быть пути к Pods:
   - `$(inherited)`
   - `${PODS_CONFIGURATION_BUILD_DIR}/Google-Mobile-Ads-SDK`
   - `${PODS_ROOT}/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework`

Если пусто - выполните `pod install` снова.



