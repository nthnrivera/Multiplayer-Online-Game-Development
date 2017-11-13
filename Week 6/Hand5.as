﻿
package
{
	import PokerEval;
	
	/**
		 * Represents a five card poker hand.
		 * <p>Has methods to very quickly evaluate hand strength and category (one pair, flush etc.) by using CactusKev's poker hand analysis algorithm</p>
		 * <p>Can get and swap individual cards, and compare two poker hands to each other</p>
		 * <p>Tested to evaluate 2,598,960 hands in 6.3 seconds on a 2.8 Ghz Dual Core Macbook Pro</p>
		 * @see net.houen.pokerface.Deck
		 * @see net.houen.pokerface.Card
		 */
	public class Hand5 extends AHand implements IHand
	{
		private var _cards:Array;
		private var _strength:uint;
		private var _strengthRank:uint;
		private var _name:String;
		
		/**
		 * Create new hand
		 * @param cardReps An array of card representations in the cactuskev format (often delivered by a hand pull from Deck class
		 * @param name A custom name for this hand
		 */
		public function Hand5(cardReps:Array,name:String = "")
		{
			super(5,cardReps,name);
			this.recalcStrength();
		}
		
		/**
		 * Set a card in the hand to a certain card.
		 * @param num The card number to change
		 * @param card The card to change to
		 * @see AHand
		 */
		public function setCard(num:uint,card:Card):void
		{
			super.setTheCard(num,card);
			this.recalcStrength();
		}

		/**
		 * Recalculate the hand strength. Called automatically every time a hand is created or a card is changed
		 */
		public function recalcStrength():void
		{
			this.setStrength(PokerEval.eval_5hand_fast([this.getCard(0).cardRep,this.getCard(1).cardRep,this.getCard(2).cardRep,this.getCard(3).cardRep,this.getCard(4).cardRep]));
		}
	}
}