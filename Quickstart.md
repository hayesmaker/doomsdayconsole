## Via ActionScript 3 ##

```
package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import com.furusystems.dconsole2.DConsole;
	
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//add the console instance to the stage or the root layer of your application
			addChild(DConsole.view);
			
			//by default, the console toggles on ctrl+shift+enter, but can also be shown with DConsole.show() and hidden with DConsole.hide()
			DConsole.show();
			
			//to link a command to a method, do as follows
			DConsole.createCommand("drawRect", drawRect);
			
			//now try opening the console. Start typing in "dra" and it should autocomplete to drawRect. 
			//hit tab to jump to the end of the line and enter a few numbers, for instance  'drawRect 30 30 100 200 0xff0000'
			//hit enter to complete your command. voila.
		}
		private function drawRect(x:Number, y:Number, width:Number, height:Number,color:uint):void {
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawRect(x, y, width, height);
		}
		
	}
	
}
```

## Or MXML ##

```
<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" applicationComplete="appCompleteHandler()">
	<mx:Script>
		<![CDATA[
			import com.furusystems.dconsole2.DConsole;
			private function appCompleteHandler():void {				
				
				// Add the console instance to the application's parent (e.g.
				// the SystemManager instance).  We wrap it within a sprite
				// so that addChild() plays nice.
				var c:Sprite = new Sprite();
				c.addChild(DConsole.view);
				parent.addChild(c);
				
				// By default, the console toggles on shift-enter, but it 
				// can also be programatically shown or hidden via the
				// DConsole.show() and DConsole.hide() methods.
				DConsole.show();
				
				// To a link a command to a method, do as follows
				DConsole.createCommand("drawRect", drawRect);
				
				// Now try opening the console.  Start typing in "draw" and
				// it should autocomplete to drawRect.  Hit tab to jump to
				// the end of the line and enter a few numbers, for instance
				//
				// drawRect 30 30 100 200 0xff0000
				//
				// Hit enter to complete your command.  Voila.
			}			
			
			public function drawRect(x:Number, y:Number, width:Number, height:Number, color:uint):void {
				var g:Graphics = canvas.graphics;
				g.clear();
				g.beginFill(color, 1);
				g.drawRect(x, y, width, height);
			}
		]]>
	</mx:Script>
	<mx:Canvas id="canvas" width="100%" height="100%" />
</mx:Application>

```

Try the commands "help" and "commands" to get a look at the built-in functionality, which includes methods for listing available embedded fonts, measuring sizes and distances and the like.

Explore DConsole's static methods to get a feel for how things work.

The api is very verbose with lots of imports. An IDE with good autocomplete is highly recommended.