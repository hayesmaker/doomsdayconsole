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
	public class ParserMessageListener implements IMessageListener
	{
		
		public function ParserMessageListener() 
		{
			
		}
		
		/* INTERFACE interpreter.message.IMessageListener */
	
		private static const PARSER_SUMMARY_FORMAT:String = "\n% source lines. " + "\n% syntax errors." + "\n% seconds total parsing time.\n";
		public function messageReceived(message:Message):void
		{
			switch(message.getType()) {
				case MessageTypes.PARSER_SUMMARY:
					var lineNumber:Number = message.getBody()[0];
					var errorcount:Number = message.getBody()[1];
					var elapsedtime:Number= message.getBody()[2];
					ConsoleUtil.log(MessageUtil.withFormat(PARSER_SUMMARY_FORMAT, lineNumber, errorcount, elapsedtime ));
				break;
			}
		}
		
	}

}