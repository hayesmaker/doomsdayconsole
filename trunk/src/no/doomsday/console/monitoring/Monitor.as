package no.doomsday.console.monitoring 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Monitor
	{
		private var _scope:Dictionary = new Dictionary(true);
		public var properties:Array;
		public function Monitor(scope:Object,...properties:Array) 
		{
			_scope["scope"] = scope;
			this.properties = properties;
		}
		public function get scope():*{
			return _scope["scope"];
		}
		public function update():void {
			
		}
		
	}

}