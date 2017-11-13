
package
{
	import PokerEval;
	import PokerLib;
	import PokerVars;
	import HandError;
	
	/**
		 * Represents a poker hand.
		 * <p>Has methods to very quickly evaluate hand strength and category (one pair, flush etc.) by using CactusKev's poker hand analysis algorithm</p>
		 * <p>Can get and swap individual cards, and compare two poker hands to each other</p>
		 * <p>Tested to evaluate 2,598,960 hands in 6.3 seconds on a 2.6 Ghz Dual Core Macbook Pro</p>
		 * @see net.houen.pokerface.Deck
		 * @see net.houen.pokerface.Card
		 */
	public interface IHand
	{
		/**
		 * Get a Card in the hand
		 * @param num The number of card to get. Must be between 0 and 4
		 * @throws HandError Will throw a HandError if invalid number given as parameter
		 * @return Card
		 * @see Card
		 */
		function getCard(num:uint):Card;
		
		/**
		 * Set a card in the hand. Will recalculate hand strength when set, so use with caution
		 * @param num The number of the card to set (0-4)
		 * @param card The new Card object to replace card with
		 * @throws HandError Will throw a HandError if invalid number given as parameter
		 * @see Card
		 */
		function setCard(num:uint,card:Card):void;
		
		/**
		 * Get the hands strength in cactuskev format
		 * @return int
		 */
		function get strength():int;
		
		/**
		 * Get the name of the current hand category (One Pair, Flush, etc.)
		 * @return String
		 */
		function get category():String;
		
		/**
		 * The string representation of the hand
		 */
		function toString():String;
	
		/**
		 * Set the hands cactuskev strength (unique hand strength for every possible poker hand)
		 */
		function recalcStrength():void;
		
		/**
		 * Compare two hands to eachother
		 * @param otherHand a Hand5 object representing the hand to be compared to
		 * @return Returns 1 if this hand is greater, -1 if this hand is lesser, 0 if equal
		 */
		function compare(handOther:AHand):int;
	}
}