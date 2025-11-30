#!/bin/bash
# Универсальный скрипт сборки для Convertik
# Автоматически собирает Pods перед основной сборкой
#
# Использование:
#   ./build.sh [Debug|Release] [destination] [scheme] [--clean]
#
# Примеры:
#   ./build.sh Debug "generic/platform=iOS Simulator" Convertik
#   ./build.sh Debug "generic/platform=iOS Simulator" Convertik --clean
#   ./build.sh --clean  # Очистка кэша и сборка с параметрами по умолчанию

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
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--clean" ]]; then
        CLEAN_CACHE=true
    else
        ARGS+=("$arg")
    fi
done

# Параметры по умолчанию
CONFIGURATION="${ARGS[0]:-Debug}"
DESTINATION="${ARGS[1]:-generic/platform=iOS Simulator}"
SCHEME="${ARGS[2]:-Convertik}"

echo -e "${GREEN}🔧 Building Convertik${NC}"
echo "Configuration: $CONFIGURATION"
echo "Destination: $DESTINATION"
echo "Scheme: $SCHEME"
if [ "$CLEAN_CACHE" = true ]; then
    echo -e "${BLUE}🧹 Clean cache: ENABLED${NC}"
fi
echo ""

# Проверка workspace
if [ ! -f "Convertik.xcworkspace/contents.xcworkspacedata" ]; then
    echo -e "${RED}❌ Error: Convertik.xcworkspace not found!${NC}"
    echo "Make sure you're in the frontend/ios directory"
    exit 1
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
if xcodebuild \
    -workspace Convertik.xcworkspace \
    -scheme Pods-Convertik \
    -configuration "$CONFIGURATION" \
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

