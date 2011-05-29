package no.doomsday.dconsole2.core.plugins 
{
	import flash.display.BitmapData;
	import no.doomsday.dconsole2.core.inspector.AbstractInspectorView;
	import no.doomsday.dconsole2.core.inspector.Inspector;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IDConsoleInspectorPlugin extends IUpdatingDConsolePlugin
	{
		function get view():AbstractInspectorView;
		function get tabIcon():BitmapData;
		function associateWithInspector(inspector:Inspector):void;
	}
	
}