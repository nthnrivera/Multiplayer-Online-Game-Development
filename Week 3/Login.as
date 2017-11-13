package  {
	
	import flash.display.MovieClip;
	import flash.text.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.net.*;
	import MainDocument;
	
	public class Login extends MovieClip {
		
		
		public function Login() {
			// constructor code
			trace("Login box is open")
			//modify existing text boxes
			
			login_txt.tabEnabled = true;
			login_txt.tabIndex = 1;
			login_txt.border = true;
			login_txt.borderColor = 0xAAAAAA;
			login_txt.background = true;
			login_txt.backgroundColor - 0xFFFFDD;
			
			pwd_txt.tabEnabled = true;
			pwd_txt.tabIndex = 2;
			pwd_txt.border = true;
			pwd_txt.borderColor = 0xAAAAAA;
			pwd_txt.background = true;
			pwd_txt.backgroundColor - 0xFFFFDD;
			
			login_btn.tabEnabled = true;
			login_btn.tabIndex = 3;
			
			//button listeners
			login_btn.addEventListener(MouseEvent.MOUSE_UP, doLogin);
			
			login_close_btn.addEventListener(MouseEvent.MOUSE_UP, doClose);
			
			//the following code cause error 1120: access of undefined property onEnter
			//addEventListener(KeyboardEvent.KEY_DOWN, onEnter);
		}
		
		/* the following section of script causes Error 1120: Access of undefined property keyboard
		private function onEnter(e:KeyboardEvent):void
		{
				trace("User presses keyboard ENTER key");
				
				if(e.keyCode == keyboard.ENTER)
				{
					doLogin(null);
				}
		}
		*/
		
		function trimWhitespace($string:String):String
		{
			if($string == null)
			{
				return "";
			}
			
			return $string.replace(/^\s+|\s+$/g, "");
		}
		
		private function doLogin(e:MouseEvent)
		{
				//trace("User presses OK Button");
				
				//Following line gives error Access of possibly undefined propert local path through a reference with static type Class
				//var req:URLRequest=new URLRequest(MainDocument.localpath + "login.php");
			
				req.method = URLRequestMethod.POST;
				
				var vars:URLVariables = new URLVariables();
				vars.login=login_txt.text;
				vars.pwd = pwd_txt.text;
				req.data = vars;
				
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.VARIABLES;
				loader.load(req);
				
				loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				loader.addEventListener(Event.COMPLETE, retrieveData);
				
				function retrieveData(e:Event):void
				{
					var rawString:String = trimWhitespace(unescape(e.target.data));
					var stArray:Array = rawString.split("&");
					
					for(var i:unit; i<stArray.length; i++)
					{
						stArray[i] = trimWhitespace(stArray[i]);
						var pair:Array = stArray[i].split("=");
						pair[0] = trimWhitespace(pair[0]);
						switch(pair[0])
						{
							case "myStatus":
								var ms:String = trimWhitespace(pair[1]);
								break;
							case "p_id":
								var id:int = int(trimWhitespace(pair[1]));
								break;
							case "fullname":
								var fn:String = trimWhitespace(pair[1]);
							default:
						}
					}
					
					switch(ms)
					{
						case "NOTOK":
							MainDocument.doc.showMsg("There is a communication problem\n Try Again!")
							break;
						case "OK":
							if(fn != "INVALID")
							{
								MainDocument.doc.showMsg("Welcome" + fn);
								//MainDocument.player_id = id;
								//MainDocument.player_name = fn;
								MainDocument.doc.removeLogin();
								MainDocument.doc.turnOffButton("both");
								//MainDocument.doc.enable_chat_button();
								//MainDocument.doc.activateConsole();
								///////////////////
								// start game here
								///////////////////
							}
							else
							{
								MainDocument.doc.showMsg("Login or password is incorrect. try again, or \n if you are not a member, please register")
								MainDocument.doc.turnOnButton("register");
								MainDocument.doc.turnOffButton("login");
							}
							break;
						default:
							
					}
				}
				
				function onHTTPStatus(event:HTTPStatusEvent):void
				{
					//trace("HTTP response code " + event.status);
					if(event.status !=200)
					{
						MainDocument.doc.showMsg("There is an I/O Error #" + event.status);
					}
				}
		}
		
		private function doClose(e:MouseEvent)
		{
				trace("User presses Close button");
			MainDocument.doc.showMsg("");
			MainDocument.doc.removeLogin();
			MainDocument.doc.turnOnButton("both");
		}
	}
	
}
