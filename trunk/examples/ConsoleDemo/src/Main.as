package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.utils.getDefinitionByName;
	import no.doomsday.console.ConsoleUtil;
	import no.doomsday.console.core.DLogger;
	import no.doomsday.console.LoggerUtil;
	
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
			addChild(ConsoleUtil.instance);
			ConsoleUtil.pass = "mypass";
			
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
			tf.y = stage.stageHeight -tf.height;
			tf.type = TextFieldType.INPUT;
			addChild(tf);
			
			//add the console instance using ConsoleUtil
			//ContextMenuUtil.setUp(ConsoleUtil.instance,this);
			
			//ConsoleUtil.linkFunction("buttonClickCommand", buttonClick);
			//ConsoleUtil.linkFunction("out", outputTest);
		}
		
		private function outputTest(input:String):String {
			return input;
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
			ConsoleUtil.log("Click!");
		}
		
	}
	
}