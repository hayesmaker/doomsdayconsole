package no.doomsday.console.monitoring 
{
	import flash.events.TimerEvent;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MonitorManager
	{
		
		private var monitors:Vector.<Monitor> = new Vector.<Monitor>();
		public function MonitorManager() 
		{
			
		}
		public function addMonitor(scope:Object, ...properties:Array):void {
			for (var i:int = 0; i < monitors.length; i++) 
			{
				if(monitors[i].
			}
		}
		public function removeMonitor(scope:Object, ...properties:Array):void {
			
		}
		private function update(e:TimerEvent = null):void {
			for (var i:int = 0; i < monitors.length; i++) 
			{
				monitors[i].update();
			}
		}
		
	}

}