package no.doomsday.aronning.debug.console
{
	import no.doomsday.aronning.debug.console.commands.ConsoleCallbackCommand;
	import no.doomsday.aronning.debug.console.DebugConsole;
	import no.doomsday.aronning.debug.console.messages.MessageTypes;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleUtil 
	{
		public function ConsoleUtil() 
		{
			
		}
		public static function get instance():DebugConsole {
			return DebugConsole.getInstance();
		}
		public static function addMessage(msg:String):void {
			instance.addMessage(msg);
		}
		public static function addSystemMessage(msg:String):void {
			instance.addMessage(msg, MessageTypes.SYSTEM);
		}
		public static function addErrorMessage(msg:String):void {
			instance.addMessage(msg, MessageTypes.ERROR);
		}
		public static function addCallbackCommand(triggerPhrase:String, callback:Function,commandGroup:String = "Application",helpText:String = ""):void {
			instance.addCommand(new ConsoleCallbackCommand(triggerPhrase, callback, commandGroup, helpText));
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