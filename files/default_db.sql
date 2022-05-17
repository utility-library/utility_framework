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
/*!40000 ALTER TABLE `objects` ENABLE KEYS */;

-- Dump della struttura di tabella utility.society
CREATE TABLE IF NOT EXISTS `society` (
  `name` tinytext DEFAULT NULL,
  `money` tinytext DEFAULT NULL,
  `deposit` text DEFAULT NULL,
  `weapon` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dump dei dati della tabella utility.society: ~0 rows (circa)
/*!40000 ALTER TABLE `society` DISABLE KEYS */;
INSERT INTO `society` (`name`, `money`, `deposit`, `weapon`) VALUES
	('police', '{"black":0,"bank":100}', '[]', '[]');
/*!40000 ALTER TABLE `society` ENABLE KEYS */;

-- Dump della struttura di tabella utility.users
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
  `weapon_exp` text DEFAULT '[]',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This is the table where the Utility Framework store all the data for any player';

-- Dump dei dati della tabella utility.users: ~4 rows (circa)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`identifier`, `name`, `accounts`, `identity`, `jobs`, `inventory`, `licenses`, `bills`, `weapons`, `coords`, `last_quit`, `external`, `weapon_exp`) VALUES
	('110784a30', '✘ MrFreex™', '[500,10000,0]', '["","","","",""]', '[["unemployed",1,true]]', '[["example",2]]', '[]', NULL, '[]', '[]', '2022-02-27', '{"coords":[422.06,-975.09,30.68],"weapon":{"wheavyrifle":165}}', '"{\\"-947031628\\":72}"'),
	('11525c3cc', 'XenoS', '[500,10000,0]', '["","","","",""]', '[["unemployed",1,true]]', '[["test",10,{"serial":"TEST11458048","dio":"cane"}]]', '{"test":true}', '[["police","Test",1000],["police","Test",1000],["police","Test",1000]]', '[]', '[-258.66,-759.68,32.14]', '2022-04-18', '[]', '[]'),
	('11cd5a037', 'MarKz', '[500,9900,0]', '["","","","",""]', '[["police",3,true]]', '[["example",2]]', '[]', NULL, '{"wheavyrifle":160,"wpistol":0,"wpistol_mk2":0,"wsmg":0}', '[406.83,-992.52,28.86]', '2022-03-02', '{"coords":[406.83,-992.52,28.86],"weapon":{"wheavyrifle":160,"wpistol":0,"wpistol_mk2":0,"wsmg":0}}', '"\\"{\\\\\\"453432689\\\\\\":1}\\""'),
	('14660a99a', 'antonio.kaminari', '[500,10000,0]', '["","","","",""]', '[["unemployed",1,true]]', '[["example",2]]', '[]', NULL, '[]', '[]', '2022-02-23', '{"coords":[92.86,-1940.66,20.64],"weapon":{"wpistol":448,"wassaultrifle":38,"wheavyrifle":18,"wmicrosmg":15}}', '[]');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

-- Dump della struttura di tabella utility.vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
  `owner` varchar(32) DEFAULT NULL,
  `plate` varchar(8) DEFAULT NULL,
  `data` text DEFAULT NULL,
  `trunk` text DEFAULT '{}',
  `coords` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dump dei dati della tabella utility.vehicles: ~0 rows (circa)
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
