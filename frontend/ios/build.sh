#!/bin/bash
# Универсальный скрипт сборки для Convertik
# Автоматически собирает Pods перед основной сборкой

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Параметры по умолчанию
CONFIGURATION="${1:-Debug}"
DESTINATION="${2:-generic/platform=iOS Simulator}"
SCHEME="${3:-Convertik}"

echo -e "${GREEN}🔧 Building Convertik${NC}"
echo "Configuration: $CONFIGURATION"
echo "Destination: $DESTINATION"
echo "Scheme: $SCHEME"
echo ""

# Проверка workspace
if [ ! -f "Convertik.xcworkspace/contents.xcworkspacedata" ]; then
    echo -e "${RED}❌ Error: Convertik.xcworkspace not found!${NC}"
    echo "Make sure you're in the frontend/ios directory"
    exit 1
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

