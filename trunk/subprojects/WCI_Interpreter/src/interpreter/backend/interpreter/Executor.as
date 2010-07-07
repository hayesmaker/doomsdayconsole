package interpreter.backend.interpreter 
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
	public class Executor extends Backend
	{
		
		public function Executor() 
		{
			
		}
		override public function process(iCode:IiCode, symTab:ISymTab):void 
		{
			var startTime:Number = getTimer();
			var elapsedTime:Number = (getTimer() - startTime) / 1000;
			var executionCount:int = 0;
			var runtimeErrors:int = 0;
			sendMessage(new Message(MessageTypes.INTERPRETER_SUMMARY, [executionCount, runtimeErrors, elapsedTime]));
		}
		
	}

}