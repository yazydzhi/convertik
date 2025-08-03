import os
import subprocess
import time

DEVICE_NAME = "iPhone 16"
BUNDLE_ID = "com.azg.Convertik"

SCREENS = [
    ("main", None),
    ("add_currency", "add_currency"),
    ("settings", "settings")
]

LIGHT_DIR = "screenshots_light"
DARK_DIR = "screenshots_dark"


def run(cmd):
    print(f"$ {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(result.stderr)
    return result


def set_appearance(mode):
    run(f"xcrun simctl ui booted appearance {mode}")
    time.sleep(1)


def take_screenshot(name, folder):
    os.makedirs(folder, exist_ok=True)
    path = os.path.join(folder, f"{name}.png")
    run(f"xcrun simctl io booted screenshot {path}")
    print(f"Saved: {path}")


def launch_app():
    run(f"xcrun simctl launch booted {BUNDLE_ID}")
    time.sleep(2)


def open_add_currency():
    # Открытие экрана добавления валюты: пользователь должен вручную открыть, либо реализовать deeplink/универсальный метод
    print("[!] Откройте экран 'Добавить валюту' вручную для скриншота, затем нажмите Enter...")
    input()

def open_settings():
    print("[!] Откройте экран 'Настройки' вручную для скриншота, затем нажмите Enter...")
    input()


def main():
    print("=== Velvet Sunset Screenshot Automation ===")
    launch_app()

    # Light theme
    set_appearance("light")
    print("\nСветлая тема:")
    take_screenshot("main", LIGHT_DIR)
    open_add_currency()
    take_screenshot("add_currency", LIGHT_DIR)
    launch_app()  # Вернуться на главный экран
    open_settings()
    take_screenshot("settings", LIGHT_DIR)
    launch_app()

    # Dark theme
    set_appearance("dark")
    print("\nТёмная тема:")
    take_screenshot("main", DARK_DIR)
    open_add_currency()
    take_screenshot("add_currency", DARK_DIR)
    launch_app()
    open_settings()
    take_screenshot("settings", DARK_DIR)
    launch_app()

    set_appearance("light")
    print("Готово!")

if __name__ == "__main__":
    main()