<?php
	
//=================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			updateRound.php
// DESCRIPTION:			Increments current round in game table
// LAST UPDATE:			01/01/20xx
//=================================================================================

require_once("settings.inc.php");

//=================================================================================
// GLOBALS & CONSTANTS
//=================================================================================


//=================================================================================

// INCOMING VARIABLES
//=================================================================================
//this will be the incoming player requesting a new game
$g_id = $_POST['g_id'];
if(!isset($g_id)){
	$g_id = $_GET['g_id'];
} // end if
	
$theRound= $_POST['theRound'];
if(!isset($theRound)){
	$theRound = $_GET['theRound'];
} // end if
	
//=================================================================================
// MAIN
//=================================================================================

$query = "UPDATE `game` SET `g_currentRound` = '$theRound' WHERE `g_id` = $g_id";
$result = @mysql_query($query);
if(mysql_error()) handleError("query 1");

print "myStatus=OK&dummy=dummy";

?>
	