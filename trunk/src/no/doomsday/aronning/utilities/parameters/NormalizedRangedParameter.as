package no.doomsday.aronning.utilities.parameters
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class NormalizedRangedParameter extends RangedParameter
	{
		private var mul:Number;
		public function NormalizedRangedParameter(min:Number = 0,max:Number = 1,defaultValue:Number = 0,name:String = "Parameter") 
		{
			super(min, max, defaultValue, name);
			mul = defaultValue / max;
		}
		override public function get value():Number { 
			var diff:Number = max - min;
			return min + mul * diff;
		}
		
		
		override public function set value(value:Number):void 
		{
			mul = Math.max(0, Math.min(1, value));
			//value = Math.min(_max, Math.max(value, _min));
			//super.value = value;
		}
		
	}
	
}