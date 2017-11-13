<?php
	
//=================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			initNewGame.php
// DESCRIPTION:			Initializes a new game with requester as dealer
// LAST UPDATE:			01/01/20xx
//=================================================================================

require_once("settings.inc.php");

//=================================================================================
// GLOBALS & CONSTANTS
//=================================================================================
$MAX_GAMES = 3;  // your choice of number here

//=================================================================================

// INCOMING VARIABLES
//=================================================================================
//this will be the incoming player requesting a new game -- with capability of using GET for testing
$p_id = $_POST['p_id'];
if(!isset($p_id)){
	$p_id = $_GET['p_id'];
} // end if
	
//=================================================================================
// MAIN
//=================================================================================

// First, check whether our player is currently in a game (one entry per login)
$query = "SELECT gp.`g_id` FROM `game_player` AS gp,`game` AS g WHERE gp.`g_id` = g.`g_id` AND gp.`p_id`= $p_id AND g.`g_gameOver` IS null";
$result = mysql_query($query) or die("myStatus=ERROR 1");


if (mysql_num_rows($result) > 0){
	print "myStatus=GAMEINPLAY&dummy=dummy";	
	
}else{
	
	// Second, check whether there are too many games 
	$query1 = "SELECT * FROM `game` WHERE `g_gameStart` IS NULL";
	$result1 = mysql_query($query1) or die(	"myStatus=ERROR 2");

	if (mysql_num_rows($result1) < $MAX_GAMES){
		// continue with start-up -- insert query -- only fields that need be initialized
		// others will have default values per dB design
		$query2 = "INSERT INTO `game`
							(
							`g_id`,	
							`g_gameInit`,
                            `g_currentRound`                            					
							)
							VALUES
							(
							NULL,	
							NULL,
                            -1                          				
							)";
		$result2 = mysql_query($query2) or die("myStatus=ERROR 3");		
		//Get the last insert ID from mySQL server
		$new_game_id = mysql_insert_id();
		//print "New game ID= " . $new_game_id;
		// Create new record in game_player table
		$query3 = "INSERT INTO `game_player`
							(
							`gpl_id`,	
							`g_id`,
							`p_id`
							)
							VALUES
							(
							NULL,	
							$new_game_id,
							$p_id
							)";
		$result3 = mysql_query($query3) or die("myStatus=ERROR 4");		
		$new_game_player_id = mysql_insert_id();
		
		
		//Send back to client "status" and the new game ID	
		print "myStatus=OK&g_id=" . trim($new_game_id) . "&gp_id=" . trim($new_game_player_id) . "&dummy=dummy";	
		
	}else{
		print "myStatus=TOOMANY&dummy=dummy";		
	} //end if-else
} //end else


?>
	