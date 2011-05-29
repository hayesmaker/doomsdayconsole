package interpreter.frontend 
{
	import interpreter.frontend.tokentypes.ITokenType;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Token
	{
		protected var type:ITokenType;
		protected var text:String;
		protected var value:Object;
		protected var source:Source;
		protected var lineNum:int;
		protected var position:int;
		public function Token(source:Source) 
		{
			this.source = source;
			this.lineNum = source.getLineNum();
			this.position = source.getPosition();
			extract();
		}
		//Abstract, to be overridden completely
		public function extract():void 	{
			text = String(currentChar());
			value = null;
			nextChar();
		}
		public function currentChar():String {
			return source.currentChar();
		}
		public function nextChar():String {
			return source.nextChar();
		}
		public function peekChar():String {
			return source.peekChar();
		}
		public function getLineNum():int {
			return lineNum;
		}
		
	}

}