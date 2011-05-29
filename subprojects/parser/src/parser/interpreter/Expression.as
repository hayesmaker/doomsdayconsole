package parser.interpreter
{
	import parser.tokenizer.Token;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Expression
	{
		
		private var _tokens:Vector.<Token>;
		private var _value:* = null;
		/**
		 * Encapsulates tokens representative of a complete expression
		 * @param	tokens
		 */
		public function Expression(tokens:Vector.<Token>) 
		{
			_tokens = tokens;
		}
		
		public function get tokens():Vector.<Token> { return _tokens; }
		
		public function get value():* { return _value; }
		
		public function set value(value:*):void 
		{
			_value = value;
		}
		
	}

}