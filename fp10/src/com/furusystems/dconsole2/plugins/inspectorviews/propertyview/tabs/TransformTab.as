package com.furusystems.dconsole2.plugins.inspectorviews.propertyview.tabs 
{
	import com.furusystems.dconsole2.DConsole;
	import flash.display.DisplayObject;
	import com.furusystems.dconsole2.core.introspection.IntrospectionScope;
	import com.furusystems.dconsole2.plugins.inspectorviews.propertyview.fieldtypes.PropertyField;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class TransformTab extends PropertyTab
	{
		
		public function TransformTab(console:DConsole, target:IntrospectionScope) 
		{
			super("Transform", false);
			populate(console,target);
		}
		public function populate(console:DConsole, scope:IntrospectionScope):void {
			if (!(scope.obj is DisplayObject)) throw new Error("Cannot populate transform tab with non displayobject scope");
			addField(new PropertyField(console, scope.obj, "x", "number"));
			addField(new PropertyField(console, scope.obj, "y", "number"));
			addField(new PropertyField(console, scope.obj, "z", "number"));
			addField(new PropertyField(console, scope.obj, "rotationX", "number"));
			addField(new PropertyField(console, scope.obj, "rotationY", "number"));
			addField(new PropertyField(console, scope.obj, "rotationZ", "number"));
			addField(new PropertyField(console, scope.obj, "width", "number"));
			addField(new PropertyField(console, scope.obj, "height", "number"));
			addField(new PropertyField(console, scope.obj, "scaleX", "number"));
			addField(new PropertyField(console, scope.obj, "scaleY", "number"));
			addField(new PropertyField(console, scope.obj, "scaleZ", "number"));
		}
		
	}

}