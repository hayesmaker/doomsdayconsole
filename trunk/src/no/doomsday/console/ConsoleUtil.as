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
			throw new Error("Abstract class, don't instance");
		}
		/**
		 * Get the singleton console instance
		 */
		public static function get instance():DConsole {
			return DConsole.instance;
		}
		/**
		 * Add a message
		 * @param	msg
		 */
		public static function print(msg:String):void {
			instance.print(msg);
		}
		/**
		 * Add a message with system color coding
		 * @param	msg
		 */
		public static function addSystemMessage(msg:String):void {
			instance.print(msg, MessageTypes.SYSTEM);
		}
		/**
		 * Add a message with error color coding
		 * @param	msg
		 */
		public static function addErrorMessage(msg:String):void {
			instance.print(msg, MessageTypes.ERROR);
		}
		/**
		 * Create a command for calling a specific function
		 * @param	triggerPhrase
		 * The trigger word for the command
		 * @param	func
		 * The function to call
		 * @param	commandGroup
		 * Optional: The group name you want the command sorted under
		 * @param	helpText
		 */
		public static function linkFunction(triggerPhrase:String, func:Function,commandGroup:String = "Application",helpText:String = ""):void {
			instance.addCommand(new FunctionCallCommand(triggerPhrase, func, commandGroup, helpText));
		}
		/**
		 * Use this to print event messages on dispatch (addEventListener(Event.CHANGE, ConsoleUtil.onEvent))
		 */
		public static function get onEvent():Function {
			return instance.onEvent;
		}
		/**
		 * Add a message to the trace buffer
		 */
		public static function get trace():Function {
			return instance.trace;
		}
		/**
		 * Show the console
		 */
		public static function show():void {
			instance.show();
		}
		/**
		 * Hide the console
		 */
		public static function hide():void {
			instance.hide();
		}
	}
}