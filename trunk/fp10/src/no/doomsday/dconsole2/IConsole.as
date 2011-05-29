package no.doomsday.dconsole2 
{
	import flash.events.Event;
	import no.doomsday.dconsole2.core.gui.maindisplay.ConsoleView;
	import no.doomsday.dconsole2.core.introspection.ScopeManager;
	import no.doomsday.dconsole2.core.persistence.PersistenceManager;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IConsole 
	{
		function get view():ConsoleView;
		function show():void;
		function hide():void;
		function executeStatement(statement:String, echo:Boolean = false):*;
		function select(target:*):void;
		function get visible():Boolean;
		function set visible(b:Boolean):void;
		function set defaultInputCallback(f:Function):void;
		function get defaultInputCallback():Function;
		function print(str:String, type:String = "Info", tag:String = ""):void;
		function changeKeyboardShortcut(keystroke:uint, modifier:uint):void;
		function onEvent(e:Event):void;
		function clear():void;
		function createCommand(keyword:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void;		
		function setHeaderText(title:String):void;
		function set overrideCallback(callback:Function):void;
		function clearOverrideCallback():void;
	}
	
}