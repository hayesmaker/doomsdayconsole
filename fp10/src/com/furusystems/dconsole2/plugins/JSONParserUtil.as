package no.doomsday.dconsole2.plugins 
{
	import com.adobe.serialization.json.JSON;
	import no.doomsday.dconsole2.core.plugins.IParsingDConsolePlugin;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class JSONParserUtil implements IParsingDConsolePlugin
	{
		
		public function JSONParserUtil() 
		{
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IParsingDConsolePlugin */
		
		public function parse(data:String):*
		{
			var firstChar:String = data.charAt(0);
			switch(firstChar) {
				case "[":
				case "{":
					try {
						var ret:* = JSON.decode(data);
						return ret;
					}catch (e:Error) {
						return null;
					}
				break;
			}
			return null;
		}
		
		public function initialize(pm:PluginManager):void
		{
			
		}
		
		public function shutdown(pm:PluginManager):void
		{
			
		}
		
		public function get descriptionText():String
		{
			return "Adds JSON parsing of command arguments";
		}
		
	}

}