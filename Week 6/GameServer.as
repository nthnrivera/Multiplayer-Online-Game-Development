package  {
	
	import flash.display.MovieClip;
	import flash.net.*;	
	import CactusArrays;
	import PokerLib;
	import PokerVars;
	import PokerEval;
	import Hand_mc;
	import VCard;
	import flash.events.*;
	import MainDocument;

	import flash.utils.Timer;


	public class GameServer extends MovieClip {
		
		private var myDeck:Deck;		// this is used only by dealer, thus gameServer
		private var _players:Array;		
		private var N:uint; // Number of players
		
		// This is the main game object that holds all current game players and their complete hands
		// and is created here and uploaded to the server database for all other clients/players
		private var theGame:Object;
		
		
		
		//This array holds the visual representations of the hands
		private var wbg_hand:Array = new Array(5);			

				
		// CONSTRUCTOR FOR GameServer
		public function GameServer(players:Array) { //players come from call in Main
			// constructor code
			trace("Current Game open");
						
			//Store player names, numbers in an array coming from call in MainDocument.as
			_players = new Array();
			N = players.length;			
			for (var i:uint=0;i<N;i++){
				_players[i] = players[i];
			}//end for				
				
							
			
			//Create new deck coming from Deck.as
			myDeck = new Deck();	
			//Shuffle deck (100 times)
			myDeck.shuffle();
			myDeck.shuffle();
			myDeck.shuffle();
			myDeck.shuffle();
			
			//====================================================
			// CREATE THE MAIN OBJECT ARRAY for game play - 
			// this is the main data structure for the game which
			// was started by this player as the dealer
			//
			// 		Object theGame:
			// 			.hand:Hand5 = pull5Hand();
			//				.strength
			//				.cards
			//			.player = _players[i]
			//				{id, name}
			//			
			//====================================================
			
			theGame = new Object(); // shared through upload to dB for all players in game
			
			for(var j:uint=0; j < N; j++){		
				var h:Hand5 = myDeck.pull5Hand(); //using the CactusKev routine from Deck.as
				trace("handtostring= " + h.toString());
				var obj:Object = new Object();
				obj.player = _players[j]; 
				obj.hand = hand5Parse(h);	
				obj.handtostring = h.toString();				
				
				theGame[j] = obj;						
				trace("theGame["+j+"].player= " + theGame[j].player);
				trace("theGame["+j+"].hand= " + theGame[j].hand.strength);
				trace("theGame["+j+"].hand= " + theGame[j].hand.cards);
			} // end for			
			
			
			displayHands(); 		
			dealCards(1);
			dealCards(2);
			dealCards(3);
			dealCards(4);
			dealCards(5);
			
		} //end constructor function
			
			
		
		
		//=================================================================================
		// Utility Functions
		//=================================================================================	
		
		
		// This function translates the special custom type of hand5 into normal native types for
		// use in the byte array sent to the database and ultimately other players
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
			
			
			for(var i:uint=0;i<N;i++){				
				var xx:uint; 
				var yy:uint;
				var localHand:Object = theGame[i].hand;				
				var p:String = theGame[i].player;
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
				
				//wbg_hand[i].showCard(0);	
				//card1.play();
				
			} // end for
			
		} // end function
			
				
			
		private function dealCards(round:uint):void{			
			for(var i:uint=0;i<N;i++){
				wbg_hand[i].showCard(round-1);
			} // end for			
		} // end function	
				
		
			
	}//end class
	
}//end package
