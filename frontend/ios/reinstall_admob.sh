#!/bin/bash

# Скрипт для полной переустановки Google Mobile Ads SDK через CocoaPods

set -e

echo "🔧 Полная переустановка Google Mobile Ads SDK"
echo "=============================================="
echo ""

# Переходим в директорию проекта
cd "$(dirname "$0")"

# Шаг 1: Проверка Podfile
echo "📋 Шаг 1: Проверка Podfile..."
if ! grep -q "Google-Mobile-Ads-SDK" Podfile; then
    echo "❌ Ошибка: Google-Mobile-Ads-SDK не найден в Podfile!"
    exit 1
fi
echo "✅ Podfile содержит Google-Mobile-Ads-SDK"
echo ""

# Шаг 2: Деинтеграция CocoaPods
echo "🗑️  Шаг 2: Удаление текущей интеграции CocoaPods..."
if [ -d "Pods" ]; then
    pod deintegrate || echo "⚠️  pod deintegrate завершился с ошибкой, продолжаем..."
fi
echo "✅ Деинтеграция завершена"
echo ""

# Шаг 3: Очистка
echo "🧹 Шаг 3: Очистка кэша CocoaPods..."
rm -rf Pods
rm -rf ~/Library/Caches/CocoaPods
rm -f Podfile.lock
echo "✅ Очистка завершена"
echo ""

# Шаг 4: Установка CocoaPods
echo "📦 Шаг 4: Установка CocoaPods зависимостей..."
pod install --repo-update
echo "✅ Установка завершена"
echo ""

# Шаг 5: Проверка установки
echo "🔍 Шаг 5: Проверка установки..."
if [ -d "Pods/Google-Mobile-Ads-SDK" ]; then
    echo "✅ Google-Mobile-Ads-SDK найден в Pods/"
    
    # Проверяем наличие framework
    if [ -d "Pods/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework" ]; then
        echo "✅ GoogleMobileAdsFramework найден"
    else
        echo "⚠️  GoogleMobileAdsFramework не найден, но это может быть нормально для новой версии SDK"
    fi
else
    echo "❌ Ошибка: Google-Mobile-Ads-SDK не найден после установки!"
    exit 1
fi
echo ""

# Шаг 6: Проверка workspace
echo "📁 Шаг 6: Проверка workspace..."
if [ -f "Convertik.xcworkspace/contents.xcworkspacedata" ]; then
    if grep -q "Pods/Pods.xcodeproj" Convertik.xcworkspace/contents.xcworkspacedata; then
        echo "✅ Workspace правильно настроен с Pods"
    else
        echo "⚠️  Workspace не содержит ссылку на Pods, но это может быть нормально"
    fi
else
    echo "⚠️  Workspace файл не найден"
fi
echo ""

echo "✅ Переустановка завершена!"
echo ""
echo "📝 Следующие шаги:"
echo "1. Закройте Xcode (если открыт)"
echo "2. Откройте Convertik.xcworkspace (НЕ .xcodeproj!)"
echo "3. Product → Clean Build Folder (⇧⌘K)"
echo "4. Соберите проект (⌘B)"
echo ""



