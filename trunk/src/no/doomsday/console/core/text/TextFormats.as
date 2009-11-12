package no.doomsday.console.core.text 
{
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class TextFormats
	{
		public static const debugTformatInput:TextFormat = new TextFormat("_typewriter", 11, 0xFFD900, null, null, null, null, null, null, 0, 0, 0,0);
		public static const debugTformatOld:TextFormat = new TextFormat("_typewriter", 11, 0xBBBBBB, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatNew:TextFormat = new TextFormat("_typewriter", 11, 0xFFFFFF, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatSystem:TextFormat = new TextFormat("_typewriter", 11, 0x00DD00, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatTimeStamp:TextFormat = new TextFormat("_typewriter", 11, 0xAAAAAA, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatError:TextFormat = new TextFormat("_typewriter", 11, 0xEE0000, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatHelp:TextFormat = new TextFormat("_typewriter", 10, 0xbbbbbb, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatTrace:TextFormat = new TextFormat("_typewriter", 11, 0x9CB79B, null, null, null, null, null, null, 0, 0, 0, 0);
		
		public static const windowTitleFormat:TextFormat = new TextFormat("_sans", 10, 0xeeeeee, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const windowDefaultFormat:TextFormat = new TextFormat("_sans", 10, 0x111111, null, null, null, null, null, null, 0, 0, 0, 0);
		public function TextFormats() 
		{
		}
		public static function setTheme(input:uint, oldMessage:uint, newMessage:uint, system:uint, timestamp:uint, error:uint, help:uint, trace:uint):void {
			debugTformatInput.color = input;
			debugTformatOld.color = oldMessage;
			debugTformatNew.color = newMessage;
			debugTformatSystem.color = system;
			debugTformatTimeStamp.color = timestamp;
			debugTformatError.color = error;
			debugTformatHelp.color = help;
			debugTformatTrace.color = trace;
		}
		
	}

}