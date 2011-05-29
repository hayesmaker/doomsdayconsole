package no.doomsday.dconsole2.core.style.fonts 
{
	import flash.text.Font;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Fonts
	{
		
		[Embed(source="cft.ttf", fontName="CodingFontTobi", embedAsCFF = "false", unicodeRange="U+0020-U+007E", mimeType="application/x-font-truetype")]
        private static var CodingFontTobi:Class;
		public static const codingFontTobi:Font = new CodingFontTobi();
		
	}

}