#!/bin/bash
# Pre-Build Script для Xcode
# Автоматически собирает Pods перед основной сборкой
# Решает проблему "Unable to find module dependency: 'GoogleMobileAds'"

set -e

echo "🔧 [Pre-Build] Building Pods first..."

# Определяем конфигурацию и destination из переменных окружения Xcode
# Маппинг новых конфигураций на стандартные для Pods
RAW_CONFIGURATION="${CONFIGURATION:-Debug}"
case "$RAW_CONFIGURATION" in
    DebugOld|DebugNew)
        PODS_CONFIGURATION="Debug"
        ;;
    DeployOld|DeployNew)
        PODS_CONFIGURATION="Release"
        ;;
    *)
        PODS_CONFIGURATION="$RAW_CONFIGURATION"
        ;;
esac

# Определяем destination
if [[ "${PLATFORM_NAME:-iphonesimulator}" == *"simulator"* ]]; then
    BUILD_DESTINATION="generic/platform=iOS Simulator"
else
    BUILD_DESTINATION="generic/platform=iOS"
fi

# Путь к workspace
if [ -n "$SRCROOT" ]; then
    WORKSPACE_PATH="$SRCROOT/Convertik.xcworkspace"
else
    WORKSPACE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/Convertik.xcworkspace"
fi

# Проверяем наличие workspace
if [ ! -f "$WORKSPACE_PATH/contents.xcworkspacedata" ]; then
    echo "❌ Error: Workspace not found at $WORKSPACE_PATH"
    exit 1
fi

# Шаг 1: Собираем Google-Mobile-Ads-SDK явно
echo "📦 Building Google-Mobile-Ads-SDK for $PODS_CONFIGURATION..."
xcodebuild \
    -workspace "$WORKSPACE_PATH" \
    -scheme Google-Mobile-Ads-SDK \
    -configuration "$PODS_CONFIGURATION" \
    -destination "$BUILD_DESTINATION" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /dev/null 2>&1 || echo "⚠️  Google-Mobile-Ads-SDK build had warnings"

# Шаг 2: Собираем Pods-Convertik
echo "📦 Building Pods-Convertik for $PODS_CONFIGURATION..."
xcodebuild \
    -workspace "$WORKSPACE_PATH" \
    -scheme Pods-Convertik \
    -configuration "$PODS_CONFIGURATION" \
    -destination "$BUILD_DESTINATION" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /dev/null 2>&1 || echo "⚠️  Pods-Convertik build had warnings"

# Шаг 3: Создаем символические ссылки для нестандартных конфигураций
if [ "$RAW_CONFIGURATION" != "$PODS_CONFIGURATION" ]; then
    echo "🔗 Creating symlinks for $RAW_CONFIGURATION -> $PODS_CONFIGURATION..."
    
    # Получаем пути к build директориям
    BUILD_DIR=$(xcodebuild -showBuildSettings -workspace "$WORKSPACE_PATH" -scheme Convertik -configuration "$RAW_CONFIGURATION" -destination "$BUILD_DESTINATION" 2>/dev/null | grep "^[ ]*BUILD_DIR" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    PODS_BUILD_DIR=$(xcodebuild -showBuildSettings -workspace "$WORKSPACE_PATH" -scheme Pods-Convertik -configuration "$PODS_CONFIGURATION" -destination "$BUILD_DESTINATION" 2>/dev/null | grep "^[ ]*BUILD_DIR" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    
    if [ -n "$BUILD_DIR" ] && [ -n "$PODS_BUILD_DIR" ]; then
        # Определяем EFFECTIVE_PLATFORM_NAME
        if [[ "$BUILD_DESTINATION" == *"Simulator"* ]]; then
            EFFECTIVE_PLATFORM="-iphonesimulator"
        else
            EFFECTIVE_PLATFORM="-iphoneos"
        fi
        
        SOURCE_DIR="${PODS_BUILD_DIR}/${PODS_CONFIGURATION}${EFFECTIVE_PLATFORM}"
        TARGET_DIR="${BUILD_DIR}/${RAW_CONFIGURATION}${EFFECTIVE_PLATFORM}"
        
        # Создаем директорию назначения, если её нет
        mkdir -p "$TARGET_DIR"
        
        # Создаем символические ссылки
        if [ -d "${SOURCE_DIR}/Google-Mobile-Ads-SDK" ]; then
            if [ ! -e "${TARGET_DIR}/Google-Mobile-Ads-SDK" ]; then
                ln -sf "${SOURCE_DIR}/Google-Mobile-Ads-SDK" "${TARGET_DIR}/Google-Mobile-Ads-SDK"
                echo "  ✅ Created symlink: Google-Mobile-Ads-SDK"
            fi
        fi
        
        if [ -d "${SOURCE_DIR}/XCFrameworkIntermediates" ]; then
            if [ ! -e "${TARGET_DIR}/XCFrameworkIntermediates" ]; then
                ln -sf "${SOURCE_DIR}/XCFrameworkIntermediates" "${TARGET_DIR}/XCFrameworkIntermediates"
                echo "  ✅ Created symlink: XCFrameworkIntermediates"
            fi
        fi
    fi
fi

echo "✅ [Pre-Build] Pods are ready"

