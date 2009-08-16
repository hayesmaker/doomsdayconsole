package no.doomsday.aronning.debug.console.messages
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Message 
	{
		public var timestamp:String = "";
		public var text:String = "";
		public var type:uint = 0;
		
		public function Message(text:String, timestamp:String, type:uint = 0) 
		{
			this.text = text;
			this.timestamp = timestamp;
			this.type = type;
		}
		
	}
	
}