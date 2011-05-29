﻿package no.doomsday.console.core.introspection 
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
		public static function getChildren(o:*):Array {
			var out:Array = [];;
			//if we're in a DisplayObjectContainer, add first level children
			var c:ChildScopeDesc;
			if (o is DisplayObjectContainer) {
				var d:DisplayObjectContainer = o as DisplayObjectContainer;
				var cd:DisplayObject;
				var n:int = d.numChildren;
				for (n > 0; n--; ) {
					cd = d.getChildAt(n);
					c = new ChildScopeDesc();
					c.name = cd.name;
					c.type = cd.toString();
					out.push(c);
				}
			}
			return out;
		}
		
	}

}