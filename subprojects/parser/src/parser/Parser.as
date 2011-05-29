package parser 
{
	import parser.tokenizer.Token;
	import parser.tokenizer.Tokenizer;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Parser
	{
		
		public function Parser() 
		{
			
		}
		public static function parse(input:String):String {
			var tokens:Vector.<Token> = Tokenizer.tokenize(input);
			var out:String = "";
			for (var i:int = 0; i < tokens.length; i++) 
			{
				var t:Token = tokens[i];
				out += t.toString() + "\n";
			}
			return out;
		}
		
	}

}