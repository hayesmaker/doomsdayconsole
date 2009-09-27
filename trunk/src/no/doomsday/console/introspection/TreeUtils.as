package no.doomsday.console.introspection 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TreeUtils
	{
		
		public function TreeUtils() 
		{
			
		}
		public static function getChildren(o:*):Vector.<ChildContextDesc> {
			var out:Vector.<ChildContextDesc> = new Vector.<ChildContextDesc>();
			//if we're in a DisplayObjectContainer, add first level children
			var c:ChildContextDesc;
			if (o is DisplayObjectContainer) {
				var d:DisplayObjectContainer = o as DisplayObjectContainer;
				var cd:DisplayObject;
				var n:int = d.numChildren;
				for (n > 0; n--; ) {
					cd = d.getChildAt(n);
					c = new ChildContextDesc();
					c.name = cd.name;
					c.type = cd.toString();
					out.push(c);
				}
			}
			return out;
		}
		
	}

}