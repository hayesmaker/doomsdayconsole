package com.furusystems.dconsole2.utilities 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ColorSwatch extends Sprite
	{
		public var color:uint;
		public static const RADIUS:int = 10;
		private var bg:Shape;
		private var c:Shape;
		private var _selected:Boolean;
		public function ColorSwatch(color:uint = 0xFFFFFF) 
		{
			buttonMode = true;
			bg = new Shape();
			c = new Shape();
			addChild(bg);
			selected = false;
			addChild(c);
			setColor(color);
		}
		public function set selected(b:Boolean):void {
			_selected = b;
			bg.graphics.clear();
			bg.graphics.beginFill(_selected?0xFFFFFF:0);
			bg.graphics.drawCircle(RADIUS, RADIUS, RADIUS);
		}
		public function get selected():Boolean {
			return _selected;
		}
		public function setColor(color:uint):void {
			this.color = color;
			c.graphics.clear();
			c.graphics.beginFill(color);
			c.graphics.drawCircle(RADIUS, RADIUS, RADIUS-2);
		}
		
	}

}