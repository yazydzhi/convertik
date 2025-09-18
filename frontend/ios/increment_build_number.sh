#!/bin/bash

# Скрипт для автоматического увеличения номера сборки
# Используется в Build Phases проекта Xcode

# Определяем путь к проекту
if [ -n "$PROJECT_DIR" ]; then
    PROJECT_PATH="$PROJECT_DIR"
else
    PROJECT_PATH="$(dirname "$0")"
fi

INFO_PLIST="$PROJECT_PATH/Info.plist"
PROJECT_FILE="$PROJECT_PATH/Convertik.xcodeproj/project.pbxproj"

echo "Project path: $PROJECT_PATH"
echo "Info.plist path: $INFO_PLIST"
echo "Project file path: $PROJECT_FILE"

# Проверяем существование файлов
if [ ! -f "$INFO_PLIST" ]; then
    echo "Error: Info.plist not found at $INFO_PLIST"
    exit 1
fi

if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: project.pbxproj not found at $PROJECT_FILE"
    exit 1
fi

# Получаем текущий номер сборки из Info.plist
CURRENT_BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST")

if [ -z "$CURRENT_BUILD_NUMBER" ]; then
    echo "Error: Could not find CFBundleVersion in Info.plist"
    exit 1
fi

# Увеличиваем номер сборки на 1
NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))

echo "Current build number: $CURRENT_BUILD_NUMBER"
echo "New build number: $NEW_BUILD_NUMBER"

# Обновляем номер сборки в Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD_NUMBER" "$INFO_PLIST"

echo "Build number incremented from $CURRENT_BUILD_NUMBER to $NEW_BUILD_NUMBER"
