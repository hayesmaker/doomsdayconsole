package com.furusystems.dconsole2.plugins.inspectorviews.propertyview.fieldtypes
{
	import com.furusystems.dconsole2.core.introspection.descriptions.ChildScopeDesc;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ChildField extends PropertyField
	{
		public function ChildField(child:ChildScopeDesc) 
		{
			super(null, child.name, "string", "readonly");
			controlField.value = child.type;
			//super(null, child.name, child.type, child.object);
			//readOnly = true;
			controlField.enableDoubleClickToSelect(child.object);
		}
		override public function updateFromSource():void 
		{
			
		}
		
	}

}