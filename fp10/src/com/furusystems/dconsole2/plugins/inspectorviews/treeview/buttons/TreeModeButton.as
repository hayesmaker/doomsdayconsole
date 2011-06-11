package com.furusystems.dconsole2.plugins.inspectorviews.treeview.buttons 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.furusystems.dconsole2.core.gui.AbstractButton;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class TreeModeButton extends AbstractButton
	{
		[Embed(source='../assets/displaylist_icon.png')]
		private static var bitmap:Class;
		private static const ICON:BitmapData = Bitmap(new bitmap()).bitmapData;
		public function TreeModeButton() 
		{
			super();
			setIcon(ICON);
		}
		
	}

}