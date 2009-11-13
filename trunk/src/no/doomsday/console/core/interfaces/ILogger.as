package no.doomsday.console.core.interfaces 
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface ILogger 
	{
		function log(...args:Array):void;
		function show():void;
		function hide():void;
	}
	
}