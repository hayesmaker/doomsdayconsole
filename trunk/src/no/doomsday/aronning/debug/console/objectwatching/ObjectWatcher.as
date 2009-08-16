package no.doomsday.aronning.debug.console.objectwatching
{
	import away3d.loaders.Obj;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import no.doomsday.aronning.debug.console.events.ConsoleEvent;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ObjectWatcher extends EventDispatcher
	{
		private var pollTimer:Timer;
		public var objectToWatch:Object;
		public var propertiesToWatch:Array;
		public var status:String;
		public var lineName:String;
		private var enabled:Boolean;
		public function ObjectWatcher(objectToWatch:Object, properties:Array = null, lineName:String = "", interval:uint = 500) {
			this.objectToWatch = objectToWatch;
			this.lineName = lineName;
			propertiesToWatch = properties;
			pollTimer = new Timer(interval);
			pollTimer.addEventListener(TimerEvent.TIMER, poll);
			status = lineName;
		}
		public function forceUpdate():void {
			poll();
		}
		protected function poll(e:TimerEvent = null):void 
		{
			status = lineName;
			for (var i:int = 0; i < propertiesToWatch.length; i++) 
			{
				status += " " + propertiesToWatch[i] + ":" + objectToWatch[propertiesToWatch[i]];
			}
			dispatchEvent(new ConsoleEvent(ConsoleEvent.PROPERTY_UPDATE));
		}
		public function start():void {
			if(pollTimer.delay!=0){
				pollTimer.start();
			}
			poll();
		}
		public function stop():void {
			pollTimer.stop();
		}
		public function enable():void {
			enabled = true;
		}
		public function disable():void {
			enabled = false;
		}
		
	}
}