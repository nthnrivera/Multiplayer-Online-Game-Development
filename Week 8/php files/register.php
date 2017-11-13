<?php

//=========================================================================================
// YOUR BUSINESS NAME
// PROJECT TITLE:		WBGPOKER GAME
// PROJECT DATE:		01/01/20xx
// PROGRAMMER: 			you
// FILE NAME:			register.php
// DESCRIPTION:			Validates registered user 
// LAST UPDATE:			01/01/20xx
//=========================================================================================


require_once("settings.inc.php");


//=========================================================================================
// INCOMING DATA
//=========================================================================================
// Create vars and load with incoming POST data 

$fullname = $_POST['fullname'];
$email = $_POST['email'];
$login = $_POST['login'];
$pwd = $_POST['pwd'];

//========= Check Login Name and PWD ====================
if(!isset($fullname)){
	print "myStatus=DATAERROR1";
	die("myStatus=DATAERROR1");
}
if(!isset($email)){
	print "myStatus=DATAERROR2";
	die("myStatus=DATAERROR2");
}
if(!isset($login)){
	print "myStatus=DATAERROR3";
	die("myStatus=DATAERROR3");
}
if(!isset($pwd)){
	print "myStatus=DATAERROR4";
	die("myStatus=DATAERROR2");
}


//=========================================================================================
// MAIN
//=========================================================================================



$query = "INSERT INTO `player`
				(
				`p_id`,
				`p_name`,
				`p_email`,
				`p_login`,
				`p_pwd`				
				)
				VALUES
				(
				NULL,
				'$fullname',
				'$email',
				'$login',
				'$pwd'				
				)";
				
					 
$result = @mysql_query($query);
if(mysql_error()) handleError("query 1");
$p_id = mysql_insert_id();

//send results back to client
print "myStatus=OK";
print "&fullname=" . $fullname;
print "&p_id=" . $p_id;
print "&dummy=dummy";
				
				
?>
				