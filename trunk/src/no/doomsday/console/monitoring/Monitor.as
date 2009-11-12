package no.doomsday.console.monitoring 
{
	import flash.utils.Dictionary;
	import no.doomsday.console.introspection.ScopeManager;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Monitor
	{
		private var _scope:Dictionary = new Dictionary(true);
		public var properties:Array;
		public var outObj:Object = { };
		public function Monitor(scope:Object, properties:Array) 
		{
			_scope["scope"] = scope;
			this.properties = properties;
		}
		public function get scope():*{
			return _scope["scope"];
		}
		public function update():void {
			outObj.name = scope.name ? scope.name : String(typeof scope);
			for (var i:int = 0; i < properties.length; i++) 
			{
				outObj[properties[i]] = scope[properties[i]];
			}
		}
		public function toString():String {
			return outObj.toString();
		}
		
	}

}