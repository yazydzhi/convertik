# Инструкция по использованию конфигураций деплоя

## Обзор

Проект настроен для поддержки двух версий приложения с разными Bundle ID, SKU и настройками Google Ads:

1. **Старая версия**: `com.yazydzhi.convertik`
2. **Новая версия**: `com.azg.Convertik`

## Структура конфигураций

Все конфигурационные файлы находятся в `Configs/`:

- `Debug.xcconfig` - для разработки (тестовые данные)
- `DeployOld.xcconfig` - для старой версии приложения
- `DeployNew.xcconfig` - для новой версии приложения

## Как использовать

### Для разработки

1. В Xcode выберите схему **`Convertik`**
2. Убедитесь что выбран Build Configuration: **Debug**
3. Запустите проект (⌘R)

**Используемые настройки:**
- Bundle ID: `com.azg.Convertik`
- IAP SKU: `com.azg.Convertik`
- Google Ads: тестовые ID
- BG Task: `com.azg.convertik.refresh`

### Для деплоя старой версии

1. В Xcode выберите схему **`Convertik-Old`**
2. Убедитесь что выбран Build Configuration: **DeployOld**
3. Создайте архив: Product → Archive (⌘B, затем Product → Archive)

**Используемые настройки:**
- Bundle ID: `com.yazydzhi.convertik`
- IAP SKU: `com.yazydzhi.convertik`
- Google Ads: production ID для старой версии
- BG Task: `com.yazydzhi.convertik.refresh`

### Для деплоя новой версии

1. В Xcode выберите схему **`Convertik-New`**
2. Убедитесь что выбран Build Configuration: **DeployNew**
3. Создайте архив: Product → Archive (⌘B, затем Product → Archive)

**Используемые настройки:**
- Bundle ID: `com.azg.Convertik`
- IAP SKU: `com.azg.Convertik`
- Google Ads: production ID для новой версии
- BG Task: `com.azg.convertik.refresh`

## Что настраивается автоматически

При выборе соответствующей схемы автоматически применяются:

1. **Bundle ID** через `PRODUCT_BUNDLE_IDENTIFIER` в `.xcconfig`
2. **IAP Product SKU** через условную компиляцию в `StoreService.swift`
3. **Google Ads IDs** через условную компиляцию в `AdConfig.swift`
4. **BG Task Identifier** через условную компиляцию в `BackgroundService.swift` и переменную в `Info.plist`

## Обновление Google Ads Unit IDs

Если нужно использовать разные Ad Unit IDs для старой и новой версии:

1. Откройте `Configs/DeployOld.xcconfig` или `Configs/DeployNew.xcconfig`
2. Найдите нужные значения:
   ```
   ADMOB_BANNER_MAIN_BOTTOM = ca-app-pub-xxxxx/xxxxx
   ADMOB_INTERSTITIAL_MAIN = ca-app-pub-xxxxx/xxxxx
   ADMOB_REWARDED_MAIN = ca-app-pub-xxxxx/xxxxx
   ```
3. Замените на новые значения из AdMob
4. Значения автоматически применятся через условную компиляцию в `AdConfig.swift`

## Командная строка

### Сборка для старой версии

```bash
cd frontend/ios
xcodebuild -workspace Convertik.xcworkspace \
  -scheme Convertik-Old \
  -configuration DeployOld \
  -archivePath ./build/Convertik-Old.xcarchive \
  archive
```

### Сборка для новой версии

```bash
cd frontend/ios
xcodebuild -workspace Convertik.xcworkspace \
  -scheme Convertik-New \
  -configuration DeployNew \
  -archivePath ./build/Convertik-New.xcarchive \
  archive
```

## Проверка конфигурации

После сборки можно проверить что правильные значения используются:

1. Откройте собранный `.app` файл
2. Проверьте `Info.plist` внутри приложения:
   - `CFBundleIdentifier` должен соответствовать выбранной конфигурации
   - `GADApplicationIdentifier` должен соответствовать выбранной конфигурации

Или добавьте отладочный вывод в код:

```swift
print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
print("AdMob App ID: \(AdConfig.appID)")
print("IAP SKU: \(StoreService.shared.productIds.first ?? "unknown")")
```

## Перегенерация проекта

Если вы изменили `project.yml` или `.xcconfig` файлы:

```bash
cd frontend/ios
xcodegen generate
```

Затем откройте `Convertik.xcworkspace` в Xcode.

## Важные замечания

1. **Не коммитьте реальные Ad Unit IDs** если они отличаются для разных версий - используйте placeholder'ы
2. **Убедитесь что Bundle ID соответствует App ID в App Store Connect** перед деплоем
3. **Проверьте что IAP продукты созданы** в App Store Connect с правильными SKU для каждой версии
4. **Тестируйте каждую конфигурацию отдельно** перед отправкой в продакшн

## Troubleshooting

### Проблема: Bundle ID не меняется

**Решение:** Убедитесь что вы выбрали правильную схему и что `PRODUCT_BUNDLE_IDENTIFIER` правильно установлен в `.xcconfig` файле.

### Проблема: Неправильные Ad Unit IDs

**Решение:** Проверьте что значения в `.xcconfig` соответствуют значениям в `AdConfig.swift` и что условная компиляция работает правильно.

### Проблема: IAP не работает

**Решение:** 
1. Убедитесь что правильный SKU используется в `StoreService.swift`
2. Проверьте что продукт создан в App Store Connect с правильным SKU
3. Проверьте что Bundle ID совпадает с App ID в App Store Connect

