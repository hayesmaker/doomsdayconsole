package no.doomsday.dconsole2.plugins.notepad 
{
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	import no.doomsday.dconsole2.core.inspector.Inspector;
	import flash.display.BitmapData;
	import no.doomsday.dconsole2.core.inspector.AbstractInspectorView;
	import no.doomsday.dconsole2.core.plugins.IDConsoleInspectorPlugin;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class NotepadUtil extends AbstractInspectorView
	{
		
		public function NotepadUtil() 
		{
			
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IDConsoleInspectorPlugin */
		
		override public function get descriptionText():String { 
			return "Adds a simple persistent text input window to the inspector";
		}
		
		
	}

}