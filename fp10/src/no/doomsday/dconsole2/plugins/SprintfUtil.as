package no.doomsday.dconsole2.plugins 
{
	import de.popforge.utils.sprintf;
	import no.doomsday.dconsole2.core.plugins.IDConsolePlugin;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	import no.doomsday.dconsole2.DConsole;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class SprintfUtil implements IDConsolePlugin
	{
		private var _console:DConsole;
		
		public function SprintfUtil() 
		{
			
		}
		public function sprintf(format:String, ...args):void {
			var out:String = sprintf.apply(this, [format].concat(args));
			_console.print(out);
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IDConsolePlugin */
		
		public function get descriptionText():String
		{
			return "Adds sprintf(format, args) to the console";
		}
		
		public function initialize(pm:PluginManager):void
		{
			//TODO: How can a plugin best add a public method to the console?
			_console = pm.console;
		}
		
		public function shutdown(pm:PluginManager):void
		{
			_console = null;
		}
		
	}

}