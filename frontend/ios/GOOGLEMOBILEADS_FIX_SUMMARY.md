# Полный анализ и решение проблемы с GoogleMobileAds

## Текущая ситуация

### ✅ Что правильно настроено:

1. **Podfile** - содержит правильную зависимость:
   ```ruby
   pod 'Google-Mobile-Ads-SDK'
   ```

2. **Workspace** (`Convertik.xcworkspace/contents.xcworkspacedata`) - правильно настроен:
   - Включает `Convertik.xcodeproj`
   - Включает `Pods/Pods.xcodeproj`

3. **xcconfig файлы** - правильно настроены:
   - `Configs/Debug.xcconfig` включает `Pods-Convertik.debug.xcconfig`
   - `Configs/Release.xcconfig` включает `Pods-Convertik.release.xcconfig`

4. **Info.plist** - содержит `GADApplicationIdentifier`

5. **Код** - правильно использует `import GoogleMobileAds` в:
   - `ConvertikApp.swift`
   - `AdBannerRepresentable.swift`
   - `AdService.swift`
   - `InterstitialAdService.swift`
   - `RewardedAdService.swift`

### ❌ Проблема:

**CocoaPods не может установить зависимости из-за отсутствия gem `ffi` в окружении CocoaPods.**

Ошибка:
```
Could not find 'ffi' (>= 1.15.0) among 121 total gem(s)
```

## Решение

### Шаг 1: Исправление проблемы с CocoaPods

Выберите один из вариантов:

#### Вариант A: Установка ffi через gem (быстро)

```bash
cd frontend/ios
sudo gem install ffi
pod install
```

#### Вариант B: Переустановка CocoaPods через Homebrew (рекомендуется)

```bash
brew uninstall cocoapods
brew install cocoapods
cd frontend/ios
pod install
```

#### Вариант C: Использование Xcode

1. Откройте `Convertik.xcworkspace` в Xcode
2. **File → Open** → выберите `Podfile`
3. Xcode предложит установить Pods - нажмите **"Install"**

### Шаг 2: После успешной установки Pods

1. **Закройте Xcode** (если открыт)

2. **Откройте workspace** (НЕ project!):
   ```bash
   open Convertik.xcworkspace
   ```

3. **Очистите build folder**:
   - В Xcode: **Product → Clean Build Folder** (⇧⌘K)

4. **Соберите проект**:
   - В Xcode: **Product → Build** (⌘B)

### Шаг 3: Проверка установки

После установки проверьте:

```bash
cd frontend/ios
ls -la Pods/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework
```

Должен быть framework `GoogleMobileAds.framework`.

## Что было проверено

1. ✅ Podfile содержит правильную зависимость
2. ✅ Workspace правильно настроен с Pods
3. ✅ xcconfig файлы правильно включают Pods конфигурацию
4. ✅ Info.plist содержит GADApplicationIdentifier
5. ✅ Код правильно использует import GoogleMobileAds
6. ✅ Структура проекта соответствует требованиям

## Дополнительные файлы

- `reinstall_admob.sh` - скрипт для автоматической переустановки (требует исправления проблемы с ffi)
- `FIX_COCOAPODS_FFI.md` - подробная инструкция по исправлению проблемы с ffi

## Если проблема сохраняется после установки Pods

1. Проверьте, что открыт **workspace**, а не **project**
2. Проверьте Build Settings → Framework Search Paths:
   - Должен содержать `$(inherited)`
   - Должен содержать пути к Pods
3. Убедитесь, что в xcconfig файлах правильно указаны пути к Pods
4. Попробуйте удалить Derived Data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

## Контакты и ресурсы

- [Официальная документация Google Mobile Ads SDK](https://developers.google.com/admob/ios/quick-start)
- [CocoaPods документация](https://guides.cocoapods.org/)



