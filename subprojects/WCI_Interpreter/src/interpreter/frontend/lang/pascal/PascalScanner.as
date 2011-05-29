package interpreter.frontend.lang.pascal 
{
	import interpreter.frontend.EofToken;
	import interpreter.frontend.Scanner;
	import interpreter.frontend.Source;
	import interpreter.frontend.Token;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class PascalScanner extends Scanner
	{
		
		public function PascalScanner(source:Source) 
		{
			super(source);
		}
		override protected function extractToken():Token 
		{
			var token:Token;
			var currentChar:String = currentChar();
			if (currentChar == Source.EOF) {
				token = new EofToken(source);
			}else {
				token = new Token(source);
			}
			return token;
		}
		
	}

}