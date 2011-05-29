package interpreter.frontend 
{
	import interpreter.message.IMessageListener;
	import interpreter.message.IMessageProducer;
	import interpreter.message.Message;
	import interpreter.message.MessageHandler;
	import interpreter.message.MessageTypes;
	import utils.BufferedReader;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Source implements IMessageProducer
	{
		public static const EOL:String = "\n";
		public static const EOF:String = String.fromCharCode(0);
		
		protected static var messageHandler:MessageHandler = new MessageHandler();
				
		private var reader:BufferedReader;
		private var line:String;
		private var lineNum:int;
		private var currentPos:int;
		public function Source(reader:BufferedReader) 
		{
			//Abstract
			this.lineNum = 0;
			this.currentPos = -2;
			this.reader = reader;
		}
		public function currentChar():String {
			//first run?
			if (currentPos == -2) {
				readLine();
				return nextChar();
			//at end of file?
			}else if (line == null) {
				return EOF;
			//at end of line?
			}else if ((currentPos ==-1) || (currentPos==line.length)){
				return EOL;
			//Need to read the next line?
			}else if (currentPos > line.length) {
				readLine();
				return nextChar();
			//Return the char at current position
			}else {
				return line.charAt(currentPos);
			}
		}
		public function nextChar():String {
			++currentPos;
			return currentChar();
		}
		public function peekChar():String {
			currentChar();
			if (line == null) {
				return EOF;
			}
			var nextPos:int = currentPos + 1;
			return nextPos < line.length?line.charAt(nextPos):EOL;
		}
		private function readLine():void {
			line = reader.readLine();
			currentPos = 0; //??
			//currentPos = -1;
			if (line != null) {
				trace(line);
				++lineNum;
				sendMessage(new Message(MessageTypes.SOURCE_LINE, [lineNum, line] ));
			}
			
		}
		public function close():void {
			if (reader != null) {
				reader.close();
			}
		}
		public function getLineNum():int {
			return lineNum;
		}
		public function getPosition():int {
			return currentPos;
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