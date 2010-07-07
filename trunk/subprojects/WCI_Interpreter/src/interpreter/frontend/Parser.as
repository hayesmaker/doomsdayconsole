package interpreter.frontend 
{
	import errors.NotImplementedError;
	import interpreter.intermediate.IiCode;
	import interpreter.intermediate.ISymTab;
	import interpreter.message.IMessageListener;
	import interpreter.message.IMessageProducer;
	import interpreter.message.Message;
	import interpreter.message.MessageHandler;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Parser implements IMessageProducer
	{
		protected var iCode:IiCode;
		protected static var symTab:ISymTab = null;
		protected static var messageHandler:MessageHandler = new MessageHandler();
		protected var scanner:Scanner;
		public function Parser(scanner:Scanner) 
		{
			//Abstract
			this.scanner = scanner;
			this.iCode = null;
		}
		public function parse():void {
			throw new NotImplementedError;
		}
		public function getErrorCount():int {
			throw new NotImplementedError;
		}
		public function currentToken():Token {
			return scanner.currentToken();
		}
		public function nextToken():Token {
			return scanner.nextToken();
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
		public function getICode():IiCode {
			return iCode;
		}
		public function getSymtab():ISymTab {
			return symTab;
		}
		
	}

}