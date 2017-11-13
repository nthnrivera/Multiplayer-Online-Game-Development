package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import MainDocument;
	import flash.net.*;
	import flash.display.SimpleButton;	
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	public class Chat extends MovieClip {
		
		private var chatTime:Timer = new Timer(3000,1);
		private var vars:URLVariables = new URLVariables();		
		private var req:URLRequest = new URLRequest(MainDocument.localPath + "chat.php");
		private var chatLoader1:URLLoader = new URLLoader();
		private var chatLoader2:URLLoader = new URLLoader();
		private var chatLoader3:URLLoader = new URLLoader();
		
		public function Chat() {
			// constructor code
			initWindow();
			trace("Chat is alive");			
			
			// Listen for "New post Send" button or key "Enter"
			chat_send_btn.addEventListener(MouseEvent.MOUSE_UP, onNewPost);
			addEventListener(KeyboardEvent.KEY_DOWN,onEnter); // allow keyboard to submit
			
			// Timer for auto refreshing chats every 3 seconds							
			chatTime.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			chatTime.start();			
			
		} // end constructor
		
		///////////////////////////////////////////////////
		// UTILITY FUNCTIONS
		///////////////////////////////////////////////////
		
		function trimWhitespace($string:String):String {
			if ($string == null) {
				return "";
			} //end if
			return $string.replace(/^\s+|\s+$/g, ""); // see regular expressions
		} // end function	
		
		private function onEnter(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.ENTER){
				onNewPost(null); // must be null to meet the need for a parameter
			} //end if
		}//end function
		
		private function parseChat(inStr:String):String{
			var begSt:String = '<b><font color="#006699">';
			var outHTML:String = "";
			var lineArray:Array = inStr.split("^");
			for(var i:uint=0;i<lineArray.length;i++){
				var fieldArray:Array = lineArray[i].split("|");
				outHTML += begSt + fieldArray[0] + ': </font></b> <font color="#999999" size="-2">';
				outHTML += fieldArray[1] + '</font> <font color="#000000"> ';
				outHTML += fieldArray[2] + '</font> <br />';
			} // end for loop
			return outHTML;
		} // end function
		
		///////////////////////////////////////////////////
		// INITIALIZE CHAT WINDOW
		///////////////////////////////////////////////////
		
		protected function initWindow():void{			
			
			vars.requester = "initial_request";			
			req.method = URLRequestMethod.POST;
			req.data = vars;					
			chatLoader1.dataFormat = URLLoaderDataFormat.VARIABLES;
			chatLoader1.load(req);
			chatLoader1.addEventListener(Event.COMPLETE, retrieveData1);
			chatLoader1.addEventListener(HTTPStatusEvent.HTTP_STATUS,onHTTPStatus);								
					
		} //end function

		private function retrieveData1(e:Event):void{					
			var rawString:String = trimWhitespace(unescape(e.target.data));			
			var stArray:Array = rawString.split("&");
			
			for(var i:uint; i<stArray.length; i++){
				stArray[i] = trimWhitespace(stArray[i]);				
				var pair:Array = stArray[i].split("=");
				pair[0] = trimWhitespace(pair[0]);
				switch (pair[0]){
					case "returnBody":
						var returnBody:String = trimWhitespace(pair[1]);  // return data value
						break;
					case "stored_id":
						var stored_id:String = trimWhitespace(pair[1]);
						break;
					default: // this is all the other garbage---> dump
						//do nothing
				} // end switch
			} //end for 	
			
			if (returnBody == "NORECORDS") {
				chat_msg_txt.text = "No current chat";					
			} else {		
				MainDocument.stored_id = int(stored_id);
				chat_msg_txt.condenseWhite = true;
				chat_msg_txt.htmlText = parseChat(returnBody);					
			} //end if-else
				
		} //end function
		
		
		///////////////////////////////////////////////////////////
		// HANDLER FOR TIMED CHECKING OF CHATS
		///////////////////////////////////////////////////////////
		
		protected function onTimerComplete(evt:TimerEvent):void{
			
			vars.requester = "chat_check";			
			vars.stored_id = MainDocument.stored_id;			
			
			req.method = URLRequestMethod.POST;
			req.data = vars;			
			chatLoader2.dataFormat = URLLoaderDataFormat.VARIABLES;
			chatLoader2.load(req);
			
			chatLoader2.addEventListener(Event.COMPLETE, retrieveData2);
			chatLoader2.addEventListener(HTTPStatusEvent.HTTP_STATUS,onHTTPStatus);			
			
			chatTime.reset();
			chatTime.start();
			
		} // end function
		
		private function retrieveData2(e:Event):void{
			
			var rawString:String = trimWhitespace(unescape(e.target.data));			
			var stArray:Array = rawString.split("&");			
			for(var i:uint; i<stArray.length; i++){
				stArray[i] = trimWhitespace(stArray[i]);				
				var pair:Array = stArray[i].split("=");
				pair[0] = trimWhitespace(pair[0]);
				switch (pair[0]){
					case "returnBody":
						var returnBody:String = trimWhitespace(pair[1]);  // return data value
						break;
					case "stored_id":
						var stored_id:String = trimWhitespace(pair[1]);
						break;
					case "statusline":
						var statusline:String = trimWhitespace(pair[1]);
						break;
					default: // this is all the other garbage---> dump
						//do nothing
				} // end switch
			} //end for
				
			if (returnBody == "NORECORDS") {
				chat_msg_txt.text = "No chat yet";
			}else{	
				if(statusline=="is_new"){
					chat_msg_txt.condenseWhite = true;
					chat_msg_txt.htmlText = parseChat(returnBody);					
					MainDocument.stored_id = int(stored_id);
					//MainDocument.doc.showMsg("" + statusline);
				}
			}// end if				
		} //end function
		
		/////////////////////////////////////////////
		//  NEW POSTS
		/////////////////////////////////////////////
		protected function onNewPost(e:Event):void{			
			myChat_txt.restrict = "a-zA-Z 0-9\\-_!@#$%^";			
			
			vars.requester = "new_chat";
			vars.player_id = MainDocument.player_id;
			vars.chat_body = myChat_txt.text;			
			
			req.method = URLRequestMethod.POST;
			req.data = vars;
			
			chatLoader3.dataFormat = URLLoaderDataFormat.VARIABLES;	
			chatLoader3.load(req);
			
			chatLoader3.addEventListener(Event.COMPLETE, retrieveData3);
			chatLoader3.addEventListener(HTTPStatusEvent.HTTP_STATUS,onHTTPStatus);				
			
		} //end protected function onNewPost
		
		function retrieveData3(e:Event):void{
			var rawString:String = trimWhitespace(unescape(e.target.data));			
			var stArray:Array = rawString.split("&");			
			for(var i:uint; i<stArray.length; i++){
				stArray[i] = trimWhitespace(stArray[i]);				
				var pair:Array = stArray[i].split("=");
				pair[0] = trimWhitespace(pair[0]);
				switch (pair[0]){
					case "returnBody":
						var returnBody:String = trimWhitespace(pair[1]);  // return data value
						break;
					case "stored_id":
						var stored_id:String = trimWhitespace(pair[1]);
						break;
					case "statusline":
						var statusline:String = trimWhitespace(pair[1]);
						break;
					default: // this is all the other garbage---> dump
						//do nothing
				} // end switch
			} //end for
			if (statusline == "new_insert") {
				chat_msg_txt.condenseWhite = true;
				trace("returnBody=XXX" + returnBody + "XXX") 
				chat_msg_txt.htmlText = parseChat(returnBody);
				MainDocument.stored_id = int(stored_id);				
			}// end if
			myChat_txt.text = "";
		} //end function
		 
		 private function onHTTPStatus(event:HTTPStatusEvent):void { 
				trace("HTTP response code " + event.status); 
				if(event.status!=200){
					MainDocument.doc.showMsg("There is an I/O Error #" + event.status);
				} // end if
			} // end function
			
		 public function dispose():void      {
          // clean up!
          stop();
		  stage.removeEventListener(KeyboardEvent.KEY_DOWN,onEnter);
		  chat_send_btn.removeEventListener(MouseEvent.MOUSE_UP, onNewPost);
          chatTime.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
          chatLoader1.removeEventListener(Event.COMPLETE, retrieveData1);
		  chatLoader2.removeEventListener(Event.COMPLETE, retrieveData2);
		  chatLoader3.removeEventListener(Event.COMPLETE, retrieveData3);
		  chatTime.removeEventListener(HTTPStatusEvent.HTTP_STATUS,onHTTPStatus);
      	} // end function dispose
		
	} //end class
	
} //end package
