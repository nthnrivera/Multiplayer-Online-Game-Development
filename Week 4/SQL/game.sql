/*
MySQL Data Transfer
Source Host: localhost
Source Database: wbgpoker
Target Host: localhost
Target Database: wbgpoker
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for game
-- ----------------------------
CREATE TABLE `game` (
  `g_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `g_gameInit` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `g_gameStart` timestamp NULL DEFAULT NULL,
  `g_gameOver` timestamp NULL DEFAULT NULL,
  `g_currentRound` smallint(6) DEFAULT NULL,
  `g_win_pot` int(11) DEFAULT NULL,
  `g_win_p_id` smallint(6) DEFAULT NULL,
  `g_theGame` blob,
  PRIMARY KEY (`g_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records 
-- ----------------------------
INSERT INTO `game` VALUES ('1', '2013-07-15 17:26:08', null, null, '-1', null, null, null);
INSERT INTO `game` VALUES ('2', '2013-07-15 17:45:00', null, null, '-1', null, null, null);
INSERT INTO `game` VALUES ('3', '2013-07-15 19:09:01', null, null, '-1', null, null, null);
