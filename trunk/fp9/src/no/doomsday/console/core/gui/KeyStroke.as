package no.doomsday.console.core.gui 
{
	import flash.events.KeyboardEvent;
	import no.doomsday.console.core.input.KeyboardManager;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class KeyStroke
	{
		public var keyCodes:Array = [];
		public var charCodes:Array = [];
		private var manager:KeyboardManager;
		public function KeyStroke(manager:KeyboardManager, keyCodes:Array = null, charCodes:Array = null ) 
		{
			if (!keyCodes) keyCodes = [];
			if (!charCodes) charCodes = [];
			this.manager = manager;
			this.keyCodes = keyCodes;
			this.charCodes = charCodes;
		}
		public function get valid():Boolean {
			var valid:Boolean = true;
			for (var i:int = keyCodes.length; i--; ) 
			{
				if (!manager.keycodedict[keyCodes[i]]) {
					valid = false;
					break;
				}
			}
			for (i = charCodes.length; i--; ) 
			{
				if (!manager.charcodedict[charCodes[i]]) {
					valid = false;
					break;
				}
			}
			return valid;
		}
		
	}

}