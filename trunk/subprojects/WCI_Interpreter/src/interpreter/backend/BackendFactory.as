package interpreter.backend 
{
	import interpreter.backend.compiler.CodeGenerator;
	import interpreter.backend.interpreter.Executor;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class BackendFactory
	{
		
		public function BackendFactory() 
		{
			
		}
		public static function createBackend(operation:String):Backend {
			if (equalsIgnoreCase(operation, "compile")) {
				return new CodeGenerator();
			}else if (equalsIgnoreCase(operation, "execute")) {
				return new Executor();
			}
			throw new Error("Invalid operation " + operation);
		}
		private static function equalsIgnoreCase(a:String, b:String):Boolean {
			return a.toLowerCase() == b.toLowerCase();
		}
		
	}

}