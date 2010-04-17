package no.doomsday.console.core.input
{
	import flash.events.KeyboardEvent;

	internal interface KeyboardList
	{
		function onKeyUp(event:KeyboardEvent):void;
		function onKeyDown(event:KeyboardEvent):void;
		function removeAll():void;
		function isEmpty():Boolean;
	}
}