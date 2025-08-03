#!/usr/bin/env python3
"""
Скрипт для тестирования палитры Velvet Sunset
Автоматизирует создание скриншотов в светлой и темной темах
"""

import subprocess
import time
import os
import sys

def run_command(command):
    """Выполняет команду и возвращает результат"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def take_screenshot(filename):
    """Делает скриншот симулятора"""
    command = f'xcrun simctl io booted screenshot "velvet_sunset_screenshots/{filename}"'
    success, stdout, stderr = run_command(command)
    if success:
        print(f"✅ Скриншот сохранен: {filename}")
    else:
        print(f"❌ Ошибка создания скриншота: {stderr}")
    return success

def set_appearance(appearance):
    """Устанавливает внешний вид симулятора"""
    command = f'xcrun simctl ui booted appearance {appearance}'
    success, stdout, stderr = run_command(command)
    if success:
        print(f"✅ Внешний вид установлен: {appearance}")
    else:
        print(f"❌ Ошибка установки внешнего вида: {stderr}")
    return success

def tap_coordinates(x, y):
    """Нажимает на координаты экрана"""
    command = f'xcrun simctl spawn booted uiautomator tap {x} {y}'
    success, stdout, stderr = run_command(command)
    if success:
        print(f"✅ Нажатие на координаты: {x}, {y}")
    else:
        print(f"❌ Ошибка нажатия: {stderr}")
    return success

def main():
    """Основная функция тестирования"""
    print("🎨 Тестирование палитры Velvet Sunset")
    print("=" * 50)
    
    # Создаем папку для скриншотов
    os.makedirs("velvet_sunset_screenshots", exist_ok=True)
    
    # Проверяем, что симулятор запущен
    success, stdout, stderr = run_command('xcrun simctl list devices | grep "iPhone 16" | grep "Booted"')
    if not success:
        print("❌ Симулятор iPhone 16 не запущен")
        return
    
    print("📱 Симулятор iPhone 16 запущен")
    
    # 1. Светлая тема - главный экран
    print("\n1️⃣ Создание скриншота главного экрана в светлой теме")
    set_appearance("light")
    time.sleep(2)  # Ждем применения темы
    take_screenshot("01_light_theme_main_screen.png")
    
    # 2. Светлая тема - настройки
    print("\n2️⃣ Открытие настроек в светлой теме")
    # Нажимаем на кнопку настроек (примерные координаты для iPhone 16)
    tap_coordinates(50, 60)  # Кнопка настроек в левом верхнем углу
    time.sleep(2)
    take_screenshot("02_light_theme_settings.png")
    
    # 3. Переключение на темную тему
    print("\n3️⃣ Переключение на темную тему")
    # Нажимаем на переключатель темы (примерные координаты)
    tap_coordinates(300, 200)  # Переключатель темы
    time.sleep(2)
    take_screenshot("03_dark_theme_settings.png")
    
    # 4. Темная тема - главный экран
    print("\n4️⃣ Возврат на главный экран в темной теме")
    # Нажимаем "Готово" в настройках
    tap_coordinates(350, 60)  # Кнопка "Готово"
    time.sleep(2)
    take_screenshot("04_dark_theme_main_screen.png")
    
    # 5. Дополнительные скриншоты в темной теме
    print("\n5️⃣ Дополнительные скриншоты в темной теме")
    # Нажимаем на кнопку добавления валюты
    tap_coordinates(350, 60)  # Кнопка "+" в правом верхнем углу
    time.sleep(2)
    take_screenshot("05_dark_theme_add_currency.png")
    
    # 6. Возврат в светлую тему
    print("\n6️⃣ Возврат в светлую тему")
    set_appearance("light")
    time.sleep(2)
    take_screenshot("06_light_theme_final.png")
    
    print("\n" + "=" * 50)
    print("✅ Тестирование палитры Velvet Sunset завершено!")
    print("📁 Скриншоты сохранены в папке: velvet_sunset_screenshots/")
    
    # Показываем список созданных файлов
    files = os.listdir("velvet_sunset_screenshots")
    print("\n📸 Созданные скриншоты:")
    for file in sorted(files):
        if file.endswith('.png'):
            print(f"   - {file}")

if __name__ == "__main__":
    main() 