package no.doomsday.dconsole2.core.gui.maindisplay.sections 
{
	import flash.geom.Rectangle;
	import no.doomsday.dconsole2.core.inspector.Inspector;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class InspectorSection extends ConsoleViewSection
	{
		
		public var inspector:Inspector;
		public function InspectorSection() 
		{
			inspector = new Inspector(new Rectangle(0, 0, 50, 50));
			addChild(inspector);
		}
		override public function onParentUpdate(allotedRect:Rectangle):void 
		{
			inspector.onParentUpdate(allotedRect);
		}
		
	}

}