package no.doomsday.dconsole2.plugins.plugcollections
{
	import no.doomsday.dconsole2.core.plugins.IPluginBundle;
	import no.doomsday.dconsole2.plugins.BatchRunnerUtil;
	import no.doomsday.dconsole2.plugins.BytearrayHexdumpUtil;
	import no.doomsday.dconsole2.plugins.ChainsawConnectorUtil;
	import no.doomsday.dconsole2.plugins.ClassFactoryUtil;
	import no.doomsday.dconsole2.plugins.colorpicker.ColorPickerUtil;
	import no.doomsday.dconsole2.plugins.CommandMapperUtil;
	import no.doomsday.dconsole2.plugins.controller.ControllerUtil;
	import no.doomsday.dconsole2.plugins.FontUtil;
	import no.doomsday.dconsole2.plugins.FullscreenUtil;
	import no.doomsday.dconsole2.plugins.inspectorviews.propertyview.PropertyViewUtil;
	import no.doomsday.dconsole2.plugins.inspectorviews.treeview.TreeViewUtil;
	import no.doomsday.dconsole2.plugins.invokegesture.InvokeGestureUtil;
	import no.doomsday.dconsole2.plugins.JSONParserUtil;
	import no.doomsday.dconsole2.plugins.JSRouterUtil;
	import no.doomsday.dconsole2.plugins.LogFileUtil;
	import no.doomsday.dconsole2.plugins.measurebracket.MeasurementBracketUtil;
	import no.doomsday.dconsole2.plugins.mediatester.MediaTesterUtil;
	import no.doomsday.dconsole2.plugins.MouseUtil;
	import no.doomsday.dconsole2.plugins.PerformanceTesterUtil;
	import no.doomsday.dconsole2.plugins.ProductInfoUtil;
	import no.doomsday.dconsole2.plugins.ScreenshotUtil;
	import no.doomsday.dconsole2.plugins.StageUtil;
	import no.doomsday.dconsole2.plugins.StatsOutputUtil;
	import no.doomsday.dconsole2.plugins.SystemInfoUtil;
	/**
	 * Collection of all available plugins
	 * @author Andreas Rønning
	 */
	public class AllPlugins implements IPluginBundle
	{
		private var _plugins:Vector.<Class>;
		public function AllPlugins() 
		{
			_plugins = Vector.<Class>([
				BytearrayHexdumpUtil,
				ProductInfoUtil,
				MeasurementBracketUtil,
				ColorPickerUtil,
				ClassFactoryUtil,
				ControllerUtil,
				LogFileUtil,
				BatchRunnerUtil,
				MediaTesterUtil,
				ScreenshotUtil,
				FontUtil,
				JSRouterUtil,
				MouseUtil,
				FullscreenUtil,
				SystemInfoUtil,
				StatsOutputUtil,
				PerformanceTesterUtil,
				CommandMapperUtil,
				JSONParserUtil,
				PropertyViewUtil,
				StageUtil,
				ChainsawConnectorUtil,
				InvokeGestureUtil,
				TreeViewUtil
			]);
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IPluginBundle */
		
		public function get plugins():Vector.<Class>
		{
			return _plugins;
		}
		
	}

}