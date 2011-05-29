package no.doomsday.dconsole2.core.plugins 
{
	import no.doomsday.dconsole2.core.output.ConsoleMessage;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IFilteringDConsolePlugin extends IDConsolePlugin
	{
		/**
		 * Defines a filtering function that validates a message for output
		 * @param	output
		 * The message to validate
		 * @return
		 * Wether the message is to be displayed or not
		 */
		function filter(output:ConsoleMessage):Boolean;
	}
	
}