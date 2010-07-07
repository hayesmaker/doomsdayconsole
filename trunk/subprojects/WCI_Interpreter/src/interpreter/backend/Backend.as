package interpreter.backend 
{
	import errors.NotImplementedError;
	import interpreter.intermediate.IiCode;
	import interpreter.intermediate.ISymTab;
	import interpreter.message.Message;
	import interpreter.message.IMessageListener;
	import interpreter.message.IMessageProducer;
	import interpreter.message.MessageHandler;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Backend implements IMessageProducer
	{
		protected static var messageHandler:MessageHandler = new MessageHandler();
		protected var symTab:ISymTab;
		protected var iCode:IiCode;
		public function Backend() 
		{
			
		}
		public function process(iCode:IiCode, symTab:ISymTab):void {
			throw new NotImplementedError;
		}
		
		/* INTERFACE interpreter.message.IMessageProducer */
		
		public function addMessageListener(listener:IMessageListener):Boolean
		{
			return messageHandler.addMessageListener(listener);
		}
		
		public function removeMessageListener(listener:IMessageListener):Boolean
		{
			return messageHandler.removeMessageListener(listener);
		}
		
		public function sendMessage(message:Message):void
		{
			return messageHandler.sendMessage(message);
		}
		
	}

}