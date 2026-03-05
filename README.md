# SA-MP Portfolio Mod

Мод для San Andreas Multiplayer: **регистрация и авторизация** через MySQL (плагин a_mysql).

## Содержимое репозитория

| Путь | Описание |
|------|----------|
| `gamemodes/portfolio_rp.pwn` | Исходник геймода (логин/регистрация, диалоги, команды) |
| `gamemodes/README_portfolio.md` | Подробная инструкция по установке и настройке |
| `sql/schema.sql` | Схема БД (таблица `accounts`) |

## Быстрый старт

1. Импортируй `sql/schema.sql` в MySQL.
2. В начале `gamemodes/portfolio_rp.pwn` укажи хост, пользователя, пароль и имя БД.
3. Скомпилируй геймод (нужны инклуды `a_samp` и `a_mysql`).
4. В `server.cfg`: `gamemode0 portfolio_rp 0` и плагин `mysql`.

Подробности — в [gamemodes/README_portfolio.md](gamemodes/README_portfolio.md).

## Технологии

- **Pawn** (SA-MP)
- **a_mysql** (R41+) — асинхронные запросы
- **MySQL / MariaDB** — хранение аккаунтов (пароль как SHA256 + соль)
