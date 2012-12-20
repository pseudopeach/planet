SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


CREATE TABLE `game_players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `next_player_id` int(11) DEFAULT NULL,
  `owner_player_id` int(11) DEFAULT NULL,
  `name` varchar(64) CHARACTER SET utf16 NOT NULL,
  `prototype_player_id` int(11) DEFAULT NULL,
  `engineering_cost` float DEFAULT NULL,
  `launch_cost` float DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `data` text,
  `type` varchar(64) NOT NULL DEFAULT 'Game::Player',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
