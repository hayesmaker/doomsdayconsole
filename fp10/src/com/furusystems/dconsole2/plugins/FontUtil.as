package no.doomsday.dconsole2.plugins 
{
	import flash.text.Font;
	import no.doomsday.dconsole2.core.plugins.IDConsolePlugin;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	import no.doomsday.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class FontUtil implements IDConsolePlugin
	{
		private var _console:DConsole;
		
		private function printFonts(c:DConsole):void {
			var fnts:Array = Font.enumerateFonts();
			if (fnts.length < 1) {
				c.print("Only system fonts available");
			}
			for (var i:int = 0; i < fnts.length; i++) 
			{
				c.print("	" + fnts[i].fontName);
			}
		}
		private function listFonts():void
		{
			printFonts(_console);
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IDConsolePlugin */
		
		public function initialize(pm:PluginManager):void
		{
			_console = pm.console;
			_console.createCommand("listFonts", listFonts, "FontUtil", "Prints a list of all embedded fonts (excluding system fonts)");
		}
		
		public function shutdown(pm:PluginManager):void
		{
			_console = null;
			_console.removeCommand("listFonts");
		}
		
		public function get descriptionText():String
		{
			return "Enables readouts of embedded fonts";
		}
		
	}

}