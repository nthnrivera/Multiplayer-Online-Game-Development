package  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import Login;	
	//import Register;  weeks 7 & 8
	import Chat;
	import Console;
	import BetCon;
	import flash.events.MouseEvent;		
	
	public class MainDocument extends MovieClip {
		
		private var login:Login;
		//private var register:Register;
		private var chat:Chat;
		private var console:Console;
		public static var consoleIsCreated:Boolean = false;
		public static var STAGE:Stage;
		public static var doc:MainDocument; 		// need to easily use methods in other classes
		public static var player_id:int = -1; 		// ID of player -- comes from login.as or register.as
		public static var player_name:String; 		// Full name of player -- comes from login.as 
		public static var stored_id:int; 			// for chat room -- id of last chat
		public static var currentGame:int = 0; 		// ID of game started or subscribed in Console	
		public static var dealer:Boolean = false;	// True if this player starts a game
		public static var numPlayers:int = 0; 		// number of players in current game from Console
		public static var currentGamePlayers:Array = new Array(); //actual players and names into array from Console
		public static var gameOver:Boolean = false;
		public static var gameRound:uint = 1;
		public static var winningPot:uint = 0;
		public static var winningPlayer:uint;
		public static var winningHand:String;
		
		public static var localPath:String = "";	
		//public static var localPath:String = "";	
			
		
		public function MainDocument() {
			// constructor code				
			STAGE = stage;		
			doc = this;
			//Show the disabled game console 
			showConsole(null);
			// Set up listeners for UI login and register buttons
			selectLogin_btn.addEventListener(MouseEvent.MOUSE_UP,showLogin);
			selectRegister_btn.addEventListener(MouseEvent.MOUSE_UP,showRegister);
			
			// Set up listeners for UI console and chat buttons
			selectChat_btn.addEventListener(MouseEvent.MOUSE_UP,showChat);
			selectConsole_btn.addEventListener(MouseEvent.MOUSE_UP,showConsole);	
			
			
		} // end constructor function
		
		public function toggle_chat_console_buttons():void{
			selectChat_btn.enabled = !selectChat_btn.enabled;
			selectConsole_btn.enabled = !selectConsole_btn.enabled;
		} // end function
		
		public function enable_chat_button(){
			selectChat_btn.enabled = true;
		} // end function
		
		public function enable_console_button(){
			selectConsole_btn.enabled = true;
		} //end function
		
		/////////////////////////////////////////////////////
		// Console window will be instantiated once, but 
		// covered by chat window, occasionally, as necessary
		/////////////////////////////////////////////////////
		
		private function showConsole(e:MouseEvent):void{
			
			//Check for existence of Chat window and remove
			for (var i:uint=0;i<numChildren;i++){
				if(getChildAt(i).name == "Chat"){				
					removeChat();					
				} // end if
			} // end for
			
			// Create new console window, if not already created - make active
			if(consoleIsCreated==true){
				console.makeActive();	
			}else{		// place for first time	
				console = new Console();
				console.x = 738;
				console.y = 9;
		
				//Instantiate console on stage
				addChild(console);
				console.name = "Console";	
				consoleIsCreated = true;
			}// end else
			
			showMsg("");
			trace("open console window");
			toggle_chat_console_buttons();
			
						
		} // end function
		
		public function activateConsole():void{			
			console.makeActive();
		}//end function		
		
		//////////////////////////////////////////////////////
		// Chat window can be instantiated and then removed
		// to save bandwidth when not in use
		//////////////////////////////////////////////////////
		private function showChat(e:MouseEvent):void{			
			trace("open chat window");			
			showMsg("");
			toggle_chat_console_buttons();
			chat = new Chat();
			chat.x = 738;
			chat.y = 11;
			// Instanttiate chat window on stage
			addChild(chat);
			chat.name = "Chat";
			STAGE.focus = chat.myChat_txt;				
		} // end function
		
		private function showRegister(e:MouseEvent):void{
			trace("register user");
			/*  week 7 or 8
			for(var i:uint=0;i<numChildren;i++){
				if(getChildAt(i).name == "Login"){
					removeLogin();
				} // end if
			} //end for
			register = new Register();
			register.x = 222;
			register.y = 133;
			
			addChild(register);
			register.name = "Register";
			STAGE.focus = register.fullname_txt;
			showMsg("");
			turnOffButton("both"); // makes login and register buttons visible or invisible	
			*/
		} // end function
		
		private function showLogin(e:MouseEvent):void{
			for(var i:uint=0;i<numChildren;i++){
				if(getChildAt(i).name == "Register"){
					removeRegister();
				} // end if
			} //end for
			login = new Login();
			login.x = 272;
			login.y = 183;
			
			addChild(login);
			login.name = "Login";
			STAGE.focus = login.login_txt;
			showMsg("");
			turnOffButton("both"); // makes login and register buttons visible or invisible			
		} //end function
		
		
		public function removeChat():void{			
			chat.dispose();	// cleans up all listners from instance			
			removeChild(chat); // removes instance from the display
			chat = null; // renders instance available for garbage collection			
		} // end function
		
		
		public function removeLogin():void{
			removeChild(login);
		} // end function
		
		public function removeRegister():void{
			//removeChild(register); // week 7 or 8
		} // end function
		
		public function playerTitle(s:String):void{
			player_txt.text = s;
		} //end function
		
		public function showMsg(s:String):void{
			welcome_txt.text = s;
		} // end function
		
		// Makes Login & register buttons invisible as needed
		public function turnOffButton(btn:String):void{
			switch (btn){
				case "login" :
					selectLogin_btn.visible = false;
					break;
				case "register":
					selectRegister_btn.visible = false;
					break;
				case "both":
					selectLogin_btn.visible = false;
					selectRegister_btn.visible = false;
			} //end switch
						
		}// function
		
		// Makes Login & register buttons visible as needed
		public function turnOnButton(btn:String):void{
			switch (btn){
				case "login" :
					selectLogin_btn.visible = true;
					break;
				case "register":
					selectRegister_btn.visible = true;
					break;
				case "both":
					selectLogin_btn.visible = true;
					selectRegister_btn.visible = true;
			} //end switch
						
		}// function
		
	} //end class
	
} // end package
