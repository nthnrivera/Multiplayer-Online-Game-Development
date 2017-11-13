<?php

//=========================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			login.php
// DESCRIPTION:			Validates registered user 
// LAST UPDATE:			01/01/20xx
//=========================================================================================


require_once("settings.inc.php");


//=========================================================================================
// INCOMING DATA
//=========================================================================================
// Create vars and load with incoming POST data 

$login = $_POST['login'];
if(!isset($login)){
	$login = $_GET['login'];
}
$pwd = $_POST['pwd'];
if(!isset($pwd)){
	$pwd = $_GET['pwd'];
}


//=========================================================================================
// MAIN
//=========================================================================================

if(!(isset($login) && isset($pwd))){
	print "myStatus=NOTOK&dummy=dummy";
}else{
	$query = "SELECT `p_id`,`p_name` FROM `player` WHERE `p_login`='$login' AND `p_pwd`='$pwd'";						 
	$result = mysql_query($query) or die("dB Problem");
	$row = mysql_fetch_row($result);
	if($row[0] != null && $row[0] != ''){
		$p_id = $row[0];
		$fullname =  trim($row[1]);
		print "myStatus=OK&p_id=" . trim($p_id) . "&fullname=" . trim($fullname) . "&dummy=dummy";		
	}else{
		$fullname = "INVALID";		
		print "myStatus=OK&fullname=" . trim($fullname) . "&dummy=dummy";		
	} //end else	

} //end else
				
				
?>
				