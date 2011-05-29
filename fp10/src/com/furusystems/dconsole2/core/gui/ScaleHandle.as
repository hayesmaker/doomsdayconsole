package no.doomsday.dconsole2.core.gui 
{
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import no.doomsday.dconsole2.core.gui.layout.IContainable;
	import no.doomsday.dconsole2.core.Notifications;
	import no.doomsday.dconsole2.core.strings.Strings;
	import no.doomsday.dconsole2.core.style.Alphas;
	import no.doomsday.dconsole2.core.style.Colors;
	import no.doomsday.dconsole2.core.style.GUIUnits;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ScaleHandle extends Sprite implements IContainable
	{
		
		public var dragging:Boolean = false;
		public function ScaleHandle() 
		{
			//buttonMode = true;
			doubleClickEnabled = true;
			tabEnabled = false;
			//var dsf:DropShadowFilter = new DropShadowFilter(0, 90, 0, 1, 4, 4, 1, 1, true);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function onMouseOut(e:MouseEvent):void 
		{
			PimpCentral.send(Notifications.ASSISTANT_CLEAR_REQUEST);
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			PimpCentral.send(Notifications.ASSISTANT_MESSAGE_REQUEST, Strings.ASSISTANT_STRINGS.get(Strings.ASSISTANT_STRINGS.SCALE_HANDLE_ID), this);
		}
		
		private function onRollOut(e:MouseEvent):void 
		{
			if (dragging) return;
			//alpha = 0;
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function onRollOver(e:MouseEvent):void 
		{
			//alpha = 1;
			Mouse.cursor = MouseCursor.HAND;
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.gui.layout.IContainable */
		
		public function onParentUpdate(allotedRect:Rectangle):void
		{
			graphics.clear();
			x = allotedRect.x;
			y = allotedRect.y;
			graphics.beginFill(Colors.SCALEHANDLE_BG, 1);
			var h:Number = GUIUnits.SQUARE_UNIT / 2;
			graphics.drawRect(0, 0, allotedRect.width, h);
			graphics.endFill();
			graphics.lineStyle(0, Colors.SCALEHANDLE_FG);
			graphics.moveTo(3, h / 2);
			graphics.lineTo(allotedRect.width - 3, h / 2);
		}
		
		public function get rect():Rectangle
		{
			return getRect(parent);
		}
		
		public function get minHeight():Number
		{
			return 0;
		}
		
		public function get minWidth():Number
		{
			return 0;
		}
		
	}

}