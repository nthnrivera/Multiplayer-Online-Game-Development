<?php
	
//=================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			joinSelectedGame.php
// DESCRIPTION:			Joins this player-client to an existing game 
// LAST UPDATE:			01/01/20xx
//=================================================================================

require_once("settings.inc.php");

//=================================================================================
// GLOBALS & CONSTANTS
//=================================================================================
$MAX_PLAYERS = 5;  // your choice of number

//=================================================================================

// INCOMING VARIABLES
//=================================================================================
$g_id = $_POST['g_id'];
if(!isset($g_id)){
	$g_id = $_GET['g_id'];
} //end if

$p_id = $_POST['p_id'];
if(!isset($p_id)){
	$p_id = $_GET['p_id'];
} // end if

//=================================================================================
// MAIN
//=================================================================================

// First, check whether our player is currently in this game (one entry per login)
$query = "SELECT `p_id` FROM `game_player` WHERE `g_id` = $g_id AND `p_id` = $p_id";
$result = mysql_query($query) or die("dB Error 1");


if (mysql_num_rows($result) > 0){
	print "myStatus=GAMEINPLAY&dummy=dummy";
	
}else{
	// Check if too many players
	$query1 = "SELECT count(`gpl_id`) FROM `game_player` WHERE `g_id` = $g_id";
	$result1 = mysql_query($query1) or die("dB Error 2");	

	$row = mysql_fetch_row($result1);
	$N = $row[0];
	if( $N == 0){
		print "myStatus=NULLSET&dummy=dummy";
		exit;
	}

	if ($N < $MAX_PLAYERS){		
		// Add player to given game - update dB row
		$query2 = "INSERT INTO `game_player` 
							(
							`gpl_id`,
							`g_id`,
							`p_id`
							)
							VALUES
							(
							NULL,
							$g_id,
							$p_id
							)";
						
		$result2 = mysql_query($query2) or die("dB Error 3");		
		
		$game_player_id = mysql_insert_id();
		print "myStatus=OK&gpl_id=" . trim($game_player_id) . "&dummy=dummy";
	}else{
		print "myStatus=TOOMANY&dummy=dummy";
	} //end if-else
} // end else

?>
	