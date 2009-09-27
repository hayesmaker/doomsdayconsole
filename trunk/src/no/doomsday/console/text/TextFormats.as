﻿package no.doomsday.console.text 
{
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TextFormats
	{
		
		public static const debugTformatInput:TextFormat = new TextFormat("_typewriter", 11, 0xFFD900, null, null, null, null, null, null, 0, 0, 0,0);
		public static const debugTformatOld:TextFormat = new TextFormat("_typewriter", 11, 0xBBBBBB, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatNew:TextFormat = new TextFormat("_typewriter", 11, 0xFFFFFF, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatSystem:TextFormat = new TextFormat("_typewriter", 11, 0x00DD00, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatTimeStamp:TextFormat = new TextFormat("_typewriter", 11, 0xAAAAAA, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatError:TextFormat = new TextFormat("_typewriter", 11, 0xEE0000, null, null, null, null, null, null, 0, 0, 0, 0);
		public static const debugTformatHelp:TextFormat = new TextFormat("_typewriter", 10, 0xbbbbbb, null, null, null, null, null, null, 0, 0, 0, 0);
		public function TextFormats() 
		{
		}
		
	}

}