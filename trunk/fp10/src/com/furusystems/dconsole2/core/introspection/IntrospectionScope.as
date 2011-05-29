﻿package no.doomsday.dconsole2.core.introspection 
{
	import no.doomsday.dconsole2.core.introspection.descriptions.*;
	import no.doomsday.dconsole2.core.text.autocomplete.AutocompleteDictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class IntrospectionScope
	{
		public var autoCompleteDict:AutocompleteDictionary = new AutocompleteDictionary();
		public var children:Vector.<ChildScopeDesc>; //child display objects
		public var accessors:Vector.<AccessorDesc>; //accessors/setters/getters
		public var methods:Vector.<MethodDesc>; //methods
		public var variables:Vector.<VariableDesc>; //variables
		public var obj:Object; //the actual source object
		public var xml:XML;
		public var qualifiedClassName:String;
		public var inheritanceChain:Vector.<String>;
		public var interfaces:Vector.<String>;
		public function IntrospectionScope() 
		{
			
		}
	}

}