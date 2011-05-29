package interpreter.frontend 
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class EofToken extends Token
	{
		
		public function EofToken(source:Source) 
		{
			super(source);
		}
		override public function extract():void 
		{
			//do nothing
		}
		
	}

}