package  {
	
	import flash.display.MovieClip;
	
	
	
	public class Hand_mc extends MovieClip {		
		
		private var c:Array = new Array(5);
		
		public function Hand_mc(hand:Object,player:String):void {
			// constructor code
			for(var i:uint=0;i<5;i++){
				
				c[i] = new VCard(String(hand.cards[i]));
				c[i].x = 0 + (i * 20); //starting at 0 and incrementing by 20
				c[i].y = 0;
				
				c[i].visible = false;
				this.addChild(c[i]);
			}// end for				
			
			this.player_txt.text = player;
		} // end constructor function
		
		public function hideCard(i:uint):void{
			this.c[i].visible = false;
		} //end function
		
		public function showCard(i:uint):void{
			this.c[i].visible = true;
		} //end function
		
	} // end class
	
} // end package
