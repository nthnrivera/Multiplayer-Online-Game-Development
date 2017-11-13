package
{
	import PokerLib;
	import PokerVars;
	
	/**
		 * Represents a playing card with cactuskev poker strength
		 */
	public class Card
	{
		private var _valueNum:uint;
		private var _valueString:String;
		private var _suit:String;
		private var _name:String;
		
		private var _cardRep:uint;
		
		/**
		 * Create new palying card
		 * @param cardRep The cards representation in cactuskev notation
		 * @param name An optional id name for the card
		 */
		public function Card(cardRep:uint, name:String = "")
		{
			this._cardRep = cardRep;
			this._valueNum = PokerVars.cardRankNum[PokerLib.RANK(cardRep)];
			this._valueString = PokerVars.cardRank[PokerLib.RANK(cardRep)];
			this._suit = PokerLib.SUIT(cardRep);
			this._name = name;
		}
		
		/**
		 * Get the cards suit
		 * @return String
		 */
		public function get suit():String
		{
			return this._suit;
		}
		
		/**
		 * Get the cards numerical value (2 to 14)
		 */ 
		public function get value():uint
		{
			return this._valueNum;
		}
		
		/**
		 * Get the cards string value (2 to A)
		 */
		public function get valueName():String
		{
			return this._valueString;
		}
		
		/**
		 * Get the cards cactuskev representation
		 */
		public function get cardRep():uint
		{
			return this._cardRep;
		}
		
		/**
		 * Get the cards id name
		 */
		public function get name():String
		{
			return this._name;
		}
		
		/**
		 * Get the cards string representation
		 */
		public function toString():String
		{
			return "" + this.valueName + this.suit;
		}

	}
}