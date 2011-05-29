package parser.tokenizer
{
	import utils.UIDGen;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class TokenType
	{
		public var id:int = UIDGen.next;
		public var description:String = "";
		public function TokenType(desc:String) 
		{
			description = desc;
		}
		
	}

}