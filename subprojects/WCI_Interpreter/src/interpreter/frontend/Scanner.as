package interpreter.frontend 
{
	import errors.NotImplementedError;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Scanner
	{
		protected var source:Source;
		private var _currentToken:Token;
		public function Scanner(source:Source) 
		{
			//Abstract
			this.source = source;
		}
		public function currentToken():Token {
			return _currentToken;
		}
		public function nextToken():Token {
			_currentToken = extractToken();
			return currentToken();
		}
		protected function extractToken():Token {
			throw new NotImplementedError;
		}
		public function currentChar():String {
			return source.currentChar();
		}
		public function nextChar():String {
			return source.nextChar();
		}
		
		
	}

}