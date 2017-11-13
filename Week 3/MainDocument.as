package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class MainDocument extends MovieClip {
		
		private var login:Login;
		
		public static var STAGE:Stage;
		public static var doc:MainDocument;
		public static var localPath:String = "http://nrivera24.mydevryportfolio.com/wbg450/"
		
		public function MainDocument() {
			// constructor code
			trace("Main Document is here");
			
			STAGE = stage;
			doc = this;
			
			//UI listeners
			selectLogin_btn.addEventListener(MouseEvent.MOUSE_UP, showLogin);
			selectRegister_btn.addEventListener(MouseEvent.MOUSE_UP, showRegister);
		}
		
		private function showLogin(e:MouseEvent):void
		{
			trace("Login button is pressed");
			login = new Login();
			login.x = 272;
			login.y = 183;
			
			addChild(login);
			login.name = "Login";
			STAGE.focus = login.login_txt;
			showMsg(""); // This code causes my script to break if I set welcome_txt.text to be equal to "s"
			turnOffButton("both");
		}
		
		private function showRegister(e:MouseEvent):void{
				trace("Register button is pressed")
				//turnOffButton("both");
			}
			
		public function removeLogin():void{
				removeChild(login);
			}
			
		public function removeRegister():void{
				//removeChild(register);
			}
			
		public function showMsg(s:String):void{
				welcome_txt.text = "";
			}
		
		public function turnOffButton(btn:String):void{
					switch(btn)
					{
							case "login":
									selectLogin_btn.visible = false;
									break;
							case "register":
									selectRegister_btn.visible = false;
									break;
							case "both":
									selectLogin_btn.visible = false;
									selectRegister_btn.visible = false;
									break;
					}
			}
			
			public function turnOnButton(btn:String):void{
					switch (btn){
							case "login":
									selectLogin_btn.visible = true;
									break;
							case "register":
									selectRegister_btn.visible = true;
									break;
							case "both":
									selectLogin_btn.visible = true;
									selectRegister_btn.visible = true;
									break;
						}
				}
	}
	
}
