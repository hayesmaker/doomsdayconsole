package no.doomsday.console.core.input
{
	/**
	 * Keyboardshortcut
	 * 	Wrapper class for a keyboard shortcut used by the KeyboardManager class only.
	 */ 
	public final class KeyboardShortcut
	{
		public var keystroke:uint;
		public var modifier:uint;
		public var callback:Function;
		public var released:Boolean = true;
		public function KeyboardShortcut(keystroke:uint, modifier:uint, callback:Function)
		{
			this.keystroke = keystroke;
			this.modifier = modifier;
			this.callback = callback;
		}
	}
}