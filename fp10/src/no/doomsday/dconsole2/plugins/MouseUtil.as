package no.doomsday.dconsole2.plugins 
{
	import flash.ui.Mouse;
	import no.doomsday.dconsole2.core.plugins.IDConsolePlugin;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MouseUtil implements IDConsolePlugin
	{
		
		public function MouseUtil() 
		{
			
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IDConsolePlugin */
		
		public function initialize(pm:PluginManager):void
		{
			pm.console.createCommand("showMouse", Mouse.show, "Mouse", "Shows the mouse cursor");
			pm.console.createCommand("hideMouse", Mouse.hide, "Mouse", "Hides the mouse cursor");
		}
		
		public function shutdown(pm:PluginManager):void
		{
			pm.console.removeCommand("showMouse");
			pm.console.removeCommand("hideMouse");
		}
		
		public function get descriptionText():String
		{
			return "Adds command shortcuts for Mouse.show() and Mouse.hide()";
		}
		
	}

}