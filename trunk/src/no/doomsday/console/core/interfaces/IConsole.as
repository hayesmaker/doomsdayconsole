﻿package no.doomsday.console.core.interfaces 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import no.doomsday.console.core.commands.ConsoleCommand;
	import no.doomsday.console.core.messages.Message;
	import no.doomsday.console.core.messages.MessageTypes;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IConsole
	{
		function show():void;
		function hide():void;
		function setInvokeKeys(...keyCodes:Array):void;
		function setRepeatFilter(filter:int):void;
		function toggleStats(e:Event = null):void;
		function routeToJS():void;
		function alertErrors():void;
		function screenshot(e:Event = null):void;
		function addCommand(command:ConsoleCommand):void
		function print(str:String, type:uint = MessageTypes.OUTPUT):Message;
		function clear():void;
		function saveLog(e:Event = null):void;
		function setPassword(pwd:String):void;
		function runBatch(batch:String):Boolean;
		function runBatchFromUrl(url:String):void;
		function maximize():void;
		function minimize():void;
		function onEvent(e:Event):void;
		function trace(...args:Array):void;
		function log(...args:Array):void;
		function dock(value:String):void;
		function setChromeTheme(backgroundColor:uint = 0, backgroundAlpha:Number = 0.8, borderColor:uint = 0x333333, inputBackgroundColor:uint = 0, helpBackgroundColor:uint = 0x222222):void;
		function setTextTheme(input:uint = 0xFFD900, oldMessage:uint = 0xBBBBBB, newMessage:uint = 0xFFFFFF, system:uint = 0x00DD00, timestamp:uint = 0xAAAAAA, error:uint = 0xEE0000, help:uint = 0xbbbbbb, trace:uint = 0x9CB79B, event:uint = 0x009900, warning:uint = 0xFFD900):void;
		
	}
	
}