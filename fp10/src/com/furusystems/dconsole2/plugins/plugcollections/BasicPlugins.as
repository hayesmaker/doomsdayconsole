package no.doomsday.dconsole2.plugins.plugcollections 
{
	import no.doomsday.dconsole2.core.plugins.IPluginBundle;
	import no.doomsday.dconsole2.plugins.*;
	import no.doomsday.dconsole2.plugins.measurebracket.MeasurementBracketUtil;
	/**
	 * Collection of all basic plugins
	 * @author Andreas Rønning
	 */
	public class BasicPlugins implements IPluginBundle
	{
		
		private var _plugins:Vector.<Class>;
		public function BasicPlugins() 
		{
			_plugins = Vector.<Class>([
				BytearrayHexdumpUtil,
				ProductInfoUtil,
				ClassFactoryUtil,
				LogFileUtil,
				ScreenshotUtil,
				FontUtil,
				JSRouterUtil,
				MeasurementBracketUtil,
				MouseUtil,
				FullscreenUtil,
				SystemInfoUtil,
				StatsOutputUtil,
				JSONParserUtil,
				StageUtil
			]);
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IPluginBundle */
		
		public function get plugins():Vector.<Class>
		{
			return _plugins;
		}
		
	}

}