<?php  //WBGPOKER getGames.php

require_once("settings.inc.php");

$p_id = $_POST['p_id'];
if(!isset($p_id)){
	$p_id = $_GET['p_id'];
}

function getPlayerName($g_id){
	$query = "SELECT p.`p_name` FROM `player` as p INNER JOIN `game_player` AS gp 
				WHERE gp.`g_id`=$g_id AND gp.`p_id`=p.`p_id` ORDER BY gp.`p_id` ASC LIMIT 1";
	$result = mysql_query($query);	
	
	if ($row = mysql_fetch_row($result)){
		return $row[0];
	}else{
		die("myStatus=dbERROR");
	}
} // end function

$query = "SELECT `g_id`,`g_gameInit` FROM `game` WHERE `g_gameInit` IS NOT NULL AND `g_gameStart` IS NULL
				ORDER BY `g_gameInit` ASC";
$result = mysql_query($query); 	


if(mysql_num_rows($result) > 0){
	// Init vars
	$status = "myStatus=OK";
	$outputString = "&output=";	
	//process each row (game row) and append into output string delimited by "|" and "^" for fields and rows
	$num = mysql_num_rows($result);
	for($i=0;$i < $num;$i++){
		$row = mysql_fetch_array($result); 
		$g_id 			= $row["g_id"];
		$player_name 	= getPlayerName($g_id);
		$gameInitTime	= $row["g_gameInit"];
		if ($i < $num-1){
			$outputString .= $g_id . "|" . trim($player_name) . "|" . $gameInitTime . "^";
		}else{
			$outputString .= $g_id . "|" . trim($player_name) . "|" . $gameInitTime;
		}
	} //end for
		
	print trim($status) . trim($outputString) . "&dummy=dummy";	
}else{
	print "myStatus=NOTOK&dummy=dummy";
	
} // end if-else



?>
	