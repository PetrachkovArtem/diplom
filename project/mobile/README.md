# Заряди сам — мобильное приложение

Flutter MVVM (как etin-mobile): `features/*/view|view_model|model`, `Provider`, `services/*Manager`.

Пакет: `ru.petrachkovae.charging_app`

## Запуск

```bash
# сервер на http://localhost:5024
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5024
```

Для устройства в той же сети укажите IP ПК:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5024
```

## Цвета

Как у админки: белый фон, accent `#2F6F4E`.
