package parser 
{
	import utils.UIDGen;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TokenTypes
	{
		public static const UNKNOWN:TokenType 				= new TokenType("unknown");
		public static const NUMBER:TokenType 				= new TokenType("number");
		public static const IDENTIFIER:TokenType 			= new TokenType("identifier");
		public static const STRING:TokenType 				= new TokenType("string");
		public static const EQUAL_OP:TokenType 				= new TokenType("equal operator");
		public static const PLUS_OP:TokenType 				= new TokenType("plus operator");
		public static const MINUS_OP:TokenType 				= new TokenType("minus operator");
		public static const MULTIPLY_OP:TokenType 			= new TokenType("multiply operator");
		public static const DIVIDE_OP:TokenType 			= new TokenType("divide operator");
		public static const OPEN_PARENTHESIS:TokenType 		= new TokenType("open parenthesis");
		public static const CLOSE_PARENTHESIS:TokenType 	= new TokenType("close parenthesis");
		public static const OPEN_BRACKET:TokenType 			= new TokenType("open bracket");
		public static const CLOSE_BRACKET:TokenType 		= new TokenType("close bracket");
		public static const OPEN_CURLYBRACE:TokenType 		= new TokenType("open curlybrace");
		public static const CLOSE_CURLYBRACE:TokenType 		= new TokenType("close curlybrace");
		public static const COMMA:TokenType 				= new TokenType("comma");
		public static const PERIOD:TokenType 				= new TokenType("period");
		public static const EXPRESSION:TokenType 			= new TokenType("expression");
		
	}

}