# Решение проблемы "Unable to find module dependency: 'GoogleMobileAds'"

## Проблема

Xcode иногда не может найти модуль `GoogleMobileAds` при сборке, даже если Pods установлены. Это происходит потому что:

1. **Порядок сборки**: Pods должны быть собраны **перед** основной сборкой приложения
2. **Индексация Xcode**: Xcode может потерять индексацию модулей после очистки кэша
3. **DerivedData**: Старые артефакты сборки могут конфликтовать

## Автоматическое решение

### Вариант 1: Использовать скрипт сборки (рекомендуется)

```bash
cd frontend/ios
./build.sh
```

Этот скрипт автоматически:
1. Собирает Pods
2. Собирает приложение
3. Обрабатывает ошибки

### Вариант 2: Ручная сборка

Если нужно собрать вручную:

```bash
cd frontend/ios

# Шаг 1: Собрать Pods
xcodebuild -workspace Convertik.xcworkspace \
    -scheme Pods-Convertik \
    -configuration Debug \
    -destination 'generic/platform=iOS Simulator' \
    build

# Шаг 2: Собрать приложение
xcodebuild -workspace Convertik.xcworkspace \
    -scheme Convertik \
    -configuration Debug \
    -destination 'generic/platform=iOS Simulator' \
    build
```

### Вариант 3: В Xcode

1. Откройте `Convertik.xcworkspace` (не `.xcodeproj`!)
2. Выберите схему `Pods-Convertik`
3. Нажмите **Cmd+B** (собрать)
4. Выберите схему `Convertik`
5. Нажмите **Cmd+B** (собрать)

## Если проблема повторяется

### 1. Очистить кэш

```bash
cd frontend/ios
rm -rf ~/Library/Developer/Xcode/DerivedData/Convertik-*
pod install
```

### 2. Переустановить Pods

```bash
cd frontend/ios
pod deintegrate
pod install
```

### 3. Очистить индексацию Xcode

```bash
# Закрыть Xcode
osascript -e 'quit app "Xcode"'

# Удалить кэш индексации
rm -rf ~/Library/Developer/Xcode/DerivedData/Convertik-*
rm -rf Convertik.xcworkspace/xcuserdata
rm -rf Convertik.xcodeproj/xcuserdata

# Открыть заново
open Convertik.xcworkspace
```

## Проверка

После сборки проверьте, что модуль доступен:

```bash
# Проверить наличие фреймворка
ls -la Pods/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework/
```

## Примечания

- **Всегда используйте `.xcworkspace`**, а не `.xcodeproj`
- **Сначала собирайте Pods**, потом приложение
- Если используете Xcode, подождите завершения индексации (смотрите статус-бар)

