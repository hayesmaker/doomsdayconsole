package com.furusystems.dconsole2.core.inspector.buttons 
{
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import com.furusystems.dconsole2.core.DSprite;
	import com.furusystems.dconsole2.core.gui.AbstractButton;
	import com.furusystems.dconsole2.core.inspector.AbstractInspectorView;
	import com.furusystems.dconsole2.core.interfaces.IThemeable;
	import com.furusystems.dconsole2.core.Notifications;
	import com.furusystems.dconsole2.core.plugins.IDConsoleInspectorPlugin;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class ModeSelector extends DSprite implements IThemeable
	{
		private var modeMap:Dictionary = new Dictionary();
		private var _buttons:Array = [];
		public function ModeSelector() 
		{
			PimpCentral.addCallback(Notifications.THEME_CHANGED, onThemeChange);
		}
		
		private function onButtonClick(e:MouseEvent):void 
		{
			var btn:AbstractButton = e.currentTarget as AbstractButton;
			setCurrentMode(modeMap[btn]);
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.interfaces.IThemeable */
		
		public function onThemeChange(md:MessageData):void
		{
			for (var i:int = 0; i < _buttons.length; i++) 
			{
				AbstractButton(_buttons[i]).updateAppearance();
			}
		}
		public function addButton(v:IDConsoleInspectorPlugin):void {
			var btn:AbstractButton = createButton(v.tabIcon);
			modeMap[btn] = v.view;
			btn.addEventListener(MouseEvent.CLICK, onButtonClick);
			_buttons.push(btn);
			removeAllChildren();
			addChildren(_buttons, 0);
		}
		public function removeButton(v:IDConsoleInspectorPlugin):void {
			//TODO: Remove and clean up button and mapping
		}
		
		public function setCurrentMode(v:AbstractInspectorView):void
		{
			for (var i:int = 0; i < _buttons.length; i++) 
			{
				if (modeMap[_buttons[i]] == v) {
					AbstractButton(_buttons[i]).active = true;
				}else {
					AbstractButton(_buttons[i]).active = false;
				}
			}
			PimpCentral.send(Notifications.INSPECTOR_MODE_CHANGE, v, this);
		}
		private function createButton(bmd:BitmapData):AbstractButton {
			var btn:AbstractButton = new AbstractButton();
			btn.setIcon(bmd);
			btn.updateAppearance();
			return btn;
		}
	}

}