package com.furusystems.dconsole2.core.gui.maindisplay.input 
{
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import com.furusystems.dconsole2.core.gui.layout.IContainable;
	import com.furusystems.dconsole2.core.interfaces.IThemeable;
	import com.furusystems.dconsole2.core.Notifications;
	import com.furusystems.dconsole2.core.style.Colors;
	import com.furusystems.dconsole2.core.style.GUIUnits;
	import com.furusystems.dconsole2.core.style.TextFormats;
	import com.furusystems.dconsole2.core.text.TextUtils;
	import com.furusystems.dconsole2.core.utils.ColorUtils;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class InputField extends Sprite implements IContainable,IThemeable
	{
		private var _inputTextField:TextField;
		
		public function InputField() 
		{	
			tabEnabled = tabChildren = false;
			_inputTextField = new TextField();
			_inputTextField.border = true;
			_inputTextField.embedFonts = TextFormats.INPUT_FONT.charAt(0) != "_";
			_inputTextField.defaultTextFormat = TextFormats.inputTformat;
			_inputTextField.multiline = false;
			_inputTextField.type = TextFieldType.INPUT;
			_inputTextField.background = true;
			_inputTextField.borderColor = Colors.INPUT_BORDER;
			_inputTextField.backgroundColor = Colors.INPUT_BG;
			_inputTextField.textColor = Colors.INPUT_FG;
			_inputTextField.tabEnabled = false;
			
			_inputTextField.text = "Input";
			_inputTextField.addEventListener(Event.CHANGE, onInputChange);
			addChild(_inputTextField);
			PimpCentral.addCallback(Notifications.CONSOLE_INPUT_LINE_CHANGE_REQUEST, onInputlineChangeRequest);
			PimpCentral.addCallback(Notifications.THEME_CHANGED, onThemeChange);
		}
		
		private function onInputlineChangeRequest(md:MessageData):void
		{
			text = String(md.data);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onInputChange(e:Event):void 
		{
			dispatchEvent(e.clone());
		}
		public function get text():String {
			return _inputTextField.text;
		}
		public function set text(s:String):void {
			_inputTextField.text = s;
			focus();
		}
		/* INTERFACE com.furusystems.dconsole2.core.gui.layout.IContainable */
		
		public function onParentUpdate(allotedRect:Rectangle):void
		{
			y = allotedRect.y;
			x = allotedRect.x;
			_inputTextField.height = GUIUnits.SQUARE_UNIT;
			_inputTextField.width = allotedRect.width-1;
		}
		
		public function get rect():Rectangle
		{
			return getRect(parent);
		}
		
		public function get minHeight():Number
		{
			return 0;
		}
		
		public function get minWidth():Number
		{
			return 0;
		}
		public function moveCaretToIndex(index:int = -1):void
		{
			if (index == -1) {
				index = inputTextField.length;
			}
			inputTextField.setSelection(index, index);
		}
		public function get selectionBeginIndex():int {
			return _inputTextField.selectionBeginIndex;
		}
		public function get selectionEndIndex():int {
			return _inputTextField.selectionEndIndex;
		}
		public function getWordAtIndex(index:int):String {
			return TextUtils.getWordAtIndex(_inputTextField, index);
		}
		public function get firstIndexOfWordAtCaret():int {
			return TextUtils.getFirstIndexOfWordAtCaretIndex(_inputTextField);
		}
		public function get firstWord():String {
			return getWordAtIndex(0);
		}
		public function get wordAtCaret():String {
			return TextUtils.getWordAtCaretIndex(inputTextField);
		}
		public function selectWordAtCaret():void {
			TextUtils.selectWordAtCaretIndex(_inputTextField);
		}
		public function caretToEnd():void {
			moveCaretToIndex( -1);
		}
		public function caretToStart():void {
			moveCaretToIndex(0);
		}
		
		public function focus():void
		{
			if (stage.focus == _inputTextField) return;
			stage.focus = _inputTextField;
			caretToEnd();
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.interfaces.IThemable */
		
		public function onThemeChange(md:MessageData):void
		{
			_inputTextField.borderColor = Colors.INPUT_BORDER;
			_inputTextField.backgroundColor = Colors.INPUT_BG;
			_inputTextField.textColor = Colors.INPUT_FG;
		}
		
		public function clear():void
		{
			text = "";
		}
		public function get caretIndex():int { return _inputTextField.caretIndex; }
		public function get inputTextField():TextField { return _inputTextField; }
		
	}

}