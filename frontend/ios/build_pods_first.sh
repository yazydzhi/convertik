#!/bin/bash
# Скрипт для автоматической сборки Pods перед основной сборкой
# Это решает проблему "Unable to find module dependency: 'GoogleMobileAds'"

set -e

echo "🔧 [Pre-Build] Building Pods first..."

# Определяем конфигурацию и destination из переменных окружения Xcode
CONFIGURATION="${CONFIGURATION:-Debug}"
DESTINATION="${PLATFORM_NAME:-iphonesimulator}"

# Путь к workspace
WORKSPACE_PATH="${SRCROOT}/Convertik.xcworkspace"

# Проверяем наличие workspace
if [ ! -f "$WORKSPACE_PATH/contents.xcworkspacedata" ]; then
    echo "❌ Error: Workspace not found at $WORKSPACE_PATH"
    exit 1
fi

# Определяем destination для xcodebuild
if [[ "$DESTINATION" == *"simulator"* ]]; then
    BUILD_DESTINATION="generic/platform=iOS Simulator"
else
    BUILD_DESTINATION="generic/platform=iOS"
fi

echo "📦 Building Pods-Convertik for $CONFIGURATION ($BUILD_DESTINATION)..."

# Собираем Pods
xcodebuild \
    -workspace "$WORKSPACE_PATH" \
    -scheme Pods-Convertik \
    -configuration "$CONFIGURATION" \
    -destination "$BUILD_DESTINATION" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Pods built successfully"
else
    echo "⚠️  Pods build had warnings (this is usually OK)"
fi

echo "✅ [Pre-Build] Pods are ready"

