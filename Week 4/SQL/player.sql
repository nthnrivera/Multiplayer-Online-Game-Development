/*
MySQL Data Transfer
Source Host: localhost
Source Database: wbgpoker
Target Host: localhost
Target Database: wbgpoker
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for player
-- ----------------------------
CREATE TABLE `player` (
  `p_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `p_name` varchar(100) NOT NULL,
  `p_email` varchar(100) NOT NULL,
  `p_login` varchar(40) NOT NULL,
  `p_pwd` varchar(40) NOT NULL,
  `p_createTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`p_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records 
-- ----------------------------
INSERT INTO `player` VALUES (null, 'Adam Cartwright', 'adam@ponderosa.org', 'ac', 'c1234', '2013-07-15 19:06:42');
INSERT INTO `player` VALUES (null, 'Donald Duck', 'dduck@disney.com', 'dd', 'd1234', '2013-05-23 15:05:51');
INSERT INTO `player` VALUES (null, 'Daisy Duke', 'dd@tvland.com', 'daisy', 'dd1234', '2013-05-23 18:02:10');
INSERT INTO `player` VALUES (null, 'Minnie Mouse', 'mm@disney.com', 'minniem', 'mm1234', '2013-05-23 18:08:40');
INSERT INTO `player` VALUES (null, 'Mortimer Snerd', 'ms@gmail.com', 'mort', 'ms1234', '2013-06-12 10:31:07');
INSERT INTO `player` VALUES (null, 'The Roadrunner', 'tr@desertdust.com', 'tr', 'tr1234', '2013-07-15 19:08:25');
INSERT INTO `player` VALUES (null, 'Pluto', 'pluto@disney.com', 'pluto', 'p1234', '2013-07-12 09:09:52');
