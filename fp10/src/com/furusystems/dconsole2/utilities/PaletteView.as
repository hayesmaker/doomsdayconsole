package com.furusystems.dconsole2.utilities 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class PaletteView extends Sprite
	{
		
		private var _selectedSwatch:ColorSwatch = null;
		private var rowLength:int;
		public function PaletteView(rowLength:int = 8) 
		{
			this.rowLength = rowLength;
			
		}
		
		public function setColors(colors:Vector.<uint>):void 
		{
			clear();
			for each(var c:uint in colors){
				var swatch:ColorSwatch = new ColorSwatch(c);
				addChild(swatch);
				swatch.addEventListener(MouseEvent.MOUSE_DOWN, onSwatchClicked);
			}
			layout();
		}
		
		private function onSwatchClicked(e:MouseEvent):void 
		{
			if (_selectedSwatch != null) {
				_selectedSwatch.selected = false;
			}
			_selectedSwatch = e.currentTarget as ColorSwatch;
			_selectedSwatch.selected = true;
		}
		
		private function clear():void 
		{
			while (numChildren > 0) {
				removeChildAt(0).removeEventListener(MouseEvent.MOUSE_DOWN, onSwatchClicked);
			}
		}
		public function addSwatch(color:uint = 0):void {
			var swatch:ColorSwatch = new ColorSwatch(color);
			addChild(swatch);
			swatch.addEventListener(MouseEvent.MOUSE_DOWN, onSwatchClicked);
			layout();
		}
		public function removeSwatch(swatch:ColorSwatch):void {
			removeChild(swatch);
			swatch.removeEventListener(MouseEvent.MOUSE_DOWN, onSwatchClicked);
			layout();
		}
		
		
		private function layout():void 
		{
			var x:int = 0;
			var y:int = 0;
			for (var i:int = 0; i < numChildren; i++) {
				getChildAt(i).x = x * ((ColorSwatch.RADIUS<<1)+2);
				getChildAt(i).y = y * ((ColorSwatch.RADIUS<<1)+2);
				x++;
				if (x > rowLength) {
					x = 0;
					y++;
				}
			}
		}
		
		public function get selectedSwatch():ColorSwatch 
		{
			return _selectedSwatch;
		}
		
	}

}
