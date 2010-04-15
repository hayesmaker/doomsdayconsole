package no.doomsday.console.core 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	import no.doomsday.console.ConsoleUtil;
	import no.doomsday.console.core.AbstractConsole;
	import no.doomsday.console.core.commands.ConsoleCommand;
	import no.doomsday.console.core.errors.NotImplementedError;
	import no.doomsday.console.core.input.KeyBindings;
	import no.doomsday.console.core.input.KeyboardManager;
	import no.doomsday.console.core.messages.Message;
	import no.doomsday.console.core.messages.MessageTypes;

	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class AbstractConsole extends DSprite
	{
		protected static const VERSION:String = "FP10 1.061a";
		protected var keystroke:uint = KeyBindings.ENTER;
		protected var modifier:uint = KeyBindings.ALT_SHIFT;
		
		public function AbstractConsole() 
		{
			KeyboardManager.addShorcut(keystroke, modifier, toggleDisplay); //  [ALT+SHIFT, ENTER]); //default keystroke
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			KeyboardManager.instance.setup(stage); //Setup keyboard listeners
		}
		
		/* INTERFACE no.doomsday.console.core.interfaces.IConsole */
		
		public function show():void
		{
			throw new NotImplementedError();
		}
		
		public function hide():void
		{
			throw new NotImplementedError();
		}
		
		public function setRepeatFilter(filter:int):void
		{
			throw new NotImplementedError();
		}
		
		public function toggleStats(e:Event = null):void
		{
			throw new NotImplementedError();
		}
		
		public function routeToJS():void
		{
			throw new NotImplementedError();
		}
		
		public function alertErrors():void
		{
			throw new NotImplementedError();
		}
		
		public function screenshot(e:Event = null):void
		{
			throw new NotImplementedError();
		}
		
		public function addCommand(command:ConsoleCommand):void
		{
			throw new NotImplementedError();
		}
		
		public function print(str:String, type:uint = MessageTypes.OUTPUT):void
		{
			throw new NotImplementedError();
		}
		
		public function clear():void
		{
			throw new NotImplementedError();
		}
		
		public function saveLog(e:Event = null):void
		{
			throw new NotImplementedError();
		}
		
		public function setPassword(pwd:String):void
		{
			throw new NotImplementedError();
		}
		
		public function runBatch(batch:String):Boolean
		{
			throw new NotImplementedError();
		}
		
		public function runBatchFromUrl(url:String):void
		{			
			throw new NotImplementedError();
		}
		
		public function maximize():void
		{
			throw new NotImplementedError();
		}
		
		public function minimize():void
		{
			throw new NotImplementedError();
		}
		
		public function onEvent(e:Event):void
		{
			throw new NotImplementedError();
		}
		
		public function trace(...args:Array):void
		{
			throw new NotImplementedError();
		}
		
		public function log(...args:Array):void
		{
			throw new NotImplementedError();
		}
		
		public function dock(value:String):void
		{
			throw new NotImplementedError();
		}
		
		public function setChromeTheme(backgroundColor:uint = 0, backgroundAlpha:Number = 0.8, borderColor:uint = 0x333333, inputBackgroundColor:uint = 0, helpBackgroundColor:uint = 0x222222):void
		{
			throw new NotImplementedError();
		}
		
		public function setTextTheme(input:uint = 0xFFD900, oldMessage:uint = 0xBBBBBB, newMessage:uint = 0xFFFFFF, system:uint = 0x00DD00, timestamp:uint = 0xAAAAAA, error:uint = 0xEE0000, help:uint = 0xbbbbbb, trace:uint = 0x9CB79B, event:uint = 0x009900, warning:uint = 0xFFD900):void
		{
			throw new NotImplementedError();
		}
		public function getManagerRefs():Array
		{
			throw new NotImplementedError();
		}
		public function get pluginContainer():DisplayObjectContainer {
			throw new NotImplementedError();
		}
		
		public function toggleDisplay(e:Event = null):void
		{
			throw new NotImplementedError();
		}
		
		/**
		 * Change keyboard shortcut
		 */ 
		public function changeKeyboardShortcut(keystroke:uint, modifier:uint):void {
			KeyboardManager.addShorcut(keystroke, modifier, this.toggleDisplay, null, true);
		}
	}

}