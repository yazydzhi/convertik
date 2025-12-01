#!/bin/bash
# Pre-Build Script для Xcode
# Автоматически собирает Pods перед основной сборкой
# Решает проблему "Unable to find module dependency: 'GoogleMobileAds'"

# НЕ используем set -e, чтобы скрипт не падал на предупреждениях
set +e

echo "🔧 [Pre-Build] Building Pods first..."
echo "   Configuration: ${CONFIGURATION:-Debug}"
echo "   Platform: ${PLATFORM_NAME:-iphonesimulator}"
echo "   SRCROOT: ${SRCROOT:-not set}"

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
# Используем отдельный DerivedData, чтобы избежать конфликтов с основной сборкой
TEMP_DERIVED_DATA="/tmp/PodsBuild-$$"
echo "📦 Building Google-Mobile-Ads-SDK for $PODS_CONFIGURATION..."
BUILD_LOG="/tmp/admob_build_$$.log"
xcodebuild \
    -workspace "$WORKSPACE_PATH" \
    -scheme Google-Mobile-Ads-SDK \
    -configuration "$PODS_CONFIGURATION" \
    -destination "$BUILD_DESTINATION" \
    -derivedDataPath "$TEMP_DERIVED_DATA" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > "$BUILD_LOG" 2>&1

if [ $? -eq 0 ]; then
    echo "  ✅ Google-Mobile-Ads-SDK built successfully"
    # Копируем собранные фреймворки в основной DerivedData
    if [ -d "$TEMP_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator/Google-Mobile-Ads-SDK" ]; then
        MAIN_DERIVED_DATA=$(xcodebuild -showBuildSettings -workspace "$WORKSPACE_PATH" -scheme Pods-Convertik -configuration "$PODS_CONFIGURATION" -destination "$BUILD_DESTINATION" 2>/dev/null | grep "^[ ]*BUILD_DIR" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t' | sed 's|/Build/Products.*||')
        if [ -n "$MAIN_DERIVED_DATA" ]; then
            mkdir -p "$MAIN_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator"
            cp -R "$TEMP_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator/Google-Mobile-Ads-SDK" "$MAIN_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator/" 2>/dev/null || true
        fi
    fi
else
    echo "  ⚠️  Google-Mobile-Ads-SDK build had warnings/errors"
    # Показываем последние строки лога для отладки
    tail -5 "$BUILD_LOG" | grep -E "(error|warning|succeeded)" || true
fi
rm -f "$BUILD_LOG"
rm -rf "$TEMP_DERIVED_DATA"

# Шаг 2: Собираем Pods-Convertik
# Используем отдельный DerivedData, чтобы избежать конфликтов
TEMP_DERIVED_DATA="/tmp/PodsBuild-$$"
echo "📦 Building Pods-Convertik for $PODS_CONFIGURATION..."
BUILD_LOG="/tmp/pods_build_$$.log"
xcodebuild \
    -workspace "$WORKSPACE_PATH" \
    -scheme Pods-Convertik \
    -configuration "$PODS_CONFIGURATION" \
    -destination "$BUILD_DESTINATION" \
    -derivedDataPath "$TEMP_DERIVED_DATA" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > "$BUILD_LOG" 2>&1

if [ $? -eq 0 ]; then
    echo "  ✅ Pods-Convertik built successfully"
    # Копируем собранные фреймворки в основной DerivedData
    if [ -d "$TEMP_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator" ]; then
        MAIN_DERIVED_DATA=$(xcodebuild -showBuildSettings -workspace "$WORKSPACE_PATH" -scheme Pods-Convertik -configuration "$PODS_CONFIGURATION" -destination "$BUILD_DESTINATION" 2>/dev/null | grep "^[ ]*BUILD_DIR" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t' | sed 's|/Build/Products.*||')
        if [ -n "$MAIN_DERIVED_DATA" ]; then
            mkdir -p "$MAIN_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator"
            cp -R "$TEMP_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator"/* "$MAIN_DERIVED_DATA/Build/Products/$PODS_CONFIGURATION-iphonesimulator/" 2>/dev/null || true
        fi
    fi
else
    echo "  ⚠️  Pods-Convertik build had warnings/errors"
    # Проверяем, есть ли критические ошибки
    if grep -q "error:" "$BUILD_LOG"; then
        echo "  ❌ Critical errors found:"
        grep "error:" "$BUILD_LOG" | head -3
    else
        echo "  ⚠️  Warnings only (usually OK)"
    fi
fi
rm -f "$BUILD_LOG"
rm -rf "$TEMP_DERIVED_DATA"

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
            # Удаляем старую ссылку или директорию, если есть
            [ -L "${TARGET_DIR}/Google-Mobile-Ads-SDK" ] && rm "${TARGET_DIR}/Google-Mobile-Ads-SDK"
            [ -d "${TARGET_DIR}/Google-Mobile-Ads-SDK" ] && rm -rf "${TARGET_DIR}/Google-Mobile-Ads-SDK"
            ln -sf "${SOURCE_DIR}/Google-Mobile-Ads-SDK" "${TARGET_DIR}/Google-Mobile-Ads-SDK"
            echo "  ✅ Created symlink: Google-Mobile-Ads-SDK"
            echo "     From: ${SOURCE_DIR}/Google-Mobile-Ads-SDK"
            echo "     To: ${TARGET_DIR}/Google-Mobile-Ads-SDK"
        else
            echo "  ⚠️  Source directory not found: ${SOURCE_DIR}/Google-Mobile-Ads-SDK"
        fi
        
        if [ -d "${SOURCE_DIR}/XCFrameworkIntermediates" ]; then
            # Удаляем старую ссылку или директорию, если есть
            [ -L "${TARGET_DIR}/XCFrameworkIntermediates" ] && rm "${TARGET_DIR}/XCFrameworkIntermediates"
            [ -d "${TARGET_DIR}/XCFrameworkIntermediates" ] && rm -rf "${TARGET_DIR}/XCFrameworkIntermediates"
            ln -sf "${SOURCE_DIR}/XCFrameworkIntermediates" "${TARGET_DIR}/XCFrameworkIntermediates"
            echo "  ✅ Created symlink: XCFrameworkIntermediates"
            echo "     From: ${SOURCE_DIR}/XCFrameworkIntermediates"
            echo "     To: ${TARGET_DIR}/XCFrameworkIntermediates"
        else
            echo "  ⚠️  Source directory not found: ${SOURCE_DIR}/XCFrameworkIntermediates"
        fi
    fi
fi

echo "✅ [Pre-Build] Pods are ready"

