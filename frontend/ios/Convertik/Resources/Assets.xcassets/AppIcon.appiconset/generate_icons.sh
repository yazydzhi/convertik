#!/bin/bash

# Скрипт для генерации всех размеров иконок iOS из SVG
# Использует новую версию логотипа с большим долларом и кругом

SVG_FILE="icon_fixed.svg"

# Размеры иконок для iOS (в пикселях)
declare -a sizes=(
    "40"   # 20x20@2x
    "60"   # 20x20@3x
    "58"   # 29x29@2x
    "87"   # 29x29@3x
    "80"   # 40x40@2x
    "120"  # 40x40@3x
    "120"  # 60x60@2x
    "180"  # 60x60@3x
    "20"   # 20x20@1x (iPad)
    "40"   # 20x20@2x (iPad)
    "29"   # 29x29@1x (iPad)
    "58"   # 29x29@2x (iPad)
    "40"   # 40x40@1x (iPad)
    "80"   # 40x40@2x (iPad)
    "152"  # 76x76@2x (iPad)
    "167"  # 83.5x83.5@2x (iPad)
    "1024" # App Store
)

echo "Генерирую иконки из нового дизайна Convertik..."
echo "Используется файл: $SVG_FILE"
echo ""

# Генерируем все размеры
for size in "${sizes[@]}"; do
    echo "Генерирую иконку размером ${size}x${size}..."
    rsvg-convert -h $size -w $size "$SVG_FILE" -o "icon_${size}x${size}.png"
done

echo ""
echo "Все иконки сгенерированы!"
echo "Файлы:"
ls -la *.png

echo ""
echo "Новый логотип использует палитру Velvet Sunset:"
echo "- Темный фон (dark theme: #1B1525 → #282032)"
echo "- Янтарные круги и стрелки (amberAccent: #F8B400)"
echo "- Янтарный символ доллара (amberAccent: #F8B400)"
echo "- Лавандовое акцентное свечение (accentGradient: #FF7E5F → #FD3A84)"
echo "- Современный элегантный дизайн" 