package no.doomsday.console.core.input
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	/**
	 * Maintains a dictionary of key up/down states
	 * @author Andreas Rønning
	 */
	public class KeyboardManager extends EventDispatcher
	{
		private static var INSTANCE:KeyboardManager;
		/**
		 * Gets a singleton instance of the input manager
		 * @return
		 */
		public static function get instance():KeyboardManager {
			if (!INSTANCE) {
				INSTANCE = new KeyboardManager();
			}
			return INSTANCE;
		}
		private var keyboardSource:* = null;
		public var keycodedict:Dictionary;
		public var charcodedict:Dictionary;
		
		/**
		 * Start tracking keyboard events
		 * If already tracking, previous event listeners will be removed
		 * @param	eventSource
		 * The object whose events to respond to (typically stage)
		 */
		public function setup(eventSource:InteractiveObject):void {
			try {
				shutdown();
			}catch (e:Error)
			{
				
			}
			keycodedict = new Dictionary(false);
			charcodedict = new Dictionary(false);
			keyboardSource = eventSource;
			eventSource.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, Number.POSITIVE_INFINITY, true);
			eventSource.addEventListener(KeyboardEvent.KEY_UP, onKeyUp,false,Number.POSITIVE_INFINITY,true);
		}
		/**
		 * Stop tracking keyboard events
		 */
		public function shutdown():void {
			keyboardSource.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			keyboardSource.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			keyboardSource = null;
			keycodedict = new Dictionary(false);
			charcodedict = new Dictionary(false);
		}
		public function get isTracking():Boolean {
			if (keyboardSource) {
				return true;
			}
			return false;
		}
		private function onKeyUp(e:KeyboardEvent):void 
		{
			keycodedict[e.keyCode] = false;
			charcodedict[e.charCode] = false;
		}
		private function onKeyDown(e:KeyboardEvent):void 
		{
			keycodedict[e.keyCode] = true;
			charcodedict[e.charCode] = true;
		}
		/**
		 * Check wether a given key is currently pressed
		 * @param	keyCode
		 * @return
		 */
		public function keyCodeIsDown(keyCode:int):Boolean {
			return keycodedict[keyCode];
		}
		public function charCodeIsDown(charCode:int):Boolean {
			return charcodedict[charCode];
		}
	}
	
}