package interpreter.frontend.lang.pascal 
{
	import flash.utils.getTimer;
	import interpreter.frontend.EofToken;
	import interpreter.frontend.Parser;
	import interpreter.frontend.Scanner;
	import interpreter.frontend.Token;
	import interpreter.message.Message;
	import interpreter.message.MessageTypes;

	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class PascalParserTD extends Parser
	{
		
		public function PascalParserTD(scanner:Scanner) 
		{
			super(scanner);
		}
		override public function parse():void 
		{
			var token:Token;
			var startTime:Number = getTimer();
			while (!((token = nextToken()) is EofToken)) {
				
			}
			var elapsedTime:Number = (getTimer() - startTime) / 1000;
			sendMessage(new Message(MessageTypes.PARSER_SUMMARY, [token.getLineNum(), getErrorCount(), elapsedTime]));
			
		}
		override public function getErrorCount():int 
		{
			return 0;
		}
		
	}

}