package com.furusystems.dconsole2.core.inspector 
{
	import flash.events.Event;
	import com.furusystems.dconsole2.core.interfaces.IScrollable;
	
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public interface IInspectorView extends IScrollable
	{ 
		function get visible():Boolean;
		function set visible(b:Boolean):void;
		function beginDragging():void;
		function stopDragging():void;
		function onFrameUpdate(e:Event = null):void;
		function resize():void;
	}
	
}