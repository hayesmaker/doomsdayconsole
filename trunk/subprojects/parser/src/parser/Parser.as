package parser 
{
	import flash.utils.getTimer;
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
			var out:String = Tokenizer.tokenize(input);
			return out;
		}
		
	}

}