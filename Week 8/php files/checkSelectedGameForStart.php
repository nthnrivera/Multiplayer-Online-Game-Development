<?php
	
//=================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			checkSelectedGameForStart.php
// DESCRIPTION:			Checks to see if selected has started play 
// LAST UPDATE:			01/01/20xx
//=================================================================================

require_once("settings.inc.php");

//=================================================================================
// GLOBALS & CONSTANTS
//=================================================================================


//=================================================================================

// INCOMING VARIABLES
//=================================================================================
$g_id = $_POST['g_id'];
if(!isset($g_id)){
	$g_id = $_GET['g_id'];
} //end if



//=================================================================================
// MAIN
//=================================================================================

// Check if too many players
$query = "SELECT `g_gameStart` FROM `game` WHERE `g_id` = $g_id";

$result = mysql_query($query) or die("dB Error 1"); 	


$row = mysql_fetch_row($result);

if( $row[0] == null){
	print "myStatus=GAME_NOT_STARTED&dummy=dummy";
	
}else{ // get the players send back to client
	// Get all current players from game_player table for this game inner join player table for name
	$query1 = "SELECT count(`gpl_id`) FROM `game_player` WHERE `g_id` = $g_id";

	$result1 = mysql_query($query1) or die("dB Error 2"); 	
	

	$row1 = mysql_fetch_row($result1);
	$N = $row1[0];
		
	$query2 = "SELECT gp.`p_id`,p.`p_name` FROM `game_player` AS gp, `player` AS p WHERE gp.`g_id` = $g_id AND gp.`p_id`= p.`p_id` ORDER BY gp.`gpl_id` ASC";
	$result2 = mysql_query($query2) or die("dB Error 3");
	
		
	//Initialize the string variable to hold return players and other info
	$returnString = "myStatus=GAME_STARTED&g_num_players=" . $N . "&playerStr=";
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
} //end else


	


?>
	