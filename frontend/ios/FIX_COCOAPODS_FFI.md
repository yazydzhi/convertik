# Исправление проблемы с CocoaPods и GoogleMobileAds

## Проблема
CocoaPods не может найти gem `ffi`, что препятствует установке Google Mobile Ads SDK.

## Решение

### Вариант 1: Установка ffi в окружение CocoaPods (РЕКОМЕНДУЕТСЯ)

```bash
cd frontend/ios

# Установка ffi в системный gem path
sudo gem install ffi

# Или установка через homebrew (если установлен)
brew install libffi

# Затем попробуйте установить pod
pod install
```

### Вариант 2: Переустановка CocoaPods через Homebrew

```bash
# Удалить текущую версию
brew uninstall cocoapods

# Переустановить (это установит все зависимости, включая ffi)
brew install cocoapods

# Затем установить pods
cd frontend/ios
pod install
```

### Вариант 3: Использование системного Ruby и установка через gem

```bash
# Установить CocoaPods через gem (не через homebrew)
sudo gem install cocoapods

# Затем установить pods
cd frontend/ios
pod install
```

### Вариант 4: Использование Xcode для установки Pods

1. Откройте `Convertik.xcworkspace` в Xcode
2. В Xcode: **File → Open** → выберите `Podfile`
3. Xcode предложит установить Pods - нажмите **"Install"**

## После успешной установки

1. Закройте Xcode (если открыт)
2. Откройте `Convertik.xcworkspace` (НЕ .xcodeproj!)
3. **Product → Clean Build Folder** (⇧⌘K)
4. Соберите проект (⌘B)

## Проверка установки

После установки проверьте:

```bash
cd frontend/ios
ls -la Pods/Google-Mobile-Ads-SDK
```

Должна быть директория с framework файлами.

## Если проблема сохраняется

Проверьте, что в `Configs/Debug.xcconfig` и `Configs/Release.xcconfig` есть строка:

```
#include "../Pods/Target Support Files/Pods-Convertik/Pods-Convertik.debug.xcconfig"
```

Или для Release:
```
#include "../Pods/Target Support Files/Pods-Convertik/Pods-Convertik.release.xcconfig"
```



