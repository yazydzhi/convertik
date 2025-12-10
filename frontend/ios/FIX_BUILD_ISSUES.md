# Исправление проблем сборки

## Проблемы, которые были исправлены:

1. ✅ **Удалена циклическая ссылка** `PRODUCT_BUNDLE_IDENTIFIER: $(PRODUCT_BUNDLE_IDENTIFIER)` из `project.yml`
2. ✅ **Вернут `GADApplicationIdentifier`** в `Info.plist` с правильной переменной
3. ⚠️ **Bundle Identifier** - нужно проверить подключение xcconfig файлов в Xcode

## Что нужно сделать в Xcode:

### 1. Проверьте подключение xcconfig файлов:

1. Откройте проект в Xcode
2. Выберите проект "Convertik" в навигаторе
3. Выберите таргет "Convertik"
4. Перейдите на вкладку **Build Settings**
5. Найдите **"Configuration"** вверху и выберите **"DeployOld"**
6. Найдите **"Base Configuration File"** (или используйте поиск "baseConfiguration")
7. Убедитесь, что для конфигурации **DeployOld** указан файл: `Configs/DeployOld.xcconfig`
8. Для **DeployNew** должен быть: `Configs/DeployNew.xcconfig`
9. Для **Debug** должен быть: `Configs/Debug.xcconfig`

### 2. Проверьте Bundle Identifier:

1. В **Build Settings** найдите **"Product Bundle Identifier"**
2. Для конфигурации **DeployOld** должно быть: `com.yazydzhi.convertik`
3. Если видите `$(PRODUCT_BUNDLE_IDENTIFIER)`, значит xcconfig не подключен

### 3. Если xcconfig не подключен:

1. В **Build Settings** найдите **"Base Configuration File"**
2. Для каждой конфигурации (DeployOld, DeployNew, Debug) выберите соответствующий .xcconfig файл
3. Или используйте скрипт `fix_xcconfigs.py` для автоматического исправления

### 4. Переустановите CocoaPods (если проблема с GoogleMobileAds):

```bash
cd frontend/ios
pod deintegrate
pod install
```

### 5. Очистите и пересоберите:

1. В Xcode: **Product → Clean Build Folder** (⇧⌘K)
2. Закройте Xcode
3. Откройте `Convertik.xcworkspace` (не .xcodeproj!)
4. Выберите схему **Convertik-Old**
5. Соберите проект (⌘B)

## Проверка после исправления:

После исправления проверьте:

```bash
cd frontend/ios
xcodebuild -showBuildSettings -workspace Convertik.xcworkspace \
  -scheme Convertik-Old -configuration DeployOld \
  | grep "PRODUCT_BUNDLE_IDENTIFIER"
```

Должно показать: `PRODUCT_BUNDLE_IDENTIFIER = com.yazydzhi.convertik`



