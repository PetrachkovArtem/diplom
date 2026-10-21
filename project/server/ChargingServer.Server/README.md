# ChargingServer — сервер АСУ «Заряди сам»

ASP.NET Core CSMS: OCPP 2.0.1 (WebSocket) + JWT HTTP API + SignalR для статусов сессии.

## Требования

- .NET 10 SDK
- PostgreSQL

## Настройка

В `appsettings.json` / `appsettings.Development.json`:

- `ConnectionStrings:Default` — строка PostgreSQL
- `Jwt:Key` — секрет подписи JWT (не короче 32 символов)
- `Admin:Email` / `Admin:Password` — учётная запись администратора (создаётся при первом запуске)

## Запуск

```bash
dotnet run --project ChargingServer.Server
```

По умолчанию: `http://localhost:5024`.

При старте применяются миграции EF и создаётся админ, если его ещё нет.

## OCPP 2.0.1

Станция подключается к:

```text
ws://{host}/ocpp/{bindToken}/{chargePointId}
```

`bindToken` пользователь получает через `GET /api/stations/bind-url` (после входа).  
Подпротокол: `ocpp2.0.1`.

Поддерживаемые операции: BootNotification, Heartbeat, Authorize, StatusNotification, TransactionEvent, RequestStartTransaction, RequestStopTransaction.

## HTTP API (кратко)

| Метод | Путь | Роль |
|-------|------|------|
| POST | `/api/auth/register` | аноним |
| POST | `/api/auth/login` | аноним |
| GET | `/api/me` | User/Admin |
| POST | `/api/me/password` | User/Admin |
| GET | `/api/stations` | User |
| GET | `/api/stations/bind-url` | User |
| PATCH | `/api/stations/{id}` | User |
| DELETE | `/api/stations/{id}` | User |
| POST | `/api/sessions/start` | User |
| POST | `/api/sessions/stop` | User |
| GET | `/api/sessions/current` | User |
| GET | `/api/sessions/history` | User |
| GET | `/api/admin/users` | Admin |
| POST | `/api/admin/users/{id}/block` | Admin |
| POST | `/api/admin/users/{id}/reset-password` | Admin |

Live-обновления: SignalR hub `/hubs/session` (JWT в query `access_token`).

## Лог OCPP (как в образце VoltFuel)

Категория `OccpLogger` пишет трафик станции в файл:

```text
logs/requests.log
```

Формат строк: `CP -> {id}: ...` (от станции), `CP <- {id}: ...` (к станции).  
Ошибки WebSocket — только при `"LogWSError": true`.

## Проекты

- `ChargingServer.Ocpp` — протокол OCPP 2.0.1 на `System.Text.Json`
- `ChargingServer.Server` — домен, PostgreSQL, REST, OCPP endpoint
