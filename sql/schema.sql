-- Схема БД для мода с регистрацией/авторизацией (a_mysql)
-- Кодировка: utf8mb4

CREATE DATABASE IF NOT EXISTS `portfolio_samp` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `portfolio_samp`;

-- Аккаунты: логин + пароль (SHA256 с солью)
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(24) NOT NULL COMMENT 'Никнейм в игре',
  `pass` VARCHAR(64) NOT NULL COMMENT 'SHA2(CONCAT(password, salt), 256)',
  `salt` VARCHAR(32) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
