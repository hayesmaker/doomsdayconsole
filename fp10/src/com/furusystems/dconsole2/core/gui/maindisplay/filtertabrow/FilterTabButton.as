package com.furusystems.dconsole2.core.gui.maindisplay.filtertabrow 
{
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import com.furusystems.dconsole2.core.gui.TextFieldFactory;
	import com.furusystems.dconsole2.core.Notifications;
	import com.furusystems.dconsole2.core.style.Colors;
	import com.furusystems.dconsole2.core.style.GUIUnits;
	/**
	 * ...
	 * @author Andreas Ronning 
	 */
	public class FilterTabButton extends Sprite
	{
		private var _name:String;
		private var label:TextField;
		private var _active:Boolean;
		
		public function FilterTabButton(name:String) 
		{
			buttonMode = true;
			_name = name;
			label = TextFieldFactory.getLabel(name);
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			addChild(label);
			active = false;
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		private function onClick(e:MouseEvent):void 
		{
			PimpCentral.send(Notifications.LOG_BUTTON_CLICKED, _name, this);
		}
		public function set active(b:Boolean):void {
			_active = b;
			graphics.clear();
			if(!_active){
				graphics.lineStyle(0, Colors.INPUT_BORDER);
				graphics.beginFill(Colors.BUTTON_INACTIVE_BG);
				label.textColor = Colors.BUTTON_INACTIVE_FG;
			}else {
				graphics.lineStyle(0, Colors.CORE);
				graphics.beginFill(Colors.BUTTON_ACTIVE_BG);
				label.textColor = Colors.BUTTON_ACTIVE_FG;
			}
			graphics.drawRect(0, 0, label.textWidth+4, GUIUnits.SQUARE_UNIT);
			graphics.endFill();
		}
		
		public function get active():Boolean { return _active; }
		
		public function get logName():String { return _name; }
		
	}

}