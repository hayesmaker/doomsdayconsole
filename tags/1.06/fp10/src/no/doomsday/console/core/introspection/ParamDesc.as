﻿package no.doomsday.console.core.introspection 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ParamDesc
	{
		//<parameter index="1" type="flash.display::DisplayObject" optional="false"/>
		public var index:int;
		public var type:String;
		public var optional:Boolean;
		public function ParamDesc(xml:XML) 
		{
			index = xml.@index;
			type = xml.@type;
			optional = xml.@optional;
		}
		
	}

}