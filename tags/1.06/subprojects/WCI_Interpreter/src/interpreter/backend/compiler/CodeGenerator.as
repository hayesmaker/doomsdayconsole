package interpreter.backend.compiler 
{
	import flash.utils.getTimer;
	import interpreter.backend.Backend;
	import interpreter.intermediate.IiCode;
	import interpreter.intermediate.ISymTab;
	import interpreter.message.Message;
	import interpreter.message.MessageTypes;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class CodeGenerator extends Backend
	{
		
		public function CodeGenerator() 
		{
			
		}
		override public function process(iCode:IiCode, symTab:ISymTab):void 
		{
			var startTime:Number = getTimer();
			var elapsedTime:Number = (getTimer() - startTime) / 1000;
			var instructionCount:int = 0;
			sendMessage(new Message(MessageTypes.COMPILER_SUMMARY, [instructionCount, elapsedTime]));
		}
		
	}

}