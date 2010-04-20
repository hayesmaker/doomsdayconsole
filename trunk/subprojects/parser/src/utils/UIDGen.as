package utils 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class UIDGen
	{
		private static var n:uint = 0;
		public static function get next():uint {
			return ++n;
		}
		public static function set seed(n:Number):void {
			this.n = n;
		}
		
	}

}