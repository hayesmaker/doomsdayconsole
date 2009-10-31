package no.doomsday.input.keyboard
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
	import no.doomsday.math.Vector2;
	
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
		public var keydict:Dictionary;
		private var directionVector2:Vector2 = new Vector2();
		
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
			keydict = new Dictionary(false);
			keyboardSource = eventSource;
			eventSource.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,0,true);
			eventSource.addEventListener(KeyboardEvent.KEY_UP, onKeyUp,false,0,true);
		}
		/**
		 * Stop tracking keyboard events
		 */
		public function shutdown():void {
			keyboardSource.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,0,true);
			keyboardSource.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp,false,0,true);
			keyboardSource = null;
			keydict = new Dictionary(false);
		}
		public function get isTracking():Boolean {
			if (keyboardSource) {
				return true;
			}
			return false;
		}
		private function onKeyUp(e:KeyboardEvent):void 
		{
			keydict[e.keyCode] = false;
		}
		private function onKeyDown(e:KeyboardEvent):void 
		{
			keydict[e.keyCode] = true;
		}
		/**
		 * Check wether a given key is currently pressed
		 * @param	keyCode
		 * @return
		 */
		public function keyIsDown(keyCode:int):Boolean {
			return keydict[keyCode];
		}
		
		
		public static const INPUTMETHOD_WSAD:uint = 0;
		public static const INPUTMETHOD_ARROW_KEYS:uint = 1;
		public static const INPUTMETHOD_WSAD_ARROWKEYS:uint = 2;
		public static const KEY_W:uint = String("W").charCodeAt(0);
		public static const KEY_S:uint = String("S").charCodeAt(0);
		public static const KEY_A:uint = String("A").charCodeAt(0);
		public static const KEY_D:uint = String("D").charCodeAt(0);
		public static const KEY_Q:uint = String("Q").charCodeAt(0);
		public static const KEY_E:uint = String("E").charCodeAt(0);
		/**
		 * Returns a vector describing a direction based on WSAD, arrow keys or both
		 * @param	controlMethod
		 * @return
		 */
		public function get2dDirectionVector(controlMethod:uint = INPUTMETHOD_WSAD_ARROWKEYS):Vector2 {
			directionVector2.zero();
			switch(controlMethod) {
				case INPUTMETHOD_ARROW_KEYS:
				if (keydict[Keyboard.LEFT]) directionVector2.x = -1;
				if (keydict[Keyboard.RIGHT]) directionVector2.x = 1;
				if (keydict[Keyboard.UP]) directionVector2.y = -1;
				if (keydict[Keyboard.DOWN]) directionVector2.y = 1;
				break;
				case INPUTMETHOD_WSAD:
				if (keydict[KEY_A]) directionVector2.x = -1;
				if (keydict[KEY_D]) directionVector2.x = 1;
				if (keydict[KEY_W]) directionVector2.y = -1;
				if (keydict[KEY_S]) directionVector2.y = 1;
				break;
				default:
				if (keydict[KEY_A] || keydict[Keyboard.LEFT]) directionVector2.x = -1;
				if (keydict[KEY_D] || keydict[Keyboard.RIGHT]) directionVector2.x = 1;
				if (keydict[KEY_W] || keydict[Keyboard.UP]) directionVector2.y = -1;
				if (keydict[KEY_S] || keydict[Keyboard.DOWN]) directionVector2.y = 1;
				break;
			}
			return directionVector2;
		}
	}
	
}