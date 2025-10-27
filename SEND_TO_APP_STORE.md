# Отправка версии 2.5 в App Store

## ✅ Готово

**Версия**: 2.5 (build 41)  
**Дата сборки**: 27 октября 2025  
**Тип**: Release

## 📋 Следующие шаги

### 1. Откройте Xcode и сделайте Archive

```bash
# Откройте проект в Xcode
open /Users/azg/repository/convertik/frontend/ios/Convertik.xcworkspace

# В Xcode:
# 1. Выберите схему "Convertik_release"
# 2. Выберите "Any iOS Device (arm64)" в устройствах
# 3. Product → Archive
```

### 2. Validating and Uploading

После создания архива:
1. Нажмите **"Validate App"** для проверки
2. Если всё ОК, нажмите **"Distribute App"**
3. Выберите **"App Store Connect"**
4. Следуйте инструкциям

### 3. ⚠️ ВАЖНО: Создайте In-App Purchase

**ПЕРЕД отправкой** создайте продукт IAP в App Store Connect:

1. Откройте [App Store Connect](https://appstoreconnect.apple.com)
2. Convertik → Features → In-App Purchases
3. Создайте **Auto-Renewable Subscription**:
   - Product ID: `com.azg.Convertik`
   - Duration: 1 Month
   - Price: $0.99
   - Display Name: Convertik Ads Free
4. Нажмите **"Add for Review"**

### 4. При добавлении версии 2.5 в App Store Connect

1. Создайте новую версию 2.5
2. Укажите "What's New" (изменения)
3. В разделе **"In-App Purchases"** добавьте продукт `com.azg.Convertik`
4. Отправьте на проверку

### 5. Примечание для Apple Review

Добавьте в "Notes for Review":
```
Thank you for the feedback. We have fixed the IAP issue by:
1. Created the Auto-Renewable Subscription product in App Store Connect
2. Implemented proper backend receipt validation that handles both production and sandbox receipts
3. The product is now available for review along with the app

According to Apple guidelines: "in-app purchases do not need to have been previously approved to confirm they function correctly in review."
```

## 📝 Что было исправлено

✅ Backend IAP receipt validation (production + sandbox)  
✅ Улучшенная обработка ошибок загрузки продуктов  
✅ Версия обновлена до 2.5 (build 41)  
✅ Автоматическое увеличение build number

## 📖 Документация

Подробная инструкция по созданию IAP: `frontend/ios/APP_STORE_IAP_SETUP.md`

## ⏱️ Timeline

- **0-30 минут**: Создание продукта IAP в App Store Connect
- **5-30 минут**: Синхронизация продукта с методами
- **30 минут - 2 часа**: Архивация и загрузка в App Store Connect
- **1-2 дня**: Проверка Apple

## 🎯 Цель

Продукт IAP и приложение будут проверены вместе, как рекомендует Apple.

