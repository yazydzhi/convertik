# Проблемы с запуском приложения из Xcode после сборки через build.sh

## Проблема

Сборка через `build.sh` проходит успешно, но запуск из Xcode не работает.

## Возможные причины и решения

### 1. Проверьте схему и конфигурацию в Xcode

**Важно:** После сборки через скрипт нужно правильно настроить Xcode:

1. Откройте `Convertik.xcworkspace` в Xcode
2. Вверху слева выберите:
   - **Scheme:** `Convertik` (не `Pods-Convertik`!)
   - **Configuration:** Соответствующая конфигурация (DebugNew, DeployOld и т.д.)
   - **Destination:** Симулятор (например, "iPhone 17 Pro Max")

### 2. Очистите и пересоберите в Xcode

После сборки через скрипт:

1. В Xcode: **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)
3. **Product → Run** (⌘R)

### 3. Проверьте подпись кода

Если ошибка связана с подписью:

1. Откройте проект → Target `Convertik` → **Signing & Capabilities**
2. Убедитесь, что:
   - ✅ **"Automatically manage signing"** включено
   - ✅ **Team** выбран правильно (Vladimir Yazydzhi)
   - ✅ **Bundle Identifier** соответствует конфигурации:
     - `com.yazydzhi.convertik` для DeployOld/DebugOld
     - `com.azg.Convertik` для DeployNew/DebugNew

### 4. Проверьте, что приложение установлено на симулятор

После сборки через скрипт приложение может быть не установлено на симулятор.

**Решение:**
1. В Xcode выберите симулятор из списка устройств
2. Нажмите **Product → Run** (⌘R)
3. Или установите вручную:
   ```bash
   xcodebuild -workspace Convertik.xcworkspace \
     -scheme Convertik \
     -configuration DebugNew \
     -destination "platform=iOS Simulator,name=iPhone 17 Pro Max" \
     install
   ```

### 5. Проверьте, что симулятор запущен

1. Откройте **Simulator.app** (через Spotlight или Applications)
2. Или в Xcode: **Window → Devices and Simulators** (⇧⌘2)
3. Убедитесь, что нужный симулятор запущен

### 6. Перезапустите симулятор

Если симулятор завис:

1. В Simulator: **Device → Erase All Content and Settings...**
2. Или перезапустите:
   ```bash
   xcrun simctl shutdown all
   xcrun simctl boot "iPhone 17 Pro Max"
   ```

### 7. Проверьте логи ошибок

Если приложение не запускается:

1. В Xcode: **View → Navigators → Show Debug Area** (⇧⌘Y)
2. Проверьте консоль на наличие ошибок
3. Проверьте **Report Navigator** (⌘9) на наличие ошибок сборки/установки

### 8. Установите через командную строку

Если Xcode не может установить, попробуйте через терминал:

```bash
cd frontend/ios

# Соберите и установите
xcodebuild -workspace Convertik.xcworkspace \
  -scheme Convertik \
  -configuration DebugNew \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro Max" \
  build install

# Или запустите через xcrun
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/Convertik-*/Build/Products/DebugNew-iphonesimulator/Convertik.app
xcrun simctl launch booted com.azg.Convertik
```

### 9. Проверьте Bundle Identifier

Убедитесь, что Bundle ID в Xcode соответствует конфигурации:

- **DebugNew/DeployNew:** `com.azg.Convertik`
- **DebugOld/DeployOld:** `com.yazydzhi.convertik`

Проверка:
```bash
# В Xcode: Product → Scheme → Edit Scheme → Run → Info
# Или через терминал:
xcodebuild -showBuildSettings -workspace Convertik.xcworkspace \
  -scheme Convertik \
  -configuration DebugNew \
  | grep PRODUCT_BUNDLE_IDENTIFIER
```

### 10. Переустановите приложение на симулятор

Если приложение уже установлено, но не запускается:

1. В Simulator: **Device → Erase All Content and Settings...**
2. Или удалите вручную:
   ```bash
   xcrun simctl uninstall booted com.azg.Convertik
   ```
3. Затем установите заново через Xcode (⌘R)

## Быстрое решение

Если ничего не помогает:

1. **Закройте Xcode**
2. **Очистите DerivedData:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Convertik-*
   ```
3. **Откройте Xcode заново:**
   ```bash
   open frontend/ios/Convertik.xcworkspace
   ```
4. **Выберите правильную схему и конфигурацию**
5. **Product → Clean Build Folder** (⇧⌘K)
6. **Product → Build** (⌘B)
7. **Product → Run** (⌘R)

## Проверка после исправления

После исправления проверьте:

1. ✅ Приложение устанавливается на симулятор
2. ✅ Приложение запускается без ошибок
3. ✅ Bundle ID правильный в настройках приложения
4. ✅ Логи в консоли не показывают критичных ошибок

