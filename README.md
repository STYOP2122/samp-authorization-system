# SA-MP Account System

Геймод для SA-MP с регистрацией и входом через игровые диалоги. Аккаунты хранятся в MySQL; запросы выполняются асинхронно через плагин a_mysql.

## Возможности

- Регистрация аккаунта по игровому нику.
- Вход с проверкой пароля.
- Хранение SHA256-хеша пароля и соли.
- Команда `/stats` для просмотра имени и ID аккаунта.
- Команды `/q` и `/quit` для выхода с сервера.

## Требования

Сервер SA-MP с поддержкой используемых Pawn-функций, компилятор Pawn, include-файлы `a_samp` и `a_mysql`, плагин MySQL R41+ и база MySQL или MariaDB. Подробная инструкция рассчитана на SA-MP 0.3.DL или совместимый сервер.

## Быстрый старт

```bash
git clone https://github.com/STYOP2122/samp-authorization-system.git
cd samp-authorization-system
```

1. Импортируйте `sql/schema.sql`: скрипт создаёт базу `portfolio_samp` и таблицу `accounts`.
2. Укажите параметры подключения в начале `gamemodes/portfolio_rp.pwn`.
3. Скомпилируйте файл и поместите `portfolio_rp.amx` в папку `gamemodes/` сервера.
4. Установите плагин MySQL в папку `plugins/` и добавьте в `server.cfg`:

```ini
gamemode0 portfolio_rp 0
plugins mysql
```

Подробная настройка и описание таблицы — в [инструкции](gamemodes/README_portfolio.md).

## Файлы

- `gamemodes/portfolio_rp.pwn` — авторизация, регистрация, диалоги и команды.
- `sql/schema.sql` — схема базы данных.
- `gamemodes/README_portfolio.md` — инструкция по настройке.
