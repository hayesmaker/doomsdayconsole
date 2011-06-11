package com.furusystems.dconsole2.plugins.inspectorviews.propertyview.tabs
{
	import flash.utils.getQualifiedClassName;
	import com.furusystems.dconsole2.core.introspection.IntrospectionScope;
	import com.furusystems.dconsole2.plugins.inspectorviews.propertyview.fieldtypes.PropertyField;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class InheritanceTab extends PropertyTab
	{
		
		public function InheritanceTab(scope:IntrospectionScope) 
		{
			var className:String = getQualifiedClassName(scope.obj);
			super("Inheritance", false);
			var i:int;			
			var f:PropertyField;
			for (i = 0; i < scope.inheritanceChain.length; i++) 
			{
				f = new PropertyField(null, "Extends", "string");
				f.controlField.value = scope.inheritanceChain[i];
				f.readOnly = true;
				addField(f);
			}
			for (i = 0; i < scope.interfaces.length; i++) 
			{
				f = new PropertyField(null, "Implements", "string");
				f.controlField.value = scope.interfaces[i];
				f.readOnly = true;
				addField(f);
			}
		}
		override public function updateFields():void 
		{
		}
		
	}

}