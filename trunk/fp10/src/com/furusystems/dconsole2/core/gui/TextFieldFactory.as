package com.furusystems.dconsole2.core.gui 
{
	import flash.text.TextField;
	import com.furusystems.dconsole2.core.style.GUIUnits;
	import com.furusystems.dconsole2.core.style.TextFormats;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class TextFieldFactory
	{
		public static function getLabel(label:String):TextField {
			var tf:TextField = new TextField();
			tf.defaultTextFormat = TextFormats.consoleTitleFormat;
			tf.text = label;
			tf.height = GUIUnits.SQUARE_UNIT;
			var f:String = tf.defaultTextFormat.font;
			if(f.charAt(0)!="_") tf.embedFonts = true;
			tf.mouseEnabled = true;
			tf.selectable = false;
			return tf;
		}
		
	}

}