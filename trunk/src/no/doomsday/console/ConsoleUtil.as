package no.doomsday.console
{
	import no.doomsday.console.commands.FunctionCallCommand;
	import no.doomsday.console.DConsole;
	import no.doomsday.console.messages.MessageTypes;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleUtil 
	{
		
		
		
		public function ConsoleUtil() 
		{
			
		}
		public static function get instance():DConsole {
			return DConsole.instance;
		}
		public static function print(msg:String):void {
			instance.print(msg);
		}
		public static function addSystemMessage(msg:String):void {
			instance.print(msg, MessageTypes.SYSTEM);
		}
		public static function addErrorMessage(msg:String):void {
			instance.print(msg, MessageTypes.ERROR);
		}
		public static function linkFunction(triggerPhrase:String, callback:Function,commandGroup:String = "Application",helpText:String = ""):void {
			instance.addCommand(new FunctionCallCommand(triggerPhrase, callback, commandGroup, helpText));
		}
		public static function get onEvent():Function {
			return instance.onEvent;
		}
		public static function get trace():Function {
			return instance.trace;
		}
		public static function show():void {
			instance.show();
		}
		public static function hide():void {
			instance.hide();
		}
	}
}