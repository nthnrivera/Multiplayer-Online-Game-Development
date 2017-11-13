package  {
	
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	
	public class VCard extends MovieClip {
		
		private var _suit:String;
		private var _rank:String;
		
		public function VCard(c:String) {
			// constructor code
			var c = c.toLowerCase();
			_suit = c.charAt(1);
			_rank = c.charAt(0);
			
			var shadowFilter:DropShadowFilter = new DropShadowFilter();
			shadowFilter.alpha = .60;
			shadowFilter.angle = -135;
			shadowFilter.color = 0x222222;
			shadowFilter.distance = 7;
			shadowFilter.quality = 90;
			this.filters = [shadowFilter]
			this.gotoAndStop(c);
		}
	}
	
}
