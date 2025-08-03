#!/usr/bin/env python3
"""
Простой тест для проверки переключения темы
"""

import subprocess
import time
import os

def run_command(command):
    """Выполняет команду и возвращает результат"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def take_screenshot(filename):
    """Делает скриншот симулятора"""
    command = f'xcrun simctl io booted screenshot "theme_test_screenshots/{filename}"'
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

def main():
    """Основная функция тестирования"""
    print("🎨 Тестирование переключения темы")
    print("=" * 50)
    
    # Создаем папку для скриншотов
    os.makedirs("theme_test_screenshots", exist_ok=True)
    
    # Проверяем, что симулятор запущен
    success, stdout, stderr = run_command('xcrun simctl list devices | grep "iPhone 16" | grep "Booted"')
    if not success:
        print("❌ Симулятор iPhone 16 не запущен")
        return
    
    print("📱 Симулятор iPhone 16 запущен")
    
    # 1. Светлая тема
    print("\n1️⃣ Тестирование светлой темы")
    set_appearance("light")
    time.sleep(3)  # Ждем применения темы
    take_screenshot("01_light_theme.png")
    
    # 2. Темная тема
    print("\n2️⃣ Тестирование темной темы")
    set_appearance("dark")
    time.sleep(3)  # Ждем применения темы
    take_screenshot("02_dark_theme.png")
    
    # 3. Обратно в светлую
    print("\n3️⃣ Возврат в светлую тему")
    set_appearance("light")
    time.sleep(3)  # Ждем применения темы
    take_screenshot("03_light_theme_again.png")
    
    print("\n" + "=" * 50)
    print("✅ Тестирование переключения темы завершено!")
    print("📁 Скриншоты сохранены в папке: theme_test_screenshots/")
    
    # Показываем список созданных файлов
    files = os.listdir("theme_test_screenshots")
    print("\n📸 Созданные скриншоты:")
    for file in sorted(files):
        if file.endswith('.png'):
            print(f"   - {file}")

if __name__ == "__main__":
    main() 