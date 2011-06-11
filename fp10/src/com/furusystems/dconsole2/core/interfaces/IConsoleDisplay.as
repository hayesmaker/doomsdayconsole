package com.furusystems.dconsole2.core.interfaces 
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import com.furusystems.dconsole2.core.output.ConsoleMessage;
	
	/**
	 * ...
	 * @author Andreas Roenning
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