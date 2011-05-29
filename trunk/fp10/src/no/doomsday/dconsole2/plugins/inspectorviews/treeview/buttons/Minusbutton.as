package no.doomsday.dconsole2.plugins.inspectorviews.treeview.buttons 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import no.doomsday.dconsole2.core.gui.AbstractButton;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Minusbutton extends AbstractButton
	{
		[Embed(source='../assets/minusbutton.png')]
		private static var BitmapClass:Class;
		private static const ICON:BitmapData = Bitmap(new BitmapClass()).bitmapData;
		public function Minusbutton() 
		{
			super(ICON.width, ICON.height);
			setIcon(ICON);
			active = true;
		}
		
	}

}