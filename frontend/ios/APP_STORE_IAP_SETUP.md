# Настройка In-App Purchase для App Store

## Проблема

Apple отклонил сборку с сообщением:
> "We found that your in-app purchase products exhibited one or more bugs which create a poor user experience. Specifically, the in-app purchases were loading indefinitely."

**Причина**: Продукт In-App Purchase не создан в App Store Connect для production.

## Решение

### Шаг 1: Создание продукта в App Store Connect

1. Откройте [App Store Connect](https://appstoreconnect.apple.com)
2. Выберите ваше приложение "Convertik"
3. Перейдите в раздел **"Features"** → **"In-App Purchases"**
4. Нажмите **"+"** или **"Create"**
5. Выберите **"Auto-Renewable Subscription"**

### Шаг 2: Заполнение данных продукта

**Reference Name**: `Ads Free`
- Это внутреннее имя, видимое только вам

**Product ID**: `com.azg.Convertik`
- ⚠️ ВАЖНО: Должно совпадать с кодом в `StoreService.swift`
- Это уникальный идентификатор

**Subscription Group**: `AdsFree` (или создайте новый)
- Создайте группу подписок если её нет

**Subscription Duration**: `1 Month`

### Шаг 3: Локализация (локализованный контент)

Добавьте для каждой локализации (минимум English и Russian):

**English (en_US)**:
- Display Name: `Convertik Ads Free`
- Description: `Remove all ads and get an uninterrupted currency conversion experience. Your subscription supports continued development of the app.`

**Russian (ru_RU)**:
- Display Name: `Конвертик без рекламы`
- Description: `Удалите всю рекламу и получите бесперебойный опыт конвертации валют. Ваша подписка поддерживает дальнейшую разработку приложения.`

### Шаг 4: Pricing (Цены)

1. Выберите цену (например, $0.99)
2. Нажмите "Save"

### Шаг 5: Review Information (Опционально)

Если Apple запросит, добавьте:
- Review Notes: `This is an auto-renewable subscription that removes ads from the app`
- Screenshots (опционально): скриншот экрана "О нас" или где-то упоминается премиум

### Шаг 6: Отправка продукта

1. Нажмите "Save" внизу
2. Нажмите "Add for Review"
3. Продукт будет в статусе "Waiting for Review"

### Шаг 7: Добавление продукта к submission

**ВАЖНО**: Когда отправляете новую версию приложения в App Review:

1. В разделе "App Version" убедитесь, что продукт `com.azg.Convertik` добавлен в "In-App Purchases"
2. Продукт должен быть в статусе "Waiting for Review" или "In Review"
3. Apple проверит продукт вместе с приложением

## Ключевые моменты

### ✅ Что НЕ нужно делать:

- ❌ Не нужно одобрять продукт заранее отдельно
- ❌ Не нужно создавать тестовую покупку перед отправкой
- ❌ Не нужно ждать одобрения продукта перед отправкой приложения

### ✅ Что нужно сделать:

- ✅ Создать продукт в App Store Connect
- ✅ Заполнить минимальную информацию (имя, описание, цена)
- ✅ Отправить продукт "для проверки"
- ✅ Добавить продукт к submission приложения
- ✅ Отправить приложение и продукт вместе на проверку

## После создания продукта

1. Продукт появится в App Store Connect с статусом "Waiting for Review"
2. Соберите новую версию приложения (версия 2.4, build 33+)
3. Отправьте приложение в App Review
4. В разделе In-App Purchases проверьте, что продукт добавлен
5. Apple проверит продукт и приложение одновременно

## Проверка в TestFlight

После создания продукта в App Store Connect:

1. Подождите несколько минут для синхронизации
2. Установите production сборку через TestFlight
3. Продукт должен загрузиться успешно
4. Вы сможете сделать тестовую покупку (если у вас настроен sandbox tester)

## Конфигурация продукта в коде

В файле `StoreService.swift`:
```swift
private let productIds = [
    "com.azg.Convertik"  // Должно совпадать с Product ID в App Store Connect
]
```

В файле `.storekit` (для тестирования в Xcode):
```json
{
  "productID": "com.azg.Convertik",
  "type": "RecurringSubscription",
  "subscriptionGroupID": "0948EBA3"
}
```

## FAQ

### Q: Нужно ли одобрять продукт до отправки приложения?
**A**: Нет. Apple явно пишет: "in-app purchases do not need to have been previously approved". Продукт проверяется вместе с приложением.

### Q: Почему в TestFlight продукт не загружается?
**A**: Потому что он не создан в App Store Connect. Создайте продукт, подождите синхронизации, и он появится.

### Q: Можно ли тестировать покупки до одобрения?
**A**: Да, через Sandbox environment в TestFlight. Настройте Sandbox Tester в Users and Access → Sandbox Testers.

### Q: Сколько времени занимает синхронизация?
**A**: Обычно 5-30 минут после создания продукта в App Store Connect.

## Следующие шаги

1. Создайте продукт в App Store Connect (следуя инструкциям выше)
2. Подождите синхронизации
3. Проверьте в TestFlight
4. Соберите новую версию приложения
5. Отправьте в App Review с добавленным продуктом
6. Apple проверит всё вместе

## Контакты

Если возникнут проблемы:
- Проверьте, что Product ID точно совпадает
- Убедитесь, что Subscription Group создан
- Проверьте, что все обязательные поля заполнены

