package interpreter.message 
{
	import interpreter.message.IMessageListener;
	import interpreter.message.Message;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MessageHandler
	{
		protected var message:Message;
		protected var listeners:Vector.<IMessageListener> = new Vector.<IMessageListener>();
		public function MessageHandler() 
		{
			
		}
		private function notifyListeners():void {
			for each(var listener:IMessageListener in listeners) {
				listener.messageReceived(message);
			}
		}
		public function getLastMessage():Message {
			return message;
		}
		
		/* INTERFACE interpreter.message.IMessageProducer */
		
		public function addMessageListener(listener:IMessageListener):Boolean
		{
			if (listeners.indexOf(listener) > -1) return false;
			listeners.push(listener);
			return true;
		}
		
		public function removeMessageListener(listener:IMessageListener):Boolean
		{
			if (listeners.indexOf(listener) < 0) return false;
			listeners.splice(listeners.indexOf(listener), 1);
			return true;
		}
		
		public function sendMessage(message:Message):void
		{
			this.message = message;
			notifyListeners();
		}
		
		
	}

}