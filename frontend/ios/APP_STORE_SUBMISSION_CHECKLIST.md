# App Store Submission Checklist

## ✅ Требования для выкладки в App Store

### 1. Export Compliance Information ✅

**Проблема:** "This build is missing export compliance information"

**Решение:**
- ✅ Добавлен ключ `ITSAppUsesNonExemptEncryption` в `Info.plist` со значением `false`
- ✅ Приложение использует только стандартное шифрование Apple (TLS, AES, Keychain)
- ✅ Не требуется экспортная лицензия (mass market encryption software)

**Что сделано:**
- Добавлен `ITSAppUsesNonExemptEncryption: false` в `Info.plist`
- Добавлен в `project.yml` для автоматической генерации

**В Xcode:**
1. Откройте проект в Xcode
2. Выберите таргет `Convertik`
3. Перейдите в `Signing & Capabilities`
4. Убедитесь, что `ITSAppUsesNonExemptEncryption` установлен в `NO` (или оставьте пустым)

**При архивации:**
- Xcode спросит про Export Compliance
- Выберите: **"No, it does not use encryption"** или **"Yes, but it uses only standard encryption"**
- Это автоматически установит `ITSAppUsesNonExemptEncryption: false`

---

### 2. NSUserTrackingUsageDescription ⚠️

**Проблема:** "Your app contains NSUserTrackingUsageDescription, indicating that it may request permission to track users"

**Решение (выберите один из вариантов):**

#### Вариант A: Обновить App Privacy в App Store Connect (РЕКОМЕНДУЕТСЯ)

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Выберите ваше приложение
3. Перейдите в **App Privacy**
4. Нажмите **"Get Started"** или **"Edit"**
5. Добавьте категорию данных:
   - **"Identifiers"** → **"Device ID"**
   - **"Usage Data"** → **"Product Interaction"**
   - **"Advertising Data"** → **"Advertising Data"**
6. Для каждой категории укажите:
   - **Used for Tracking:** ✅ Yes
   - **Linked to User:** ✅ Yes (для персонализированной рекламы)
   - **Used to Track You:** ✅ Yes
7. Укажите цель: **"Third-Party Advertising"**
8. Сохраните изменения

**После этого:**
- Загрузите новый билд
- Ошибка должна исчезнуть

#### Вариант B: Убрать NSUserTrackingUsageDescription (если не нужен tracking)

Если вы не используете tracking для рекламы:

1. Удалите `NSUserTrackingUsageDescription` из `Info.plist`
2. Удалите код, который запрашивает tracking permission
3. Загрузите новый билд

**Где используется:**
- `Info.plist` → `NSUserTrackingUsageDescription`
- Возможно в коде AdMob (если используется `requestTrackingAuthorization`)

---

### 3. Дополнительные проверки

#### ✅ App Information
- [ ] Название приложения
- [ ] Подзаголовок (если есть)
- [ ] Категория
- [ ] Описание
- [ ] Ключевые слова
- [ ] Поддержка (URL)
- [ ] Политика конфиденциальности (URL)
- [ ] Маркетинговый URL (опционально)

#### ✅ Pricing and Availability
- [ ] Цена
- [ ] Доступность по странам

#### ✅ Version Information
- [ ] Скриншоты (минимум для iPhone 6.7" и 6.5")
- [ ] Превью (опционально)
- [ ] Описание версии
- [ ] Что нового в этой версии

#### ✅ Build
- [ ] Загружен билд через Xcode или Transporter
- [ ] Билд прошел валидацию
- [ ] Export compliance заполнен

#### ✅ App Review Information
- [ ] Контактная информация
- [ ] Тестовый аккаунт (если требуется)
- [ ] Примечания для ревьюера

---

## 📝 Пошаговая инструкция

### Шаг 1: Обновить Export Compliance

1. Откройте `Info.plist` в Xcode
2. Убедитесь, что есть ключ `ITSAppUsesNonExemptEncryption` со значением `NO`
3. Или при архивации выберите "No, it does not use encryption"

### Шаг 2: Обновить App Privacy

1. Войдите в App Store Connect
2. App Privacy → Edit
3. Добавьте категории данных для tracking
4. Укажите, что данные используются для tracking
5. Сохраните

### Шаг 3: Загрузить новый билд

1. Соберите новый билд в Xcode (Product → Archive)
2. Загрузите через Organizer или Transporter
3. Дождитесь обработки билда
4. Проверьте, что ошибки исчезли

---

## 🔍 Проверка перед отправкой

```bash
# Проверить Info.plist
grep -A 1 "ITSAppUsesNonExemptEncryption" frontend/ios/Info.plist
# Должно быть: <false/>

# Проверить NSUserTrackingUsageDescription
grep -A 1 "NSUserTrackingUsageDescription" frontend/ios/Info.plist
# Должно быть описание на русском языке
```

---

## 📚 Дополнительные ресурсы

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Export Compliance FAQ](https://developer.apple.com/documentation/security/compiling_against_cryptographic_apis)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)

---

## ⚠️ Важно

- **ITSAppUsesNonExemptEncryption: false** означает, что приложение использует только стандартное шифрование Apple
- Если вы используете кастомное шифрование, установите `true` и заполните форму экспортного контроля
- **NSUserTrackingUsageDescription** требует обновления App Privacy в App Store Connect
- После обновления App Privacy нужно загрузить новый билд

