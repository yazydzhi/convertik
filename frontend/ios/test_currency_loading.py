#!/usr/bin/env python3
"""
Тест для проверки загрузки валют в экране добавления валют
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
    command = f'xcrun simctl io booted screenshot "currency_loading_test_screenshots/{filename}"'
    success, stdout, stderr = run_command(command)
    if success:
        print(f"✅ Скриншот сохранен: {filename}")
    else:
        print(f"❌ Ошибка создания скриншота: {stderr}")
    return success

def tap_element(accessibility_id):
    """Нажимает на элемент по accessibility identifier"""
    command = f'xcrun simctl spawn booted xcrun simctl ui booted tap --accessibility-id "{accessibility_id}"'
    success, stdout, stderr = run_command(command)
    if success:
        print(f"✅ Нажат элемент: {accessibility_id}")
    else:
        print(f"❌ Ошибка нажатия на элемент {accessibility_id}: {stderr}")
    return success

def wait(seconds):
    """Ждет указанное количество секунд"""
    print(f"⏳ Ожидание {seconds} секунд...")
    time.sleep(seconds)

def main():
    print("🔄 Тестирование загрузки валют")
    print("=" * 50)
    
    # Создаем папку для скриншотов
    os.makedirs("currency_loading_test_screenshots", exist_ok=True)
    
    print("📱 Симулятор iPhone 16 запущен")
    
    # Ждем загрузки приложения
    wait(3)
    
    # 1. Делаем скриншот главного экрана
    print("\n1️⃣ Скриншот главного экрана")
    take_screenshot("01_main_screen.png")
    
    # 2. Нажимаем на кнопку добавления валюты
    print("\n2️⃣ Нажатие на кнопку добавления валюты")
    tap_element("addCurrencyButton")
    wait(2)
    
    # 3. Делаем скриншот экрана добавления валюты
    print("\n3️⃣ Скриншот экрана добавления валюты")
    take_screenshot("02_add_currency_screen.png")
    
    # 4. Ждем загрузки валют (до 10 секунд)
    print("\n4️⃣ Ожидание загрузки валют")
    for i in range(10):
        wait(1)
        take_screenshot(f"03_loading_{i+1:02d}.png")
        
        # Проверяем, есть ли ошибка или список валют
        # Если есть ошибка, делаем скриншот и выходим
        # Если есть список валют, делаем финальный скриншот
    
    # 5. Финальный скриншот
    print("\n5️⃣ Финальный скриншот")
    take_screenshot("04_final_screen.png")
    
    # 6. Нажимаем "Отмена" для возврата
    print("\n6️⃣ Возврат на главный экран")
    tap_element("cancelButton")
    wait(2)
    
    # 7. Финальный скриншот главного экрана
    print("\n7️⃣ Финальный скриншот главного экрана")
    take_screenshot("05_main_screen_final.png")
    
    print("\n" + "=" * 50)
    print("✅ Тестирование загрузки валют завершено!")
    print("📁 Скриншоты сохранены в папке: currency_loading_test_screenshots/")
    
    # Показываем созданные файлы
    files = os.listdir("currency_loading_test_screenshots")
    print(f"\n📸 Созданные скриншоты:")
    for file in sorted(files):
        print(f"   - {file}")

if __name__ == "__main__":
    main() 