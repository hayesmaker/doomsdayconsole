package com.furusystems.dconsole2.plugins.inspectorviews.propertyview.tabs
{
	import com.furusystems.dconsole2.DConsole;
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	import com.furusystems.dconsole2.core.introspection.IntrospectionScope;
	import com.furusystems.dconsole2.plugins.inspectorviews.propertyview.fieldtypes.PropertyField;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class OverviewTab extends PropertyTab
	{
		
		public function OverviewTab(console:DConsole, scope:IntrospectionScope) 
		{
			var className:String = getQualifiedClassName(scope.obj);
			super(className.split("::").pop(), true);
			var i:int;
			if (scope.obj is DisplayObject) {
				var displayObject:DisplayObject = scope.obj as DisplayObject;
				if (displayObject != displayObject.root) addField(new PropertyField(console, scope.obj, "name", "string", "readwrite"));
				for (i = 0; i < scope.accessors.length; i++) 
				{
					if (scope.accessors[i].name.toLowerCase() == "parent") {
						addField(new PropertyField(console, scope.obj, scope.accessors[i].name, scope.accessors[i].type, scope.obj[scope.accessors[i].name]));
						break;
					}
				}
			}
		}
		
	}

}