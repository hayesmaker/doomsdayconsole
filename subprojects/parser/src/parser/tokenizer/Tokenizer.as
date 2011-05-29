package parser.tokenizer
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Tokenizer
	{
		private static const NUM_TABLE:String = "0123456789.";
		private static const LOWERCASE_TABLE:String = "abcdefghijklmnopqrstuvwxyz";
		private static const OPERATORS_TABLE:String = "+-*/=";
		private static const STRUCTURE_TABLE:String = "()[]{}";
		private static const SEPARATORS_TABLE:String = " ,";
		private static const QUOTES_TABLE:String = "'" + '"';
		
		//private static var typeTableBuffer:String = "";
		private static var currentType:TokenType = TokenTypes.UNKNOWN;
		static private var lastType:TokenType = currentType;
		private static var stringBuffer:Vector.<String>;
		private static var openStack:Vector.<String> = new Vector.<String>();
		private static var out:Vector.<Token>;
		public static function tokenize(input:String):Vector.<Token> {
			clearBuffer();
			out = new Vector.<Token>;
			if (input.length < 1) return out;
			var split:Array = input.split("");
			split.reverse();
			var lastItem:String = "";
			lastType;
			var lookingAt:String = "";
			while (split.length > 0) {
				//left to right, no look forward
				lastItem = lookingAt;
				lookingAt = split.pop();
				if (isQuote(lookingAt)) {
					if (openStack.length == 0) {
						setCurrentType(TokenTypes.STRING);
						openStack.push(lookingAt);
					}else if (openStack[openStack.length - 1] == lookingAt) {
						openStack.pop();
						reduce();
					}else {
						setCurrentType(TokenTypes.STRING);
						openStack.push(lookingAt);
					}
					continue;
				}
				if (currentType == TokenTypes.STRING) {
					//If we're currently a string, simply push to buffer
					stringBuffer.push(lookingAt);
				}else if (isSeparator(lookingAt) || isOperator(lookingAt) || isStructure(lookingAt)) { 
					//if we're currently not a string, and the current symbol is an operator or a separator...
					reduce(); //reduce the current buffer
					if (!isSeparator(lookingAt)) { //simply ignore all separators
						switch(lookingAt) {
							case "+":
							setCurrentType(TokenTypes.PLUS_OP);
							break;
							case "-":
							setCurrentType(TokenTypes.MINUS_OP);
							break;
							case "/":
							setCurrentType(TokenTypes.DIVIDE_OP);
							break;
							case "*":
							setCurrentType(TokenTypes.MULTIPLY_OP);
							break;
							case "=":
							setCurrentType(TokenTypes.EQUAL_OP);
							break;
							case "(":
							setCurrentType(TokenTypes.OPEN_PARENTHESIS);
							break;
							case ")":
							setCurrentType(TokenTypes.CLOSE_PARENTHESIS);
							break;
							case "[":
							setCurrentType(TokenTypes.OPEN_BRACKET);
							break;
							case "]":
							setCurrentType(TokenTypes.CLOSE_BRACKET);
							break;
							case "{":
							setCurrentType(TokenTypes.OPEN_CURLYBRACE);
							break;
							case "}":
							setCurrentType(TokenTypes.CLOSE_CURLYBRACE);
							break;
							default:
							setCurrentType(TokenTypes.UNKNOWN);
						}
						stringBuffer.push(lookingAt);
					}
					reduce(); //the current buffer should only contain an operator or be empty, so reduce
				}else {
					//we are probably an identifier or a number..
					//assuming this is the first pass after a buffer clear, check the type
					if (isNumber(lookingAt)&&currentType!=TokenTypes.IDENTIFIER){
						setCurrentType(TokenTypes.NUMBER);
					}else if (getTypeTable(lookingAt) == LOWERCASE_TABLE) {
						setCurrentType(TokenTypes.IDENTIFIER);
					}
					stringBuffer.push(lookingAt);
				}
			}
			if (stringBuffer.length > 0) {
				reduce();
			}
			return out;
		}
		static private function setCurrentType(t:TokenType):void {
			lastType = currentType;
			currentType = t;
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
		static private function isStructure(input:String):Boolean {
			return STRUCTURE_TABLE.indexOf(input) > -1;
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
			setCurrentType(TokenTypes.UNKNOWN);
		}
		private static function makeTokenObject(data:String, type:TokenType):Token {
			var malFormed:Boolean = false;
			if (type == TokenTypes.IDENTIFIER) {
				if (isNumber(data.charAt(0)))
				malFormed = true;
			}
			var t:Token = new Token();
			if (malFormed) t.malFormed = malFormed;
			t.type = type;
			t.value = data;
			return t;
		}
		/**
		 * Reduce the current buffer to a token
		 * @param	type
		 * @return
		 */
		private static function reduce():void {
			if (stringBuffer.length < 1) return;
			try{
				//var t:XML = makeTokenNode(stringBuffer.join(""), currentType);
				//out.appendChild(t);
				var t:Token = makeTokenObject(stringBuffer.join(""), currentType);
				out.push(t);
			}catch (e:Error) {
				
			}
			clearBuffer();
		}
		
	}

}