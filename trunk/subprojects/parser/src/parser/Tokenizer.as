package parser 
{
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
		private static var typeTableBuffer:String = "";
		private static var currentType:String = "";
		private static var stringBuffer:Vector.<String>;
		private static var out:XML;
		public static function tokenize(input:String):XML {
			clearBuffer();
			out = <stream/>;
			var split:Array = input.split("");
			split.reverse();
			var newToken:XML;
			while (split.length > 0) {
				//left to right, no look forward
				var lookingAt:String = split.pop();
				var t:String = getTypeTable(lookingAt);
				if (t != typeTableBuffer) {
					if (stringBuffer.length > 0) {
						newToken = reduce();
						if(newToken.name()!="separator") out.appendChild(newToken);
					}
					typeTableBuffer = t;
				}
				stringBuffer.push(lookingAt);
			}
			if (stringBuffer.length > 0) {
				newToken = reduce();
				if(newToken.name()!="separator") out.appendChild(newToken);
			}
			
			return out;
		}
		
		static private function getTypeTable(input:String):String
		{
			input = input.toLowerCase();
			trace("get type table for: " + input);
			if (NUM_TABLE.indexOf(input) > -1) return NUM_TABLE;
			if (LOWERCASE_TABLE.indexOf(input) > -1) return LOWERCASE_TABLE;
			if (OPERATORS_TABLE.indexOf(input) > -1) return OPERATORS_TABLE;
			if (STRUCTURE_TABLE.indexOf(input) > -1) return STRUCTURE_TABLE;
			if (SEPARATORS_TABLE.indexOf(input) > -1) return SEPARATORS_TABLE;
			throw new Error("Unrecognized type");
		}
		
		private static function clearBuffer():void
		{
			stringBuffer = new Vector.<String>();
		}
		/**
		 * Take a data/type pair and create a compatible XML node
		 * @param	data
		 * @param	type
		 * @return
		 */
		private static function makeToken(data:String, type:String):XML {
			var n:XML = <{type}>{data}</{type}>;
			trace("generated token: " + n);
			return n;
		}
		/**
		 * Reduce the current buffer to a token
		 * @param	type
		 * @return
		 */
		private static function reduce():XML {
			switch(typeTableBuffer) {
				case NUM_TABLE:
				currentType = "number";
				break;
				case STRUCTURE_TABLE:
				currentType = "structure";
				break;
				case OPERATORS_TABLE:
				currentType = "operator";
				break;
				case LOWERCASE_TABLE:
				currentType = "text";
				break;
				case SEPARATORS_TABLE: 
				currentType = "separator";
				break;
			}
			var t:XML = makeToken(stringBuffer.join(""), currentType);
			clearBuffer();
			return t;
		}
		
	}

}