package no.doomsday.dconsole2.core.gui.maindisplay.toolbar 
{
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import no.doomsday.dconsole2.core.gui.layout.IContainable;
	import no.doomsday.dconsole2.core.interfaces.IThemeable;
	import no.doomsday.dconsole2.core.Notifications;
	import no.doomsday.dconsole2.core.style.Colors;
	import no.doomsday.dconsole2.core.style.GUIUnits;
	import no.doomsday.dconsole2.core.style.TextFormats;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleToolbar extends Sprite implements IContainable,IThemeable
	{
		
		private var _titleField:TextField = new TextField();
		private var _rect:Rectangle;
		private var _clock:ToolbarClock;
		public function ConsoleToolbar() 
		{
			_titleField.height = GUIUnits.SQUARE_UNIT;
			_titleField.selectable = _titleField.mouseEnabled = false;
			_titleField.defaultTextFormat = TextFormats.consoleTitleFormat;
			_titleField.embedFonts = true;
			_titleField.textColor = Colors.HEADER_FG;
			_titleField.text = "Doomsday Console 64";
			_titleField.x = _titleField.y = 1;
			_clock = new ToolbarClock();
			_clock.y = 1;
			addChild(_clock);
			addChild(_titleField);
			PimpCentral.addCallback(Notifications.THEME_CHANGED, onThemeChange);
			
		}
		public function setTitle(text:String):void {
			_titleField.text = text;
		}
		/* INTERFACE no.doomsday.dconsole2.core.gui.layout.IContainable */
		
		public function onParentUpdate(allotedRect:Rectangle):void
		{
			_rect = allotedRect;
			//x = _rect.x;
			//y = _rect.y;
			graphics.clear();
			graphics.beginFill(Colors.HEADER_BG);
			graphics.drawRect(0, 0, _rect.width, GUIUnits.SQUARE_UNIT);
			graphics.endFill();
			_titleField.width = allotedRect.width;
			_clock.x = allotedRect.width;
			_clock.visible = allotedRect.width > 500;
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.interfaces.IThemeable */
		
		public function onThemeChange(md:MessageData):void
		{
			_titleField.textColor = Colors.HEADER_FG;
			_clock.setColor(Colors.HEADER_FG);
			graphics.clear();
			graphics.beginFill(Colors.HEADER_BG);
			graphics.drawRect(0, 0, _rect.width, GUIUnits.SQUARE_UNIT);
			graphics.endFill();
		}
		
		public function get minHeight():Number
		{
			return 0;
		}
		
		public function get minWidth():Number
		{
			return 0;
		}
		
		public function get rect():Rectangle
		{
			return getRect(this);
		}
		
	}

}