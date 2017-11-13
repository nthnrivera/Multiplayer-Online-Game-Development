package  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;		
	import flash.events.MouseEvent;	
	import GameServer;
	
	public class MainDocument extends MovieClip {				
		
		public static var STAGE:Stage;
		public static var doc:MainDocument;	// need to easily use methods in other classes		
						
		private var testGame:GameServer;
		private var players:Array;

		public function MainDocument() {
			// constructor code				
			STAGE = stage;		
			doc = this;
			
			//Call Game Server
			players = new Array();
			players[0] = "Donald Duck";
			players[1] = "Mickey Mouse";
			players[2] = "Daisy Duck";
			players[3] = "Minnie Mouse";
			players[4] = "Pluto";
			
			testGame = new GamesServer(players);
			addChild(testGame);
			
		} // end constructor function		
		
	} //end class
	
} // end package
