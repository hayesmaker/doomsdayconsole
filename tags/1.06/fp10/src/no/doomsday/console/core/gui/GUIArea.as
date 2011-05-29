package no.doomsday.console.core.gui 
{
	import flash.display.Sprite;
	import no.doomsday.console.core.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class GUIArea extends Sprite
	{
		private var console:DConsole;
		public function GUIArea(console:DConsole) 
		{
			//TODO: Not sure we even need this; figured we'd get a dedicated view for any custom GUI widgets/plugins
			this.console = console;
		}
		/**
		 * Called to rescale to stage dimensions
		 */
		public function scale():void {
			graphics.clear();
			//graphics.beginFill(0xFF0000, 1);
			graphics.drawRect(0, 0, stage.stageWidth, 100);
		}
		
	}

}