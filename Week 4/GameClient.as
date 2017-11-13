package  {
	
	import flash.display.MovieClip;
	import flash.net.*;
	import flash.utils.ByteArray;
	import CactusArrays;
	import PokerLib;
	import PokerVars;
	import PokerEval;
	import Hand_mc;
	import flash.events.*;
	import MainDocument;
	import Console;
	import BetCon;
	import VCard;
	import flash.utils.Timer;
	import BetSound;
	import DealSound;
	import GameOverSound;
	
	
	public class GameClient extends MovieClip {		
			
		private var _players:Array;
		private var bytes:ByteArray;
		private var N:uint; // Number of players
		
		// This is the main game object that holds all current game players and their complete hands
		// In GameClient this is downloaded from the server database game table
		private var theGame:Object;
		private var gameover:GameOverSound = new GameOverSound();
		
		// The betting console movieclip
		private var bet_console:BetCon;	
		private var money:BetSound = new BetSound();
		
		// This represents the visual representations of the hands
		private var wbg_hand:Array = new Array(5);
		
		// Funds available to this player at start
		private var myBank:uint = 100;
		//Delay for checking bets on server
		private var myDelay:Timer = new Timer(5000,1);	
		private var shuffle:DealSound = new DealSound();
		

		// Begin new game play --> GamerClient Class - receiving game data from database
		private var beginNewGamePlayVars:URLVariables = new URLVariables();		
		private var beginNewGamePlayReq:URLRequest = new URLRequest(MainDocument.localPath + "beginNewGame.php");
		private var beginNewGamePlayLoader:URLLoader = new URLLoader();
		// Communications for betting & round updates from server
		private var getBetsVars:URLVariables = new URLVariables();		
		private var getBetsReq:URLRequest = new URLRequest(MainDocument.localPath + "getBets.php");
		private var getBetsLoader:URLLoader = new URLLoader();
		// Communications for placing bets
		private var placeBetVars:URLVariables = new URLVariables();		
		private var placeBetReq:URLRequest = new URLRequest(MainDocument.localPath + "placeBet.php");
		private var placeBetLoader:URLLoader = new URLLoader();
		
		
		
		private var dealDelay:uint = 1;
		private var sound_wait:Timer = new Timer(50);
		private var cardCount:uint = 0;
		private var roundHold:uint = 1;
		private var dealing:Boolean = false;
		
		public function GameClient(players:Array) {
			// constructor code
			trace("Current Game open");
			
			//Store player names, numbers in an array coming from call in Console.as
			_players = new Array();
			N = players.length;
			
			for (var i:uint=0;i<N;i++){
				_players[i] = players[i];
			}//end for			
				
			// Instantiate the main game data object
			theGame = new Object();		
			
			// Instantiate the betting console
			bet_console = new BetCon();
			bet_console.x = 470;
			bet_console.y = 300;
			
			this.addChild(bet_console);
			bet_console.makeBetCon("enabled");
			bet_console.thePot_txt.text = "$0";
			bet_console.myFunds_txt.text = "$" + String(myBank);
			
			bet_console.bet_btn.addEventListener(MouseEvent.MOUSE_DOWN, handleBet);			
			
			
			
			//=========================================================================
			// Get Game info from server database -- in game table row for current game
			//   placed in dB by GameServer when game is started
			// beginNewGame.php	-- this is the original upload of all players and hands
			//=========================================================================
			
			//These are the two uploaded variables conataining the game ID and the main object
			beginNewGamePlayVars.gameID = MainDocument.currentGame;			
			beginNewGamePlayVars.playerID = MainDocument.player_id;
			beginNewGamePlayVars.req_status = "client_start"; //indicates the client
			// Set up the server request and loader using POST, setting data format to binary
			beginNewGamePlayReq.method = URLRequestMethod.POST;
			beginNewGamePlayReq.data = beginNewGamePlayVars;						
			beginNewGamePlayLoader.dataFormat = URLLoaderDataFormat.VARIABLES; 
			beginNewGamePlayLoader.load(beginNewGamePlayReq);
			// Add a listener for the load request
			beginNewGamePlayLoader.addEventListener(Event.COMPLETE, beginNewGamePlayComplete);	
						
			
		}//end constructor function
		
		
		//================================================================================
		// Complete Handler for "theGame" server download
		//================================================================================
		private function beginNewGamePlayComplete(e:Event):void{
			beginNewGamePlayLoader.removeEventListener(Event.COMPLETE, beginNewGamePlayComplete);				
			
			var rawString:String = trimWhitespace(unescape(e.target.data));
			var stArray:Array = rawString.split("&");			
			for(var i:uint; i<stArray.length; i++){
				stArray[i] = trimWhitespace(stArray[i]);
				var pair:Array = stArray[i].split("=");
				pair[0] = trimWhitespace(pair[0]);
				switch (pair[0]){
					case "theGame":
						var inGame:String = trimWhitespace(pair[1]);    //  status data value
						break;	
					case "dummy":						
						break;					
					default: // this is all the other garbage---> dump
						//do nothing
				} // end switch
			} //end for 			
			
			// This function translates the delimited string from the server back into the game object
			theGame = convertTheGameFromDownload(inGame);					
			
			displayHands(); //displays all cards for each hand, making only the first card visible			
			
			dealCards(1);	// deal round 1
			
			Console.gs_update('<font size="14" color="#660033">Welcome ' + MainDocument.player_name + '<br/>ROUND 1 - Let the betting begin</font><br/>');
			
			//=============================================================================
			//Begin betting loop (Main Game Loop)  
			//=============================================================================
			mainGameLoop();
				
		} //end function
		
		//=================================================================================
		// Utility Functions
		//=================================================================================
		
		private function handleBet(e:Event):void{
			bet_console.bet_btn.removeEventListener(MouseEvent.MOUSE_DOWN, handleBet);
			bet_console.bet_btn.enabled = false;
			var b:uint;
			switch (MainDocument.gameRound){
				case 1:
					bet_console.myBet_txt.text = "$5";
					b = 5;
					break;
				case 2:
					bet_console.myBet_txt.text = "$10";
					b = 10;
					break;
				case 3:
					bet_console.myBet_txt.text = "$15";
					b = 15;
					break;
				case 4:
					bet_console.myBet_txt.text = "$25";
					b = 25;
					break;
				default: bet_console.myBet_txt.text = "$0";
			} //end switch
			//Update our bank
			myBank -= b;
			bet_console.myFunds_txt.text = "$" + String(myBank);
			
			//upload to server
			// Set up the server request and loader using POST
			placeBetVars.g_id = MainDocument.currentGame;
			placeBetVars.p_id = MainDocument.player_id;
			placeBetVars.theRound = MainDocument.gameRound;
			trace("Game_client - Placebet -game round = " + MainDocument.gameRound);
			placeBetVars.bet_amt = b;
			
			placeBetReq.method = URLRequestMethod.POST;
			placeBetReq.data = placeBetVars;						
			placeBetLoader.dataFormat = URLLoaderDataFormat.VARIABLES; 
			placeBetLoader.load(placeBetReq);
			// the complete handler here is used for game logic based on dB conditions
			placeBetLoader.addEventListener(Event.COMPLETE, placeBetComplete);
			
		} // end function		
			
			// Complete function for place bet
			private function placeBetComplete(e:Event):void{
				placeBetLoader.removeEventListener(Event.COMPLETE, placeBetComplete);		
				
				
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
						case "thePot":
							var pot:uint = uint(trimWhitespace(pair[1]));
							break;						
						default: // this is all the other garbage---> dump
							//do nothing
					} // end switch
				} //end for 	
				if (ms == "OK"){
					bet_console.thePot_txt.text = "$" + String(pot);
					trace("Bet was placed");
					money.play();
				}else if(ms == "DUPLICATE"){
					trace("Duplicate Bet");
				}else{
					trace("Unknown Eror");
				}//end if-else
			} //end function
			
		private function trimWhitespace($string:String):String {
			if ($string == null) {
				return "";
			}
			return $string.replace(/^\s+|\s+$/g, "");
		}//end function trim		
		
		/*
		private function findPlayerPosition(theGame:Object,id:int):int{			
			
			for (var i:uint=0; i < N; i++){
				if(theGame[i].player[0] == id){
					trace("Findourposition, id= " + id);					
					return i;
				} // end if
			} // end for
			return -1;
		} //end function
		*/
		
		//=========================================================
		// Displays all hands, but only first card is visible
		//=========================================================
		private function displayHands():void{
			
			//place hand_mc instances in pre-determined stage locations
			// always start with dealer as h[0] and rotate clockwise			
			shuffle.play();
			//Clear messages
			MainDocument.doc.showMsg("");
			for(var i:uint=0;i<N;i++){				
				var xx:uint; 
				var yy:uint;
				trace("In DisplayHands - theGame[i].hand= " + theGame[i].hand);
				var localHand:Object = theGame[i].hand;				
				var p:String = theGame[i].player[1];
				trace("In DisplayHands - theGame[i].player= " + theGame[i].player[1]);
				switch (i) { // get x and y coordinates for each hand
					case 0:						
						xx = 290;
						yy = 408;												
						break;
					case 1:						
						xx = 72;
						yy = 275;													
						break;
					case 2:						
						xx = 134;
						yy = 94;												
						break;
					case 3:							
						xx = 440;
						yy = 94;											
						break;
					case 4:						
						xx = 504;
						yy = 275;												
						break;
				} // switch
				//Compose each hand store in array
				trace("localhand= " + localHand);
				wbg_hand[i] = new Hand_mc(localHand,p);
				
				wbg_hand[i].x = xx;
				wbg_hand[i].y = yy;
				
				addChild(wbg_hand[i]);					
				
			} // end for
			
		} // end function
		
		//////////////////////////////////////////////////////////////////////////////////
		//////////////////////////// MAIN GAME LOOP //////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////
		private function mainGameLoop():void{
			
			if (MainDocument.gameOver == true){
				shutDownGame();
			}else{
				//Get info from server - using getBets.php				
				getBetsVars.g_id = MainDocument.currentGame;				
				//Set up the server request and loader using POST
				getBetsReq.method = URLRequestMethod.POST;
				getBetsReq.data = getBetsVars;						
				getBetsLoader.dataFormat = URLLoaderDataFormat.VARIABLES; 
				getBetsLoader.load(getBetsReq);
				// the complete handler here is used for game logic based on dB conditions
				getBetsLoader.addEventListener(Event.COMPLETE, getBetsComplete);
			}// end else		
		
		} // end function							

		
		private function getBetsComplete(e:Event):void{
			
			getBetsLoader.removeEventListener(Event.COMPLETE, getBetsComplete);			
			
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
					case "server_data":
						var theData:String = trimWhitespace(pair[1]);
						break;
					case "totalPot":
						var thePot:String = trimWhitespace(pair[1]);
						break;
					case "theRound":
						var theRound:String = trimWhitespace(pair[1]);
					default: // this is all the other garbage---> dump
						//do nothing
				} // end switch
			} //end for 			
			
			
			switch(ms){
				case "GAME_OVER":
					MainDocument.gameRound = 5;
					MainDocument.gameOver = true;					
					dealCards(MainDocument.gameRound);
					MainDocument.winningPot = uint(thePot);
					bet_console.thePot_txt.text = "$" + String(MainDocument.winningPot);
					Console.gs_update('<font size="14" color="#660033">ROUND 5 - Game Over</font><br/>');
					
					break;
				case "OK":
					if(MainDocument.gameRound < uint(theRound)){
						MainDocument.gameRound = uint(trimWhitespace(e.target.data.theRound));						
						dealCards(MainDocument.gameRound);
						bet_console.thePot_txt.text =  "$" + String(thePot);
						bet_console.bet_btn.addEventListener(MouseEvent.MOUSE_DOWN, handleBet);
						bet_console.bet_btn.enabled = true;
						Console.gs_update('<font size="14" color="#660033">ROUND ' + theRound + ' - Place your bets</font><br/>');
					}//end if
					break;
				case "ERROR_IN_ROUND":
					trace("Something wrong in getBets");
			}//end switch									
			updateLocalGameUI(theData);
						
			// Delay 5 secs
			myDelay.start(); //calls the function delay after 5000 milliseconds
			myDelay.addEventListener(TimerEvent.TIMER_COMPLETE,delayComplete);
			
		} // end function
		
		private function delayComplete(e:Event):void{
				myDelay.removeEventListener(TimerEvent.TIMER_COMPLETE,delayComplete);
				myDelay.reset();
				mainGameLoop();
		}// end function
			
		////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////// END OF GAME LOOP  //////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////
		
		// Translates delimited string back into theGame object
		private function convertTheGameFromDownload(inStr:String):Object{
			
			var theGame = new Object(); 
			var recArray:Array = inStr.split("^"); //split the incoming string into records on "^"
			for(var j:uint=0; j < N; j++){				
				var lineArray:Array = recArray[j].split("|");  // split each record into fields
				var obj:Object = new Object();
				var playerA:Array = new Array(lineArray[0],lineArray[1]);
				var handA:Object = new Object();
				handA.strength = lineArray[2];
				handA.cards = lineArray[3].split(",");
				obj.player = playerA; 
				obj.hand = handA;	
				obj.handtostring = lineArray[4];				
				
				theGame[j] = obj;	
			} // end for
			return theGame;
		}// end function
		
		// Sorts hands by hand.strength, and so the hand with the lowest index is the winner
		private function sortHands(inGame:Object):void{							
			var j:uint = 0;
			while (j < N-1){
				if (inGame[j].hand.strength > inGame[j+1].hand.strength){
					var hold:Object = inGame[j+1];
					inGame[j+1] = inGame[j];
					inGame[j] = hold;
					sortHands(inGame);
				} // end if
				j++;
			} //end while
		} // end function
		
	private function updateLocalGameUI(theData:String):void{
		
			for(var i:uint=0;i<N;i++){
				wbg_hand[i].status_txt.text = theGame[i].hand.cards.toString();
			}		
	}// end function
	
	private function dealCards(round:uint):void{
		for(var i:uint=0;i<N;i++){
			wbg_hand[i].showCard(round-1);
		}
		
	} // end function
		
		
		private function shutDownGame():void{			
			//Sort the hand to determine winner based on hand strength
			sortHands(theGame);							
			Console.gs_update('<font size="14" color="#660033">The Winner: ' + theGame[0].player[1] + '</font><br/>');
			Console.gs_update('<font size="14" color="#660033">The Winning hand: ' + theGame[0].handtostring + '</font><br/>');
			MainDocument.doc.gotoAndStop(2);
			gameover.play();
		}// end function
		
			
	}//end class
	
}//end package
