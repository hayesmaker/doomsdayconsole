package parser.interpreter
{
	import parser.tokenizer.Token;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Interpreter
	{
		public static const instance:Interpreter = new Interpreter();
		public var testString:String = "test string";
		public var testNumber:Number = 10;
		private var _expressionBuffer:Vector.<Expression>;
		private var _tokenBuffer:Vector.<Token>;
	
		public function execute(tokens:Vector.<Token>):String {
			clearBuffers();
			var result:String = "";
			//from left to right, group tokens into expressions by structure tokens (braces)
			/*var e:Expression;
			for (var i:int = 0; i < tokens.length; i++) 
			{
				var t:Token = tokens[i];
				switch(t.type) {
					case TokenTypes.OPEN_BRACKET:
					case TokenTypes.OPEN_CURLYBRACE:
					case TokenTypes.OPEN_PARENTHESIS:
					break;
					case TokenTypes.CLOSE_BRACKET:
					case TokenTypes.CLOSE_CURLYBRACE:
					case TokenTypes.CLOSE_PARENTHESIS:
					break;
					default:
					_tokenBuffer.push(t);
				}
			}
			reduceTokenBuffer();
			for (i = 0; i < _expressionBuffer.length; i++) 
			{
				e = _expressionBuffer[i];
			}*/
			return result;
		}
		protected function clearBuffers():void {
			clearTokenBuffer();
			clearExpressionBuffer();
		}
		protected function clearTokenBuffer():void {
			_tokenBuffer = new Vector.<Token>();
		}
		protected function clearExpressionBuffer():void {
			_expressionBuffer = new Vector.<Expression>();
		}
		protected function reduceTokenBuffer():void {
			var e:Expression = new Expression(_tokenBuffer.concat());
			_expressionBuffer.push(e);
			e.value = doExpression(e);
			
			clearTokenBuffer();
		}
		protected function doExpression(e:Expression):* {
			return "";
		}
		
	}

}