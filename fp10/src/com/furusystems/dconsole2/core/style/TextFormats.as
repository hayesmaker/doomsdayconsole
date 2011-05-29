package com.furusystems.dconsole2.core.style 
{
	import flash.text.TextFormat;
	import com.furusystems.dconsole2.core.style.fonts.Fonts;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class TextFormats
	{
		public static const OUTPUT_SIZE:Number = 11;
		public static const GUI_SIZE:Number = 16;
		public static const OUTPUT_LEADING:Number = 0;
		//public static const OUTPUT_FONT:String = Fonts.codingFontTobi.fontName;
		public static const OUTPUT_FONT:String = "_typewriter";
		public static const GUI_FONT:String = Fonts.codingFontTobi.fontName;
		public static const INPUT_FONT:String = "_typewriter";
		//public static const INPUT_FONT:String = Fonts.codingFontTobi.fontName;
		public static const INPUT_SIZE:Number = 11;
		
		public static const inputTformat:TextFormat = 			new TextFormat(INPUT_FONT, 		INPUT_SIZE, 	Colors.INPUT_FG, 			null, null, null, null, null, null, 0, 0, 0, 0);
		public static const helpTformat:TextFormat = 			new TextFormat(INPUT_FONT, 		INPUT_SIZE, 	Colors.ASSISTANT_FG, 		null, null, null, null, null, null, 0, 0, 0, 0);
		
		public static const outputTformatUser:TextFormat = 		new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE,	BaseColors.GRAY,			null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatLineNo:TextFormat = 	new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE,	BaseColors.GRAY,			null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatOld:TextFormat = 		new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE,	BaseColors.LIGHT_GRAY,		null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatHidden:TextFormat = 	new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE,	BaseColors.BLACK,			null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatTag:TextFormat = 		new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE,	BaseColors.LIGHT_GRAY,		null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatNew:TextFormat = 		new TextFormat(OUTPUT_FONT,		OUTPUT_SIZE,	BaseColors.WHITE, 			null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const hoorayFormat:TextFormat = 			new TextFormat(OUTPUT_FONT,		OUTPUT_SIZE,	BaseColors.GREEN, 			null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatSystem:TextFormat = 	new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE, 	BaseColors.DARK_GREEN, 		null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatTimeStamp:TextFormat = new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE, 	BaseColors.DARK_GRAY, 		null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatDebug:TextFormat = 	new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE, 	BaseColors.WHITE, 			null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatWarning:TextFormat = 	new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE, 	BaseColors.WARNING_ORANGE, 	null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatError:TextFormat = 	new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE, 	BaseColors.DARK_RED, 		null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		public static const outputTformatFatal:TextFormat = 	new TextFormat(OUTPUT_FONT, 	OUTPUT_SIZE, 	BaseColors.PINK, 			null, null, null, null, null, null, 0, 0, 0, OUTPUT_LEADING);
		//TODO: Running out of colors here. Need to take another gander at these	
		public static const consoleTitleFormat:TextFormat = 	new TextFormat(GUI_FONT, 	GUI_SIZE, 	Colors.HEADER_FG, 			null, null, null, null, null, null, 0, 0, 0, 0);
		public static const windowDefaultFormat:TextFormat = 	new TextFormat(GUI_FONT, 	GUI_SIZE, 	BaseColors.BLACK, 			null, null, null, null, null, null, 0, 0, 0, 0);
		/**
		 * Returns a textformat copy with inverted color
		 * @param	tformat
		 * @return
		 */
		public static function getInverse(tformat:TextFormat):TextFormat {
			var newFormat:TextFormat = new TextFormat(tformat.font, tformat.size, tformat.color, tformat.bold, tformat.italic, tformat.underline, tformat.url, tformat.target, tformat.align, tformat.leftMargin, tformat.rightMargin, tformat.indent, tformat.leading);
			newFormat.color = BaseColors.WHITE - uint(tformat.color);
			return newFormat;
		}
		
	}

}