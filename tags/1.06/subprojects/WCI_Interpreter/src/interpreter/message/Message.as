package interpreter.message 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Message
	{
		private var body:Object;
		private var type:uint;
		public function Message(type:uint, body:Object) 
		{
			this.type = type;
			this.body = body;
		}
		public function getBody():Object { return body; };
		public function getType():uint { return type; };
		public function toString():String {
			return "Message: " + type + ": " + body.toString();
		}
		
	}

}