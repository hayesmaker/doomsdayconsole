package no.doomsday.dconsole2.core.gui 
{
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import no.doomsday.dconsole2.core.effects.Filters;
	import no.doomsday.dconsole2.core.gui.TextFieldFactory;
	import no.doomsday.dconsole2.core.interfaces.IThemeable;
	import no.doomsday.dconsole2.core.Notifications;
	import no.doomsday.dconsole2.core.style.Colors;
	import no.doomsday.dconsole2.core.style.GUIUnits;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ToolTip extends Sprite implements IThemeable
	{
		private var labelField:TextField;
		
		public function ToolTip() 
		{
			mouseEnabled = mouseChildren = false;
			labelField = TextFieldFactory.getLabel("Help");
			labelField.autoSize = TextFieldAutoSize.LEFT;
			labelField.height = GUIUnits.SQUARE_UNIT;
			labelField.textColor = Colors.TOOLTIP_FG;
			labelField.backgroundColor = Colors.TOOLTIP_BG;
			
			filters = [Filters.CONSOLE_DROPSHADOW];
			labelField.background = true;
			addChild(labelField).y = -GUIUnits.SQUARE_UNIT*1.5;
			PimpCentral.addCallback(Notifications.TOOLTIP_SHOW_REQUEST, onTooltipShowRequest);
			PimpCentral.addCallback(Notifications.TOOLTIP_HIDE_REQUEST, onTooltipHideRequest);
			PimpCentral.addCallback(Notifications.THEME_CHANGED, onThemeChange);
			visible = false;
		}
		
		private function onTooltipHideRequest():void
		{
			hide();
		}
		
		private function onTooltipShowRequest(md:MessageData):void
		{
			setToolTip(String(md.data),stage.mouseX,stage.mouseY);
		}
		public function setToolTip(string:String, x:Number, y:Number):void {
			if (string.length < 1 || string == " ") return;
			labelField.text = string;
			visible = true;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			onMouseMove();
		}
		
		private function onMouseMove(e:MouseEvent = null):void 
		{
			x = stage.mouseX + GUIUnits.SQUARE_UNIT;
			y = stage.mouseY;
		}
		public function hide():void {
			visible = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.interfaces.IThemeable */
		
		public function onThemeChange(md:MessageData):void
		{
			labelField.textColor = Colors.TOOLTIP_FG;
			labelField.backgroundColor = Colors.TOOLTIP_BG;
		}
		
	}

}