package no.doomsday.aronning.debug.console.testbuttons 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import no.doomsday.aronning.debug.console.DebugConsole;
	import no.doomsday.aronning.debug.console.messages.MessageTypes;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TestButton extends Sprite
	{
		private var func:Function;
		public var funcName:String;
		private var params:Array;
		public function TestButton(funcName:String,func:Function,params:Array) 
		{
			this.funcName = funcName;
			this.func = func;
			this.params = params;
			graphics.beginFill(0, 0.5);
			graphics.lineStyle(0, 0xFFFFFF, 0.3);
			graphics.drawRect(0, 0, 80, 20);
			var tf:TextField = new TextField();
			addChild(tf);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.defaultTextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
			tf.text = funcName;
			tf.mouseEnabled = false;
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			try{
				var val:* = func.apply(this, params);			
				if (val) {
					DebugConsole.getInstance().trace("Button call "+funcName+" : "+val);
				}
			}catch (error:Error) {
				DebugConsole.getInstance().addMessage("Button call " + funcName + " error: " + error, MessageTypes.ERROR);
			}
		}
		
	}
	
}