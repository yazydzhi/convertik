#!/bin/bash

# Скрипт для проверки AdMob конфигурации

echo "🔍 Проверка AdMob конфигурации для схемы Convertik-Old..."
echo ""

SCHEME="Convertik-Old"
CONFIG="DeployOld"

echo "📋 Проверка build settings:"
echo ""

# Проверка ADMOB_APP_ID
echo "1. ADMOB_APP_ID:"
xcodebuild -showBuildSettings -workspace Convertik.xcworkspace -scheme "$SCHEME" -configuration "$CONFIG" 2>/dev/null | grep "ADMOB_APP_ID" || echo "   ❌ Не найдено"

echo ""

# Проверка PRODUCT_BUNDLE_IDENTIFIER
echo "2. PRODUCT_BUNDLE_IDENTIFIER:"
xcodebuild -showBuildSettings -workspace Convertik.xcworkspace -scheme "$SCHEME" -configuration "$CONFIG" 2>/dev/null | grep "PRODUCT_BUNDLE_IDENTIFIER" | head -1

echo ""

# Проверка значений из xcconfig
echo "3. Значения из DeployOld.xcconfig:"
echo "   ADMOB_APP_ID должен быть: ca-app-pub-3963008621997262~3198843168"
echo "   PRODUCT_BUNDLE_IDENTIFIER должен быть: com.yazydzhi.convertik"

echo ""
echo "✅ Проверка завершена!"



