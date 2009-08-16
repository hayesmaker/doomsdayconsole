package no.doomsday.aronning.utilities
{
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Time 
	{
		private static var _previousTime:int = 0;
		private static var _delta:Number = 0;
		public static var deltaMultiplier:Number = 0.001;
		public function Time() 
		{
			throw new Error("Use static methods");
		}
		/**
		 * Returns the number of milliseconds since the last time delta was retrieved, multiplied by deltaMultiplier
		 * if multiple calls to delta are done within the same millisecond, the previous delta will be returned
		 */
		public static function calcDelta():Number 
		{
			var newTime:int = getTimer();
			if (newTime == _previousTime) return _delta;
			_delta = (newTime - _previousTime) * deltaMultiplier;
			_previousTime = newTime;
			return _delta;
		}
		/**
		 * Returns the number of milliseconds the application has run
		 */
		public static function get applicationTime():int {
			return getTimer();
		}
		
	}
	
}