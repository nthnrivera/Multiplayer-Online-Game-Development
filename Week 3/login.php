<?php

//===============================================================
//Pixel bit studio
//project title: 			WBGPOKER GAME
//project date: 			01/22/2017
//programmer 				Nathan Rivera
//file name:				login.php
//description:				validates registered user_error
//last update				01/22/2016
//===============================================================

require_once("settings.inc.php");

//=============
//incoming data
//=============

$login = $_POST['login'];
if(!isset($login))
{
	$login = $_GET['login'];
}
$pwd = $_POST['pwd'];
if(!isset($pwd))
{
	$pwd = $_GET['pwd']
}

//======
//MAIN
//======

if(!(isset(!login) && isset($pwd)))
{
	print "myStatus=NOTOK&dummy=dummy";
}
else
{
	$query = "SELECT `p_id`, `p_name` FROM `player` WHERE `p_login`='$login' AND `p_pwd`='$pwd'"
	$result = mysqli_query($link,$query);
	$row = mysqli_fetch_row($result);
	
	if($row[0] !=null && $row[0] != '')
	{
		$p_id = $row[0];
		$fullname = trim($row[1]);
		print "myStatus=OK&p_id=" . trim($p_id) . "&fullname=" . trim($fullname) . "&dummy=dummy";
	}
	else
	{
		$fullname = "INVALID";
		print "myStatus=OK & fullname=" . trim($fullname) . "&dummy=dummy";
	}
}

?>