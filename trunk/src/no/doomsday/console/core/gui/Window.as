package no.doomsday.console.core.gui 
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import no.doomsday.console.core.text.TextFormats;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Window extends Sprite
	{
		private var contents:Sprite = new Sprite();
		private var chrome:Sprite = new Sprite();
		private var outlines:Shape = new Shape();
		private var header:Sprite = new Sprite();
		private var titleField:TextField = new TextField();
		private const BAR_HEIGHT:int = 12;
		private const SCALE_HANDLE_SIZE:int = 10;
		private var resizeHandle:Sprite = new Sprite();
		private var clickOffset:Point = new Point();
		private var resizeRect:Rectangle = new Rectangle();
		private var maxRect:Rectangle;
		private var minRect:Rectangle;
		private static const GRADIENT_MATRIX:Matrix = new Matrix();
		private var maxScrollV:Number = 0;
		private var maxScrollH:Number = 0;
		private var scrollBarBottom:SimpleScrollbar = new SimpleScrollbar(SimpleScrollbar.HORIZONTAL);
		private var scrollBarRight:SimpleScrollbar = new SimpleScrollbar(SimpleScrollbar.VERTICAL);
		private var viewRect:Rectangle;
		private var background:Shape = new Shape();
		public function Window(title:String, rect:Rectangle, contents:DisplayObject = null, maxRect:Rectangle = null, minRect:Rectangle = null)
		{
			scrollBarBottom.addEventListener(Event.CHANGE, onScroll);
			scrollBarRight.addEventListener(Event.CHANGE, onScroll);
			
			addChild(background);
			this.contents.y = background.y = BAR_HEIGHT;
			addChild(this.contents);
			
			this.maxRect = maxRect;
			this.minRect = minRect;
			
			titleField.height = BAR_HEIGHT+3;
			titleField.selectable = false;
			titleField.defaultTextFormat = TextFormats.windowTitleFormat;
			titleField.text = title;
			titleField.y -= 2;
			titleField.mouseEnabled = false;
			
			resizeHandle.graphics.clear();
			resizeHandle.graphics.beginFill(0xFF0000, 0);
			resizeHandle.graphics.drawRect(0, 0, SCALE_HANDLE_SIZE, SCALE_HANDLE_SIZE);
			resizeHandle.graphics.endFill();
			resizeHandle.graphics.lineStyle(0, 0x333333);
			resizeHandle.graphics.moveTo(SCALE_HANDLE_SIZE, 0);
			resizeHandle.graphics.lineTo(0, SCALE_HANDLE_SIZE);
			resizeHandle.graphics.moveTo(SCALE_HANDLE_SIZE, 5);
			resizeHandle.graphics.lineTo(0, SCALE_HANDLE_SIZE + 5);
			resizeHandle.scrollRect = new Rectangle(0, 0, SCALE_HANDLE_SIZE, SCALE_HANDLE_SIZE);
			
			
			addChild(chrome);
			header.addChild(titleField);
			chrome.addChild(header);
			chrome.addChild(scrollBarBottom);
			chrome.addChild(scrollBarRight);
			chrome.addChild(resizeHandle);
			chrome.addChild(outlines);
			
			resizeHandle.buttonMode = header.buttonMode = true;
			
			x = rect.x;
			y = rect.y;
			
			var dsf:DropShadowFilter = new DropShadowFilter(4, 45, 0, .1,8,8);
			filters = [dsf];
			
			redraw(rect);
			
			header.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, startResizing);
			addEventListener(MouseEvent.MOUSE_DOWN, setDepth);
			if (contents) {
				setContents(contents);
			}
		}
		
		private function onScroll(e:Event):void 
		{
			var r:Rectangle = getContentsRect();
			var newRect:Rectangle = contents.scrollRect.clone();
			switch(e.target) {
				case scrollBarBottom:
					newRect.x = scrollBarBottom.outValue * (maxScrollH - newRect.width);
				break;
				case scrollBarRight:
					newRect.y = scrollBarRight.outValue * (maxScrollV-newRect.height);
				break;
			}
			contents.scrollRect = newRect;
			redraw(viewRect);
		}
		
		private function startResizing(e:MouseEvent):void 
		{
			clickOffset.x = SCALE_HANDLE_SIZE - resizeHandle.mouseX;
			clickOffset.y = SCALE_HANDLE_SIZE - resizeHandle.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onResizeDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, onResizeStop);
		}
		
		private function onResizeStop(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResizeDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onResizeStop);
		}
		
		private function onResizeDrag(e:MouseEvent):void 
		{
			e.updateAfterEvent();
			var newMaxX:Number = Math.max(SCALE_HANDLE_SIZE + BAR_HEIGHT, mouseX + clickOffset.x);
			var newMaxY:Number = Math.max(SCALE_HANDLE_SIZE + BAR_HEIGHT, mouseY + clickOffset.y);
			resizeRect.width = newMaxX;
			resizeRect.height = newMaxY - BAR_HEIGHT;
			redraw(resizeRect);
		}
		private function scroll(x:int = 0, y:int = 0):void {
			if (contents.scrollRect.x + x >= 0) {
				if (contents.scrollRect.width + x <= maxScrollH) contents.scrollRect.x += x;
			}
			if (contents.scrollRect.y + y >= 0) {
				if (contents.scrollRect.height + y <= maxScrollV) contents.scrollRect.y += y;
			}
		}
		private function resetScroll():void {
			contents.scrollRect.x = 0;
			contents.scrollRect.y = 0;
			scrollBarBottom.outValue = 0;
			scrollBarRight.outValue = 0;
		}
		private function redraw(rect:Rectangle):void {
			GRADIENT_MATRIX.createGradientBox(rect.width * 3, rect.height * 3);
			
			background.graphics.clear();	
			background.graphics.beginGradientFill(GradientType.RADIAL, [0xBBBBBB, 0xEEEEEE], [1, 1], [0, 255], GRADIENT_MATRIX);
			background.graphics.drawRect(0, 0, rect.width, rect.height);
			
			header.graphics.clear();
			header.graphics.beginFill(0x111111);
			header.graphics.drawRect(0, 0, rect.width, BAR_HEIGHT);
			header.graphics.endFill();
			
			outlines.graphics.clear();
			outlines.graphics.lineStyle(0, 0);
			outlines.graphics.drawRect(0, 0, rect.width, rect.height + BAR_HEIGHT);
			
			titleField.width = rect.width;
			resizeHandle.x = rect.width - SCALE_HANDLE_SIZE;
			resizeHandle.y = rect.height + BAR_HEIGHT - SCALE_HANDLE_SIZE;
			
			var cRect:Rectangle = getContentsRect();
		
			if (rect.width < cRect.width) {
				maxScrollH = cRect.width;
			}else {
				maxScrollH = 0;
			}
			if (rect.height < cRect.height) {
				maxScrollV = cRect.height;
			}else {
				maxScrollV = 0;
			}
			contents.scrollRect = new Rectangle(Math.max(0, scrollBarBottom.outValue * (maxScrollH - rect.width)), Math.max(0, scrollBarRight.outValue * (maxScrollV - rect.height)), rect.width + 1, rect.height + 1);
			updateScrollBars(maxScrollH, maxScrollV, rect);
			viewRect = rect;
		}
		
		private function updateScrollBars(maxH:Number,maxV:Number,rect:Rectangle):void
		{
			if (maxH > 0) {
				scrollBarBottom.visible = true;
				scrollBarBottom.y = rect.height+BAR_HEIGHT-scrollBarBottom.trackWidth;
				scrollBarBottom.draw(rect.width - SCALE_HANDLE_SIZE, contents.scrollRect, contents.scrollRect.x, maxH);
			}else {
				scrollBarBottom.visible = false;
			}
			
			if (maxV > 0) {
				scrollBarRight.visible = true;
				scrollBarRight.x = rect.width - scrollBarRight.trackWidth;
				scrollBarRight.y = BAR_HEIGHT;
				scrollBarRight.draw(rect.height - SCALE_HANDLE_SIZE, contents.scrollRect, contents.scrollRect.y, maxV);
			}else {
				scrollBarRight.visible = false;
			}
		}
		private function getContentsRect():Rectangle {
			if (contents.numChildren < 1) return new Rectangle();
			return contents.getChildAt(0).getRect(contents);
		}
		
		private function setDepth(e:MouseEvent):void 
		{
			parent.setChildIndex(this, parent.numChildren - 1);	
		}
		
		private function startDragging(e:MouseEvent):void 
		{
			clickOffset.x = chrome.mouseX;
			clickOffset.y = chrome.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onWindowDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private function stopDragging(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onWindowDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private function onWindowDrag(e:MouseEvent):void 
		{
			x = stage.mouseX - clickOffset.x;
			y = stage.mouseY - clickOffset.y;
			e.updateAfterEvent();
		}
		public function setContents(d:DisplayObject):void {
			while (contents.numChildren > 0) {
				contents.removeChildAt(0);
			}
			contents.addChild(d);
		}
		
	}

}