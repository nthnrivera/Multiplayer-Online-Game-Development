package  {
	
	import flash.display.MovieClip;
	import flash.text.*;	
	import flash.events.*;		
	import flash.net.*;	
	import flash.ui.Keyboard;
	import MainDocument;	
	
	public class Login extends MovieClip {		
		
		public function Login() {
			// constructor code
			//modify existing text boxes
			login_txt.tabEnabled = true;
			login_txt.tabIndex = 1;			
			login_txt.border = true;
			login_txt.borderColor = 0xAAAAAA;
			login_txt.background = true;
			login_txt.backgroundColor = 0xFFFFDD;				
			pwd_txt.tabEnabled = true;
			pwd_txt.tabIndex = 2;
			pwd_txt.border = true;
			pwd_txt.borderColor = 0xAAAAAA;
			pwd_txt.background = true;
			pwd_txt.backgroundColor = 0xFFFFDD;			
			login_btn.tabEnabled = true;
			login_btn.tabIndex = 3;				
			// Add buttons event listeners
			login_btn.addEventListener(MouseEvent.MOUSE_UP, doLogin);
			login_close_btn.addEventListener(MouseEvent.CLICK, doClose);
			addEventListener(KeyboardEvent.KEY_DOWN,onEnter); // allow keyboard to submit	
		} // end constructor function
		
		private function onEnter(e:KeyboardEvent):void{						
			if(e.keyCode == Keyboard.ENTER){
				trace("User presses enter key");
				doLogin(null); // must be null to meet the need for a parameter
			} // end if
		} // end function
		
		function trimWhitespace($string:String):String {
			if ($string == null) {
				return "";
			} //end if
			return $string.replace(/^\s+|\s+$/g, ""); // see regular expressions
		} // end function		   
		
		private function doLogin(e:MouseEvent):void{			
			//trace("User presses OK button");
			
			var req:URLRequest=new URLRequest(MainDocument.localPath + "login.php");
			req.method = URLRequestMethod.POST;					
			
			var vars:URLVariables=new URLVariables();
			vars.login=login_txt.text;
			vars.pwd = pwd_txt.text;
			req.data = vars;						
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;	
			loader.load(req);
			
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,onHTTPStatus); 
			loader.addEventListener(Event.COMPLETE, retrieveData);
			
			function retrieveData(e:Event):void { 		
				var rawString:String = trimWhitespace(unescape(e.target.data));
				trace("e.target.data = " + e.target.data);
				trace("myStatus = " + trimWhitespace(e.target.data.myStatus));
				var stArray:Array = rawString.split("&");
				trace(stArray);
				for(var i:uint; i<stArray.length; i++){
					stArray[i] = trimWhitespace(stArray[i]);
					var pair:Array = stArray[i].split("=");
					pair[0] = trimWhitespace(pair[0]);
					switch (pair[0]){
						case "myStatus":
						  	var ms:String = trimWhitespace(pair[1]);    //  status data value
						  	break;
						case "p_id":
						  	var id:int = int(trimWhitespace(pair[1]));  // player id
						  	break;
						case "fullname":
							var fn:String = trimWhitespace(pair[1]);    // fullname
							break;
						default: // this is all the other garbage---> dump
						    //do nothing
					} // end switch
				} //end for 					
				
				switch (ms){
					case "NOTOK" :
						MainDocument.doc.showMsg("There is a communication problem\nTry Again!");
						break;
					case "OK" :
						if(fn != "INVALID"){							
							MainDocument.doc.showMsg("Welcome " + fn);							
							MainDocument.player_id = id;
							MainDocument.player_name = fn;
							MainDocument.doc.removeLogin();
							MainDocument.doc.turnOffButton("both");							
							MainDocument.doc.enable_chat_button();
							MainDocument.doc.activateConsole();
							////////////////////////
							// start game here
							////////////////////////
						}else{
							MainDocument.doc.showMsg("Login or password is incorrect. Try again, or                                                      \nif you are not a member,  please register");
							MainDocument.doc.turnOnButton("register");
							MainDocument.doc.turnOffButton("login");							
						}
						break;
					default :
						MainDocument.doc.showMsg("An unknown problem has occured");
				} // end switch				
			} // end function			
			function onHTTPStatus(event:HTTPStatusEvent):void { 
				//trace("HTTP response code " + event.status); 
				if(event.status!=200){
					MainDocument.doc.showMsg("There is an I/O Error #" + event.status);
				} // end if
			} // end function				
		} // end function doLogin
	
		private function doClose(e:MouseEvent):void{			
			trace("User presses Close Button");
			MainDocument.doc.showMsg(""); // clears any message
			MainDocument.doc.removeLogin();
			MainDocument.doc.turnOnButton("both");			
		} // end function
	
	} // end class
	
	
} // end package
