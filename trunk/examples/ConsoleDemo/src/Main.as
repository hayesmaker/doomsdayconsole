package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import no.doomsday.console.ConsoleUtil;
	import no.doomsday.console.introspection.IntrospectionScope;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Main extends Sprite 
	{		
		private var testButton:Sprite;
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			
			//some stage elements
			testButton = new Sprite();
			testButton.graphics.beginFill(0xFF0000);
			testButton.graphics.drawRect(0, 0, 50, 50);
			testButton.y = stage.stageHeight >> 1;
			testButton.x = stage.stageWidth >> 1;
			testButton.buttonMode = true;
			addChild(testButton);
			testButton.addEventListener(MouseEvent.CLICK, buttonClick);
			
			var tf:TextField = new TextField();
			tf.width = 200;
			tf.text = "shift-tab to toggle console";
			tf.x = 10;
			tf.y = stage.stageHeight -tf.height
			addChild(tf);
			
			//add the console instance using ConsoleUtil
			addChild(ConsoleUtil.instance);
			
			var enc:ByteArray = new ByteArray();
			var enc2:ByteArray = new ByteArray();
			enc2.writeFloat(20);
			
			trace(enc.toString() == enc2.toString());
			
			
			ConsoleUtil.linkFunction("buttonClickCommand", buttonClick);
			ConsoleUtil.linkFunction("say", say);
		}
		//demonstrates how console commands handle arguments. In the console, type "mathAdd 3 1" for instance
		//also demonstrates how the console prints return values
		private function mathTest(a:Number, b:Number):Number {
			return a + b;
		}
		//demonstrates how the console handles method calls that fail
		private function failingFunction():void
		{
			var a:Array = [10];
			addChild(a[0]);
		}
		//this method is called both by the mouse click and the console command
		public function buttonClick(e:MouseEvent = null):void 
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = Math.random() * 0xFFFFFF;
			testButton.transform.colorTransform = ct;
		}
		public function say(s:String):String {
			return "Hey " + s;
		}
		
	}
	
}