package parser 
{
	import mx.accessibility.DateChooserAccImpl;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Tokenizer
	{
		private static const NUM_TABLE:String = "0123456789";
		private static const LOWERCASE_TABLE:String = "abcdefghijklmnopqrstuvwxyz";
		private static const OPERATORS_TABLE:String = "+-*/=.";
		private static const STRUCTURE_TABLE:String = "()[]{}";
		private static const SEPARATORS_TABLE:String = " ,";
		private static const QUOTES_TABLE:String = "'" + '"';
		
		//private static var typeTableBuffer:String = "";
		private static var currentType:TokenType = TokenTypes.IDENTIFIER;
		private static var stringBuffer:Vector.<String>;
		private static var out:XML;
		private static var openStack:Vector.<String> = new Vector.<String>();
		public static function tokenize(input:String):XML {
			clearBuffer();
			out = <stream/>;
			if (input.length < 1) return out;
			var split:Array = input.split("");
			split.reverse();
			while (split.length > 0) {
				//left to right, no look forward
				var lookingAt:String = split.pop();
				//var t:String = getTypeTable(lookingAt);
				if (isQuote(lookingAt)) {
					if (openStack.length == 0) {
						currentType = TokenTypes.STRING;
						openStack.push(lookingAt);
					}else if (openStack[openStack.length - 1] == lookingAt) {
						openStack.pop();
						reduce();
					}else {
						currentType = TokenTypes.STRING;
						openStack.push(lookingAt);
					}
					continue;
				}
				if (currentType != TokenTypes.STRING && (isSeparator(lookingAt) || isOperator(lookingAt))) { 
					trace("critical change");
					reduce();
					//We have a critical change in type
					if (!isSeparator(lookingAt)) {
						switch(lookingAt) {
							case "+":
							currentType = TokenTypes.PLUS_OP;
							break;
							case "-":
							currentType = TokenTypes.MINUS_OP;
							break;
							case "/":
							currentType = TokenTypes.DIVIDE_OP;
							break;
							case "*":
							currentType = TokenTypes.MULTIPLY_OP;
							break;
							default:
							currentType = TokenTypes.IDENTIFIER;
						}
						stringBuffer.push(lookingAt);
					}
					reduce();
				}else {
					if (currentType != TokenTypes.STRING && isNumber(lookingAt)) { 
						currentType = TokenTypes.NUMBER;
					}
					stringBuffer.push(lookingAt);
				}
			}
			if (stringBuffer.length > 0) {
				reduce();
			}
			
			return out;
		}
		
		static private function isNumber(input:String):Boolean {
			return NUM_TABLE.indexOf(input) > -1;
		}
		static private function isOperator(input:String):Boolean
		{
			return OPERATORS_TABLE.indexOf(input) > -1;
		}
		static private function isSeparator(input:String):Boolean {
			return SEPARATORS_TABLE.indexOf(input) > -1;
		}
		static private function isQuote(input:String):Boolean {
			return QUOTES_TABLE.indexOf(input) > -1;
		}
		
		static private function getTypeTable(input:String):String
		{
			input = input.toLowerCase();
			if (NUM_TABLE.indexOf(input) > -1) return NUM_TABLE;
			if (LOWERCASE_TABLE.indexOf(input) > -1) return LOWERCASE_TABLE;
			if (OPERATORS_TABLE.indexOf(input) > -1) return OPERATORS_TABLE;
			if (STRUCTURE_TABLE.indexOf(input) > -1) return STRUCTURE_TABLE;
			if (SEPARATORS_TABLE.indexOf(input) > -1) return SEPARATORS_TABLE;
			if (QUOTES_TABLE.indexOf(input) > -1) return QUOTES_TABLE;
			throw new Error("Unrecognized type");
		}
		
		private static function clearBuffer():void
		{
			stringBuffer = new Vector.<String>();
			currentType = TokenTypes.IDENTIFIER;
		}
		/**
		 * Take a data/type pair and create a compatible XML node
		 * @param	data
		 * @param	type
		 * @return
		 */
		private static function makeToken(data:String, type:TokenType):XML {
			trace("Make token", data, type.description);
			var n:XML = <token/>;
			n.@desc = type.description;
			n.@typeID = type.id;
			n.@value = data;
			return n;
		}
		/**
		 * Reduce the current buffer to a token
		 * @param	type
		 * @return
		 */
		private static function reduce():void {
			if (stringBuffer.length < 1) return;
			var t:XML = makeToken(stringBuffer.join(""), currentType);
			out.appendChild(t);
			clearBuffer();
		}
		
	}

}