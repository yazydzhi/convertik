# Установка CocoaPods зависимостей

## Проблема
GoogleMobileAds не установлен (директория Pods удалена или не установлена).

## Решение

### Вариант 1: Через Xcode (РЕКОМЕНДУЕТСЯ)

1. Откройте `Convertik.xcworkspace` в Xcode
2. В Xcode: **File → Open** → выберите `Podfile`
3. Xcode предложит установить Pods - нажмите **"Install"**

### Вариант 2: Через терминал (если CocoaPods работает)

```bash
cd frontend/ios
pod install
```

### Вариант 3: Если CocoaPods не работает

Исправьте проблему с gem:

```bash
gem install ffi
cd frontend/ios
pod install
```

## После установки

1. Закройте Xcode
2. Откройте `Convertik.xcworkspace` (НЕ .xcodeproj!)
3. Product → Clean Build Folder (⇧⌘K)
4. Соберите проект (⌘B)

## Что уже сделано

✅ Добавлен `GADApplicationIdentifier` в `Info.plist` со значением для старой версии:
- `ca-app-pub-3963008621997262~3198843168`

Это значение будет использоваться для схемы Convertik-Old.



