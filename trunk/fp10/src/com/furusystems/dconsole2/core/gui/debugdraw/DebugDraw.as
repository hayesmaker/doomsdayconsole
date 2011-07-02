package com.furusystems.dconsole2.core.gui.debugdraw 
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Andreas Ronning
	 */
	public class DebugDraw 
	{
		private var _shape:Shape = new Shape();
		private var _g:Graphics;
		private var colors:Vector.<uint> = Vector.<uint>([0xFF0000, 0xFFFF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0x00FF00]);
		private var currentColor:uint = 0;
		private var _enabled:Boolean = true;
		private var _arrowSize:Number;
		public function DebugDraw() 
		{
			_g = _shape.graphics;
		}
		
		public function get g():Graphics 
		{
			return _g;
		}
		
		public function get shape():Shape 
		{
			return _shape;
		}
		
		public function get enabled():Boolean 
		{
			return _enabled && shape.stage != null;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		public function clear():void {
			g.clear();
			currentColor = 0;
		}
		public function drawArrowV(x:Number, y:Number, angle:Number = 0, color:uint = 0):void {
			g.lineStyle(1, color);
			_arrowSize = 8;
			var angleOffset:Number = 0.785;
			g.moveTo(x + Math.cos(angle - angleOffset) * -_arrowSize, y + Math.sin(angle - angleOffset) * -_arrowSize);
			g.lineTo(x, y);
			g.lineTo(x + Math.cos(angle + angleOffset) * -_arrowSize, y + Math.sin(angle +angleOffset) * -_arrowSize);
		}
		public function bracketObject(o:DisplayObject):void {
			if (!enabled) return;
			currentColor++;
			var pb:Rectangle = o.transform.pixelBounds;
			var outOfBounds:Boolean = false;
			
			var sw:Number = shape.stage.stageWidth;
			var sh:Number = shape.stage.stageHeight;
			
			if (pb.x + pb.width < 0) {
				
				outOfBounds = true;
			}else if (pb.x > sw) {
				outOfBounds = true;
			}
			
			if (pb.y + pb.height < 0) {
				outOfBounds = true;
			}else if (pb.y > sh) {
				outOfBounds = true;
			}
			var color:uint = colors[currentColor % colors.length];
			if (outOfBounds) {
				var tx:Number = pb.x + pb.width * 0.5;
				var ty:Number = pb.y + pb.height * 0.5;
				var dx:Number = tx - sw * 0.5;
				var dy:Number = ty - sh * 0.5;
				drawArrowV(Math.max(_arrowSize, Math.min(sw - _arrowSize, tx)), Math.max(_arrowSize, Math.min(sh - _arrowSize, ty)), Math.atan2(dy, dx), color);
			}else{
				g.lineStyle(0, color);
				g.drawRect(pb.x, pb.y, pb.width, pb.height);
			}
		}
		public function drawMotionVector(o:DisplayObject):void {
			
		}
		public function lineBetween(o1:DisplayObject, o2:DisplayObject):void {
			if (!enabled) return;
			currentColor++;
			//var pb:Rectangle = o.transform.pixelBounds;
			g.lineStyle(0, colors[currentColor % colors.length]);
		}
		
	}

}7