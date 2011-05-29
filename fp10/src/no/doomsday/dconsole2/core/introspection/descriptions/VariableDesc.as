package no.doomsday.dconsole2.core.introspection.descriptions 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class VariableDesc extends NamedDescription
	{
		public var type:String;
		public function VariableDesc(xml:XML) 
		{
			this.name = xml.@name;
			this.type = xml.@type;
		}
		
	}

}