<?php
	
//=================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			getBets.php
// DESCRIPTION:			Returns info to both server and clients on given game
// LAST UPDATE:			01/01/20xx
//=================================================================================

require_once("settings.inc.php");

//=================================================================================
// GLOBALS & CONSTANTS
//=================================================================================
$numPlayers = 0;
$round = 0;	
$numBets = 0;


//=================================================================================
// INCOMING VARIABLES
//=================================================================================

$g_id = $_POST['g_id'];
if(!isset($g_id)){
	$g_id = $_GET['g_id'];
} // end if
	
//=================================================================================
// SUPPORTING FUNCTIONS
//=================================================================================
	
function gameOver($gameID){
	// Get current round from game
	$query = "SELECT * FROM `game` WHERE `g_id`=$gameID AND `g_gameOver` IS NULL";	
	$result = @mysql_query($query);
	if(mysql_error()) handleError("query 1");
	
	if(mysql_num_rows($result)==0){
		return true;
	}else{
		return false;
	} // end if-else
		
} // end function

function gameIsOver($gameID){
    $query = "UPDATE `game` SET `g_gameOver` = now() WHERE `g_id`=$gameID";
    $result = @mysql_query($query);
    if(mysql_error()) handleError("query 1a");
}
			
function getCurrentRound($gameID){
	// Get current round from game
	$query = "SELECT `g_currentRound` FROM `game` WHERE `g_id`=$gameID";	
	$result = @mysql_query($query);
	if(mysql_error()) handleError("query 2");	
	$row = mysql_fetch_row($result);
	return $row[0];
	
} // end function
	
function getNumPlayers($gameID){
	$query = "SELECT count(`gpl_id`) FROM `game_player` WHERE `g_id` = $gameID";
	$result = @mysql_query($query);
	if(mysql_error()) handleError("query 3");
	$row = mysql_fetch_row($result);
	return $row[0];
	
} // end function
	
function getNumBetsForRound($gameID,$round){
	$query = "SELECT * FROM `bet` WHERE `g_id`=$gameID AND `b_round`= $round";	
	$result = @mysql_query($query);
	if(mysql_error()) handleError("query 4");
	return mysql_num_rows($result);
} //end function
	
function updateRound($gameID){
    $query = "UPDATE `game` SET `g_currentRound` = `g_currentRound` + 1 WHERE `g_id` = $gameID";
    $result = mysql_query($query);
    if(mysql_error()) handleError("query 5"); 
}//end function 
	

    
function getAllBets($gameID){
     $data = "";
     $query = "SELECT `b_round`,`b_id`,`p_id`,`b_amt` FROM `bet` WHERE `g_id`=$gameID ORDER BY `b_round`, `b_id` ASC";
     $result = @mysql_query($query);
     if(mysql_error()) handleError("query 6");
     $N = mysql_num_rows($result);
     
     
     for($i=0;$i<$N;$i++){
         $row = mysql_fetch_assoc($result);
         if($i < $N-1)  {
           $data .=  $row['b_round'] . "|" . $row['b_id'] . "|" . $row['p_id'] . "|" . $row['b_amt'] . "^";
         }else{
            $data .=  $row['b_round'] . "|" . $row['b_id'] . "|" . $row['p_id'] . "|" . $row['b_amt'];
         } // end if          
     }//end for
     
      return $data;  
     
} //end function

function getTotalPot($gameID){
    $query = "SELECT sum(`b_amt`) FROM `bet` WHERE `g_id` = $gameID";
    $result = @mysql_query($query);
    if(mysql_error()) handleError("query 7"); 
    $row = mysql_fetch_row($result);
    return $row[0];
}  //end function

function updateGame($gameID,$pot){
    $query = "UPDATE `game` SET `g_win_pot`=$pot WHERE `g_id` = $gameID";
    $result = @mysql_query($query);
    if(mysql_error()) handleError("query 8"); 
    
}
	
//=================================================================================
// MAIN
//=================================================================================
if (!gameOver($g_id)){
	
	$round = getCurrentRound($g_id);  
	$numPlayers = getNumPlayers($g_id);   
	$numBets = getNumBetsForRound($g_id,$round);
    $pot = getTotalPot($g_id);
	
	if($round < 4){    		
	    if($numBets == $numPlayers){ //all bets for round are in			
            updateRound($g_id);
            $round = getCurrentRound($g_id);       
		} //end if
		$returnString = "myStatus=OK&theRound=" . $round . "&totalPot=" . $pot;
    }elseif($round == 4){  // else last betting round (4)
		if($numBets == $numPlayers){ //all bets for round are in and game is over	
			gameIsOver($g_id);		
			updateGame($g_id,$pot);
			$returnString = "myStatus=GAME_OVER&totalPot=" . $pot; 		
		}else{ //some bets, but not all
			$returnString = "myStatus=OK&theRound=" . $round . "&totalPot=" . $pot;
		} // end if-elseif-else
			
    }else{
        $returnString = "myStatus=ERROR_IN_ROUND";
    }//end if-elseif-else

}else{ // Game is over
  $pot = getTotalPot($g_id);
  updateGame($g_id,$pot);
  $returnString = "myStatus=GAME_OVER&totalPot=" . $pot;  
}// end if-else

$returnString .= "&server_data=" . getAllBets($g_id);
print $returnString;
print "&dummy=dummy";
    
 
?>

	