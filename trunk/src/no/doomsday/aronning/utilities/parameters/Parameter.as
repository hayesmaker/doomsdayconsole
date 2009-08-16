package no.doomsday.aronning.utilities.parameters
{	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Parameter 
	{
		private var m_n_value:Number = 0;
		public var name:String = "Parameter";
		public function Parameter(value:Number = 0 , name:String = "Parameter")
		{
			this.name = name;
			m_n_value = value;
		}
		
		public function get value():Number { return m_n_value; }
		
		public function set value(v:Number):void 
		{
			m_n_value = v;
		}
		public function toString():String {
			return name +": "+ m_n_value.toString();
		}
	}
}