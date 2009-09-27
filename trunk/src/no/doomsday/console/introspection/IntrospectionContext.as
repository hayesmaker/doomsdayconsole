package no.doomsday.console.introspection 
{
	import no.doomsday.console.text.autocomplete.AutocompleteDictionary;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class IntrospectionContext
	{
		public var autoCompleteDict:AutocompleteDictionary = new AutocompleteDictionary();
		public var children:Vector.<ChildContextDesc>;
		public var accessors:Vector.<AccessorDesc>;
		public var methods:Vector.<MethodDesc>;
		public var variables:Vector.<VariableDesc>;
		public var obj:Object;
		public function IntrospectionContext() 
		{
			
		}
		
	}

}