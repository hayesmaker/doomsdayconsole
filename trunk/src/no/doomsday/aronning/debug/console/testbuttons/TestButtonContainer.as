package no.doomsday.aronning.debug.console.testbuttons
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TestButtonContainer extends Sprite
	{
		public var buttons:Vector.<TestButton>;
		public function TestButtonContainer() 
		{
			buttons = new Vector.<TestButton>;
		}
		public function addButton(label:String, func:Function, args:Array):Boolean {
			for (var i:int = 0; i < buttons.length; i++) 
			{
				if (buttons[i].funcName == label) return false;
			}
			var btn:TestButton = new TestButton(label, func, args);
			addChild(btn);
			buttons.push(btn);
			redraw();
			return true;
		}
		public function removeButton(label:String):void {
			for (var i:int = 0; i < buttons.length; i++) 
			{
				if (buttons[i].funcName == label) {
					removeChild(buttons[i]);
					buttons.splice(i, 1)
				}
			}
			redraw();
		}
		public function redraw():void {
			if (!stage) return;
			var row:int = 0;
			var col:int = 0;
			for (var i:int = 0; i < buttons.length; i++) 
			{
				if (col * 85 >= stage.stageWidth) {
					col = 0;
					row++;
				}
				buttons[i].x = col * 85;
				buttons[i].y = row * 22;
				col++;
			}
		}
		
	}
	
}