<?php
	
//============================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			getPlayers.php
// DESCRIPTION:			Determines who has signed up for a given game
// LAST UPDATE:			01/01/20xx
//============================================================================

require_once("settings.inc.php");

//============================================================================
// INCOMING VARIABLES
//============================================================================
$g_id = $_POST['g_id'];
if(!isset($g_id)){
	$g_id = $_GET['g_id'];
} //end if

$g_num_players = $_POST['g_num_players'];
if(!isset($g_num_players)){
	$g_num_players = $_GET['g_num_players'];
} // end if


//=============================================================================
// MAIN
//=============================================================================

// Check if change
$query = "SELECT count(`gpl_id`) FROM `game_player` WHERE `g_id` = $g_id";

$result = mysql_query($query) or die("dB Error 1"); 	

$row = mysql_fetch_row($result);
$N = $row[0];
if( $N == 0){
	print "myStatus=NULLSET&dummy=dummy";
	exit;
}

if($N > $g_num_players){
	
	// Get all current players from game_player table for this game inner join player table for name
	$query2 = "SELECT gp.`p_id`,p.`p_name` FROM `game_player` AS gp, `player` AS p 
				WHERE gp.`g_id` = $g_id AND gp.`p_id`= p.`p_id`
				ORDER BY gp.`gpl_id` ASC";
	$result2 = mysql_query($query2) or die("dB Error 2");
	
		
	//Initialize the string variable to hold return players and other info
	$returnString = "myStatus=OK&g_num_players=" . trim($N) . "&playerStr=";
	// loop through the number of players rows indicated by $N total -- starting index = 4 in table
	for($i=0;$i<$N;$i++){
		$row2 = mysql_fetch_array($result2);
		if($i<$N-1){ // up to second to last line
			// add for each player: id and name separated by "|" character and line ended with "^" character
			$returnString .= $row2[0] . "|" . $row2[1] ."^";
		}else{ // last line
			$returnString .= $row2[0] . "|" . $row2[1];
		} // end if-else
	} //end for
	
	//send back to client
	print trim($returnString) . "&dummy=dummy";
	 
}else{
	print "myStatus=NOCHANGE&dummy=dummy";
}


?>
