package no.doomsday.console.core.introspection 
{
	import no.doomsday.console.core.text.autocomplete.AutocompleteDictionary;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class IntrospectionScope
	{
		public var autoCompleteDict:AutocompleteDictionary = new AutocompleteDictionary();
		public var children:Array;
		public var accessors:Array;
		public var methods:Array;
		public var variables:Array;
		public var obj:Object;
		public function IntrospectionScope() 
		{
			
		}
		
	}

}