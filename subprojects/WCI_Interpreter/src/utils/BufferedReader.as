package utils 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class BufferedReader extends EventDispatcher
	{
		protected var sourceLoader:URLLoader;
		protected var source:String;
		protected var lines:Vector.<String>;
		protected var lastLineRead:String;
		protected var locked:Boolean = false;
		public function BufferedReader(input:String = null) 
		{
			sourceLoader = new URLLoader();
			sourceLoader.addEventListener(Event.COMPLETE, onSourceLoaded);
			if (input != null) {
				loadFromString(input);
			}
		}
		public function loadFromString(str:String):void {
			if (locked) return;
			locked = true;
			source = str;
			parseSource();
		}
		public function loadFromURL(url:String):void {
			if (locked) return;
			locked = true;
			sourceLoader.close();
			sourceLoader.load(new URLRequest(url));
		}
		
		private function onSourceLoaded(e:Event = null):void 
		{
			source = sourceLoader.data;
			parseSource();
		}
		
		private function parseSource():void
		{
			var a:Array = source.split("\r").join("\n").split("\n");
			lines = new Vector.<String>();
			for (var i:int = 0; i < a.length; i++) 
			{
				lines.push(a[i]);
			}
			locked = false;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		public function readLine():String {
			if (lines.length > 0) {
				lastLineRead = lines.shift();
				return lastLineRead;
			}
			return null;
		}
		public function close():void {
			lines = new Vector.<String>();
			source = null;
		}
		
	}

}