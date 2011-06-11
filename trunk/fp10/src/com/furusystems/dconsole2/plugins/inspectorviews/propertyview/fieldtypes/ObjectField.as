package com.furusystems.dconsole2.plugins.inspectorviews.propertyview.fieldtypes
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class ObjectField extends PropertyField
	{
		
		public function ObjectField(object:Object,property:String,type:String, access:String = "readwrite") 
		{
			super(object, property, type, access);
		}
		override public function updateFromSource():void 
		{
			
		}
		
	}

}