package no.doomsday.console.core.input
{
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;

	/**
	 * Keyboard Sequences
	 * 	A singleton class for the keyboard sequences managed by the Keyboard Manager class.
	 */ 
	public final class KeyboardSequences
	{
		private static var INSTANCE:KeyboardSequences = null; 
		private var keyboardSequences:Vector.<KeyboardSequence> = new Vector.<KeyboardSequence>();
		
		/* @group API */
		
		/**
		 * Instance
		 * 
		 * @return
		 * 	Returns the singleton representation of this class. 
		 */ 
		public static function get instance():KeyboardSequences {
			if(!INSTANCE){
				INSTANCE = new KeyboardSequences();
			}
			return INSTANCE;
		}
		
		/**
		 * Add
		 * 
		 * @param keyCodes	The list of keycodes to trigger a callback.
		 * @param callback	The callback function to call.
		 * @param override	Optional override for an existing keyboard sequence with the new function.
		 */ 
		public function add(keyCodes:Array, callback:Function, override:Boolean = false):Boolean {
			var success:Boolean = true;
			
			/*
			 *	1. Must satisfy minimum of length 1
			 *  2. Must satisfy a valid callback.
			 */
			if(keyCodes.length == 0){ // < 2?
				throw new Error("A keyboard sequence can not be of length 0");
			}
			
			if(typeof(callback) != "function"){
				throw new Error("Invalid callback function");
			}
			
			/*
			 * 1. If the keyCodes are not registered yet add them.
			 * 2. If the exist and set to override, remove the old one and add the new one.
			 * 3. Warn the user that the keyCodes could not be added success is set to false.
			 */
			if(!has(keyCodes)){
				keyboardSequences.push(new KeyboardSequence(keyCodes, callback));
			}else if(override){
				remove(keyCodes);
				keyboardSequences.push(new KeyboardSequence(keyCodes, callback));
			} else {
				trace("Warn: Keyboard sequence exists and was not set to be overriden.");
				success = false;
			} 
			return success;
		}
		
		/**
		 * Remove keyboard sequence.
		 * 
		 * @param keyCodes	The keyCodes to stop listening on. 
		 * 
		 * @return
		 * 	Returns true or false depending on wether it successfully removed the keyCode sequence from the list or not.
		 */ 
		public function remove(keyCodes:Array):Boolean {
			var success:Boolean = false;
			if(!isEmpty()){
				if(has(keyCodes)){
					var i:int = 0;
					for(var l:int = keyboardSequences.length; i < l; i++){
						if(inKeyboardSequence(keyCodes, keyboardSequences[i])){
							break;
						}
					}
					keyboardSequences.splice(i, 1);
				}
			} else {
				trace("Warn: Empty keyboard sequence none to remove");
			}
			return success;
		}
		
		/**
		 * Has
		 * 
		 * @param keyCodes The keyCodes to search on.
		 * 
		 * @return
		 * 	Returns true or false depending on wether the given keyCode sequence is in the list or not.
		 */ 
		public function has(keyCodes:Array):Boolean {
			var success:Boolean = false;
			if(!isEmpty()){
				for(var i:int = 0, l:int =  keyboardSequences.length; i < l; i++){
					if(inKeyboardSequence(keyCodes, keyboardSequences[i])){
						success = true;
						break;
					}
				}
			}
			return success;
		}
		
		
		/**
		 * Is empty
		 * 
		 * @return
		 * 	Returns true or false depending on wether there are any registered keyboardsequences or not.
		 */ 
		public function isEmpty():Boolean {
			return (keyboardSequences.length == 0 ? true : false);
		}
		
		
		/* @end */
		
		/* @group Delegates called  directly by the KeyboardManager */
		// We could have added custom events but do not to save some resources while keyboard input should be as fast as possible. 
		
		/**
		 * On key down.
		 * 
		 * @param keyCode 	The keycode
		 * @param modifier 	The modifier
		 * @param event		The keyboard event.
		 */ 
		public function onKeyDown(keyCode:uint, modifer:uint, event:KeyboardEvent):void {
			// Nothing to do here, placeholder function only.
		}
		
		/**
		 * On key up.
		 * 
		 * @param keyCode 	The keycode
		 * @param modifier 	The modifier
		 * @param event 	The keyboard event.
		 */ 
		public function onKeyUp(keyCode:uint, modifier:uint, event:KeyboardEvent):void {
			if(!isEmpty()){
				for(var i:int = 0, l:int = keyboardSequences.length, reset:Boolean = true; i < l; i++, reset = true){
					if(keyCode == keyboardSequences[i].keystrokes.shift()){
						if(keyboardSequences[i].keystrokes.length == 0){
							try {
								keyboardSequences[i].callback();
							}catch(error:Error){ /* Suppress Warnings */ }
						} else {
							reset = false;
						}
					}
					
					if(reset){
						// Reset values if the sequence was not correctly set.
						keyboardSequences[i].keystrokes = keyboardSequences[i].keyCodes.concat();
					}
				}
			}
		}
		
		/* @end */
		
		/* @group Private Functions */
		
		/**
		 * In keyboard sequence
		 * 
		 * @param keyCodes	The keyCodes to test for.
		 * @param keyboardSequence	The keyboardSequence to check on.
		 */ 
		private function inKeyboardSequence(keyCodes:Array, keyboardSequence:KeyboardSequence):Boolean {
			var success:Boolean = true;
			if(keyCodes.length == keyboardSequence.keyCodes.length){	
				for(var i:int = 0, l:int = keyCodes.length; i < l; i++){
					if(keyCodes[i] != keyboardSequence[i]){
						success = false;
						break;
					}
				}
			}
			return success;
		}
		
		/* @end */
	}
}