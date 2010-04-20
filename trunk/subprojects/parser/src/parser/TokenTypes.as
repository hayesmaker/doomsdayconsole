package parser 
{
	import utils.UIDGen;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TokenTypes
	{
		public static const NUMBER:uint 				= UIDGen.next;
		public static const IDENTIFIER:uint 			= UIDGen.next;
		public static const STRING:uint 				= UIDGen.next;
		public static const EQUAL_OP:uint 				= UIDGen.next;
		public static const PLUS_OP:uint 				= UIDGen.next;
		public static const MINUS_OP:uint 				= UIDGen.next;
		public static const MULTIPLY_OP:uint 			= UIDGen.next;
		public static const DIVIDE_OP:uint 				= UIDGen.next;
		public static const OPEN_PARENTHESIS:uint 		= UIDGen.next;
		public static const CLOSE_PARENTHESIS:uint 		= UIDGen.next;
		public static const OPEN_BRACKET:uint 			= UIDGen.next;
		public static const CLOSE_BRACKET:uint 			= UIDGen.next;
		public static const OPEN_CURLYBRACE:uint 		= UIDGen.next;
		public static const CLOSE_CURLYBRACE:uint 		= UIDGen.next;
		public static const COMMA:uint 					= UIDGen.next;
		public static const PERIOD:uint 				= UIDGen.next;
		
	}

}