package no.doomsday.console.text 
{
	import no.doomsday.console.DConsole;
	import flash.text.Font;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TextUtils
	{
		
		public function TextUtils() 
		{
			
		}
		public static function listFonts(c:DConsole):void {
			var fnts:Array = Font.enumerateFonts();
			if (fnts.length < 1) {
				c.print("Only system fonts available");
			}
			for (var i:int = 0; i < fnts.length; i++) 
			{
				c.print("	" + fnts[i].fontName);
			}
		}
		public static function selectWordAtCaretIndex(tf:TextField):void 
		{
			var str:String = tf.text;
			var first:int = str.lastIndexOf(" ", tf.caretIndex)+1;
			var last:int = str.indexOf(" ", first);
			if (last == -1) last = str.length;
			tf.setSelection(first, last);
		}
		public static function getFirstIndexOfWordAtCaretIndex(tf:TextField):int 
		{
			var str:String = tf.text;
			return str.lastIndexOf(" ", tf.caretIndex) + 1;
		}
		
	}

}