CREATE DATABASE IF NOT EXISTS `utility` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `utility`;

CREATE TABLE IF NOT EXISTS `bans` (
  `name` tinytext DEFAULT NULL,
  `data` text DEFAULT NULL,
  `token` text DEFAULT NULL,
  `internal_reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `entities` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `pool` tinytext DEFAULT NULL,
  `model` tinytext DEFAULT NULL,
  `coords` tinytext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `stashes` (
  `identifier` varchar(50) DEFAULT NULL,
  `datas` text DEFAULT NULL,
  `weight` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `users` (
  `identifier` varchar(50) NOT NULL,
  `name` varchar(32) DEFAULT NULL,
  `accounts` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  `identity` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  `jobs` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `inventory` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  `licenses` text DEFAULT '[]',
  `bills` varchar(250) DEFAULT '[]',
  `weapons` text DEFAULT NULL,
  `coords` tinytext DEFAULT '[]',
  `last_quit` tinytext DEFAULT curdate(),
  `external` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This is the table where the Utility Framework store all the data for any player';

CREATE TABLE IF NOT EXISTS `vehicles` (
  `owner` varchar(32) DEFAULT NULL,
  `plate` varchar(8) DEFAULT NULL,
  `data` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;