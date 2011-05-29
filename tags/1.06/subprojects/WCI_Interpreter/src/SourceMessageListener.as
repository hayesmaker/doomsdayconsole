package  
{
	import interpreter.message.IMessageListener;
	import interpreter.message.Message;
	import interpreter.message.MessageTypes;
	import no.doomsday.console.ConsoleUtil;
	import utils.MessageUtil;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class SourceMessageListener implements IMessageListener
	{
		
		public function SourceMessageListener() 
		{
			
		}
		
		/* INTERFACE interpreter.message.IMessageListener */
		private static const SOURCE_LINE_FORMAT:String = "% \t %";
		public function messageReceived(message:Message):void
		{
			switch(message.getType()) {
				case MessageTypes.SOURCE_LINE :
					var lineNumber:int = message.getBody()[0];
					var lineText:String = message.getBody()[1];
					ConsoleUtil.log(MessageUtil.withFormat(SOURCE_LINE_FORMAT, lineNumber, lineText));
				break;
			}
		}
		
	}

}