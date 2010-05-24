package parser.tokenizer
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class Token
	{
		public var type:TokenType;
		public var value:*;
		public var malFormed:Boolean = false;
		public function Token() 
		{
			
		}
		public function get description():String {
			return type.description;
		}
		public function toString():String {
			return "[Token] " + description + " : " + value;
		}
		
	}

}