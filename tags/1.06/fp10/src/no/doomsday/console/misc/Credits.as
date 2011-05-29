package no.doomsday.console.misc
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class Credits
	{
		public static function getCreditsString():String {
			var credits:String = "Doomsday Console team\n";
			credits += "Project lead\n";
			credits += "	Andreas Rønning (http://www.doomsday.no)\n";
			credits += "Committers\n";
			credits += "	Øyvind Nordhagen (http://www.oyvindnordhagen.com/)\n";
			credits += "	Miha Lunar (http://liquify.eu/)\n";
			credits += "	Jim M. Cheng\n";
			return credits;
		}
		
	}

}