<?php
	
//=================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			placeBet.php
// DESCRIPTION:			Logs in a bet for game, player, round and amount in the bet table
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
	
$p_id= $_POST['p_id'];
if(!isset($p_id)){
	$p_id = $_GET['p_id'];
} // end if
	
$theRound= $_POST['theRound'];
if(!isset($theRound)){
	$theRound = $_GET['theRound'];
} // end if

$b = $_POST['bet_amt'];
if(!isset($b)){
	$b = $_GET['bet_amt'];
} // end if	

//=================================================================================
// SUPPORTING FUNCTIONS
//=================================================================================
function hasDuplicate($g,$r,$p){
	//create query
	$query = "SELECT `b_id` FROM `bet` WHERE `g_id`=$g AND `b_round`=$r AND `p_id`=$p";
	$result = @mysql_query($query);
	if(mysql_error()) handleError("query 0");
	
	if(mysql_num_rows($result) > 0){
		return true;
	}else{
		return false;
	}
} // end function
		
function getTotalPot($gameID){
    $query = "SELECT sum(`b_amt`) FROM `bet` WHERE `g_id` = $gameID";
    $result = @mysql_query($query);
    if(mysql_error()) handleError("query 7"); 
    $row = mysql_fetch_row($result);
    return $row[0];
}  //end function		
//=================================================================================
// MAIN
//=================================================================================
if(hasDuplicate($g_id,$theRound,$p_id)==false){
		// insert the following into the bet table
		$query = "INSERT INTO `bet`
							(
							`b_id`,
							`g_id`,
							`p_id`,
							`b_round`,
							`b_amt`
							)
							VALUES
							(
							NULL,
							$g_id,
							$p_id,
							$theRound,
							$b
							)";
						
			
		$result = @mysql_query($query);
		if(mysql_error()) handleError("query 1");
		
	$pot = getTotalPot($g_id);
	
	print "myStatus=OK&thePot=" . $pot;
	
	
}else{
	print "myStatus=DUPLICATE";
} // end if-else

print "&dummy=dummy";

?>
	