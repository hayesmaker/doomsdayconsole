package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import no.doomsday.console.ConsoleUtil;
	import no.doomsday.console.measurement.MeasurementTool;
	
	public class Main extends Sprite 
	{
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(ConsoleUtil.instance);
			// entry point
			//add the console instance to the stage or the root layer of your application
			
			//by default, the console toggles on control-tab, but can also be shown with ConsoleUtil.show and ConsoleUtil.hide
			//ConsoleUtil.show();
			
			//to link a command to a method, do as follows
			ConsoleUtil.linkFunction("drawRect", drawRect);
			
			
			//now try opening the console. Start typing in "dra" and it should autocomplete to drawRect. 
			//hit tab to jump to the end of the line and enter a few numbers, for instance  'drawRect 30 30 100 200 0xff0000'
			//hit enter to complete your command. voila.
		}
		private function drawRect(x:Number, y:Number, width:Number, height:Number,color:uint):void {
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawRect(x, y, width, height);
		}
		
	}
	
}