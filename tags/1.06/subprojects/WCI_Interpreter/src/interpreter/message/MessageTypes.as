package interpreter.message 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MessageTypes
	{
		private static var types:uint = 0;
		public static const SOURCE_LINE:uint = ++types;
		public static const SYNTAX_ERROR:uint = ++types;
		public static const PARSER_SUMMARY:uint = ++types;
		public static const INTERPRETER_SUMMARY:uint = ++types;
		public static const COMPILER_SUMMARY:uint = ++types;
		public static const MISCELLANEOUS:uint = ++types;
		public static const TOKEN:uint = ++types;
		public static const ASSIGN:uint = ++types;
		public static const FETCH:uint = ++types;
		public static const BREAKPOINT:uint = ++types;
		public static const RUNTIME_ERROR:uint = ++types;
		public static const CALL:uint = ++types;
		public static const RETURN:uint = ++types;

		
	}

}