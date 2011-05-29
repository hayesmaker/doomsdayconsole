package interpreter.frontend 
{
	import interpreter.frontend.lang.pascal.PascalParserTD;
	import interpreter.frontend.lang.pascal.PascalScanner;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class FrontendFactory
	{
		
		public function FrontendFactory() 
		{
			
		}
		public static function createParser(language:String, type:String, source:Source):Parser {
			if (equalsIgnoreCase(language,"pascal")&&equalsIgnoreCase(type,"top-down")) {
				var scanner:Scanner = new PascalScanner(source);
				return new PascalParserTD(scanner);
			}else if (!equalsIgnoreCase("pascal", language)) {
				throw new Error("Invalid language " + language);
			}else {
				throw new Error("Invalid type " + type);
			}
		}
		private static function equalsIgnoreCase(a:String, b:String):Boolean {
			return a.toLowerCase() == b.toLowerCase();
		}
		
	}

}