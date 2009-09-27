package no.doomsday.console.controller 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ControllerManager extends Sprite
	{
		private var controllers:Vector.<Controller> = new Vector.<Controller>;
		public function ControllerManager() 
		{
			
		}
		public function createController(object:*, properties:Array,x:Number = 0,y:Number = 0):void {
			var c:Controller = new Controller(object, properties, this);
			c.x = x;
			c.y = y;
			controllers.push(addChild(c) as Controller);
		}
		public function removeController(c:Controller):void {
			for (var i:int = 0; i < controllers.length; i++) 
			{
				if (controllers[i] == c) {
					controllers.splice(i, 1);
					removeChild(c);
					break;
				}
			}
		}
		
	}

}