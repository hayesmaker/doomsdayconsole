package 
{
	import errors.NotImplementedError;
	import flash.display.Sprite;
	import no.doomsday.console.ConsoleUtil;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Main extends Sprite 
	{
		public function Main():void 
		{
			addChild(ConsoleUtil.instance);
			ConsoleUtil.show();
			ConsoleUtil.instance.maximize();
			ConsoleUtil.createCommand("pascalTest", doPascaltest);
		}
		
		private function doPascaltest(operation:String="execute",statement:String = "Hello world",flags:String=""):void
		{
			ConsoleUtil.addSystemMessage("Starting pascal test: " + operation+", " + statement + ", " + flags);
			var p:Pascal = new Pascal(operation, statement, flags);
			ConsoleUtil.addSystemMessage("Done");
		}

		
	}
	
}