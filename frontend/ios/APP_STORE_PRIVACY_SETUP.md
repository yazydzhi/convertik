# Настройка App Privacy в App Store Connect

## Проблема
Apple требует обновить App Privacy response, если в приложении есть `NSUserTrackingUsageDescription`.

## Решение: Обновить App Privacy

### Шаг 1: Войти в App Store Connect
1. Откройте [App Store Connect](https://appstoreconnect.apple.com)
2. Войдите в свой аккаунт
3. Выберите приложение **Convertik**

### Шаг 2: Открыть App Privacy
1. В левом меню выберите **App Privacy**
2. Нажмите **"Get Started"** или **"Edit"** (если уже настроено)

### Шаг 3: Добавить категории данных (если tracking используется)

Если вы используете персонализированную рекламу через AdMob:

1. Нажмите **"Add Data Type"** или **"Edit"**
2. Добавьте следующие категории:

#### A. Identifiers → Device ID
- **Used for Tracking:** ✅ **Yes**
- **Linked to User:** ✅ **Yes** (для персонализированной рекламы)
- **Used to Track You:** ✅ **Yes**
- **Purpose:** **Third-Party Advertising**

#### B. Usage Data → Product Interaction
- **Used for Tracking:** ✅ **Yes**
- **Linked to User:** ✅ **Yes**
- **Used to Track You:** ✅ **Yes**
- **Purpose:** **Third-Party Advertising**

#### C. Advertising Data → Advertising Data
- **Used for Tracking:** ✅ **Yes**
- **Linked to User:** ✅ **Yes**
- **Used to Track You:** ✅ **Yes**
- **Purpose:** **Third-Party Advertising**

### Шаг 4: Сохранить изменения
1. Нажмите **"Save"** или **"Done"**
2. Дождитесь обработки (обычно несколько минут)

### Шаг 5: Загрузить новый билд
1. После сохранения App Privacy, загрузите новый билд через Xcode или Transporter
2. Ошибка должна исчезнуть

---

## Альтернатива: Использовать нон-персонализированную рекламу

Если вы НЕ хотите использовать tracking:

1. **Обновите App Privacy:**
   - Укажите, что tracking **НЕ используется**
   - Или удалите все категории данных, связанные с tracking

2. **Настройте AdMob на нон-персонализированную рекламу:**
   - В коде добавьте настройку `GADMobileAds.sharedInstance().requestConfiguration.tagForChildDirectedTreatment = .tagged`
   - Или используйте `GADRequest` с `tagForChildDirectedTreatment` и `tagForUnderAgeOfConsent`

3. **Удалите `NSUserTrackingUsageDescription`** (если он есть в билде):
   - Очистите DerivedData
   - Пересоберите проект

---

## Проверка

После обновления App Privacy:
1. Загрузите новый билд
2. Попробуйте отправить на ревью
3. Ошибка должна исчезнуть

Если ошибка сохраняется:
- Убедитесь, что App Privacy сохранен
- Проверьте, что загружен новый билд (не старый)
- Подождите несколько минут для обработки изменений

