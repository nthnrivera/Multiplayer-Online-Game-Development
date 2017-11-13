/*
MySQL Data Transfer
Source Host: localhost
Source Database: wbgpoker
Target Host: localhost
Target Database: wbgpoker
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for game_player
-- ----------------------------
CREATE TABLE `game_player` (
  `gpl_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `g_id` smallint(6) NOT NULL,
  `p_id` smallint(6) NOT NULL,
  PRIMARY KEY (`gpl_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records 
-- ----------------------------
INSERT INTO `game_player` VALUES ('1', '1', '3');
INSERT INTO `game_player` VALUES ('2', '2', '1');
INSERT INTO `game_player` VALUES ('3', '1', '2');
INSERT INTO `game_player` VALUES ('4', '1', '4');
INSERT INTO `game_player` VALUES ('5', '2', '6');
INSERT INTO `game_player` VALUES ('6', '2', '7');
INSERT INTO `game_player` VALUES ('7', '1', '8');
INSERT INTO `game_player` VALUES ('8', '3', '5');
INSERT INTO `game_player` VALUES ('9', '2', '8');
