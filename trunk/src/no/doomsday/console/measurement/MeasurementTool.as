package no.doomsday.console.measurement 
{
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import no.doomsday.console.DConsole;
	import no.doomsday.console.messages.MessageTypes;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MeasurementTool extends Sprite
	{
		private var rect:Rectangle = new Rectangle();
		private var rectSprite:Sprite;
		private var initialized:Boolean = false;
		private var topLeftCornerHandle:Sprite;
		private var bottomRightCornerHandle:Sprite;
		private var widthField:TextField;
		private var heightField:TextField;
		private var xyField:TextField;
		private var fmt:TextFormat;
		private var currentlyChecking:Sprite;
		private var _increment:Number = -1;
		public var clickOffset:Point;
		private var console:DConsole;
		public function MeasurementTool(console:DConsole) 
		{
			this.console = console;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(e:Event):void 
		{
			//stage.removeEventListener(Event.RESIZE, getValues);
		}
		private function roundTo(num:Number, target:Number):Number {
			return Math.round(num / target) * target;
		}
		private function onAddedToStage(e:Event):void 
		{
			if (!initialized) {
				fmt = new TextFormat("_sans", 10, 0);
				widthField = new TextField();
				heightField = new TextField();
				xyField = new TextField();
				widthField.defaultTextFormat = heightField.defaultTextFormat = xyField.defaultTextFormat = fmt;
				var center:Point = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
				rect = new Rectangle(center.x - 20, center.y - 20, 40, 40);
				
				rectSprite = new Sprite();
				topLeftCornerHandle = new Sprite();
				bottomRightCornerHandle = new Sprite();
				
				topLeftCornerHandle.graphics.beginFill(0);
				topLeftCornerHandle.graphics.lineStyle(0, 0xFF0000);
				bottomRightCornerHandle.graphics.beginFill(0);
				bottomRightCornerHandle.graphics.lineStyle(0, 0xFF0000);
				topLeftCornerHandle.graphics.drawCircle(0, 0, 4);
				bottomRightCornerHandle.graphics.drawCircle(0, 0, 4);
				
				topLeftCornerHandle.addEventListener(MouseEvent.MOUSE_DOWN, startGettingValues, false, 0, true);
				bottomRightCornerHandle.addEventListener(MouseEvent.MOUSE_DOWN, startGettingValues, false, 0, true);
				rectSprite.addEventListener(MouseEvent.MOUSE_DOWN, startGettingValues, false, 0, true);
				
				rectSprite.buttonMode = topLeftCornerHandle.buttonMode = bottomRightCornerHandle.buttonMode = true;
				
				addChild(rectSprite);
				addChild(topLeftCornerHandle);
				addChild(bottomRightCornerHandle);
				
				xyField.mouseEnabled = widthField.mouseEnabled = heightField.mouseEnabled = false;
				
				xyField.autoSize = widthField.autoSize = heightField.autoSize = TextFieldAutoSize.LEFT;
				
				addChild(xyField);
				addChild(widthField);
				addChild(heightField);
				
				initialized = true;
				tabEnabled = tabChildren = false;
			}
			
			blendMode = BlendMode.INVERT;
			render();
			//stage.addEventListener(Event.RESIZE, getValues, false, 0, true);
		}
		
		private function startGettingValues(e:MouseEvent):void 
		{
			currentlyChecking = e.target as Sprite;
			if (currentlyChecking == rectSprite) clickOffset = new Point(mouseX - rect.x, mouseY - rect.y);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, getValues, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopGettingValues, false, 0, true);
		}
		
		private function stopGettingValues(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, getValues);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopGettingValues);
		}
		
		private function setTopLeft(x:Number, y:Number):void {
			var prevX:Number = rect.x;
			var prevY:Number = rect.y;
			rect.x = x;
			rect.y = y;	
			checkSnap();
			var diffX:Number = prevX - rect.x;
			var diffY:Number = prevY - rect.y;
			rect.width += diffX;
			rect.height += diffY;
			rect.width = Math.max(0, rect.width);
			rect.height = Math.max(0, rect.height);
			keepOnStage();
			render();
		}
		private function setBotRight(x:Number, y:Number):void {
			if (x < rect.x) rect.x = x;
			if (y < rect.y) rect.y = y;
			rect.width = x - rect.x;
			rect.height = y - rect.y;
			checkSnap();
			keepOnStage();
			render();
		}
		private function setCenter(x:Number, y:Number):void {
			rect.x = x-clickOffset.x;
			rect.y = y-clickOffset.y;	
			checkSnap();
			keepOnStage();
			render();
		}
		
		private function keepOnStage():void
		{
			rect.x = Math.max(0, Math.min(rect.x,stage.stageWidth-rect.width));
			rect.y = Math.max(0, Math.min(rect.y,stage.stageHeight-rect.height));
		}
		
		private function checkSnap():void
		{
			if (increment > 0) {
				rect.x = roundTo(rect.x, increment);
				rect.y = roundTo(rect.y, increment);
				rect.width = roundTo(rect.width, increment);
				rect.height= roundTo(rect.height, increment);
			}
		}
		private function getValues(e:Event = null):void
		{
			var mx:Number = Math.max(0, Math.min(stage.mouseX, stage.stageWidth));
			var my:Number = Math.max(0, Math.min(stage.mouseY, stage.stageHeight));
			increment = 1
			if (e is MouseEvent) {
				var me:MouseEvent = e as MouseEvent
				if (me.shiftKey) {
					increment = 10;
				}else if (me.ctrlKey) {
					increment = 5;
				}else {
					increment = 1;
				}
				try { 
					me.updateAfterEvent();
				}catch (err:Error) { };
			}
			
			switch(currentlyChecking) {
				case topLeftCornerHandle:
				setTopLeft(mx, my);
				break;
				case bottomRightCornerHandle:
				setBotRight(mx,my);
				break;
				case rectSprite:
				setCenter(mx, my);
				break;
			}
			render();
		}
		/**
		 * sets x/y and width to the specified display object
		 * @param	displayObject
		 */
		public function bracket(displayObject:DisplayObject):void {
			visible = true;
			rect = displayObject.getRect(this);
			render();
		}
		public function getMeasurements():String {
			return rect.toString();
		}
		private function render():void
		{
			rectSprite.graphics.clear();
			rectSprite.graphics.beginFill(0, 0.2);
			rectSprite.graphics.lineStyle(0, 0xFF0000);
			rectSprite.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				
			bottomRightCornerHandle.x = rect.x + rect.width;
			bottomRightCornerHandle.y = rect.y + rect.height;
			topLeftCornerHandle.x = rect.x;
			topLeftCornerHandle.y = rect.y;
			
			xyField.text = "x:" + rect.x + " y:" + rect.y;
			xyField.x = rect.x+5;
			xyField.y = rect.y - 14;
			heightField.text = String(rect.height);
			heightField.x = rect.x+rect.width;
			heightField.y = rect.y + rect.height / 2-heightField.textHeight/2;
			
			widthField.text = String(rect.width);
			widthField.x = rect.x+rect.width/2-widthField.textWidth/2;
			widthField.y = rect.y + rect.height;
			
		}
		
		public function get increment():Number { return _increment; }
		
		public function set increment(value:Number):void 
		{
			_increment = value; 
			checkSnap();
		}
		
		public function toggle():void
		{
			visible = !visible;
			console.print("Measuring bracket active: " + visible, MessageTypes.SYSTEM);
		}
		
	}
	
}