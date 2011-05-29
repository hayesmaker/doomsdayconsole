package com.furusystems.dconsole2.plugins 
{
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import com.furusystems.dconsole2.core.plugins.IDConsolePlugin;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	import com.furusystems.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ScreenshotUtil implements IDConsolePlugin
	{
		private const _fileRef:FileReference = new FileReference();
		private var _console:DConsole;
		
		private function getScreenshot(target:DisplayObject = null):BitmapData
		{
			var bmd:BitmapData;
			_console.isVisible = false;
			if (target == null){
				bmd = new BitmapData(_console.stage.stageWidth, _console.stage.stageHeight, true, 0);
				bmd.draw(_console.stage);
			}else {
				bmd = new BitmapData(target.width, target.height, true, 0);
				bmd.draw(target);
			}
			_console.isVisible = true;
			return bmd;
		}
		
		private function saveScreenshot(target:DisplayObject = null,title:String = ""):void
		{
			var screenGrab:BitmapData = getScreenshot(target);
			var pngBytes:ByteArray = PNGEncoder.encode(screenGrab);
			if (title == "") title = "Screenshot";
			_fileRef.save(pngBytes, title + ".png");
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.plugins.IDConsolePlugin */
		
		public function initialize(pm:PluginManager):void
		{
			_console = pm.console;
			_console.createCommand("saveScreenshot", saveScreenshot, "ScreenshotUtil", "Grab a png screenshot of the target object (default stage) and save it as PNG");
			_console.createCommand("getScreenshot", getScreenshot, "ScreenshotUtil", "Grab a bitmapdata screenshot of the target object (default stage) and return it");
		}
		
		public function shutdown(pm:PluginManager):void
		{
			_console.removeCommand("saveScreenshot");
			_console.removeCommand("getScreenshot");
		}
		
		public function get descriptionText():String
		{
			return "Enables saving of screenshots of selections or the full stage";
		}
		
	}

}