package no.doomsday.console
{
	import flash.utils.describeType;
	import no.doomsday.console.commands.FunctionCallCommand;
	import no.doomsday.console.DConsole;
	import no.doomsday.console.measurement.MeasurementTool;
	import no.doomsday.console.messages.MessageTypes;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleUtil 
	{
		
		private static var console:DConsole;
		
		public function ConsoleUtil() 
		{
			throw new Error("Abstract class, don't instance");
		}
		/**
		 * Get the singleton console instance
		 */
		public static function get instance():DConsole {
			if (!console) {
				console = new DConsole();
			}
			return console;
			//return DConsole.instance;
		}
		/**
		 * Add a message
		 * @param	msg
		 */
		public static function print(input:Object):void {
			instance.print(input.toString());
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
		 * Legacy, deprecated. Use "createCommand" instead
		 */
		public static function linkFunction(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
			createCommand(triggerPhrase, func, commandGroup, helpText);
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
		public static function createCommand(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
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
		 * Clears the trace buffer
		 */
		public static function get clearTrace():Function {
			return instance.clearTrace;
		}
		public static function get clear():Function {
			return instance.clear;
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
		/**
		 * Toggles tabbing unknown words to search and list commands and methods
		 */
		public static function set tabSearch(value:Boolean):void {
			instance.setTabSearch(value);
		}
	}
}