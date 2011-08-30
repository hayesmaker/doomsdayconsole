package com.furusystems.dconsole2.plugins 
{
	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import com.furusystems.dconsole2.core.plugins.IDConsolePlugin;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	import com.furusystems.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Roenning
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
			_console.createCommand("alignStage", alignStage, "Stage", "Sets stage.align to TOP_LEFT and stage.scaleMode to NO_SCALE");
			_console.createCommand("setFrameRate", setFramerate, "Stage", "Sets stage.frameRate");
			_console.createCommand("toggleFullscreen", toggleFullscreen, "FullscreenUtil", "Toggles stage.displayState between FULL_SCREEN and NORMAL");

		}
		private function setFramerate(rate:int = 60):void
		{
			_console.stage.frameRate = rate;
			_console.print("Framerate set to " + _console.stage.frameRate, ConsoleMessageTypes.SYSTEM);
		}
		private function alignStage():void
		{
			_console.stage.align = StageAlign.TOP_LEFT;
			_console.stage.scaleMode = StageScaleMode.NO_SCALE;
			_console.print("StageAlign set to TOP_LEFT, StageScaleMode set to NO_SCALE", ConsoleMessageTypes.SYSTEM);
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
			_console.removeCommand("alignStage");
			_console.removeCommand("setFrameRate");
			_console.removeCommand("toggleFullscreen");
			_console = null;
		}
		
				
		public function get dependencies():Vector.<Class> 
		{
			return new Vector.<Class>();
		}
		
	}

}