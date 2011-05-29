package no.doomsday.dconsole2.core.logmanager 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class DLogFilter
	{
		public var term:String;
		public var tag:String;
		
		public function DLogFilter(term:String = "", tag:String = "") 
		{
			this.term = term;
			this.tag = tag;
		}
		public function get id():String {
			return String(term + tag);
		}
		
	}

}