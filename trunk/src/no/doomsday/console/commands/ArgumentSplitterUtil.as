package no.doomsday.console.commands
{
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ArgumentSplitterUtil
	{
		private static const stringOpener1:int = "'".charCodeAt(0);
		private static const stringOpener2:int = '"'.charCodeAt(0);
		private static const objectOpener:int = "{".charCodeAt(0);
		private static const objectCloser:int = "}".charCodeAt(0);
		private static const arrayOpener:int = "[".charCodeAt(0);
		private static const arrayCloser:int = "]".charCodeAt(0);
		private static const space:int = " ".charCodeAt(0);
		
		public static function slice(a:String):Array {
			var position:int = 0;
			
			while (position < a.length) {
				position++;
				var char:int = a.charCodeAt(position);
				switch(char) {
					case space:
					var sa:String = a.substring(0, position);
					var sb:String = a.substring(position+1);
					var ar:Array = [sa, sb];
					a = ar.join("|");
					break;
					case stringOpener1:
					case stringOpener2:
					position = findString(a, position);
					break;
					case objectOpener:
					position = findObject(a, position);
					break;
					case arrayOpener:
					position = findArray(a, position);
					break;
				}
			}
			var out:Array = a.split("|");
			//TODO: embarassing string cleanup, need to mend this
			var str:String = "";
			for (var i:int = 0; i < out.length; i++) 
			{
				str = out[i];
				if (str.charCodeAt(0) == stringOpener1||str.charCodeAt(0) == stringOpener2) {
					out[i] = str.substring(1, str.length - 1);
				}
			}
			return out;
		}
		private static function findObject(input:String,start:int):int {
			//var t:Token = new Token();
			//t.type = "Object";
			var score:int = 0;
			//var opener:int = input.charCodeAt(start);
			var l:int = input.length;
			var char:int;
			var end:int;
			for (var i:int = start; i < l; i++) 
			{
				char = input.charCodeAt(i);
				if (char == objectOpener) {
					score++;
				}else if (char == objectCloser) {
					score--;
					if (score <= 0) {
						end = i;
						//t.contents = input.slice(start, i+1);
						break;
					}
				}
			}
			if (score > 0) {
				throw(new ArgumentError("Object argument not properly terminated"));
			}
			//t.start = start+1;
			return end;
		}
		private static function findArray(input:String, start:int):int {
			//var t:Token = new Token();
			//t.type = "Array";
			var score:int = 0;
			//var opener:int = input.charCodeAt(start);
			var l:int = input.length;
			var char:int;
			var end:int;
			for (var i:int = start; i < l; i++) 
			{
				char = input.charCodeAt(i);
				if (char == arrayOpener) {
					score++;
				}else if (char == arrayCloser) {
					score--;
					if (score <= 0) {
						end = i;
						//t.contents = input.slice(start, i+1);
						break;
					}
				}
			}
			if (score > 0) {
				throw(new ArgumentError("Array argument not properly terminated"));
			}
			return end;
		}
		private static function findString(input:String, start:int):int {
			var out:int = input.indexOf(input.charAt(start), start + 1);
			if (out < start) throw(new ArgumentError("String argument not properly terminated"));
			return out;
		}
		private static function findCommand(input:String):int {
			//var t:Token = new Token();
			//t.type = "Command";
			//t.contents = input.split(" ").shift();
			//t.start = 0;
			//t.end = t.contents.length;
			return input.split(" ").shift().length;
		}
		
	}

}