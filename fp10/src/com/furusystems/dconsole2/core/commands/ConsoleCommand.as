package com.furusystems.dconsole2.core.commands
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleCommand 
	{
		public var trigger:String;
		public var helpText:String = "";
		public var returnType:String = "";
		public var grouping:String = "Application";
		public var includeInHistory:Boolean = true;
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