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
	public class BackendMessageListener implements IMessageListener
	{
		
		public function BackendMessageListener() 
		{
			
		}
		
		/* INTERFACE interpreter.message.IMessageListener */
		private static const INTERPRETER_SUMMARY_FORMAT:String = "\n% statements executed.\n% runtime errors.\n% seconds total execution time.\n";
		private static const COMPILER_SUMMARY_FORMAT:String = "\n% instructions generated.\n% seconds total execution time.\n";
		public function messageReceived(message:Message):void
		{
			var elapsedTime:Number;
			switch(message.getType()) {
				case MessageTypes.INTERPRETER_SUMMARY :
					var execcount:Number = message.getBody()[0];
					var runtimeerrors:Number = message.getBody()[1];
					elapsedTime = message.getBody()[1];
					ConsoleUtil.log(MessageUtil.withFormat(INTERPRETER_SUMMARY_FORMAT,execcount,runtimeerrors,elapsedTime));
				break;
				case MessageTypes.COMPILER_SUMMARY:
					var instructionCount:int = message.getBody()[0];
					elapsedTime = message.getBody()[1];
					ConsoleUtil.log(MessageUtil.withFormat(COMPILER_SUMMARY_FORMAT,instructionCount,elapsedTime));
				break;
			}
		}
		
	}

}