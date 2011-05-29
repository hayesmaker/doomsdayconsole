package no.doomsday.dconsole2.core.plugins 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import no.doomsday.dconsole2.core.introspection.ScopeManager;
	import no.doomsday.dconsole2.core.logmanager.DLogManager;
	import no.doomsday.dconsole2.core.output.ConsoleMessage;
	import no.doomsday.dconsole2.core.output.ConsoleMessageTypes;
	import no.doomsday.dconsole2.core.references.ReferenceManager;
	import no.doomsday.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class PluginManager
	{
		private var _pluginMap:Dictionary;
		private var _updatingPlugins:Vector.<IUpdatingDConsolePlugin> = new Vector.<IUpdatingDConsolePlugin>();
		private var _filteringPlugins:Vector.<IFilteringDConsolePlugin> = new Vector.<IFilteringDConsolePlugin>();
		private var _parsers:Vector.<IParsingDConsolePlugin> = new Vector.<IParsingDConsolePlugin>();
		private var _inspectorViews:Vector.<IDConsoleInspectorPlugin> = new Vector.<IDConsoleInspectorPlugin>();
		private var _scopeManager:ScopeManager;
		private var _referenceManager:ReferenceManager;
		private var _console:DConsole;
		private var _topLayer:Sprite;
		private var _botLayer:Sprite;
		private var _consoleBgLayer:Sprite;
		private var _logManager:DLogManager
		public function PluginManager(scopeManager:ScopeManager,referenceManager:ReferenceManager,console:DConsole,topLayer:Sprite,botLayer:Sprite,consoleBackgroundLayer:Sprite,logManager:DLogManager) 
		{
			_logManager = logManager;
			_topLayer = topLayer
			_botLayer = botLayer
			_consoleBgLayer = consoleBackgroundLayer;
			
			_scopeManager = scopeManager;
			_referenceManager = referenceManager;
			_console = console;
			_pluginMap = new Dictionary();
		}
		public function unregisterPlugin(plug:Class):void {
			if (_pluginMap[plug] != null) {
				_pluginMap[plug].shutdown(this);
				if (_pluginMap[plug] is IDConsoleInspectorPlugin) {
					_console.view.inspector.removeView(_pluginMap[plug]);
					_inspectorViews.splice(_inspectorViews.indexOf(_pluginMap[plug]), 1);
				}else if (_pluginMap[plug] is IParsingDConsolePlugin) {
					_parsers.splice(_parsers.indexOf(_pluginMap[plug]), 1);
				}else if (_pluginMap[plug] is IFilteringDConsolePlugin) {
					_filteringPlugins.splice(_filteringPlugins.indexOf(_pluginMap[plug]), 1);
				}else if (_pluginMap[plug] is IUpdatingDConsolePlugin) {
					_updatingPlugins.splice(_updatingPlugins.indexOf(_pluginMap[plug]), 1);
				}
				_pluginMap[plug] = null;
				delete(_pluginMap[plug]);
			}
		}
		public function registerPlugin(plug:Class):void {
			var obj:* = new plug();
			if (obj is IDConsolePlugin) {
				var plugInstance:IDConsolePlugin = obj as IDConsolePlugin;
				if (_pluginMap[plug] == null) {
					plugInstance.initialize(this);
					_pluginMap[plug] = plugInstance;
					if (plugInstance is IDConsoleInspectorPlugin) {
						_inspectorViews.push(plugInstance);
						_console.view.inspector.addView(IDConsoleInspectorPlugin(plugInstance));
					}else if (plugInstance is IParsingDConsolePlugin) {
						_parsers.push(plugInstance);
					}else if (plugInstance is IFilteringDConsolePlugin) {
						_filteringPlugins.push(plugInstance);
					}else if (plugInstance is IUpdatingDConsolePlugin) {
						_updatingPlugins.push(plugInstance);
					}
				}
			}else if (obj is IPluginBundle) {
				var plugBundle:IPluginBundle = obj as IPluginBundle;
				for (var i:int = 0; i < plugBundle.plugins.length; i++) 
				{
					registerPlugin(plugBundle.plugins[i]);
				}
			}else {
				console.print("Couldn't register plug-in: " + String(describeType(plug).@name).split("::").pop(), ConsoleMessageTypes.ERROR);
			}
		}
		public function get numPlugins():int {
			var count:int = 0;
			for each(var plug:IDConsolePlugin in _pluginMap) {
				++count;
			}
			return count;
		}
		public function printPluginInfo():void {
			var count:int = 0;
			for each(var plug:IDConsolePlugin in _pluginMap) {
				count++;
				console.print(String(describeType(plug).@name).split("::").pop(),ConsoleMessageTypes.SYSTEM);
				console.print("\t(" + plug.descriptionText + ")");
			}
			console.print(count + " plugins registered", ConsoleMessageTypes.SYSTEM);
		}
		public function runParsers(data:String):*{
			for (var i:int = 0; i < _parsers.length; i++) 
			{
				var p:IParsingDConsolePlugin = _parsers[i];
				var result:* = p.parse(data); //Stops at the first parser that returns a valid response
				if (result != null) return result;
			}
			return data;
		}
		public function runFilters(m:ConsoleMessage):Boolean {
			
			for each(var plug:IFilteringDConsolePlugin in _filteringPlugins) {
				if (!plug.filter(m)) return false;
			}
			return true;
		}
		public function update():void {
			for each(var plug:IUpdatingDConsolePlugin in _updatingPlugins) {
				plug.update(this);
			}
		}
		public function get console():DConsole {
			return _console;
		}
		public function get scopeManager():ScopeManager {
			return _scopeManager;
		}
		public function get referenceManager():ReferenceManager {
			return _referenceManager;
		}
		public function get topLayer():DisplayObjectContainer {
			return _topLayer;
		}
		public function get botLayer():DisplayObjectContainer {
			return _botLayer;
		}
		public function get consoleBackground():DisplayObjectContainer {
			return _consoleBgLayer;
		}		
		public function get logManager():DLogManager { return _logManager }
	}

}