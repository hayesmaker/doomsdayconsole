package no.doomsday.dconsole2.plugins 
{
	import flash.utils.Dictionary;
	import no.doomsday.dconsole2.core.introspection.IntrospectionScope;
	import no.doomsday.dconsole2.core.plugins.IDConsolePlugin;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	import no.doomsday.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class CommandMapperUtil implements IDConsolePlugin
	{
		private var _console:DConsole;
		private var methodsCreated:Dictionary = new Dictionary();
		public function CommandMapperUtil() 
		{
			
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IDConsolePlugin */
		
		public function get descriptionText():String
		{
			return "Offers fast automatic mapping of public methods to commands";
		}
		
		public function initialize(pm:PluginManager):void
		{
			_console = pm.console;
			pm.console.createCommand("quickmap", doMap,"CommandMapperUtil","Maps every method of the current scope to a command if possible");
		}
		
		private function doMap():void
		{
			var target:IntrospectionScope = _console.currentScope;
			for (var i:int = 0; i < target.methods.length; i++) 
			{
				_console.createCommand(target.methods[i].name, target.obj[target.methods[i].name], target.obj.toString());
				methodsCreated[target.methods[i].name] = 1;
			}
		}
		
		public function shutdown(pm:PluginManager):void
		{
			pm.console.removeCommand("quickmap");
			for(var m:String in methodsCreated) {
				pm.console.removeCommand(m);
			}
			_console = null;
		}
		
	}

}