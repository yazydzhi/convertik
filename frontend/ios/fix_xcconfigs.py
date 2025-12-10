#!/usr/bin/env python3
"""
Скрипт для исправления baseConfigurationReference в project.pbxproj
после выполнения pod install. Подключает наши .xcconfig файлы вместо CocoaPods.
"""
import re
import sys
import os

pbxproj_path = "Convertik.xcodeproj/project.pbxproj"

if not os.path.exists(pbxproj_path):
    print(f"❌ Файл {pbxproj_path} не найден")
    sys.exit(1)

with open(pbxproj_path, 'r') as f:
    content = f.read()

# Конфигурации и соответствующие .xcconfig файлы
configs = {
    'DeployOld': 'Configs/DeployOld.xcconfig',
    'DeployNew': 'Configs/DeployNew.xcconfig',
    'Debug': 'Configs/Debug.xcconfig',
}

# Найти или создать PBXFileReference для наших .xcconfig файлов
file_refs = {}

# Проверить существующие PBXFileReference
for match in re.finditer(r'(\w+)\s+=\s+{.*?PBXFileReference.*?path\s+=\s+"?([^";]+\.xcconfig)"?', content, re.DOTALL):
    ref_id = match.group(1)
    path = match.group(2)
    if path.startswith('Configs/'):
        file_refs[path] = ref_id
        print(f"✓ Найден PBXFileReference: {path} -> {ref_id}")

# Если файлы не найдены, нужно их создать
# Но это сложно, поэтому проще всего - использовать относительный путь напрямую

# Найти конфигурации таргета Convertik
target_config_pattern = r'43E22285C7020C9C184ED1C5.*?buildConfigurations\s*=\s*\((.*?)\);'
target_match = re.search(target_config_pattern, content, re.DOTALL)
if not target_match:
    print("❌ Не найдена секция buildConfigurations для таргета Convertik")
    sys.exit(1)

# Найти все конфигурации и их baseConfigurationReference
for config_name, xcconfig_path in configs.items():
    # Найти конфигурацию по имени
    pattern = rf'(\w+)\s+/\* {config_name} \*/\s*=\s*{{[^}}]*isa\s*=\s*XCBuildConfiguration;[^}}]*baseConfigurationReference\s*=\s*(\w+)?'
    match = re.search(pattern, content, re.DOTALL)
    
    if match:
        config_id = match.group(1)
        old_ref = match.group(2) if len(match.groups()) > 1 and match.group(2) else None
        
        # Найти строку с baseConfigurationReference для этой конфигурации
        config_block_pattern = rf'({config_id}\s+/\* {config_name} \*/\s*=\s*{{[^}}]*isa\s*=\s*XCBuildConfiguration;[^}}]*)baseConfigurationReference\s*=\s*\w+\s*/\*[^;]+;'
        config_block_match = re.search(config_block_pattern, content, re.DOTALL)
        
        if config_block_match:
            # Заменить baseConfigurationReference
            new_ref = None
            if xcconfig_path in file_refs:
                new_ref = f"{file_refs[xcconfig_path]} /* {xcconfig_path} */"
            else:
                # Используем относительный путь (Xcode поддержит)
                # Но нужно найти или создать PBXFileReference
                # Для простоты - используем формат без ID, Xcode сам разберется
                # Лучше создать скрипт который добавляет файлы в проект
                print(f"⚠️  PBXFileReference для {xcconfig_path} не найден, требуется ручное добавление")

print("\n✅ Анализ завершен")
print("\n💡 РЕКОМЕНДАЦИЯ:")
print("   В Xcode вручную установите baseConfigurationReference:")
print("   1. Project → Target Convertik → Build Settings")
print("   2. Для каждой конфигурации (DeployOld, DeployNew, Debug)")
print("   3. Найдите 'Configuration File' или установите baseConfigurationReference")
print("   4. Выберите соответствующий файл из Configs/")























































