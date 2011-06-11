package com.furusystems.dconsole2.core.plugins 
{
	import flash.display.BitmapData;
	import com.furusystems.dconsole2.core.inspector.AbstractInspectorView;
	import com.furusystems.dconsole2.core.inspector.Inspector;
	
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public interface IDConsoleInspectorPlugin extends IUpdatingDConsolePlugin
	{
		function get view():AbstractInspectorView;
		function get tabIcon():BitmapData;
		function associateWithInspector(inspector:Inspector):void;
	}
	
}