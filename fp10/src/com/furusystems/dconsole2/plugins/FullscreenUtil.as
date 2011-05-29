package com.furusystems.dconsole2.plugins 
{
	import flash.display.StageDisplayState;
	import com.furusystems.dconsole2.core.plugins.IDConsolePlugin;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	import com.furusystems.dconsole2.DConsole;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class FullscreenUtil implements IDConsolePlugin
	{
		private var _console:DConsole;
		
		public function FullscreenUtil() 
		{
			
		}
		private function toggleFullscreen():void {
			switch(_console.stage.displayState) {
				case StageDisplayState.FULL_SCREEN:
				_console.stage.displayState = StageDisplayState.NORMAL;
				break;
				case StageDisplayState.NORMAL:
				_console.stage.displayState = StageDisplayState.FULL_SCREEN;
				break;
			}
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.plugins.IDConsolePlugin */
		
		public function initialize(pm:PluginManager):void
		{
			_console = pm.console;
			pm.console.createCommand("toggleFullscreen", toggleFullscreen, "FullscreenUtil", "Toggles stage.displayState between FULL_SCREEN and NORMAL");
		}
		
		public function shutdown(pm:PluginManager):void
		{
			_console = null;
			pm.console.removeCommand("toggleFullscreen");
		}
		
		public function get descriptionText():String
		{
			return "Adds commands for toggling fullscreen display";
		}
		
	}

}