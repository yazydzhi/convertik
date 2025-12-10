# Как найти "Base Configuration File" в Xcode

## Пошаговая инструкция:

### Шаг 1: Откройте проект
1. Откройте `Convertik.xcworkspace` в Xcode (НЕ .xcodeproj!)

### Шаг 2: Откройте настройки проекта
1. В левой панели (Navigator) нажмите на самый верхний элемент - **"Convertik"** (синяя иконка проекта)
2. В центральной панели вы увидите вкладки: **General**, **Signing & Capabilities**, **Info**, **Build Settings**, **Build Phases**, **Build Rules**

### Шаг 3: Перейдите в Build Settings
1. Нажмите на вкладку **"Build Settings"**

### Шаг 4: Найдите "Base Configuration File"
Есть два способа:

#### Способ 1: Через поиск
1. В правом верхнем углу панели Build Settings есть **поле поиска** (лупа 🔍)
2. Введите: **"baseConfiguration"** или **"Base Configuration"**
3. В результатах поиска найдите **"Base Configuration File"** или **"CONFIGURATION_BUILD_DIR"**

#### Способ 2: Вручную
1. В панели Build Settings найдите секцию **"Packaging"**
2. Внутри секции "Packaging" найдите **"Base Configuration File"**
3. Или найдите секцию **"Project"** - там тоже может быть

### Шаг 5: Выберите конфигурацию
1. Вверху панели Build Settings есть кнопки: **"All"**, **"Debug"**, **"Release"**, **"DeployOld"**, **"DeployNew"**
2. Нажмите на **"DeployOld"** чтобы увидеть настройки для этой конфигурации
3. Теперь в поле "Base Configuration File" должно быть видно, какой файл подключен

### Шаг 6: Проверьте/Измените
1. Для **DeployOld** должно быть: `Configs/DeployOld.xcconfig`
2. Для **DeployNew** должно быть: `Configs/DeployNew.xcconfig`
3. Для **Debug** должно быть: `Configs/Debug.xcconfig`

Если файл не указан или указан неправильно:
1. Нажмите на поле "Base Configuration File"
2. Выберите правильный .xcconfig файл из списка
3. Или нажмите "+" и добавьте файл

## Альтернативный способ через Project Navigator:

1. В левой панели найдите папку **"Configs"**
2. Убедитесь, что там есть файлы:
   - `Debug.xcconfig`
   - `DeployOld.xcconfig`
   - `DeployNew.xcconfig`
3. Если файлов нет в проекте, добавьте их:
   - Правой кнопкой на папку "Configs" → "Add Files to Convertik..."
   - Выберите файлы .xcconfig

## Визуальное расположение:

```
Xcode Interface:
┌─────────────────────────────────────────┐
│ [Convertik] ← Нажмите здесь (синяя иконка)│
├─────────────────────────────────────────┤
│ [General] [Signing] [Info] [Build Settings] ← Нажмите "Build Settings"
├─────────────────────────────────────────┤
│ [All] [Debug] [DeployOld] [DeployNew]   │ ← Выберите конфигурацию
│                                         │
│ 🔍 [поиск: baseConfiguration]          │ ← Введите здесь
│                                         │
│ Packaging                                │
│   Base Configuration File               │ ← Вот оно!
│     DeployOld: [Configs/DeployOld.xcconfig] │
└─────────────────────────────────────────┘
```

## Если не можете найти:

Попробуйте:
1. В Build Settings нажмите на иконку **"Levels"** (две горизонтальные линии) в правом верхнем углу
2. Это покажет все настройки, включая скрытые
3. Или нажмите на иконку **"Combined"** чтобы увидеть все уровни настроек



