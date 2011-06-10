package com.furusystems.dconsole2.plugins 
{
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import com.furusystems.dconsole2.core.plugins.IDConsolePlugin;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	import com.furusystems.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class StageUtil implements IDConsolePlugin
	{
		private var _console:DConsole;
		
		public function StageUtil() 
		{
			
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.plugins.IDConsolePlugin */
		
		public function get descriptionText():String
		{
			return "Adds commands for common stage operations";
		}
		
		public function initialize(pm:PluginManager):void
		{
			_console = pm.console;
			pm.console.createCommand("alignStage", alignStage, "Stage", "Sets stage.align to TOP_LEFT and stage.scaleMode to NO_SCALE");
			pm.console.createCommand("setFrameRate", setFramerate, "Stage", "Sets stage.frameRate");
			pm.console.createCommand("toggleFullscreen", toggleFullscreen, "FullscreenUtil", "Toggles stage.displayState between FULL_SCREEN and NORMAL");

		}
		private function setFramerate(rate:int = 60):void
		{
			_console.stage.frameRate = rate;
			DConsole.addSystemMessage("Framerate set to " + _console.stage.frameRate);
		}
		private function alignStage():void
		{
			_console.stage.align = StageAlign.TOP_LEFT;
			_console.stage.scaleMode = StageScaleMode.NO_SCALE;
			DConsole.addSystemMessage("StageAlign set to TOP_LEFT, StageScaleMode set to NO_SCALE");
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
		
		public function shutdown(pm:PluginManager):void
		{
			pm.console.removeCommand("alignStage");
			pm.console.removeCommand("setFrameRate");
			pm.console.removeCommand("toggleFullscreen");
			_console = null;
		}
		
	}

}