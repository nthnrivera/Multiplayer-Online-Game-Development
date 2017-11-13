package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import MainDocument;
	//import GameServer;
	//import GameClient;
	import flash.net.*;
	import flash.display.SimpleButton;	
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import fl.controls.List;
	import fl.controls.Button;
	import fl.data.DataProvider;
	import flash.text.*;
	import fl.controls.TextArea;
	
	
	public class Console extends MovieClip {
		//===============================================================
		// SERVER COMM - Set up server communications variables
		//===============================================================		
		
		// Timer for checking games availability
		private var timeToCheckGames:Timer = new Timer(10000,1);
		private var timeToCheckForPlayers:Timer = new Timer(5000,1);
		private var timeToCheckForGameStart:Timer = new Timer(5000,1);
		
		// Variables to hold data for transfer to and from server
		private var getGamesVars:URLVariables = new URLVariables();	
		private var newGameVars:URLVariables = new URLVariables();
		private var getPlayersVars:URLVariables = new URLVariables();
		private var joinSelectedGameVars:URLVariables = new URLVariables();
		private var checkSelectedGameForStartVars:URLVariables = new URLVariables();
		
		
		// Get logged games from database
		private var getGamesReq:URLRequest = new URLRequest(MainDocument.localPath + "getGames.php");		
		private var getGamesLoader:URLLoader = new URLLoader();
		
		// Set up new game - log to database
		private var startNewGameReq:URLRequest = new URLRequest(MainDocument.localPath + "initNewGame.php");
		private var startNewGameLoader:URLLoader = new URLLoader();		
		
		// Join a game selected from local list - log to database
		private var joinSelectedGameReq:URLRequest = new URLRequest(MainDocument.localPath + "joinSelectedGame.php");
		private var joinSelectedGameLoader:URLLoader = new URLLoader();
		
		// For current game started - Get the current players from database
		private var getPlayersReq:URLRequest = new URLRequest(MainDocument.localPath + "getPlayers.php");
		private var getPlayersLoader:URLLoader = new URLLoader();
		
		// For selected game--check server for start status
		private var checkSelectedGameForStartReq:URLRequest = new URLRequest(MainDocument.localPath + "checkSelectedGameForStart.php");
		private var checkSelectedGameForStartLoader:URLLoader = new URLLoader();
		
		//==================================================================
		// OBJECT DECLARATIONS - variables needed for buttons and list boxes
		//==================================================================
		private var games_lb:List;
		private var current_game_lb:List;
		private var stats_lb:List;
		private var new_game_btn:Button;
		private var new_game_begin_btn:Button;
		private var select_game_btn:Button;		
		private static var game_stats_txt:TextArea;				
		
		//===============================================================
		// TRACKING VARIABLES
		//===============================================================
		private var gamesAvailable:Boolean = false;
		private var savedGamesListIndex:int = -1;
		
		//===============================================================
		// CLASS CONSTRUCTOR function
		//===============================================================
		public function Console() {
			// constructor code			
			trace("console is here");
			
			//************ Set up list boxes and buttons ****************
			games_lb = new List();
			games_lb.x = 12.20;
			games_lb.y = 67;
			games_lb.width = 220;
			games_lb.height = 94.0;
			games_lb.enabled = false;			
			this.addChild(games_lb);
			
			current_game_lb = new List();
			current_game_lb.x = 12.20;
			current_game_lb.y = 265;
			current_game_lb.width = 220;
			current_game_lb.height = 100;
			current_game_lb.enabled = false;
			current_game_lb.selectable = false;
			this.addChild(current_game_lb);
						
			
			select_game_btn = new Button();
			select_game_btn.x = 12.20;
			select_game_btn.y = 174.35;
			select_game_btn.width = 220;
			select_game_btn.height = 22.00;
			select_game_btn.label = "J O I N  G A M E  A B O V E";
			select_game_btn.enabled = false;
			this.addChild(select_game_btn);			
			
			new_game_btn = new Button();
			new_game_btn.x = 12.20;
			new_game_btn.y = 208.35;
			new_game_btn.width = 220;
			new_game_btn.height = 22.00;
			new_game_btn.label = "C R E A T E  N E W  G A M E";
			new_game_btn.enabled = false;
			this.addChild(new_game_btn);	
			
			new_game_begin_btn = new Button();
			new_game_begin_btn.x = 174;
			new_game_begin_btn.y = 266;
			new_game_begin_btn.width = 55;
			new_game_begin_btn.height = 18.00;
			new_game_begin_btn.label = "START";
			new_game_begin_btn.enabled = false;
			this.addChild(new_game_begin_btn);	
			new_game_begin_btn.visible = false;			

			game_stats_txt = new TextArea();
			
			game_stats_txt.x = 12.2;
			game_stats_txt.y = 400;
			game_stats_txt.width = 220;
			game_stats_txt.height = 130;				
			game_stats_txt.verticalScrollPolicy="auto";					
			
			this.addChild(game_stats_txt);						
			
			//************ Set up listeners for start/select game buttons **************
			new_game_btn.addEventListener(MouseEvent.CLICK,startNewGame);
			select_game_btn.addEventListener(MouseEvent.CLICK,joinSelectedGame);
			
			//************* Variable in MainDocument to indicate that console class is intiated
			MainDocument.consoleIsCreated = true;
		} //end constructor function
		
		//==============================================================
		//  UTILITY FUNCTIONS
		//==============================================================
		
		function trimWhitespace($string:String):String {
			if ($string == null) {
				return "";
			} //end if
			return $string.replace(/^\s+|\s+$/g, ""); // see regular expressions
		} // end function		
		
		private function time2twelve(t:String):String{
			if(t != ""){
				var theHours:Array = new Array("12"," 1"," 2"," 3"," 4"," 5"," 6"," 7"," 8"," 9","10","11");
				var HM:Array = t.split(":");	
				var hours:Number = Number(HM[0]);
				if(hours > 11){
					var i = hours - 12;
					return String(theHours[i] + ":" + HM[1] + " PM");
				}else{
					return String(hours + ":" + HM[1] + " AM");
				}
			}else{
				return "error";
			}
		}// end function
		
		//==============================================================
		// CONSOLE ACTIVE - enables lists and buttons, starts timer
		//                        to check for games additions
		//==============================================================
		public function makeActive():void{
			if(MainDocument.currentGame == 0){
				new_game_btn.enabled = true;
				games_lb.enabled = true;									
				showGames(null);			
				timeToCheckGames.start();
				timeToCheckGames.addEventListener(TimerEvent.TIMER_COMPLETE,showGames);
			} // end if
			current_game_lb.enabled = true;		
			
		} // end function		
		
		//===========================================================================================
		// SHOW GAMES - Displays updated list of games as init or as handler for timer complete event
		//  showGames initiates the server request, which is handled by retrieveData
		//===========================================================================================
		private function showGames(e:TimerEvent):void{
			// send request for continuing data -- check data
			trace("showgames");
			getGamesVars.p_id = MainDocument.player_id;			
			getGamesReq.method = URLRequestMethod.POST;
			getGamesReq.data = getGamesVars;						
			getGamesLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			getGamesLoader.load(getGamesReq);
			getGamesLoader.addEventListener(Event.COMPLETE, retrieveData);			
			
			timeToCheckGames.reset();
			timeToCheckGames.start();
		} //end function
		
			// ************ Complete Handler for showgames **************
			private function retrieveData(e:Event):void{
				var rawString:String = trimWhitespace(unescape(e.target.data));
				var stArray:Array = rawString.split("&");				
				for(var i:uint; i<stArray.length; i++){
					stArray[i] = trimWhitespace(stArray[i]);
					var pair:Array = stArray[i].split("=");
					pair[0] = trimWhitespace(pair[0]);
					switch (pair[0]){
						case "myStatus":
						  	var ms:String = trimWhitespace(pair[1]);    //  status data value
						  	break;
						case "output":
						  	var output:String = trimWhitespace(pair[1]);  // output string
							break;
						default: // this is all the other garbage---> dump
						    //do nothing
					} // end switch
				} //end for 					
				
				if(ms == "NOTOK"){					
					var dp:DataProvider = new DataProvider();
					dp.addItem({label:"No current games"});
					games_lb.dataProvider = dp;
					gamesAvailable = false;
					select_game_btn.enabled = false;
				}else{
					select_game_btn.enabled = true;
					gamesAvailable = true;
					var inStr:String = trimWhitespace(output);
					parseData(inStr);			
				} // end if-else			
					
			} //end function
			
			// ******************* Parses data retrieved above and 
			// ******************* loads list box, sets listener for selection
			private function parseData(inStr:String):void{
				var d:DataProvider = new DataProvider();
				var lineArray:Array = inStr.split("^");
				for(var i:uint=0;i<lineArray.length;i++){
					var fieldArray:Array = lineArray[i].split("|");	
					//get the time part of the date/time - then convert to 12 hour
					var time:String = String(fieldArray[2].split(" ")[1]);				
					time = time2twelve(time);
					d.addItem({label:time + " - " + fieldArray[1],data:fieldArray[0]});				
				} //end for
				games_lb.dataProvider = d;			
				if(savedGamesListIndex != -1){
					games_lb.selectedIndex = savedGamesListIndex;
				} //end if
				games_lb.addEventListener(Event.CHANGE,getSelection);
			} //end function
		
			// ******************** Handles selection from above list listener
			private function getSelection(e:Event):void{
				savedGamesListIndex = e.target.selectedIndex;
				var x:String = e.target.selectedItem.label;				
			} //end function
			
		//==============================================================================
		//  START NEW GAME (after button is pressed; this is the handler )
		//  disables appropriate buttons, handlers, timers and lists
		//  Sends two-way request to server database to initiate a NEW game
		//  Script: initNewGame.php
		//==============================================================================
		private function startNewGame(evt:MouseEvent):void{
			trace("Start New Game Function");			
			// Disable games_lb, listeners and buttons
			games_lb.enabled = false;
			select_game_btn.enabled = false;
			select_game_btn.removeEventListener(MouseEvent.CLICK, joinSelectedGame);
			timeToCheckGames.removeEventListener(TimerEvent.TIMER_COMPLETE,showGames);
			getGamesLoader.removeEventListener(Event.COMPLETE, retrieveData);
			
			// Disable new_game_btn and listener
			new_game_btn.enabled = false;
			new_game_btn.removeEventListener(MouseEvent.CLICK,startNewGame);							
			
			// Update dB - insert new game - return 
			newGameVars.p_id = MainDocument.player_id;			
			startNewGameReq.method = URLRequestMethod.POST;
			startNewGameReq.data = newGameVars;						
			startNewGameLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			startNewGameLoader.load(startNewGameReq);
			startNewGameLoader.addEventListener(Event.COMPLETE, startNewGameOnComplete);
			
		} //end function
		
			//=================================================================
			// This function handles the COMPLETE EVENT for above, 
			// starts timer and  listener for the checkForPlayers method below
			//=================================================================
			private function startNewGameOnComplete(e:Event):void{
				var rawString:String = trimWhitespace(unescape(e.target.data));
				var stArray:Array = rawString.split("&");				
				for(var i:uint; i<stArray.length; i++){
					stArray[i] = trimWhitespace(stArray[i]);
					var pair:Array = stArray[i].split("=");
					pair[0] = trimWhitespace(pair[0]);
					switch (pair[0]){
						case "myStatus":
						  	var ms:String = trimWhitespace(pair[1]);    //  status data value
						  	break;
						case "g_id":
						  	var g_id:String = trimWhitespace(pair[1]);  // output string
							break;
						default: // this is all the other garbage---> dump
						    //do nothing
					} // end switch
				} //end for 			
				switch (ms){
					case "GAMEINPLAY":
						MainDocument.doc.showMsg("You are already logged in to one game.");				
						makeActive();
						break;
					case "TOOMANY":
						MainDocument.doc.showMsg("There are too many games open.\nPlease join one of these, or come back later");				
						makeActive();
						break;
					case "OK":
						// Log in current game ID
						MainDocument.currentGame = int(g_id);						
						// Insert player into current game 1st position as dealer/admin
						var dealer:String = "Dealer: " + MainDocument.player_name;
						var d:DataProvider = new DataProvider();
						MainDocument.doc.playerTitle(dealer);										
						current_game_lb.dataProvider = d;
						d.addItemAt({label:dealer,data:MainDocument.player_id},0);
						// Message to user
						MainDocument.doc.showMsg("New game started--awaiting more players");
						MainDocument.numPlayers = 1;
						MainDocument.dealer = true;						
						// Set listener and start timer to check for new players for this game
						timeToCheckForPlayers.addEventListener(TimerEvent.TIMER_COMPLETE,checkForPlayers);
						timeToCheckForPlayers.start();
						break;
					default:
						trace("A dB ERROR occured - check log");
				} // end switch
				
			} // end function
		
		//==============================================================================
		// CHECKS server database FOR NEW PLAYERS for game started -- handles 
		// timer/listener and sets listener for complete, resets clock for this function
		//==============================================================================
		private function checkForPlayers(e:Event):void{			
			// Set up send variables
			getPlayersVars.g_id = MainDocument.currentGame;			
			getPlayersVars.g_num_players = MainDocument.numPlayers;			
			getPlayersReq.method = URLRequestMethod.POST;
			getPlayersReq.data = getPlayersVars;						
			getPlayersLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			getPlayersLoader.load(getPlayersReq);
			getPlayersLoader.addEventListener(Event.COMPLETE, checkForPlayersComplete);
			//reset clock to look for players
			timeToCheckForPlayers.reset();
			timeToCheckForPlayers.start();
		} //end function
		
			//******************** Handles complete event for above *********************
			private function checkForPlayersComplete(e:Event):void{				
				var rawString:String = trimWhitespace(unescape(e.target.data));				
				var stArray:Array = rawString.split("&");				
				for(var i:uint=0; i < stArray.length; i++){					
					var pair:Array = stArray[i].split("=");
					pair[0] = trimWhitespace(pair[0]);
					switch (pair[0]){
						case "myStatus":
						  	var ms:String = trimWhitespace(pair[1]);    //  status data value
							trace("Console-case-ms= " + ms);
						  	break;
						case "g_num_players":
							var g_num_players:String = trimWhitespace(pair[1]);
							trace("Console-case-g_num_players= " + g_num_players);
							break;
						case "playerStr":
						  	var S:String = trimWhitespace(pair[1]);  // output string
							trace("Console-case-S= " + S);
							break;
						default: // this is all the other garbage---> dump
						    trace("Console-default: garbage");
							//do nothing
					} // end switch
				} //end for 			
				
				if(ms == "OK"){
					var dp:DataProvider = new DataProvider();
					current_game_lb.dataProvider = dp;
					
					var lineArray:Array = new Array();
					var fieldArray:Array = new Array();
					var j:uint = new uint();					
					
					MainDocument.numPlayers = int(g_num_players);
					trace("Players data " + S);
					trace("NumPlayers = " + MainDocument.numPlayers);				
					
					lineArray = S.split("^");
					for(j=0;j<lineArray.length;j++){
						fieldArray = lineArray[j].split("|");					
						if (j==0){
							dp.addItemAt({label:"Dealer:   " + fieldArray[1],data:fieldArray[0]},j);
						}else{
							dp.addItemAt({label:"Player " + (j+1) + " " + fieldArray[1],data:fieldArray[0]},j);
						} // end if
						//Update MainDocument players array
						if(MainDocument.dealer == true){
							var g:Array = [fieldArray[0],fieldArray[1]];
							MainDocument.currentGamePlayers[j] = g;
						}
						
					} //end for
					trace(MainDocument.currentGamePlayers);
					
					//======================================================
					// Checks for dealer and enough players for start button 
					//======================================================
					if(MainDocument.dealer==true && MainDocument.numPlayers >= 2){
						new_game_begin_btn.enabled = true;
						new_game_begin_btn.visible = true;
						// Start play button
						new_game_begin_btn.addEventListener(MouseEvent.CLICK,beginGameServerPlay);
					} // end if
					
					//==============================================
					// Shuts down search for players if 5 or greater
					//==============================================
					if(MainDocument.numPlayers >= 5){
						timeToCheckForPlayers.removeEventListener(TimerEvent.TIMER_COMPLETE,checkForPlayers);
						timeToCheckForPlayers.stop();
						if(MainDocument.dealer == true){
							beginGameServerPlay(null);
						}else{
							
						}
					}// end if
				}else if(ms=="NOCHANGE"){
					// do nothing
				}else{
					trace("ERROR");
				}// end if-else-if-else
			} //end function
		
		//==================================================================================
		// JOIN A SELECTED GAME (selected from Games List box)
		// Script: joinSelectedGame.php
		//==================================================================================
		private function joinSelectedGame(evt:MouseEvent):void{			
			if(savedGamesListIndex == -1){
				MainDocument.doc.showMsg("You must select a game before clicking this button");
			}else{
				//Message clear
				MainDocument.doc.showMsg("");											
				// Send data to server script 
				joinSelectedGameVars.g_id = games_lb.getItemAt(savedGamesListIndex).data;				
				joinSelectedGameVars.p_id = MainDocument.player_id;
				joinSelectedGameReq.method = URLRequestMethod.POST;
				joinSelectedGameReq.data = joinSelectedGameVars;						
				joinSelectedGameLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
				joinSelectedGameLoader.load(joinSelectedGameReq);
				joinSelectedGameLoader.addEventListener(Event.COMPLETE, joinSelectedGameComplete);
				
			} // end if-else
				
		} //end function
			
			//=============================================================================
			// HANDLE join game above - disabling buttons, lists, listeners and timers
			// Start listener for players
			// Script: joinSelectedGame.php
			//=============================================================================
			private function joinSelectedGameComplete(e:Event):void{
				var rawString:String = trimWhitespace(unescape(e.target.data));
				var stArray:Array = rawString.split("&");				
				for(var i:uint; i<stArray.length; i++){					
					var pair:Array = stArray[i].split("=");
					pair[0] = trimWhitespace(pair[0]);
					switch (pair[0]){
						case "myStatus":
						  	var ms:String = trimWhitespace(pair[1]);    //  status data value
						  	break;						
						default: // this is all the other garbage---> dump
						    //do nothing
					} // end switch
				} //end for 					
				
				switch (ms){
					case "GAMEINPLAY":
						MainDocument.doc.showMsg("You are already in this game");
						break;
					case "TOOMANY":
						MainDocument.doc.showMsg("Sorry game is full--try later");
						break;
					case "OK":
						// Disable games_lb, listeners and buttons
						games_lb.enabled = false;
						select_game_btn.enabled = false;
						select_game_btn.removeEventListener(MouseEvent.CLICK, joinSelectedGame);
						new_game_btn.enabled = false;
						new_game_btn.removeEventListener(MouseEvent.CLICK,startNewGame);			
						timeToCheckGames.removeEventListener(TimerEvent.TIMER_COMPLETE,showGames);
						getGamesLoader.removeEventListener(Event.COMPLETE, retrieveData);
						joinSelectedGameLoader.removeEventListener(Event.COMPLETE, joinSelectedGameComplete);
						
						//update MainDoc variables
						MainDocument.currentGame = joinSelectedGameVars.g_id;
						MainDocument.doc.playerTitle(MainDocument.player_name);
											
						// Check server for game start every 15 seconds
						checkSelectedGameForStart(null);
						timeToCheckForGameStart.addEventListener(TimerEvent.TIMER_COMPLETE,checkSelectedGameForStart);
						timeToCheckForGameStart.start();
						break;
					default:
						MainDocument.doc.showMsg("I/O or DB Error");
				} // end switch								
				
			} // end private function
		
		private function checkSelectedGameForStart(e:Event):void{			
			MainDocument.doc.showMsg("Awaiting game to begin...");
			checkSelectedGameForStartVars.g_id = MainDocument.currentGame;
			checkSelectedGameForStartReq.method = URLRequestMethod.POST;
			checkSelectedGameForStartReq.data = checkSelectedGameForStartVars;						
			checkSelectedGameForStartLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			checkSelectedGameForStartLoader.load(checkSelectedGameForStartReq);
			checkSelectedGameForStartLoader.addEventListener(Event.COMPLETE, checkSelectedGameForStartComplete);			
		} // end function
		
			private function checkSelectedGameForStartComplete(e:Event):void{
				var rawString:String = trimWhitespace(unescape(e.target.data));
				var stArray:Array = rawString.split("&");				
				for(var i:uint; i<stArray.length; i++){
					stArray[i] = trimWhitespace(stArray[i]);
					var pair:Array = stArray[i].split("=");
					pair[0] = trimWhitespace(pair[0]);
					switch (pair[0]){
						case "myStatus":
						  	var ms:String = trimWhitespace(pair[1]);    //  status data value
						  	break;						
						default: // this is all the other garbage---> dump
						    //do nothing
					} // end switch
				} //end for 			
				
				if(ms=="GAME_STARTED"){
					//MainDocument.doc.showMsg("Selected Game has started");
					checkSelectedGameForStartLoader.removeEventListener(Event.COMPLETE, checkSelectedGameForStartComplete);					
					timeToCheckForGameStart.removeEventListener(TimerEvent.TIMER_COMPLETE,checkSelectedGameForStart);
					timeToCheckForGameStart.stop();
					beginGameClientPlay(e);
				}else{
					//reset clock to look for checking function
					timeToCheckForGameStart.reset();
					timeToCheckForGameStart.start();
				} // end if-else
			} //end function
		//================================================================================
		// BEGIN PLAY of local game when player is dealer
		// Creates object instance of GameServer class and adds to stage
		//================================================================================
		private function beginGameServerPlay(evt:Event):void{			
			// remove listener for button			
			new_game_btn.removeEventListener(MouseEvent.CLICK,beginGameServerPlay);
			// Shut down other listeners and timers
			timeToCheckForPlayers.removeEventListener(TimerEvent.TIMER_COMPLETE,checkForPlayers);
			timeToCheckForPlayers.stop();		
			
			new_game_begin_btn.removeEventListener(MouseEvent.CLICK,beginGameServerPlay);
			new_game_begin_btn.enabled = false;
			/*
			// Init GameServer passing array of players from MainDocument array of players
			var GS:GameServer = new GameServer(MainDocument.currentGamePlayers);
			GS.x = 0;
			GS.y = 0;
			GS.name = "server";
			MainDocument.doc.stage.addChild(GS);	
			*/
		} //end function
		
		//================================================================================
		// BEGIN PLAY of local game when player is NOT the dealer (client)
		// Creates object instance of GameClient class and adds to stage
		//================================================================================
		private function beginGameClientPlay(e:Event):void{			
			// Get players into MainDocument and list
			var dp:DataProvider = new DataProvider();
			current_game_lb.dataProvider = dp;			
			var lineArray:Array = new Array();
			var fieldArray:Array = new Array();
			var i:uint = new uint();
			
			var rawString:String = trimWhitespace(unescape(e.target.data));
			var stArray:Array = rawString.split("&");
			//MainDocument.doc.showMsg("Console-stArray-3= " + stArray);
			for(i=0; i<stArray.length; i++){
				stArray[i] = trimWhitespace(stArray[i]);
				var pair:Array = stArray[i].split("=");
				pair[0] = trimWhitespace(pair[0]);
				switch (pair[0]){
					case "playerStr":
						var S:String = trimWhitespace(pair[1]);    //  status data value
						break;		
					case "g_num_players":
						var g_num_players:String = trimWhitespace(pair[1]);    //  status data value
						break;	
					default: // this is all the other garbage---> dump
						//do nothing
				} // end switch
			} //end for 				
			
			MainDocument.numPlayers = int(g_num_players);						
			
			lineArray = S.split("^");
			for(i=0;i<lineArray.length;i++){
				fieldArray = lineArray[i].split("|");					
				if (i==0){
					dp.addItemAt({label:"Dealer:   " + fieldArray[1],data:fieldArray[0]},i);
				}else{
					dp.addItemAt({label:"Player " + (i+1) + " " + fieldArray[1],data:fieldArray[0]},i);
				} // end if
				//Update MainDocument players array				
				var g:Array = [fieldArray[0],fieldArray[1]];
				MainDocument.currentGamePlayers[i] = g;				
				
			} //end for
					/*
			// Init GameCLient 
			var GC:GameClient = new GameClient(MainDocument.currentGamePlayers);
			GC.x = 0;
			GC.y = 0;
			GC.name = "client";
			MainDocument.doc.stage.addChild(GC);	
			MainDocument.doc.showMsg("");
			*/
		} //end function
		
		public static function gs_update(msg:String):void{
			game_stats_txt.htmlText += msg;
		} // end function

	}// end class
	
} //end package
