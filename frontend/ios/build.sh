#!/bin/bash
# Универсальный скрипт сборки для Convertik
# Автоматически собирает Pods перед основной сборкой
#
# Использование:
#   ./build.sh                                    # Интерактивное меню
#   ./build.sh [Debug|Release] [destination] [scheme] [--clean] [--open] [--increment-build]
#
# Опции:
#   --clean          Очистка кэша перед сборкой (закрывает Xcode если открыт)
#   --open           Открыть workspace в Xcode после успешной сборки
#   --increment-build Увеличить номер сборки перед сборкой
#
# Примеры:
#   ./build.sh                                    # Интерактивное меню для выбора всех параметров
#   ./build.sh Debug "generic/platform=iOS Simulator" Convertik
#   ./build.sh Debug "generic/platform=iOS Simulator" Convertik --clean
#   ./build.sh --clean --open  # Очистка, сборка и открытие workspace
#   ./build.sh --open  # Сборка и открытие workspace

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Парсим аргументы
CLEAN_CACHE=false
OPEN_WORKSPACE=false
INCREMENT_BUILD=false
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--clean" ]]; then
        CLEAN_CACHE=true
    elif [[ "$arg" == "--open" ]]; then
        OPEN_WORKSPACE=true
    elif [[ "$arg" == "--increment-build" ]]; then
        INCREMENT_BUILD=true
    else
        ARGS+=("$arg")
    fi
done

# Интерактивное меню, если запущено без параметров
if [ ${#ARGS[@]} -eq 0 ] && [ "$CLEAN_CACHE" = false ] && [ "$OPEN_WORKSPACE" = false ] && [ "$INCREMENT_BUILD" = false ]; then
    echo -e "${GREEN}🔧 Convertik Build Script${NC}"
    echo ""
    echo "Выберите конфигурацию:"
    echo "  1) DebugOld (старая версия, debug, Bundle ID: com.yazydzhi.convertik, версия: 2.4)"
    echo "  2) DebugNew (новая версия, debug, Bundle ID: com.azg.Convertik, версия: 2.5)"
    echo "  3) DeployOld (старая версия, продакшн, Bundle ID: com.yazydzhi.convertik, версия: 2.4)"
    echo "  4) DeployNew (новая версия, продакшн, Bundle ID: com.azg.Convertik, версия: 2.5)"
    echo ""
    read -p "Ваш выбор [1-4] (по умолчанию: 2): " config_choice
    config_choice=${config_choice:-2}
    
    case $config_choice in
        1) 
            CONFIGURATION="DebugOld"
            SCHEME="Convertik"
            ;;
        2) 
            CONFIGURATION="DebugNew"
            SCHEME="Convertik"
            ;;
        3) 
            CONFIGURATION="DeployOld"
            SCHEME="Convertik"
            ;;
        4) 
            CONFIGURATION="DeployNew"
            SCHEME="Convertik"
            ;;
        *) 
            CONFIGURATION="DebugNew"
            SCHEME="Convertik"
            ;;
    esac
    
    echo ""
    echo "Выберите destination:"
    echo "  1) iPhone 17 Pro Max Simulator (по умолчанию)"
    echo "  2) iPhone 16 Pro Simulator"
    echo "  3) iPhone 15 Pro Simulator"
    echo "  4) iPad Pro Simulator"
    echo "  5) iOS Simulator (generic)"
    echo "  6) Generic iOS Device"
    echo ""
    read -p "Ваш выбор [1-6] (по умолчанию: 1): " dest_choice
    dest_choice=${dest_choice:-1}
    
    case $dest_choice in
        1) DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro Max" ;;
        2) DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro" ;;
        3) DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro" ;;
        4) DESTINATION="platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)" ;;
        5) DESTINATION="generic/platform=iOS Simulator" ;;
        6) DESTINATION="generic/platform=iOS" ;;
        *) DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro Max" ;;
    esac
    
    echo ""
    echo "Дополнительные опции:"
    read -p "Очистить кэш перед сборкой? [y/N]: " clean_choice
    if [[ "$clean_choice" =~ ^[Yy]$ ]]; then
        CLEAN_CACHE=true
    fi
    
    read -p "Увеличить номер сборки? [y/N]: " increment_choice
    if [[ "$increment_choice" =~ ^[Yy]$ ]]; then
        INCREMENT_BUILD=true
    fi
    
    read -p "Открыть workspace после сборки? [y/N]: " open_choice
    if [[ "$open_choice" =~ ^[Yy]$ ]]; then
        OPEN_WORKSPACE=true
    fi
    
    echo ""
    echo -e "${BLUE}📋 Выбранные параметры:${NC}"
    echo "  Configuration: $CONFIGURATION"
    echo "  Destination: $DESTINATION"
    echo "  Scheme: $SCHEME"
    if [ "$CLEAN_CACHE" = true ]; then
        echo "  Clean cache: ENABLED"
    fi
    if [ "$INCREMENT_BUILD" = true ]; then
        echo "  Increment build: ENABLED"
    fi
    if [ "$OPEN_WORKSPACE" = true ]; then
        echo "  Open workspace: ENABLED"
    fi
    echo ""
    read -p "Продолжить? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Отменено."
        exit 0
    fi
    echo ""
else
    # Параметры по умолчанию (если переданы аргументы)
    CONFIGURATION="${ARGS[0]:-Debug}"
    DESTINATION="${ARGS[1]:-platform=iOS Simulator,name=iPhone 17 Pro Max}"
    SCHEME="${ARGS[2]:-Convertik}"
fi

# Функция для чтения версии и сборки из xcconfig или Info.plist
get_app_version() {
    local version=""
    local build=""
    
    # Сначала пробуем из xcconfig файлов (приоритет)
    local xcconfig_file=""
    case "$CONFIGURATION" in
        DebugOld) xcconfig_file="Configs/DebugOld.xcconfig" ;;
        DebugNew) xcconfig_file="Configs/DebugNew.xcconfig" ;;
        DeployOld) xcconfig_file="Configs/DeployOld.xcconfig" ;;
        DeployNew) xcconfig_file="Configs/DeployNew.xcconfig" ;;
        Release) xcconfig_file="Configs/Release.xcconfig" ;;
        Debug) xcconfig_file="Configs/Debug.xcconfig" ;;
    esac
    
    if [ -n "$xcconfig_file" ] && [ -f "$xcconfig_file" ]; then
        version=$(grep "^INFOPLIST_KEY_CFBundleShortVersionString" "$xcconfig_file" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
        build=$(grep "^INFOPLIST_KEY_CFBundleVersion" "$xcconfig_file" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    fi
    
    # Если не получилось из xcconfig, пробуем Info.plist
    if [ -z "$version" ] || [ -z "$build" ]; then
        local info_plist="Info.plist"
        if [ -f "$info_plist" ]; then
            if command -v plutil &> /dev/null; then
                version=$(plutil -extract CFBundleShortVersionString raw "$info_plist" 2>/dev/null || echo "")
                build=$(plutil -extract CFBundleVersion raw "$info_plist" 2>/dev/null || echo "")
            elif command -v defaults &> /dev/null; then
                version=$(defaults read "$SCRIPT_DIR/$info_plist" CFBundleShortVersionString 2>/dev/null || echo "")
                build=$(defaults read "$SCRIPT_DIR/$info_plist" CFBundleVersion 2>/dev/null || echo "")
            else
                version=$(grep -A 1 "CFBundleShortVersionString" "$info_plist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
                build=$(grep -A 1 "CFBundleVersion" "$info_plist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
            fi
        fi
    fi
    
    if [ -z "$version" ]; then version="Unknown"; fi
    if [ -z "$build" ]; then build="Unknown"; fi
    echo "${version} (${build})"
}

# Функция для получения bundle ID из xcconfig или build settings
get_bundle_id() {
    local bundle_id=""
    
    # Сначала пробуем из xcconfig файлов (более надежно)
    if [ "$CONFIGURATION" = "DebugOld" ] && [ -f "Configs/DebugOld.xcconfig" ]; then
        bundle_id=$(grep "^PRODUCT_BUNDLE_IDENTIFIER" Configs/DebugOld.xcconfig | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    elif [ "$CONFIGURATION" = "DebugNew" ] && [ -f "Configs/DebugNew.xcconfig" ]; then
        bundle_id=$(grep "^PRODUCT_BUNDLE_IDENTIFIER" Configs/DebugNew.xcconfig | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    elif [ "$CONFIGURATION" = "DeployOld" ] && [ -f "Configs/DeployOld.xcconfig" ]; then
        bundle_id=$(grep "^PRODUCT_BUNDLE_IDENTIFIER" Configs/DeployOld.xcconfig | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    elif [ "$CONFIGURATION" = "DeployNew" ] && [ -f "Configs/DeployNew.xcconfig" ]; then
        bundle_id=$(grep "^PRODUCT_BUNDLE_IDENTIFIER" Configs/DeployNew.xcconfig | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    elif [ "$CONFIGURATION" = "Release" ] && [ -f "Configs/Release.xcconfig" ]; then
        bundle_id=$(grep "^PRODUCT_BUNDLE_IDENTIFIER" Configs/Release.xcconfig | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    elif [ "$CONFIGURATION" = "Debug" ] && [ -f "Configs/Debug.xcconfig" ]; then
        bundle_id=$(grep "^PRODUCT_BUNDLE_IDENTIFIER" Configs/Debug.xcconfig | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    fi
    
    # Проверяем, что bundle_id валидный (не пустой, не "NO", не содержит переменную)
    if [ -z "$bundle_id" ] || [ "$bundle_id" = "NO" ] || echo "$bundle_id" | grep -q '\$('; then
        # Если не получилось из xcconfig, пробуем из build settings
        bundle_id=$(xcodebuild -showBuildSettings \
            -workspace Convertik.xcworkspace \
            -scheme "$SCHEME" \
            -configuration "$CONFIGURATION" \
            2>/dev/null | grep "^[ ]*PRODUCT_BUNDLE_IDENTIFIER" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    fi
    
    # Финальная проверка
    if [ -z "$bundle_id" ] || [ "$bundle_id" = "NO" ] || echo "$bundle_id" | grep -q '\$('; then
        echo "Unknown"
    else
        echo "$bundle_id"
    fi
}

# Функция для увеличения номера сборки
increment_build_number() {
    local info_plist="Info.plist"
    local project_yml="project.yml"
    local test_info_plist="ConvertikTests/Info.plist"
    
    # Определяем xcconfig файл для текущей конфигурации
    local xcconfig_file=""
    case "$CONFIGURATION" in
        DebugOld) xcconfig_file="Configs/DebugOld.xcconfig" ;;
        DebugNew) xcconfig_file="Configs/DebugNew.xcconfig" ;;
        DeployOld) xcconfig_file="Configs/DeployOld.xcconfig" ;;
        DeployNew) xcconfig_file="Configs/DeployNew.xcconfig" ;;
        Release) xcconfig_file="Configs/Release.xcconfig" ;;
        Debug) xcconfig_file="Configs/Debug.xcconfig" ;;
    esac
    
    # Получаем текущий номер сборки из xcconfig (приоритет) или Info.plist
    local current_build=""
    if [ -n "$xcconfig_file" ] && [ -f "$xcconfig_file" ]; then
        current_build=$(grep "^INFOPLIST_KEY_CFBundleVersion" "$xcconfig_file" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    fi
    
    # Если не получилось из xcconfig, пробуем Info.plist
    if [ -z "$current_build" ]; then
        if command -v plutil &> /dev/null; then
            current_build=$(plutil -extract CFBundleVersion raw "$info_plist" 2>/dev/null || echo "")
        elif command -v defaults &> /dev/null; then
            current_build=$(defaults read "$SCRIPT_DIR/$info_plist" CFBundleVersion 2>/dev/null || echo "")
        else
            current_build=$(grep -A 1 "CFBundleVersion" "$info_plist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -1)
        fi
    fi
    
    if [ -z "$current_build" ]; then
        echo -e "${RED}❌ Error: Could not read current build number${NC}"
        return 1
    fi
    
    # Увеличиваем номер сборки
    local new_build=$((current_build + 1))
    
    echo -e "${YELLOW}📈 Incrementing build number for $CONFIGURATION: ${current_build} → ${new_build}${NC}"
    
    # Обновляем xcconfig файл (приоритет)
    if [ -n "$xcconfig_file" ] && [ -f "$xcconfig_file" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^INFOPLIST_KEY_CFBundleVersion = .*/INFOPLIST_KEY_CFBundleVersion = ${new_build}/" "$xcconfig_file"
        else
            sed -i "s/^INFOPLIST_KEY_CFBundleVersion = .*/INFOPLIST_KEY_CFBundleVersion = ${new_build}/" "$xcconfig_file"
        fi
        echo -e "${GREEN}✅ Updated build number in $xcconfig_file${NC}"
    fi
    
    # Также обновляем Info.plist (для совместимости)
    if command -v plutil &> /dev/null; then
        plutil -replace CFBundleVersion -string "$new_build" "$info_plist" 2>/dev/null || {
            # Fallback: используем sed для XML
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$info_plist"
            else
                sed -i "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$info_plist"
            fi
        }
    else
        # Используем sed для обновления
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$info_plist"
        else
            sed -i "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$info_plist"
        fi
    fi
    
    # Обновляем project.yml
    if [ -f "$project_yml" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/CFBundleVersion: \"[0-9]*\"/CFBundleVersion: \"${new_build}\"/" "$project_yml"
        else
            sed -i "s/CFBundleVersion: \"[0-9]*\"/CFBundleVersion: \"${new_build}\"/" "$project_yml"
        fi
    fi
    
    # Обновляем ConvertikTests/Info.plist
    if [ -f "$test_info_plist" ]; then
        if command -v plutil &> /dev/null; then
            plutil -replace CFBundleVersion -string "$new_build" "$test_info_plist" 2>/dev/null || {
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$test_info_plist"
                else
                    sed -i "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$test_info_plist"
                fi
            }
        else
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$test_info_plist"
            else
                sed -i "/<key>CFBundleVersion<\/key>/,/<\/string>/s/<string>[^<]*<\/string>/<string>${new_build}<\/string>/" "$test_info_plist"
            fi
        fi
    fi
    
    echo -e "${GREEN}✅ Build number incremented to ${new_build}${NC}"
    echo ""
}

# Получаем версию, сборку и bundle ID
APP_VERSION=$(get_app_version)
BUNDLE_ID=$(get_bundle_id)

# Увеличиваем номер сборки, если запрошено
if [ "$INCREMENT_BUILD" = true ]; then
    increment_build_number
    # Обновляем версию после увеличения
    APP_VERSION=$(get_app_version)
fi

echo -e "${GREEN}🔧 Building Convertik${NC}"
echo -e "${BLUE}📱 App Version: ${APP_VERSION}${NC}"
echo -e "${BLUE}🆔 Bundle ID: ${BUNDLE_ID}${NC}"
echo "Configuration: $CONFIGURATION"
echo "Destination: $DESTINATION"
echo "Scheme: $SCHEME"
if [ "$CLEAN_CACHE" = true ]; then
    echo -e "${BLUE}🧹 Clean cache: ENABLED${NC}"
fi
if [ "$INCREMENT_BUILD" = true ]; then
    echo -e "${BLUE}📈 Increment build: ENABLED${NC}"
fi
echo ""

# Проверка workspace
if [ ! -f "Convertik.xcworkspace/contents.xcworkspacedata" ]; then
    echo -e "${RED}❌ Error: Convertik.xcworkspace not found!${NC}"
    echo "Make sure you're in the frontend/ios directory"
    exit 1
fi

# Закрытие Xcode (если открыт и запрошена очистка или открытие workspace)
if [ "$CLEAN_CACHE" = true ] || [ "$OPEN_WORKSPACE" = true ]; then
    if pgrep -x "Xcode" > /dev/null; then
        echo -e "${YELLOW}🔒 Closing Xcode...${NC}"
        killall Xcode 2>/dev/null || true
        # Ждем закрытия Xcode
        sleep 2
        echo -e "${GREEN}✅ Xcode closed${NC}"
    fi
fi

# Очистка кэша (если запрошено)
if [ "$CLEAN_CACHE" = true ]; then
    echo -e "${YELLOW}🧹 Step 0: Cleaning build cache...${NC}"
    
    # Очистка DerivedData для этого проекта
    DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
    if [ -d "$DERIVED_DATA_PATH" ]; then
        # Находим и удаляем DerivedData для Convertik
        find "$DERIVED_DATA_PATH" -maxdepth 1 -type d -name "*Convertik*" -exec rm -rf {} + 2>/dev/null || true
        echo -e "${GREEN}✅ Cleaned DerivedData for Convertik${NC}"
    fi
    
    # Очистка модулей Swift (Swift Module Cache)
    SWIFT_CACHE_PATH="$HOME/Library/Developer/Xcode/DerivedData/ModuleCache.noindex"
    if [ -d "$SWIFT_CACHE_PATH" ]; then
        rm -rf "$SWIFT_CACHE_PATH"/* 2>/dev/null || true
        echo -e "${GREEN}✅ Cleaned Swift module cache${NC}"
    fi
    
    # Clean build folder через xcodebuild
    echo -e "${BLUE}🧹 Cleaning build folder...${NC}"
    xcodebuild \
        -workspace Convertik.xcworkspace \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        clean \
        > /dev/null 2>&1 || true
    
    xcodebuild \
        -workspace Convertik.xcworkspace \
        -scheme Pods-Convertik \
        -configuration "$CONFIGURATION" \
        clean \
        > /dev/null 2>&1 || true
    
    echo -e "${GREEN}✅ Build folder cleaned${NC}"
    echo ""
fi

# Шаг 1: Сборка Pods
echo -e "${YELLOW}📦 Step 1: Building Pods...${NC}"

# Определяем конфигурацию для Pods (маппинг новых конфигураций на стандартные)
PODS_CONFIGURATION="$CONFIGURATION"
case "$CONFIGURATION" in
    DebugOld|DebugNew)
        PODS_CONFIGURATION="Debug"
        ;;
    DeployOld|DeployNew)
        PODS_CONFIGURATION="Release"
        ;;
esac

# Сначала собираем Google-Mobile-Ads-SDK явно
echo "  Building Google-Mobile-Ads-SDK..."
if xcodebuild \
    -workspace Convertik.xcworkspace \
    -scheme Google-Mobile-Ads-SDK \
    -configuration "$PODS_CONFIGURATION" \
    -destination "$DESTINATION" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /tmp/admob_build.log 2>&1; then
    echo -e "${GREEN}  ✅ Google-Mobile-Ads-SDK built${NC}"
else
    echo -e "${YELLOW}  ⚠️  Google-Mobile-Ads-SDK build had warnings${NC}"
fi

# Затем собираем Pods-Convertik
echo "  Building Pods-Convertik..."
if xcodebuild \
    -workspace Convertik.xcworkspace \
    -scheme Pods-Convertik \
    -configuration "$PODS_CONFIGURATION" \
    -destination "$DESTINATION" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    > /tmp/pods_build.log 2>&1; then
    echo -e "${GREEN}✅ Pods built successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Pods build had warnings (checking if it's OK)...${NC}"
    # Проверяем, есть ли критичные ошибки
    if grep -q "error:" /tmp/pods_build.log; then
        echo -e "${RED}❌ Pods build failed!${NC}"
        echo "Last 20 lines of build log:"
        tail -20 /tmp/pods_build.log
        exit 1
    fi
    echo -e "${GREEN}✅ Pods build completed (warnings are OK)${NC}"
fi

# Шаг 1.5: Создаем символические ссылки на Pods фреймворки для нестандартных конфигураций
# Это необходимо, потому что Swift компилятор ищет модули в конфигурации-специфичных путях
if [ "$CONFIGURATION" != "$PODS_CONFIGURATION" ]; then
    echo -e "${YELLOW}🔗 Step 1.5: Creating symlinks for Pods frameworks...${NC}"
    
    # Определяем пути к Release/Debug и DeployOld/DeployNew/DebugOld/DebugNew фреймворкам
    BUILD_DIR=$(xcodebuild -showBuildSettings -workspace Convertik.xcworkspace -scheme Convertik -configuration "$CONFIGURATION" -destination "$DESTINATION" 2>/dev/null | grep "^[ ]*BUILD_DIR" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    PODS_BUILD_DIR=$(xcodebuild -showBuildSettings -workspace Convertik.xcworkspace -scheme Pods-Convertik -configuration "$PODS_CONFIGURATION" -destination "$DESTINATION" 2>/dev/null | grep "^[ ]*BUILD_DIR" | head -1 | sed 's/.*= *//' | tr -d ' ' | tr -d '\t')
    
    if [ -n "$BUILD_DIR" ] && [ -n "$PODS_BUILD_DIR" ]; then
        # Определяем EFFECTIVE_PLATFORM_NAME
        if [[ "$DESTINATION" == *"Simulator"* ]]; then
            EFFECTIVE_PLATFORM="-iphonesimulator"
        else
            EFFECTIVE_PLATFORM="-iphoneos"
        fi
        
        SOURCE_DIR="${PODS_BUILD_DIR}/${PODS_CONFIGURATION}${EFFECTIVE_PLATFORM}"
        TARGET_DIR="${BUILD_DIR}/${CONFIGURATION}${EFFECTIVE_PLATFORM}"
        
        # Создаем директорию назначения, если её нет
        mkdir -p "$TARGET_DIR"
        
        # Создаем символические ссылки на Google-Mobile-Ads-SDK и XCFrameworkIntermediates
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
        
        echo -e "${GREEN}✅ Symlinks created${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not determine BUILD_DIR, skipping symlinks${NC}"
    fi
fi
echo ""

# Шаг 2: Сборка приложения
echo -e "${YELLOW}📱 Step 2: Building $SCHEME...${NC}"
if xcodebuild \
    -workspace Convertik.xcworkspace \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    build \
    > /tmp/app_build.log 2>&1; then
    echo -e "${GREEN}✅ Build SUCCEEDED!${NC}"
    echo ""
    
    # Открытие workspace после успешной сборки (если запрошено)
    if [ "$OPEN_WORKSPACE" = true ]; then
        echo -e "${BLUE}🚀 Opening workspace in Xcode...${NC}"
        open Convertik.xcworkspace
        echo -e "${GREEN}✅ Workspace opened${NC}"
    fi
    
    exit 0
else
    echo -e "${RED}❌ Build FAILED!${NC}"
    echo ""
    echo "Errors:"
    grep -E "(error:|BUILD FAILED)" /tmp/app_build.log | head -20
    echo ""
    echo "Full log saved to: /tmp/app_build.log"
    exit 1
fi

