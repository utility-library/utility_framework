CREATE DATABASE IF NOT EXISTS `utility`
USE `utility`;

CREATE TABLE IF NOT EXISTS `bans` (
  `name` tinytext DEFAULT NULL,
  `data` text DEFAULT NULL,
  `token` text DEFAULT NULL,
  `internal_reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `objects` (
  `model` tinytext DEFAULT NULL,
  `coords` tinytext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `society` (
  `name` tinytext DEFAULT NULL,
  `money` tinytext DEFAULT NULL,
  `deposit` text DEFAULT NULL,
  `weapon` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `society` (`name`, `money`, `deposit`, `weapon`) VALUES
	('police', '{"bank":0,"black":0}', '[]', '[]'),

CREATE TABLE IF NOT EXISTS `users` (
  `steam` varchar(10) DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `accounts` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  `inventory` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `jobs` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  `identity` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `other_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'AS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This is the table where the Utility Framework store all the data for any player';

CREATE TABLE IF NOT EXISTS `vehicles` (
  `plate` varchar(8) DEFAULT NULL,
  `data` text DEFAULT NULL,
  `trunk` text DEFAULT '{}'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
