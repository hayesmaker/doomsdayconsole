package no.doomsday.dconsole2.plugins.inspectorviews.propertyview.tabs
{
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	import no.doomsday.dconsole2.core.introspection.IntrospectionScope;
	import no.doomsday.dconsole2.plugins.inspectorviews.propertyview.fieldtypes.PropertyField;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class OverviewTab extends PropertyTab
	{
		
		public function OverviewTab(scope:IntrospectionScope) 
		{
			var className:String = getQualifiedClassName(scope.obj);
			super(className.split("::").pop(), true);
			var i:int;
			if (scope.obj is DisplayObject) {
				var displayObject:DisplayObject = scope.obj as DisplayObject;
				if (displayObject != displayObject.root) addField(new PropertyField(scope.obj, "name", "string", scope.obj["name"]));
				for (i = 0; i < scope.accessors.length; i++) 
				{
					if (scope.accessors[i].name.toLowerCase() == "parent") {
						addField(new PropertyField(scope.obj, scope.accessors[i].name, scope.accessors[i].type, scope.obj[scope.accessors[i].name]));
						break;
					}
				}
			}
		}
		
	}

}