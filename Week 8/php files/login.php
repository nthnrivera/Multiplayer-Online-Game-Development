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

//========= Check Login Name and PWD ====================
if(!isset($login)){
	die("myStatus=DATAERROR1");
}
if(!isset($pwd)){
	die("myStatus=DATAERROR2");
}

//=========================================================================================
// MAIN
//=========================================================================================


$query = "SELECT count(`p_id`),`p_id`,`p_name` FROM `player` WHERE `p_login`='$login' AND `p_pwd`='$pwd'";
					 
$result = mysql_query($query) or die("myStatus=QUERY-ERROR");


$row = mysql_fetch_row($result);
if($row[0] > 0){
	$p_id = $row[1];
	$fullname = $row[2];
	print "myStatus=OK&fullname=" . trim($fullname) . "&p_id=" . trim($p_id).  "&dummy=dummy";
}else{
	$fullname = "INVALID";
	print "myStatus=OK&fullname=" . trim($fullname) . "&dummy=dummy";
}



				
				
?>
				