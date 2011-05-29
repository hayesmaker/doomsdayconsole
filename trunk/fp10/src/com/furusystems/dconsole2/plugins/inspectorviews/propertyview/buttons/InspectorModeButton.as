package no.doomsday.dconsole2.plugins.inspectorviews.propertyview.buttons 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import no.doomsday.dconsole2.core.gui.AbstractButton;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class InspectorModeButton extends AbstractButton
	{		
		[Embed(source='../assets/magnifierIcon.png')]
		private static var bitmap:Class;
		private static const ICON:BitmapData = Bitmap(new bitmap()).bitmapData;
		public function InspectorModeButton() 
		{
			super();
			setIcon(ICON);
		}
		
	}

}