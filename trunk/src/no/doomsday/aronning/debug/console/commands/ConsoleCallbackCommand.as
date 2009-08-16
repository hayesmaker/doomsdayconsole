package no.doomsday.aronning.debug.console.commands{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleCallbackCommand extends ConsoleCommand
	{
		private var callbackDict:Dictionary;
		/**
		 * Creates a callback command, which calls a function when triggered
		 * @param	trigger
		 * The trigger phrase
		 * @param	callback
		 * The function to call
		 */
		public function ConsoleCallbackCommand(trigger:String, callback:Function, grouping:String = "Application", helpText:String = "")
		{
			callbackDict = new Dictionary(true);
			callbackDict["callback"] = callback;
			super(trigger);
			this.grouping = grouping;
			this.helpText = helpText;
		}
		public function get callback():Function {
			return callbackDict["callback"] as Function;
		}
		
	}
	
}