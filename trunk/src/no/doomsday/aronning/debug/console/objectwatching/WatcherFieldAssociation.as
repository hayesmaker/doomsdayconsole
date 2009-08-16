package no.doomsday.aronning.debug.console.objectwatching
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import no.doomsday.aronning.debug.console.events.ConsoleEvent;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class WatcherFieldAssociation extends EventDispatcher
	{
		public var watcher:ObjectWatcher;
		public var field:TextField;
		public function WatcherFieldAssociation(watcher:ObjectWatcher, field:TextField) {
			this.watcher = watcher;
			this.field = field;
			field.addEventListener(MouseEvent.CLICK, doUpdate, false, 0, true);
			watcher.addEventListener(ConsoleEvent.PROPERTY_UPDATE, onUpdate);
		}
		
		private function doUpdate(e:MouseEvent):void 
		{
			watcher.forceUpdate();
		}
		public function destroy():void {
			watcher.removeEventListener(ConsoleEvent.PROPERTY_UPDATE, onUpdate);
			try{
				field.parent.removeChild(field);
			}catch (e:Error) {
				
			}
		}
		
		private function onUpdate(e:ConsoleEvent):void 
		{
			field.text = watcher.status;
		}
		
	}
}