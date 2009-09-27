package no.doomsday.console.text.autocomplete
{
	import no.doomsday.console.text.TextUtils;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 * Heavily based on Ali Mills' work at http://www.asserttrue.com/articles/2006/04/09/actionscript-projects-in-flex-builder-2-0
	 */
	public class AutocompleteManager 
	{
		
        private var txt:String;
        public var dict:AutocompleteDictionary;
		public var contextDict:AutocompleteDictionary;
        private var paused:Boolean = false;
		private var _targetTextField:TextField;
		public var suggestionActive:Boolean = false;
		public var ready:Boolean = false;
		public function AutocompleteManager(targetTextField:TextField) 
		{
			this.targetTextField = targetTextField;
		}
		public function setDictionary(newDict:AutocompleteDictionary):void {
			dict = newDict;
			ready = true;
		}
		
        private function changeListener(e:Event):void {
            if(!paused) {
                complete();
            }
        }

        private function keyDownListener(e:KeyboardEvent):void {
            if(e.keyCode == Keyboard.BACKSPACE || e.keyCode == Keyboard.DELETE) {
                paused = true;
            }
            else {
                paused = false;
            }
        }

        private function complete():void {
			//we only complete single words, so start caret is the beginning of the word the caret is currently in
			var firstIndex:int = TextUtils.getFirstIndexOfWordAtCaretIndex(_targetTextField);
			var str:String = _targetTextField.text.substr(firstIndex, _targetTextField.caretIndex);
			
            var strParts:Array = str.split("");
			var suggestion:String;
			if (!contextDict || firstIndex < 1) {
				suggestion = dict.getSuggestion(strParts);
			}else {
				suggestion = contextDict.getSuggestion(strParts);
			}
			suggestionActive = false;
			if(suggestion.length>0){
				//_targetTextField.text = str;
				_targetTextField.appendText(suggestion);
			   _targetTextField.setSelection(_targetTextField.caretIndex, _targetTextField.text.length);
			   suggestionActive = true;
			}
        }        
		
		public function get targetTextField():TextField { return _targetTextField; }
		
		public function set targetTextField(value:TextField):void 
		{
			try{
				_targetTextField.removeEventListener(Event.CHANGE, changeListener);
				_targetTextField.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			}catch (e:Error) {
			}finally{
				_targetTextField = value;
				_targetTextField.addEventListener(Event.CHANGE, changeListener);
				_targetTextField.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			}
		}
    } 
	
}