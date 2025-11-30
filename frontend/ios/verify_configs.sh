#!/bin/bash

# Скрипт для проверки конфигураций деплоя

echo "🔍 Проверка конфигураций..."
echo ""

# Проверка наличия xcconfig файлов
echo "📁 Проверка xcconfig файлов:"
for file in "Configs/Debug.xcconfig" "Configs/DeployOld.xcconfig" "Configs/DeployNew.xcconfig"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file существует"
    else
        echo "  ❌ $file не найден"
    fi
done
echo ""

# Проверка схем
echo "📋 Проверка схем:"
if [ -f "Convertik.xcodeproj/xcshareddata/xcschemes/Convertik-Old.xcscheme" ]; then
    echo "  ✅ Convertik-Old.xcscheme существует"
else
    echo "  ❌ Convertik-Old.xcscheme не найден"
fi

if [ -f "Convertik.xcodeproj/xcshareddata/xcschemes/Convertik-New.xcscheme" ]; then
    echo "  ✅ Convertik-New.xcscheme существует"
else
    echo "  ❌ Convertik-New.xcscheme не найден"
fi
echo ""

# Проверка build configurations через xcodebuild
echo "⚙️  Проверка Build Configurations:"
xcodebuild -list -project Convertik.xcodeproj 2>/dev/null | grep -A 10 "Build Configurations:"
echo ""

# Проверка Bundle ID для разных конфигураций
echo "🆔 Проверка Bundle ID:"
echo "  DeployOld:"
xcodebuild -showBuildSettings -project Convertik.xcodeproj -scheme Convertik-Old -configuration DeployOld 2>/dev/null | grep "PRODUCT_BUNDLE_IDENTIFIER" | head -1

echo "  DeployNew:"
xcodebuild -showBuildSettings -project Convertik.xcodeproj -scheme Convertik-New -configuration DeployNew 2>/dev/null | grep "PRODUCT_BUNDLE_IDENTIFIER" | head -1

echo ""
echo "✅ Проверка завершена!"























































