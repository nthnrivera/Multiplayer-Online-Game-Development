<?php
	
//=================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			beginNewGame.php
// DESCRIPTION:			Begins gamePlay for a game 
// LAST UPDATE:			01/01/20xx
//=================================================================================

require_once("settings.inc.php");

//=================================================================================
// GLOBALS & CONSTANTS
//=================================================================================


//=================================================================================

// INCOMING VARIABLES
//=================================================================================
//Incoming variables with data from individual game players - dealer is server
// and other players are clients

// Automatically convert GET or POST vars to their local variable names eg: ['fName'] => $fName
// Do not use this for user input 
foreach(${"_" . $_SERVER["REQUEST_METHOD"]} as $k=>$v) $$k=$v;

/*
$req_status = $_POST['req_status'];
if(!isset($req_status)){
	$req_status = $_GET['req_status'];
} // end if
	
$gameID = $_POST['gameID'];
if(!isset($gameID)){
	$gameID = $_GET['gameID'];
} // end if
/*
$playerID = $_POST['playerID'];
if(!isset($playerID)){
	$playerID = $_GET['playerID'];
} // end if
	
$theGameObject = $_POST['theGameObject'];
if(!isset($theGameObject)){
	$theGameObject = $_GET['theGameObject'];
} // end if	

*/
//================================================================================
// MAIN 
//================================================================================
if(!isset($req_status)){
	print "Unspecified Error&dummy=dummy";
}else{
	switch ($req_status){
		case "server_start":
			// Update game table with start time,1 for round and transfer theGame data structure as byte array to the dB table game
			$query = "UPDATE `game` SET `g_gameStart` = now(),`g_currentRound`=1, `g_theGame`='$theGameObject' WHERE `g_id` = $gameID";
			$result = mysql_query($query) or die("dB Error 1");
			
			print "myStatus=OK&dummy=dummy";
			break;
	
		case "client_start":
	
			// send to client bytearray from game row
			$query3 = "SELECT `g_theGame` FROM `game` where `g_id`=$gameID";
			$result3 = mysql_query($query3) or die("dB Error 2");
						
			$row = mysql_fetch_assoc($result3);
			print "theGame=" . trim($row['g_theGame']) . "&dummy=dummy";
			//print "theGame=" . trim($row['g_theGame'])  . "&dummy=dummy";
			
	} // end switch
	
} //end else




?>
	