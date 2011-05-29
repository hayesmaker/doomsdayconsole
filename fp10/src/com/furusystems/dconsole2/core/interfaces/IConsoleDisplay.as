package no.doomsday.dconsole2.core.interfaces 
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import no.doomsday.dconsole2.core.output.ConsoleMessage;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IConsoleDisplay 
	{
		function get displayObject():DisplayObject;
		function get visible():Boolean;
		function set visible(b:Boolean):void;
		function redraw():Rectangle;
		function updateMessages(log:Vector.<ConsoleMessage>):void;
	}
	
}