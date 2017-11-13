package  {
	
	import flash.display.MovieClip;
	import fl.controls.ComboBox;
	import fl.controls.Button;
	import flash.text.TextFormat;
	import Console;
	
	
	public class BetCon extends MovieClip {
		private var bank:int; // user's temporary bank funds in whole numbers
		private var betCon_active:Boolean = false;		
		
		public function BetCon() {
			// constructor code -- init in library -- format button here
			var tf:TextFormat = new TextFormat(); 
			tf.font = "Arial"; 
			tf.size = 16; 
			tf.bold = true; 
			this.bet_btn.setStyle("textFormat", tf);
									
		} // end constructor
		
				
		public function makeBetCon(choice:String):void{			
			switch (choice){
				case "enabled":								
					this.bet_btn.enabled = true;					
					betCon_active = true;
					break;
				case "disabled":					
					this.bet_btn.enabled = false;					
					betCon_active = false;
					break;
			} // edn switch
		} // end function
		
	} //end class
	
} // end package
