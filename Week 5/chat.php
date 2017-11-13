<?php

//=========================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			chat.php
// DESCRIPTION:			Implements server-side chat room with dB
// LAST UPDATE:			01/01/20xx
//=========================================================================================


require_once("settings.inc.php");

//=========================================================================================
// SECTION ONE - INIT CLIENT
//=========================================================================================


 // close first if for post
if ($_POST['requester'] == "initial_request") {

	$status_line = "initial load";
        $body = "";

	
	$query = "SELECT c.c_id,p.p_name,c.c_chat_body,c.c_timestamp FROM chat as c, player as p WHERE c.p_id = p.p_id ORDER BY c.c_timestamp DESC";
		
    $result = mysql_query($query) or die("dB Error 1"); 	
	
	$num = mysql_num_rows($result);

	if($num > 0){
		//process each row (chat row) and append into html body
		for($i=0;$i<$num;$i++){
			$row = mysql_fetch_array($result);
			$id 			= $row["c_id"];
			$player_name 	= $row["p_name"];
			$chat_body 		= $row["c_chat_body"];
			$date_time 		= $row["c_timestamp"];
			$chat_body 		= stripslashes($chat_body);
				
			if($i < $num-1){
				$body .= $player_name . "|" .  $date_time . "|" . $chat_body . "^";
			}else{
				$body .= $player_name . "|" .  $date_time . "|" . $chat_body;
			} // end if-else
		} //end for	
		
		// Find id of latest entry and return as "stored id"
		$query = "SELECT c_id FROM chat ORDER BY c_id DESC LIMIT 1";
		$result = mysql_query($query) or die("dB Error 2");		
		
		while($row = mysql_fetch_array($result)) { 
			$stored_id = $row["c_id"];
		} // end while
		
		print "stored_id=" . trim($stored_id) . "&statusline=" . trim($status_line) . "&returnBody=" . trim($body) . "&dummy=dummy";
	}else{
		
		print "returnBody=NORECORDS&dummy=dummy";
	} // end if-else
		
} // end if
	

if ($_POST['requester'] == "chat_check") {
	
	$status_line = "not_new";
	$stored_id = $_POST['stored_id'];
	//print "Incoming stored_id=" . $stored_id . "&dummy=dummy";
	
	$query = "SELECT c_id FROM chat ORDER BY c_id DESC LIMIT 1";
    $result = mysql_query($query) or die("dB Error 2");
	$num = mysql_num_rows($result) ;
	if ($num > 0){
		while($row = mysql_fetch_array($result)) { 
			$latest_id = $row["c_id"];
		} // end while		
		if ($latest_id > $stored_id) {			 
			 $status_line = "is_new";
			 $body = "";
			 $query2 = "SELECT c.c_id,p.p_name,c.c_chat_body,c.c_timestamp FROM chat as c, player as p WHERE c.p_id = p.p_id ORDER BY c.c_timestamp DESC"; 
			 $result2 = mysql_query($query2) or die("dB Error 3");				 
			 $num2 = mysql_num_rows($result2) ;
			 //process each row (chat row) and append into html body
			for($i=0;$i<$num2;$i++){
				$row2 = mysql_fetch_array($result2);
				$id 			= $row2["c_id"];
				$player_name 	= $row2["p_name"];
				$chat_body 		= $row2["c_chat_body"];
				$date_time 		= $row2["c_timestamp"];
				$chat_body 		= stripslashes($chat_body);
					
				if($i < $num2-1){
					$body .= $player_name . "|" .  $date_time . "|" . $chat_body . "^";
				}else{
					$body .= $player_name . "|" .  $date_time . "|" . $chat_body;
				} // end if-else
			} //end for
			  print "stored_id=" . trim($latest_id) . "&statusline=" . trim($status_line) . "&returnBody=" . trim($body) . "&dummy=dummy";
		} else{
			print "statusline=" . trim($status_line) . "&stored_id =" . trim($stored_id) . "&dummy=dummy";
		} // end if-else
	}else{
		print "returnBody=NORECORDS&dummy=dummy";
	}
}// end if


if ($_POST['requester'] == "new_chat") {

     $player_ip = $_SERVER['REMOTE_ADDR']; 
     $player_id = $_POST['player_id'];
     $chat_body = $_POST['chat_body'];
	
      // Cleanse user input of SQL injection attacks before going to database	 			
     $chat_body = mysql_real_escape_string($chat_body);
	 
     // Add this chat to the chat table
	 $query = "INSERT INTO `chat` 
								(
								`c_id`,
								`c_ip`, 
								`p_id`, 
								`c_chat_body`, 
								`c_timestamp`
								) 
								VALUES
								(
								NULL,
								'$player_ip',
								'$player_id',
								'$chat_body',
								NULL
								)" ; 
								
     $result = mysql_query($query) or die("dB Error 4");  
     
	 $latest_id = mysql_insert_id();

     $body = "";
	
	$query = "SELECT c.c_id,p.p_name,c.c_chat_body,c.c_timestamp FROM chat as c, player as p WHERE c.p_id = p.p_id ORDER BY c.c_timestamp DESC";
		
    $result = mysql_query($query) or die("dB Error 5");
	$num = mysql_num_rows($result);	
	//process each row (chat row) and append into html body
  
		for($i=0;$i<$num;$i++){
			$row = mysql_fetch_array($result);
			$id 			= $row["c_id"];
			$player_name 	= $row["p_name"];
			$chat_body 		= $row["c_chat_body"];
			$date_time 		= $row["c_timestamp"];
			$chat_body 		= stripslashes($chat_body);
				
			if($i < $num-1){
				$body .= $player_name . "|" .  $date_time . "|" . $chat_body . "^";
			}else{
				$body .= $player_name . "|" .  $date_time . "|" . $chat_body;
			} // end if-else
		} //end for
		
	$status_line = "new_insert";
    print "stored_id=" . trim($latest_id) . "&statusline=" . trim($status_line) . "&returnBody=" . trim($body) . "&dummy=dummy";
} // end if

				
				
?>
				