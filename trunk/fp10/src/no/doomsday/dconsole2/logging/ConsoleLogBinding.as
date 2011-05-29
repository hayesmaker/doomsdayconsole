package no.doomsday.dconsole2.logging 
{
	import com.furusystems.logging.slf4as.bindings.ILogBinding;
	import com.furusystems.logging.slf4as.constants.Levels;
	import no.doomsday.dconsole2.core.output.ConsoleMessageTypes;
	import no.doomsday.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleLogBinding implements ILogBinding
	{
		
		public function ConsoleLogBinding() 
		{
			
		}
		
		/* INTERFACE com.furusystems.logging.slf4as.bindings.ILogBinding */
		
		public function print(owner:Object, level:String, str:String):void 
		{
			if (String(owner) == "[Logging]") owner = DConsole.TAG;
			var l:String = ConsoleMessageTypes.DEBUG;
			switch(Levels.getID(level)) {
				case Levels.ERROR:
				l = ConsoleMessageTypes.ERROR;
				break;
				case Levels.FATAL:
				l = ConsoleMessageTypes.FATAL;
				break;
				case Levels.INFO:
				l = ConsoleMessageTypes.INFO;
				break;
				case Levels.WARN:
				l = ConsoleMessageTypes.WARNING;
				break;
				case Levels.DEBUG:
				default:
				l = ConsoleMessageTypes.DEBUG;
				break;
			}
			DConsole.print(str, l, String(owner));
		}
		
	}

}