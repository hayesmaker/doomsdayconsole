package no.doomsday.aronning.debug.console.commands
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleCommand 
	{
		public var trigger:String;
		public var helpText:String = "";
		public var grouping:String = "Application";
		/**
		 * Abstract ConsoleCommand class
		 * @param	trigger
		 */
		public function ConsoleCommand(trigger:String) 
		{
			this.trigger = trigger;
		}
		
	}
	
}