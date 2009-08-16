package no.doomsday.aronning.utilities.parameters
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class RangedParameter extends Parameter
	{
		private var _min:Number = 0;
		private var _max:Number = 1;
		public function RangedParameter(min:Number = 0,max:Number = 1,defaultValue:Number = 0,name:String = "Parameter") 
		{
			_min = min;
			_max = max;
			super(defaultValue, name);
		}
		override public function get value():Number { return super.value; }
		
		override public function set value(value:Number):void 
		{
			value = Math.min(_max, Math.max(value, _min));
			super.value = value;
		}
		
		public function get min():Number { return _min; }
		
		public function set min(value:Number):void 
		{
			_min = value;
			value = Math.min(_max, Math.max(value, _min));
		}
		
		public function get max():Number { return _max; }
		
		public function set max(value:Number):void 
		{
			_max = value;
			value = Math.min(_max, Math.max(value, _min));
		}
		
	}
	
}