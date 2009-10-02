package no.doomsday.console.controller 
{
	import no.doomsday.console.text.TextFormats;
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
	public class Controller extends Sprite
	{
		private var targetObj:*; 
		private var paramsField:TextField = new TextField();
		private var controlFields:Vector.<ControlField> = new Vector.<ControlField>();
		private var clickOffset:Point;
		private var dragArea:Sprite;
		private var closeButton:Sprite;
		private var manager:ControllerManager;
		private var bg:Shape = new Shape();
		public function Controller(o:*, params:Array,manager:ControllerManager) 
		{
			var dragBarHeight:int = 10;
			this.manager = manager;
			addChild(bg);
			dragArea = new Sprite();
			dragArea.buttonMode = true;
			dragArea.graphics.lineStyle(0, 0);
			dragArea.graphics.beginFill(0xCCCCCC);
			
			closeButton = new Sprite();
			closeButton.graphics.lineStyle(0, 0);
			closeButton.graphics.beginFill(0x330000);
			closeButton.graphics.drawRect(0, 0, 10, 10);
			closeButton.addEventListener(MouseEvent.CLICK, close, false, 0, true);
			closeButton.buttonMode = true;
			
			targetObj = o;
			paramsField.defaultTextFormat = TextFormats.debugTformatOld;
			paramsField.y = dragBarHeight;
			addChild(paramsField);
			paramsField.multiline = true;
			paramsField.selectable = false;
			paramsField.mouseEnabled = false;
			paramsField.autoSize = TextFieldAutoSize.LEFT;
			paramsField.text = o.toString();
			for (var i:int = 0; i < params.length; i++) 
			{
				var cf:ControlField = new ControlField(params[i],typeof targetObj[params[i]]);
				cf.addEventListener(ControllerEvent.VALUE_CHANGE, onCfChange,false,0,true);
				addChild(cf);
				controlFields.push(cf);
				cf.y = paramsField.textHeight+dragBarHeight;
				cf.x = 110;
				cf.value = o[params[i]];
				paramsField.appendText("\n" + params[i]);
			}
			
			addChild(dragArea);
			addChild(closeButton)
			dragArea.graphics.drawRect(0, 0, 150, dragBarHeight);
			closeButton.x = 150;
			var dimRect:Rectangle = getBounds(this);
			bg.y = dragBarHeight;
			bg.graphics.lineStyle(0, 0);
			bg.graphics.beginFill(0x222222,.9);
			bg.graphics.drawRect(0, 0, dimRect.width, dimRect.height);
			bg.graphics.endFill();
			dragArea.addEventListener(MouseEvent.MOUSE_DOWN, beginDragging, false, 0, true);
		}
		
		private function close(e:MouseEvent):void 
		{
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