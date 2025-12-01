# Отладка Pre-Build Script в Xcode

## Проблема: Скрипт выполняется, но ошибка остается

Если Pre-Build Script добавлен, но ошибка "Unable to find module dependency: 'GoogleMobileAds'" все еще появляется:

### 1. Проверьте настройки Run Script Phase

В Xcode → Build Phases → `[CP] Build Pods First`:

**ВАЖНО:**
- ❌ **"Based on dependency analysis"** = **ОТКЛЮЧИТЬ** (uncheck)
  - Это заставляет Xcode пропускать скрипт, если думает, что зависимости не изменились
  - Но для нестандартных конфигураций это не работает правильно

- ✅ **"For install builds only"** = **ОТКЛЮЧИТЬ** (uncheck)

- ✅ **"Show environment variables in build log"** = **ВКЛЮЧИТЬ** (check)
  - Это поможет увидеть, какие переменные передаются в скрипт

### 2. Проверьте логи выполнения скрипта

1. В Xcode откройте **View → Navigators → Show Report Navigator** (⌘9)
2. Выберите последнюю сборку
3. Найдите секцию `[CP] Build Pods First`
4. Проверьте вывод скрипта:
   ```
   🔧 [Pre-Build] Building Pods first...
      Configuration: DeployOld
      Platform: iphonesimulator
      SRCROOT: /path/to/project
   📦 Building Google-Mobile-Ads-SDK for Release...
     ✅ Google-Mobile-Ads-SDK built successfully
   📦 Building Pods-Convertik for Release...
     ✅ Pods-Convertik built successfully
   🔗 Creating symlinks for DeployOld -> Release...
     ✅ Created symlink: Google-Mobile-Ads-SDK
     ✅ Created symlink: XCFrameworkIntermediates
   ✅ [Pre-Build] Pods are ready
   ```

### 3. Если скрипт не выполняется

Проверьте:
- Скрипт должен быть **ПЕРВЫМ** в списке Build Phases (перед "Sources")
- Путь к скрипту правильный: `"${SRCROOT}/build_pods_for_xcode.sh"`
- Файл `build_pods_for_xcode.sh` существует и имеет права на выполнение

### 4. Если скрипт выполняется, но симлинки не создаются

Проверьте пути в логах:
- `From: /path/to/Release-iphonesimulator/Google-Mobile-Ads-SDK`
- `To: /path/to/DeployOld-iphonesimulator/Google-Mobile-Ads-SDK`

Если пути неправильные, возможно проблема с определением `BUILD_DIR`.

### 5. Ручная проверка

Выполните скрипт вручную из терминала:

```bash
cd frontend/ios
export CONFIGURATION=DeployOld
export PLATFORM_NAME=iphonesimulator
export SRCROOT=$(pwd)
./build_pods_for_xcode.sh
```

Проверьте вывод и убедитесь, что все шаги выполняются успешно.

### 6. Альтернативное решение: Отключить dependency analysis

Если проблема сохраняется, попробуйте:

1. В Build Phases → `[CP] Build Pods First`
2. **Отключите** "Based on dependency analysis"
3. **Включите** "Show environment variables in build log"
4. Очистите и пересоберите: **Cmd+Shift+K**, затем **Cmd+B**

### 7. Проверка после сборки

После успешной сборки проверьте, что симлинки созданы:

```bash
ls -la ~/Library/Developer/Xcode/DerivedData/Convertik-*/Build/Products/DeployOld-iphonesimulator/
```

Должны быть символические ссылки:
- `Google-Mobile-Ads-SDK -> .../Release-iphonesimulator/Google-Mobile-Ads-SDK`
- `XCFrameworkIntermediates -> .../Release-iphonesimulator/XCFrameworkIntermediates`

