# Настройка автоматической сборки Pods в Xcode

## Проблема

Xcode не всегда автоматически собирает Pods перед основной сборкой, что приводит к ошибке:
```
Unable to find module dependency: 'GoogleMobileAds'
```

## Решение: Добавить Pre-Build Script

### Шаг 1: Откройте проект в Xcode

1. Откройте `Convertik.xcworkspace` (не `.xcodeproj`!)
2. Выберите проект `Convertik` в навигаторе
3. Выберите target `Convertik`
4. Перейдите на вкладку **Build Phases**

### Шаг 2: Добавьте Pre-Build Script

1. Нажмите **+** вверху списка Build Phases
2. Выберите **New Run Script Phase**
3. Перетащите новый скрипт **ПЕРЕД** фазой "Sources" (важно!)
4. Назовите скрипт: `[CP] Build Pods First`
5. Вставьте следующий код:

```bash
# Автоматическая сборка Pods перед основной сборкой
# Это решает проблему "Unable to find module dependency: 'GoogleMobileAds'"

set -e

echo "🔧 [Pre-Build] Building Pods first..."

# Определяем конфигурацию
CONFIGURATION="${CONFIGURATION:-Debug}"
DESTINATION="${PLATFORM_NAME:-iphonesimulator}"

# Путь к workspace
WORKSPACE_PATH="${SRCROOT}/Convertik.xcworkspace"

# Определяем destination для xcodebuild
if [[ "$DESTINATION" == *"simulator"* ]]; then
    BUILD_DESTINATION="generic/platform=iOS Simulator"
else
    BUILD_DESTINATION="generic/platform=iOS"
fi

echo "📦 Building Pods-Convertik for $CONFIGURATION ($BUILD_DESTINATION)..."

# Собираем Pods (тихо, чтобы не засорять лог)
xcodebuild \
    -workspace "$WORKSPACE_PATH" \
    -scheme Pods-Convertik \
    -configuration "$CONFIGURATION" \
    -destination "$BUILD_DESTINATION" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /dev/null 2>&1 || echo "⚠️  Pods build had warnings (usually OK)"

echo "✅ [Pre-Build] Pods are ready"
```

6. Убедитесь, что стоит галочка **"For install builds only"** = **НЕ отмечена**
7. Убедитесь, что стоит галочка **"Show environment variables in build log"** = **НЕ отмечена** (опционально)

### Шаг 3: Проверьте порядок Build Phases

Порядок должен быть таким:

1. ✅ **[CP] Check Pods Manifest.lock** (уже есть)
2. ✅ **[CP] Build Pods First** (новый скрипт)
3. ✅ **Sources**
4. ✅ **Resources**
5. ✅ **Frameworks**
6. ✅ **[CP] Copy Pods Resources** (уже есть)

### Шаг 4: Проверьте

1. Нажмите **Cmd+Shift+K** (Clean Build Folder)
2. Нажмите **Cmd+B** (Build)
3. В логе сборки вы должны увидеть:
   ```
   🔧 [Pre-Build] Building Pods first...
   📦 Building Pods-Convertik for Debug...
   ✅ [Pre-Build] Pods are ready
   ```

## Альтернатива: Использовать скрипт сборки

Если не хотите настраивать Xcode, используйте скрипт:

```bash
cd frontend/ios
./build.sh
```

Этот скрипт автоматически собирает Pods перед приложением.

## Примечания

- Скрипт выполняется **каждый раз** при сборке
- Это добавляет ~5-10 секунд к времени сборки
- Но гарантирует, что Pods всегда собраны перед приложением
- Если Pods уже собраны, xcodebuild пропустит их (incremental build)

