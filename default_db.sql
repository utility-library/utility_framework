-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versione server:              10.4.22-MariaDB - mariadb.org binary distribution
-- S.O. server:                  Win64
-- HeidiSQL Versione:            10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dump della struttura del database utility
CREATE DATABASE IF NOT EXISTS `utility` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `utility`;

-- Dump della struttura di tabella utility.bans
CREATE TABLE IF NOT EXISTS `bans` (
  `name` tinytext DEFAULT NULL,
  `data` text DEFAULT NULL,
  `token` text DEFAULT NULL,
  `internal_reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dump dei dati della tabella utility.bans: ~0 rows (circa)
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;

-- Dump della struttura di tabella utility.objects
CREATE TABLE IF NOT EXISTS `objects` (
  `model` tinytext DEFAULT NULL,
  `coords` tinytext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dump dei dati della tabella utility.objects: ~0 rows (circa)
/*!40000 ALTER TABLE `objects` DISABLE KEYS */;
INSERT INTO `objects` (`model`, `coords`) VALUES
	('prop_weed_01', '[170.23,-1040.68,29.31]');
/*!40000 ALTER TABLE `objects` ENABLE KEYS */;

-- Dump della struttura di tabella utility.society
CREATE TABLE IF NOT EXISTS `society` (
  `name` tinytext DEFAULT NULL,
  `money` tinytext DEFAULT NULL,
  `deposit` text DEFAULT NULL,
  `weapon` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dump dei dati della tabella utility.society: ~4 rows (circa)
/*!40000 ALTER TABLE `society` DISABLE KEYS */;
INSERT INTO `society` (`name`, `money`, `deposit`, `weapon`) VALUES
	('police', '{"bank":0,"black":0}', '[]', '[]'),
	('diocane', '{"black":0,"bank":0}', '[]', '[]');
/*!40000 ALTER TABLE `society` ENABLE KEYS */;

-- Dump della struttura di tabella utility.users
CREATE TABLE IF NOT EXISTS `users` (
  `steam` varchar(10) DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `accounts` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  `inventory` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `jobs` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  `identity` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `other_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'AS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This is the table where the Utility Framework store all the data for any player';

-- Dump dei dati della tabella utility.users: ~6 rows (circa)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`steam`, `name`, `accounts`, `inventory`, `jobs`, `identity`, `other_info`) VALUES
	('11525c3cc', 'XenoS', '[5999,4900,100]', '{"water":{"ciao":[3,{"c":1,"b":"test","a":true}]},"bread":{"nodata":[20],"test":[1]}}', '[[]]', '["XenoS","","","male",""]', '{"coords":[511.48,-188.78,52.43]}'),
	('11cd5a037', 'MarKz', '[0,0,0]', '{"bread":{"nodata":[15]}}', '[[]]', '["","","","",""]', '{"coords":[-1712.28,-511.4,37.52],"scripts":{"thirst":49.61700000000088,"hunger":49.61700000000088}}'),
	('10e44d76f', 'stemon', '[500,10000,0]', '{"example":{"nodata":[100]}}', '[["unemployed",1,true]]', '["","","","",""]', '{"scripts":{"hunger":49.8290000000004,"thirst":49.8290000000004},"coords":[-269.67,-1140.96,23.08]}');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

-- Dump della struttura di tabella utility.vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
  `plate` varchar(8) DEFAULT NULL,
  `data` text DEFAULT NULL,
  `trunk` text DEFAULT '{}'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dump dei dati della tabella utility.vehicles: ~4 rows (circa)
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` (`plate`, `data`, `trunk`) VALUES
	('06DLN645', '{"neon":[255,false,false,false,false,[255,0,255]],"windowTint":-1,"fuel":80.0,"wheels":3,"livery":-1,"color":[5,0,111,156,[255,255,255]],"health":[896.0,938.2,988.6],"plate":["06DLN645",0],"model":142944341,"mods":[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,false,false,false,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],"extras":["10"],"class":3}', '[]'),
	('29QGD666', '{"health":[992.9,989.3,999.3],"model":2046537925,"wheels":1,"windowTint":-1,"mods":[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,false,false,false,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],"neon":[255,false,false,false,false,[255,0,255]],"livery":0,"fuel":65.0,"extras":["1"],"color":[134,134,0,156,[255,255,255]],"plate":["29QGD666",4],"class":3}', '{"bread":{"nodata":[100]}}');
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
