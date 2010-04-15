package no.doomsday.console.core.input
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import mx.utils.StringUtil;
	import mx.utils.object_proxy;
	
	import no.doomsday.console.ConsoleUtil;
	import no.doomsday.console.core.text.TextUtils;
	
	/**
	 * Maintains a list of keyboard shortcuts and dispatches the callback function when a shortcut has been triggered.
	 * 
	 * @author Andreas Rønning, Cristobal Dabed
	 */
	public final class KeyboardManager extends EventDispatcher
	{
		/*  Variables */
		private static var INSTANCE:KeyboardManager;
		private var keyboardSource:InteractiveObject = null;
		private var keyboardShortcuts:Vector.<KeyboardShortcut> = new Vector.<KeyboardShortcut>();
		
		/* @group Magic Methods */
		
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
		
		/* @end */
		
			
		/* @group  API */	
		
		/**
		 * Start tracking keyboard events
		 * If already tracking, previous event listeners will be removed
		 * @param	eventSource
		 * The object whose events to respond to (typically stage)
		 */
		public function setup(eventSource:InteractiveObject):void {
			try {
				shutdown();
			} catch (e:Error) { }
			eventSource.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown,false,Number.POSITIVE_INFINITY,true);
			eventSource.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp, false, Number.POSITIVE_INFINITY, true);
			keyboardSource = eventSource;
		}
		
		
		/**
		 * Stop tracking keyboard events
		 */
		public function shutdown():void {
			keyboardSource.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			keyboardSource.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			keyboardSource = null;
			removeAll();
		}
		
		/**
		 * Add shortcut
		 * 
		 * @param keystroke The keystroke an valid keycode 
		 * @param modifier	The modifier can be either ALT, CTR, SHIFT or ALT+SHIFT, CTR+ALT. CTR+SHIFT
		 * @param callback	The callback function to call when the shortcut has been triggered.
		 * @param source	The event source to listen on if none listens to stage automatically(NOT IMPLEMENTED YET).
		 * @param override	Wether to override an existing shortcut with the same name.
		 * 
		 * @return
		 * 	Return true or false depending on wether the shortcut was successfully added or not.
		 */ 
		public static function addShorcut(keystroke:uint, modifier:uint, callback:Function, source:Object=null, override:Boolean=false):Boolean {
			var success:Boolean;
			
			/* 
			 *	Throw errors if.
			 *		1. Not an valid keystroke
			 *		2. Not an valid modifier.
			 *		3. Not an valid keystroke + modifier combination.
			 *		4. Not an valid callback. 
			 */
			
			if(!instance.validateKeystroke(keystroke)){
				throw new Error("Invalid keystroke");
			}
			
			if(!instance.validateModifier(modifier)){
				throw new Error("Invalid modifier");
			}
			
			if(!instance.validateKeystrokeWithModifier(keystroke, modifier)){
				throw new Error("Invalid keystroke + modifier combination");
			}
			
			if(typeof(callback) != "function"){
				throw new Error("Invalid callback function");
			}
			
			if(!instance.hasKeyboardShortcut(keystroke, modifier)){
				instance.addKeyboardShortcut(keystroke, modifier, callback);
			}else if(override){
				instance.removeKeyboardShortcut(keystroke, modifier);
				instance.addKeyboardShortcut(keystroke, modifier, callback);
			} else {
				trace("Warn: keystroke, modifier combination already exists and was not set to be overriden.");
			} 
		
			
			return success;
		}
		
		/**
		 * Remove shortcut
		 * 
		 * @param name	The name of the keyboard shortcut to remove.
		 * 
		 * @return
		 * 	Returns true or false depending on wether it managed to release the shortcut or not.
		 */
		public static function removeShortcut(keystroke:uint, modifier:uint):Boolean {
			var success:Boolean = true;
			/* 
			*	Warn if.
			*		1. Not an valid keystroke
			*		2. Not an valid modifier.
			*		3. Not an valid keystroke + modifier combination.
			*/
			
			if(!instance.validateKeystroke(keystroke)){
				success = false;
			}
			
			if(!instance.validateModifier(modifier)){
				success = false;
			}
			
			if(!instance.validateKeystrokeWithModifier(keystroke, modifier)){
				success = false;
			}
			if(success){
				if(instance.hasKeyboardShortcut(keystroke, modifier)){
					instance.removeKeyboardShortcut(keystroke, modifier);
				} else {
					trace("Trying to remove an keystroke + modifier combination that is no present");
				}
			} else {
				trace("Trying to remove an invalid keystroke + modifier combination");
			}
			return success;
		}
		
		/**
		 * Remove all
		 * 
		 * @param source	Optional source to remove bind listen
		 * 
		 * @return
		 * 	Returns true or false depending on wether it managed release all the shortcuts or not.
		 */ 
		public static function removeAll(source:Object=null):Boolean {
			var success:Boolean = true;
			instance.keyboardShortcuts = new Vector.<KeyboardShortcut>(); // reset
			return success;
		}
		
		/**
		 * If is valid Keyboardshortcut.
		 * 
		 * @param keystroke The keystroke an valid keycode 
		 * @param modifier	The modifier can be either ALT, CTR, SHIFT or ALT+SHIFT, CTR+ALT. CTR+SHIFT
		 * 
		 * @return
		 * 	Returns true or false wether the keyboard shortcut is valid or not. 
		 */ 
		public static function isValidKeyboardShortcut(keystroke:uint, modifier:uint):Boolean {
			return instance.validateKeystrokeWithModifier(keystroke, modifier);
		}
		
		/* @end */
		
		
		/* @group Events */
		
		/**
		 * Handle key down.
		 * 
		 * @param event	The keyboard event.
		 */ 
		private function handleKeyDown(event:KeyboardEvent):void{
			// If the list is empty return.
			if(emptyKeyboardShortcuts()){
				return;
			}
			
			// Get the modifier
			var modifier:uint = 0;
			if(event.altKey){
				modifier += KeyBindings.ALT;
			}
			if(event.ctrlKey){
				modifier += KeyBindings.CTRL;
			}
			if(event.shiftKey){
				modifier += Keyboard.SHIFT;
			}
			/*
			 * 1. Loop over the keyboard shortcuts, on the first keyboard shortcut that match the criteria break out, but make sure that it is released if one wants .
			 * 2. If the keyboard shortcut is in the state released trigger it and set the released state to false.
			 */
			var keystroke:uint = event.keyCode;
			var i:int = 0;
			var success:Boolean = false;
			for(var l:int = keyboardShortcuts.length; i < l; i++){
				if(isKeyboardShortcut(keyboardShortcuts[i], keystroke, modifier)){
					success = true;
					break;
				}
			}	
			if(success){
				if(keyboardShortcuts[i].released){
					keyboardShortcuts[i].released = false;
					try {
						keyboardShortcuts[i].callback();
					}catch(error:Error){ /* suppress warning. */ }
				}
			}
		}
		
		/**
		 * Handle Key up.
		 * 
		 * @param event The keyboard event
		 */ 
		private function handleKeyUp(event:KeyboardEvent):void {
			// If the list is empty return.
			if(emptyKeyboardShortcuts()){
				return;
			}
			var keystroke:uint = event.keyCode
			/*
			 * Loop over the keyboard shortcuts and release the respective if they have the keystroke and are not already released.
			 */
			for(var i:int = 0, l:int = keyboardShortcuts.length; i < l; i++){
				if((keystroke == keyboardShortcuts[i].keystroke) && !keyboardShortcuts[i].released){
					keyboardShortcuts[i].released = true;
				}
			}
		}
		
		/* @end */
		
		
		/* @group Internal Functions */
		
		/**
		 * Validate keystroke
		 * 
		 * @param keystroke	The keystroke to validate.
		 */ 
		private function validateKeystroke(keystroke:uint):Boolean {
			var success:Boolean = true;
			switch(keystroke){
				case KeyBindings.ALT:
				case KeyBindings.SHIFT:
				case KeyBindings.CTRL:
				case Keyboard.BACKSPACE:
				case Keyboard.CAPS_LOCK:
				case Keyboard.INSERT:
				case Keyboard.DELETE:
				case Keyboard.HOME:
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
					success = false;
				break;
			}
			return success;
		}
		
		/**
		 * Validate shortcut
		 * 
		 * @param shortcut	The shortcut to validate.
		 * 
		 * @return
		 * 	Returns true or false depedending on wether it was an valid shortcut or not.
		 */ 
		private function validateModifier(modifier:uint):Boolean{
			var success:Boolean = false;
			switch(modifier){
				case KeyBindings.NONE:
				case KeyBindings.ALT:
				case KeyBindings.SHIFT:
				case KeyBindings.CTRL:
				case KeyBindings.ALT_SHIFT:
				case KeyBindings.CTRL_ALT:
				case KeyBindings.CTRL_SHIFT:
					success = true;
				break;
			}
			return success;
		}
		
		/**
		 * Validate kestroke with modifier
		 * 
		 * @param kestroke 	The keystroke 
		 * @param modifier	The modifier
		 * 
		 * @return
		 * 	Returns true or false depending on wether the keystroke + modifier is a valid combination. 
		 */ 
		private function validateKeystrokeWithModifier(keystroke:uint, modifier:uint):Boolean {
			var success:Boolean = false;
			
			/*
			 * 1. ENTER | TAB must satisfy at least 2 modifiers.
			 * 2. ESC	can only have 1 modifier
			 * 3. FN*   can not have a  modifier
			 * 4. SPACE must have at least one modifier.
			 */
			if((keystroke == KeyBindings.ENTER) || (keystroke == KeyBindings.TAB)){
				success = isCombinedModifier(modifier);
			}
			
			if(keystroke == KeyBindings.ESC){
				success = !isCombinedModifier(modifier);
			}
			
			if(modifier == KeyBindings.NONE){
				success = !isKeystrokeFN(keystroke);
			}
			
			if((keystroke == KeyBindings.SPACE)){
				success = (modifier != KeyBindings.NONE);
			}
			return success;
		}
		private static var flag:int = 0; 
		
		/**
		 * Is combined modifier.
		 * 
		 * @param modifier The modifier
		 * 
		 * @return
		 * 	Returns true or false depending on wether the modifier is a combined modifier or not. 
		 */ 
		private function isCombinedModifier(modifier:uint):Boolean {
			var success:Boolean = false;
			switch(modifier){
				case KeyBindings.ALT_SHIFT:
				case KeyBindings.CTRL_ALT:
				case KeyBindings.CTRL_SHIFT:
					success = true;
					break;
			}
			return success;
		}
		
		/**
		 * Is keystroke FN
		 * 
		 * @param keystroke	The keystroke
		 * 
		 * @return
		 * 	Returns true or false depending on wether the keeystroke is a FN key code or not.
		 */ 
		private function isKeystrokeFN(modifier:uint):Boolean {
			var success:Boolean = true;
			switch(modifier){
				case KeyBindings.F1:
				case KeyBindings.F2:
				case KeyBindings.F3:
				case KeyBindings.F4:
				case KeyBindings.F5:
				case KeyBindings.F6:
				case KeyBindings.F7:
				case KeyBindings.F8:
				case KeyBindings.F9:
				case KeyBindings.F10:
				case KeyBindings.F11:
				case KeyBindings.F12:
				case KeyBindings.F13:
				case KeyBindings.F14:
				case KeyBindings.F15:
					success = false;
					break;
			}
			return success;
		}
		
		/**
		 * Add Keyboard shortcut
		 * 
		 * @param keystroke The keystroke code
		 * @param modifier	The modifier value.
		 */ 
		private function addKeyboardShortcut(keystroke:uint, modifier:uint, callback:Function):void {
			keyboardShortcuts.push(new KeyboardShortcut(keystroke, modifier, callback));
		}
		
		/**
		 * Remove Keyboard shortcut
		 * 
		 * @param keystroke The keystroke code
		 * @param modifier	The modifier value.
		 */ 
		private function removeKeyboardShortcut(keystroke:uint, modifier:uint):void{
			var i:int = 0;
			for(var l:int = keyboardShortcuts.length; i < l; i++){
				if(isKeyboardShortcut(keyboardShortcuts[i], keystroke, modifier)){
					break;
				}
			}
			keyboardShortcuts.splice(i, 1);
		}
		
		/**
		 * Has keyboard shortcut
		 * 
		 * @return
		 * 	Returns true or false depending on wether the keystroke, modifier combination already exists or not.
		 */ 
		private function hasKeyboardShortcut(keystroke:uint, modifier:uint):Boolean{
			var success:Boolean = false;
			for(var i:int =0, l:int = keyboardShortcuts.length; i < l; i++){
				if(isKeyboardShortcut(keyboardShortcuts[i], keystroke, modifier)){
					success = true;
					break;
				}
			}
			return success;
		}
		
		/**
		 * Is keyboard shortcut
		 * 
		 * @param keyboardShortcut	The keyboard shortcut to check on.
		 * @param keystroke The keystroke value.
		 * @param modifier	The modifier value.
		 * 
		 * @returns
		 * 	Returns trur or false depending on wether the keyboard shortcut contains the keystroke, modifier combination.
		 */ 
		private function isKeyboardShortcut(keyboardShortcut:KeyboardShortcut, keystroke:uint, modifier:uint):Boolean{
			return ((keyboardShortcut.keystroke == keystroke) && (keyboardShortcut.modifier == modifier));
		}
		
		/**
		 * Empty keyboard shortcuts
		 * 
		 * @return
		 * 	Returns true or false depending on wether keyboard shortcuts list is empty or not.
		 */ 
		private function emptyKeyboardShortcuts():Boolean {
			return (keyboardShortcuts.length > 0 ? false : true);
		}
		/* @end */
	}	
	
}