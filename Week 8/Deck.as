
package
{
	import PokerLib;
	import DeckError;
	
	/**
	 * Represents a deck of 52 cards modeled by Card objects
	 * 
	 * <p>The Deck object can create and shuffle 52 playing vcard representations for use with the Hand5 and Card objects.</p>
	 * <p>It is the natural starting point for creating random poker hands.</p>
	 * 
	 * @see net.houen.pokerface.Card
	 */
	public class Deck
	{
		private var _deck:Array;
		
		/**
		 * Creates the deck unshuffled. This should normally be followed be an immediate shuffle operation
		 */
		public function Deck()
		{
			this._deck = new Array(52);
			this.reset();
		}
		
		/**
		 * Returns the last card from the deck, removing it at the same time
		 * 
		 * @param name A custom id name for the card
		 * @throws net.houen.pokerface.error.DeckError If no cards left in deck
		 * @return A net.houen.pokerface.Card object representing the card pulled
		 * @see net.houen.pokerface.Card
		 * @see net.houen.pokerface.Hand5
		 */
		public function pullCard(name:String = ""):Card
		{
			if(this._deck.length < 1)
				throw new DeckError("Tried to pull random card, but no cards left in deck");
			var cardRep:uint = this.pullCardRep();
			return new Card(cardRep,name);
		}
		
		/**
		 * Returns the last card from the deck, leaving it in the deck
		 * 
		 * @param num The number in the deck to return, empty for random
		 * @param name A custom id name for the card
		 * @throws net.houen.pokerface.error.DeckError If no cards left in deck
		 * @return A net.houen.pokerface.Card object representing the card pulled
		 * @see net.houen.pokerface.Card
		 */
		public function peekCard(num:int = -1,name:String = ""):Card
		{
			if(this._deck.length < 1)
				throw new DeckError("Tried to peek random card, but no cards left in deck");
			if(num > this._deck.length - 1)
				throw new DeckError("Tried to peek card num " + num + ", but not that many cards left in deck")
			if(num < 0)
				num = 0;
			var card:uint = this._deck[num];
			return new Card(card,name);
		}
		
		/**
		 * Returns a 5 card Hand5 object from the last 5 cards in the deck, removing them at the same time
		 * 
		 * @throws net.houen.pokerface.error.DeckError If less than five cards left in deck
		 * @return A net.houen.pokerface.Hand object representing the hand pulled
		 * @see net.houen.pokerface.Card
		 * @see net.houen.pokerface.Hard5  
		 */
		public function pull5Hand(name:String = ""):Hand5
		{
			if(this._deck.length < 5)
				throw new DeckError("Less than five cards left in deck");
			var hand:Array = [this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep()];
			return new Hand5(hand,name);
		}
		
		/**
		 * Returns a 7 card Hand7 object from the last 7 cards in the deck, removing them at the same time
		 * 
		 * @param card1 A Card object to put as first card in hand (e.g. for Texas Hold'em shared cards
		 * @param card2 A Card object to put as second card in hand
		 * @throws net.houen.pokerface.error.DeckError If less than five cards left in deck, or only one Card supplied
		 * @return A net.houen.pokerface.Hand object representing the hand pulled
		 * @see net.houen.pokerface.Card
		 * @see net.houen.pokerface.Hand7  
		
		public function pull7Hand(card1:Card = null, card2:Card = null,name:String = ""):Hand7
		{
			var hand:Array;
			
			if(this._deck.length < 7)
				throw new DeckError("Less than seven cards left in deck");
			if((card1 == null && card2 != null) || (card2 == null && card1 != null))
				throw new DeckError("Only one card was supplied as argument. Pleasy supply either two or none");
			if(card1 is Card && card2 is Card)
				hand = [card1.cardRep,card2.cardRep,this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep()];
			else
				hand = [this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep(),this.pullCardRep()];
			return new Hand7(hand,name);
		}
		 */
		
		/**
		 * Shuffles the deck, causing cards to be in random order
		 * 
		 * <p>Should nearly always be the first thing you do after initializing a deck</p>
		 */
		public function shuffle():void
		{
			PokerLib.shuffle_deck(this._deck);
		}
		
		/**
		 * Resets the deck, causing all cards to be present and unordered
		 */
		public function resetShuffled():void
		{
			this.reset();
			this.shuffle();
		}
		
		/**
		 * Resets the deck, causing all cards to be present and ordered
		 */
		public function reset():void
		{
			PokerLib.init_deck(this._deck);
		}
		
		/**
		 * Pulls a new cards cactuskev strength representation from the deck
		 * @see net.houen.cactuskev.PokerLib
		 */
		private function pullCardRep():uint
		{
			var cardRep:uint = this._deck.pop();
			return cardRep;
		}

	}
}