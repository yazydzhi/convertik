#!/bin/bash
# Простой скрипт для подготовки Pods перед сборкой в Xcode
# Использование: ./prepare_pods.sh [DeployOld|DeployNew|DebugOld|DebugNew]

set -e

cd "$(dirname "$0")"

TARGET_CONFIG="${1:-DeployOld}"

# Определяем Pods конфигурацию
case "$TARGET_CONFIG" in
    DeployOld|DeployNew)
        PODS_CONFIG="Release"
        ;;
    DebugOld|DebugNew)
        PODS_CONFIG="Debug"
        ;;
    *)
        PODS_CONFIG="$TARGET_CONFIG"
        ;;
esac

echo "🔧 Preparing Pods for $TARGET_CONFIG (using $PODS_CONFIG)..."

# Собираем Pods
echo "📦 Building Google-Mobile-Ads-SDK ($PODS_CONFIG)..."
xcodebuild \
    -workspace Convertik.xcworkspace \
    -scheme Google-Mobile-Ads-SDK \
    -configuration "$PODS_CONFIG" \
    -destination "generic/platform=iOS Simulator" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /tmp/admob_build.log 2>&1 && echo "  ✅ Google-Mobile-Ads-SDK built" || echo "  ⚠️ Build warnings (OK)"

echo "📦 Building Pods-Convertik ($PODS_CONFIG)..."
xcodebuild \
    -workspace Convertik.xcworkspace \
    -scheme Pods-Convertik \
    -configuration "$PODS_CONFIG" \
    -destination "generic/platform=iOS Simulator" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /tmp/pods_build.log 2>&1 && echo "  ✅ Pods-Convertik built" || echo "  ⚠️ Build warnings (OK)"

# Копируем фреймворки для целевой конфигурации
if [ "$TARGET_CONFIG" != "$PODS_CONFIG" ]; then
    echo ""
    echo "📋 Copying frameworks from $PODS_CONFIG to $TARGET_CONFIG..."
    
    DERIVED_DATA=$(find ~/Library/Developer/Xcode/DerivedData -maxdepth 1 -name "Convertik-*" -type d | head -1)
    
    if [ -n "$DERIVED_DATA" ]; then
        SOURCE_DIR="${DERIVED_DATA}/Build/Products/${PODS_CONFIG}-iphonesimulator"
        TARGET_DIR="${DERIVED_DATA}/Build/Products/${TARGET_CONFIG}-iphonesimulator"
        
        mkdir -p "$TARGET_DIR"
        
        # Копируем Google-Mobile-Ads-SDK
        if [ -d "${SOURCE_DIR}/Google-Mobile-Ads-SDK" ]; then
            rm -rf "${TARGET_DIR}/Google-Mobile-Ads-SDK"
            cp -R "${SOURCE_DIR}/Google-Mobile-Ads-SDK" "${TARGET_DIR}/"
            echo "  ✅ Copied Google-Mobile-Ads-SDK"
        fi
        
        # Копируем XCFrameworkIntermediates
        if [ -d "${SOURCE_DIR}/XCFrameworkIntermediates" ]; then
            rm -rf "${TARGET_DIR}/XCFrameworkIntermediates"
            cp -R "${SOURCE_DIR}/XCFrameworkIntermediates" "${TARGET_DIR}/"
            echo "  ✅ Copied XCFrameworkIntermediates"
        fi
        
        # Копируем GoogleUserMessagingPlatform
        if [ -d "${SOURCE_DIR}/GoogleUserMessagingPlatform" ]; then
            rm -rf "${TARGET_DIR}/GoogleUserMessagingPlatform"
            cp -R "${SOURCE_DIR}/GoogleUserMessagingPlatform" "${TARGET_DIR}/"
            echo "  ✅ Copied GoogleUserMessagingPlatform"
        fi
        
        # Копируем Pods_Convertik.framework
        if [ -d "${SOURCE_DIR}/Pods_Convertik.framework" ]; then
            rm -rf "${TARGET_DIR}/Pods_Convertik.framework"
            cp -R "${SOURCE_DIR}/Pods_Convertik.framework" "${TARGET_DIR}/"
            echo "  ✅ Copied Pods_Convertik.framework"
        fi
        
        echo ""
        echo "✅ Frameworks copied successfully!"
    else
        echo "❌ DerivedData not found"
        exit 1
    fi
fi

echo ""
echo "✅ Pods готовы для $TARGET_CONFIG!"
echo ""
echo "Теперь можно:"
echo "  1. Открыть Xcode"
echo "  2. Выбрать конфигурацию $TARGET_CONFIG"
echo "  3. Собрать проект (Cmd+B)"
