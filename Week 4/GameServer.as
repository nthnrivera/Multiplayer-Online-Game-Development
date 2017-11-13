package  {
	
	import flash.display.MovieClip;
	import flash.net.*;
	import flash.utils.ByteArray;
	import CactusArrays;
	import PokerLib;
	import PokerVars;
	import PokerEval;
	import Hand_mc;
	import VCard;
	import flash.events.*;
	import MainDocument;
	import Console;
	import BetCon;
	import flash.utils.Timer;
	import BetSound;
	import DealSound;
	import GameOverSound;


	public class GameServer extends MovieClip {
		
		private var myDeck:Deck;		// this is used only by dealer, thus gameServer
		private var _players:Array;
		private var bytes:ByteArray;
		private var N:uint; // Number of players
		private var shuffle:DealSound = new DealSound();
		
		// This is the main game object that holds all current game players and their complete hands
		// and is created here and uploaded to the server database for all other clients/players
		private var theGame:Object;
		private var gameover:GameOverSound = new GameOverSound();
		
		// The betting console movieclip
		private var bet_console:BetCon;		
		private var money:BetSound = new BetSound();
		
		//This array holds the visual representations of the hands
		private var wbg_hand:Array = new Array(5);		
		
		// Funds available to this player at start
		private var myBank:uint = 100;
		//Delay for checking bets on server
		private var myDelay:Timer = new Timer(5000,1);

		
		// Begin new game play --> GamerServer Class - logging changes to database
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
		
		
		// CONSTRUCTOR FOR GameServer
		public function GameServer(players:Array) { //players come from call in Console
			// constructor code
			trace("Current Game open");			
			
			//Store player names, numbers in an array coming from call in Console.as
			_players = new Array();
			N = players.length;
			
			for (var i:uint=0;i<N;i++){
				_players[i] = players[i];
			}//end for						
			
			// Instantiate the betting console on the stage
			bet_console = new BetCon();
			bet_console.x = 470; //270;
			bet_console.y = 300;  //225;
			
			this.addChild(bet_console);
			bet_console.makeBetCon("enabled");
			bet_console.thePot_txt.text = "$0";
			bet_console.myFunds_txt.text = "$" + String(myBank);
			
			bet_console.bet_btn.addEventListener(MouseEvent.MOUSE_DOWN, handleBet);
			
			
			//Create new deck coming from Deck.as
			myDeck = new Deck();	
			//Shuffle deck (100 times)
			myDeck.shuffle();
			
			//////////////////////////////////////////////////////
			//====================================================
			// CREATE THE MAIN OBJECT ARRAY for game play - 
			// this is the main data structure for the game which
			// was started by this player as dealer
			//
			// 		Object theGame:
			// 			.hand:Hand5 = pull5Hand();
			//				.strength
			//				.cards
			//			.player = _players[i]
			//				{id, name}
			//			
			//====================================================
			//////////////////////////////////////////////////////
			
			theGame = new Object(); // shared through upload to dB for all players in game
			
			// Loop for the assembly of the Game object
			for(var j:uint=0; j < N; j++){		
				var h:Hand5 = myDeck.pull5Hand(); //using the CactusKev routine from Deck.as
				
				var obj:Object = new Object();
				obj.player = _players[j]; 
				obj.hand = hand5Parse(h);	
				obj.handtostring = h.toString();				
				
				theGame[j] = obj;
				
						/* testing for validity of this object
						trace("obj ot string = " + obj.toString())
						trace("theGame["+j+"].player= " + theGame[j].player);
						trace("theGame["+j+"].hand= " + theGame[j].hand.strength);
						trace("theGame["+j+"].hand= " + theGame[j].hand.cards);
						*/
			} // end for
			
			
			//===============================================================================
			// Update server database -- in game table row for current game
			// beginNewGame.php		  -- this is the original upload of all players and hands
			//===============================================================================
			
			// These are the uploaded variables containing the game ID and the main object
			// as a formatted string (byte array doesn't work with CWP)
			beginNewGamePlayVars.gameID = MainDocument.currentGame;
			beginNewGamePlayVars.req_status = "server_start"; // indicates Game server
			// Convert theGame object to a formatted string (instead of bytearray)
			beginNewGamePlayVars.theGameObject = convertTheGameForUpload(theGame);	
			
			// Set up the server request and loader using POST, setting data format to binary
			beginNewGamePlayReq.method = URLRequestMethod.POST;
			beginNewGamePlayReq.data = beginNewGamePlayVars;						
			beginNewGamePlayLoader.dataFormat = URLLoaderDataFormat.VARIABLES; 
			beginNewGamePlayLoader.load(beginNewGamePlayReq);			
					
			// the complete handler here is used mostly for testing or error trapping
			beginNewGamePlayLoader.addEventListener(Event.COMPLETE, beginNewGamePlayComplete);					
			
		} //end constructor function		
				
		//================================================================================
		// Complete Handler for "theGame" server upload
		//================================================================================
		private function beginNewGamePlayComplete(e:Event):void{			
			beginNewGamePlayLoader.removeEventListener(Event.COMPLETE, beginNewGamePlayComplete);			
			
			// Give a visual representation on stage for the first card dealt
			// then after each betting round, display the next card
			
			displayHands(); 	// places all cards for each hand, making only the first card visible
								// then each of the remaining cards in following rounds			
			dealCards(1);		// round # 1		
			
			Console.gs_update('<font size="14" color="#660033">Welcome ' + MainDocument.player_name + '<br/>ROUND 1 - Let the betting begin</font><br/>');
			
			//*****************************************************************************
			//Begin betting loop (Main Game Loop)  -- Set listener for next betting round
			//*****************************************************************************
			
			mainGameLoop();
			
		} //end function
		
		//=================================================================================
		// Utility Functions
		//=================================================================================
		
		// THis routine is used to work around the use of a bytearray, due to server problems
		private function convertTheGameForUpload(theGame:Object):String{
				var outputSt:String = "";
				//Loop through array
				for(var i:uint=0 ; i < N; i++){
					if(i < N-1){
						outputSt += theGame[i].player[0] + "|" + theGame[i].player[1] + "|";
						outputSt += String(theGame[i].hand.strength) + "|" + theGame[i].hand.cards + "|";
						outputSt += theGame[i].handtostring + "^";
					}else{
						outputSt += theGame[i].player[0] + "|" + theGame[i].player[1] + "|";
						outputSt += String(theGame[i].hand.strength) + "|" + theGame[i].hand.cards + "|";
						outputSt += theGame[i].handtostring;
					} // end if-else
				} // end for
				return outputSt;
		} // end function
			
		
		/*
		private function findPlayerPosition(theGame:Object,id:int):int{
			
			trace("In findPLayerPosition - N= " + N);
			for (var i:uint=0; i < N; i++){
				if(theGame[i].player[0] == id){
					trace("Findourposition, id= " + id);					
					return i;
				} // end if
			} // end for
			return -1;
		} //end function
		*/
		
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
			money.play();
			trace("Update bank");
			
			//upload to server
			// Set up the server request and loader using POST
			placeBetVars.g_id = MainDocument.currentGame;
			placeBetVars.p_id = MainDocument.player_id;
			placeBetVars.theRound = MainDocument.gameRound;
			trace("Game_server - Placebet -game round = " + MainDocument.gameRound);
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
						case "thelPot":
							var pot:String = trimWhitespace(pair[1]);
							break;						
						default: // this is all the other garbage---> dump
							//do nothing
					} // end switch
				} //end for 
				if (ms == "OK"){
					bet_console.thePot_txt.text = "$" + String(pot);
					trace("Bet was placed");
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
		}//end function trimWhitespace		
		
		// This function translates the special custom type of hand5 into normal native types for
		// use in formatted string object sent to the database and ultimately other players
		private function hand5Parse(h:Hand5):Object{
			var ret:Object = new Object();
			var hold:String =  h.toString();
			// Get strength as uint -- gets first occurence of parens
			var posLeft:int = hold.indexOf("(");
			var posRight:int = hold.indexOf(")");
			var diff:int = posRight-posLeft-1;
			var strength:String = hold.substr(posLeft+1,diff);
					
			// get hand of individual cards as strings
			var posLeft2:int = hold.indexOf(" ("); // this locates the second left paren			
			var cds:String = hold.substr(posLeft2+2,14);
			
			//convert cards into array of cards
			var cards:Array = cds.split(" ");	
			
			ret.strength = strength;
			ret.cards = cards;
			return ret;
		} // end function
		

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
		
		//=============================================================
		// Displays all hands, but only first card is visible
		//=============================================================
		private function displayHands():void{
			
			//place hand_mc instances in pre-determined stage locations
			// always start with dealer as h[0] and rotate clockwise			
			shuffle.play();
			//Clear messages
			MainDocument.doc.showMsg("");
			for(var i:uint=0;i<N;i++){				
				var xx:uint; 
				var yy:uint;
				var localHand:Object = theGame[i].hand;				
				var p:String = theGame[i].player[1];
				//trace("localHand= " + localHand.cards.toString());
				//trace("p= " + p);
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
				getBetsVars.g_id = MainDocument.currentGame;						
				// Set up the server request and loader using POST
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
						bet_console.thePot_txt.text = "$" + String(thePot);						
						dealCards(MainDocument.gameRound);
						bet_console.bet_btn.addEventListener(MouseEvent.MOUSE_DOWN, handleBet);
						bet_console.bet_btn.enabled = true;
						Console.gs_update('<font size="14" color="#660033">ROUND ' + theRound + ' - Place your bets</font><br/>');
						
					}//end if
					break;
				case "ERROR_IN_ROUND":
					trace("Something wrong in getBets");
			}//end switch									
			updateLocalGameUI(theData);		
					
			// Delay 5s
			myDelay.start(); //calls the function delay after 5000 milliseconds
			myDelay.addEventListener(TimerEvent.TIMER_COMPLETE,delayComplete);
			
		}// end function
			
			private function delayComplete(e:Event):void{
				myDelay.removeEventListener(TimerEvent.TIMER_COMPLETE,delayComplete);
				myDelay.reset();
				mainGameLoop();
			}// end function

		///////////////////////////////////////////////////////////////////////////////
		/////////////////////////////   END MAIN LOOP   ///////////////////////////////
		///////////////////////////////////////////////////////////////////////////////
		
		
			
		private function updateLocalGameUI(bets:String):void{			
			for(var i:uint=0;i<N;i++){
					wbg_hand[i].status_txt.text = theGame[i].hand.cards.toString();
			} //end for			
		}// end function
		

		private function dealCards(round:uint):void{			
			for(var i:uint=0;i<N;i++){
				wbg_hand[i].showCard(round-1);
			} // end if			
		} // end function
		
				
		private function shutDownGame():void{
			//Sort the hand to determine winner based on hand strength
			sortHands(theGame);	
			//Show winner and winning hand in stats box
			Console.gs_update('<font size="14" color="#660033">The Winner: ' + theGame[0].player[1] + '</font><br/>');
			Console.gs_update('<font size="14" color="#660033">The Winning hand: ' + theGame[0].handtostring + '</font><br/>');
			// The only use of the main timeline -- shows game over
			MainDocument.doc.gotoAndStop(2);
			gameover.play();
		}// end function	
			
	}//end class
	
}//end package
