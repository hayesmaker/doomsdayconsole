package no.doomsday.console.utilities.controller 
{
	import flash.display.DisplayObject;
	import no.doomsday.console.core.gui.Window;
	import no.doomsday.console.core.text.TextFormats;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Controller extends Window
	{
		private var targetObj:*; 
		private var paramsField:TextField = new TextField();
		private var controlFields:Vector.<ControlField> = new Vector.<ControlField>();
		private var clickOffset:Point;
		private var dragArea:Sprite;
		private var closeButton:Sprite;
		private var manager:ControllerManager;
		private var bg:Shape = new Shape();
		private var contents:Sprite = new Sprite();
		public function Controller(o:*, params:Array,manager:ControllerManager) 
		{
			var dragBarHeight:int = 10;
			this.manager = manager;
			
			targetObj = o;
			paramsField.defaultTextFormat = TextFormats.windowDefaultFormat;
			paramsField.y = dragBarHeight;
			contents.addChild(paramsField);
			paramsField.multiline = true;
			paramsField.selectable = false;
			paramsField.mouseEnabled = false;
			paramsField.autoSize = TextFieldAutoSize.LEFT;
			paramsField.text = o.toString();
			for (var i:int = 0; i < params.length; i++) 
			{
				var cf:ControlField = new ControlField(params[i],typeof targetObj[params[i]]);
				cf.addEventListener(ControllerEvent.VALUE_CHANGE, onCfChange,false,0,true);
				contents.addChild(cf);
				controlFields.push(cf);
				cf.y = paramsField.textHeight+dragBarHeight;
				cf.x = 110;
				cf.value = o[params[i]];
				paramsField.appendText("\n" + params[i]);
			}
			super("Controller: " + o.name, new Rectangle(0, 0, contents.width, contents.height), contents);
			if (targetObj is DisplayObject) addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			addEventListener(Event.CHANGE, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event = null):void 
		{
			graphics.clear();
			graphics.lineStyle(0,0,.5);
			var p:Point = new Point(targetObj.x, targetObj.y);
			p = DisplayObject(targetObj).parent.localToGlobal(p);
			p = this.globalToLocal(p);
			graphics.lineTo(p.x, p.y);
			refresh();
		}
		override protected function onClose(e:MouseEvent):void 
		{
			close(e);
		}
		
		private function close(e:MouseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			manager.removeController(this);
		}
		
		private function onCfChange(e:Event):void 
		{
			var t:ControlField = e.currentTarget as ControlField;
			targetObj[t.targetProperty] = t.value;
			refresh();
		}
		
		private function refresh():void
		{
			for (var i:int = 0; i < controlFields.length; i++) 
			{
				if (controlFields[i].hasFocus) continue;
				controlFields[i].value = targetObj[controlFields[i].targetProperty];
			}
		}
		
		private function beginDragging(e:MouseEvent):void 
		{
			parent.setChildIndex(this, parent.numChildren - 1);
			clickOffset = new Point(mouseX, mouseY);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, dragUpdate, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging, false, 0, true);
		}
		
		private function dragUpdate(e:MouseEvent):void 
		{
			x = stage.mouseX - clickOffset.x;
			y = stage.mouseY - clickOffset.y;
		}
		
		private function stopDragging(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragUpdate);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
	}

}