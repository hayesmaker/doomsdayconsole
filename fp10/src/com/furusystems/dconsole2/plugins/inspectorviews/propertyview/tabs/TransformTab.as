package no.doomsday.dconsole2.plugins.inspectorviews.propertyview.tabs 
{
	import flash.display.DisplayObject;
	import no.doomsday.dconsole2.core.introspection.IntrospectionScope;
	import no.doomsday.dconsole2.plugins.inspectorviews.propertyview.fieldtypes.PropertyField;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TransformTab extends PropertyTab
	{
		
		public function TransformTab(target:IntrospectionScope) 
		{
			super("Transform", false);
			populate(target);
		}
		public function populate(scope:IntrospectionScope):void {
			if (!(scope.obj is DisplayObject)) throw new Error("Cannot populate transform tab with non displayobject scope");
			addField(new PropertyField(scope.obj, "x", "number"));
			addField(new PropertyField(scope.obj, "y", "number"));
			addField(new PropertyField(scope.obj, "z", "number"));
			addField(new PropertyField(scope.obj, "rotationX", "number"));
			addField(new PropertyField(scope.obj, "rotationY", "number"));
			addField(new PropertyField(scope.obj, "rotationZ", "number"));
			addField(new PropertyField(scope.obj, "width", "number"));
			addField(new PropertyField(scope.obj, "height", "number"));
			addField(new PropertyField(scope.obj, "scaleX", "number"));
			addField(new PropertyField(scope.obj, "scaleY", "number"));
			addField(new PropertyField(scope.obj, "scaleZ", "number"));
		}
		
	}

}