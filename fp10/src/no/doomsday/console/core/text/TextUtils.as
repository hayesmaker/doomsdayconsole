package no.doomsday.console.core.text 
{
	import flash.text.Font;
	import flash.text.TextField;
	
	import no.doomsday.console.core.DConsole;
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
		public static function getNextSpaceAfterCaret(tf:TextField):int {
			var str:String = tf.text;
			var first:int = str.lastIndexOf(" ", tf.caretIndex)+1;
			var last:int = str.indexOf(" ", first);
			if (last < 0) last = tf.text.length;
			return last;
		}
		public static function selectWordAtCaretIndex(tf:TextField):void 
		{
			var str:String = tf.text;
			var first:int = str.lastIndexOf(" ", tf.caretIndex)+1;
			var last:int = str.indexOf(" ", first);
			if (last == -1) last = str.length;
			tf.setSelection(first, last);
		}
		public static function getWordAtCaretIndex(tf:TextField):String {
			return getWordAtIndex(tf, tf.caretIndex);
		}
		public static function getWordAtIndex(tf:TextField,index:int):String {
			var str:String = tf.text;
			var first:int = str.lastIndexOf(" ", index)+1;
			var last:int = str.indexOf(" ", first);
			if (last == -1) {
				last = str.length;
			}
			return str.slice(first, last);
		}
		public static function getFirstIndexOfWordAtCaretIndex(tf:TextField):int 
		{
			var str:String = tf.text;
			return str.lastIndexOf(" ", tf.caretIndex) + 1;
		}
		
		public static function stripWhitespace(str:String):String {
			while (str.charAt(str.length - 1) == " ") 
			{
				str = str.substr(0, str.length - 1);
			}
			return str;
		}
		public static function parseForSecondElement(str:String):String {
			var split:Array = str.split(" ");
			if (split.length > 1) {
				return split[1];
			}
			return "";
		}
		
		/**
		 * Trim 
		 *	- http://blog.stevenlevithan.com/archives/faster-trim-javascript
		 * 
		 * @param str 	The string to trim.
		 * 
		 * @return
		 * 	Returns the trimmed str value with whitespace removed at the start and end of the string. 
		 */
		public static function trim(str:String):String {
			str = str.replace(/^\s\s*/, '');
			var ws:RegExp = /\s/,i:int = str.length;
			while (ws.test(str.charAt(--i))){};
			return str.slice(0, i + 1);
		}

		
	}

}