package com.furusystems.dconsole2.core.gui.layout 
{
	import flash.geom.Rectangle;
	
	/**
	 * Describes a layout container that has an array of child IContainables
	 * @author Andreas Roenning
	 */
	public interface ILayoutContainer extends IContainable
	{
		function set rect(r:Rectangle):void;
		function get children():Array;
	}
	
}