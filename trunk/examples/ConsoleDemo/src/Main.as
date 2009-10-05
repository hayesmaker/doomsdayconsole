package 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import no.doomsday.console.ConsoleUtil;
	import no.doomsday.console.introspection.IntrospectionScope;
	import no.doomsday.console.math.MathUtils;
	
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
			
			ConsoleUtil.linkFunction("greet", greet);
			ConsoleUtil.linkFunction("objectTest", objectTest);
			ConsoleUtil.linkFunction("buttonClick", buttonClick);
			ConsoleUtil.linkFunction("test", test);
		}
		
		//this method is called both by the mouse click and the console command
		public function buttonClick(e:MouseEvent = null):void 
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = Math.random() * 0xFFFFFF;
			testButton.transform.colorTransform = ct;
		}
		public function greet(s:String):String {
			return "Hey " + s;
		}
		public function objectTest(ob:Object, ar:Array):Object {
			return ob+" "+ar;
		}
		private function test():void {
			
		}
		
		
	}
	
}