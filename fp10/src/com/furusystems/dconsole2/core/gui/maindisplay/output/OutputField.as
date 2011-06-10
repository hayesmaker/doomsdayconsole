package com.furusystems.dconsole2.core.gui.maindisplay.output 
{
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.utils.Timer;
	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	
	import com.furusystems.dconsole2.core.gui.layout.IContainable;
	import com.furusystems.dconsole2.core.gui.SimpleScrollbarNorm;
	import com.furusystems.dconsole2.core.interfaces.IThemeable;
	import com.furusystems.dconsole2.core.logmanager.DConsoleLog;
	import com.furusystems.dconsole2.core.logmanager.DLogManager;
	import com.furusystems.dconsole2.core.Notifications;
	import com.furusystems.dconsole2.core.output.ConsoleMessage;
	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	import com.furusystems.dconsole2.core.style.Alphas;
	import com.furusystems.dconsole2.core.style.Colors;
	import com.furusystems.dconsole2.core.style.StyleManager;
	import com.furusystems.dconsole2.core.style.TextFormats;
	import com.furusystems.dconsole2.DConsole;
	/**
	 * Handles rendering of a vector of messages
	 * @author Andreas Rønning
	 */
	public class OutputField extends Sprite implements IContainable,IThemeable
	{
		private var _textOutput:TextField;
		private var _scrollbar:SimpleScrollbarNorm;
		private var _locked:Boolean = false;
		private var _scrollRange:int = 0;
		private var _scrollIndex:int = 0;
		private var _currentLog:DConsoleLog;
		private var _atBottom:Boolean = true;
		private var _lineMetrics:TextLineMetrics;
		private var _allotedRect:Rectangle;
		public var showLineNum:Boolean = true;
		public var traceValues:Boolean = true;
		public var showTraceValues:Boolean = true;
		public var showTimeStamp:Boolean = false;
		public var showTag:Boolean = true; //TODO: Make this private?
		private var _dirty:Boolean = false;
		private const TRUNCATE:Boolean = false;
		public function OutputField() 
		{
			_textOutput = new TextField();
			_textOutput.defaultTextFormat = TextFormats.outputTformatOld;
			_textOutput.embedFonts = TextFormats.INPUT_FONT.charAt(0) != "_";
			
			_textOutput.text = "#";
			_lineMetrics = _textOutput.getLineMetrics(0);
			addChild(_textOutput);
			_scrollbar = new SimpleScrollbarNorm(SimpleScrollbarNorm.VERTICAL);
			_scrollbar.addEventListener(Event.CHANGE, onScrollbarChange);
			_scrollbar.trackWidth = 10;
			//_textOutput.y--;
			addChild(_scrollbar);
			_textOutput.mouseWheelEnabled = false;
			_textOutput.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			PimpCentral.addCallback(Notifications.THEME_CHANGED, onThemeChange);
			PimpCentral.addCallback(Notifications.CURRENT_LOG_CHANGED, onCurrentLogChange);
			PimpCentral.addCallback(Notifications.FRAME_UPDATE, onFrameUpdate);
			
			if(TRUNCATE) _textOutput.addEventListener(MouseEvent.CLICK, onTextClick);
		}
		
		private function onFrameUpdate():void 
		{
			if (_locked) return;
			if (_currentLog.dirty||_dirty) {
				drawMessages();
				_currentLog.setClean();
				_dirty = false;
			}
		}
		
		private function onCurrentLogChange(md:MessageData):void
		{
			var lm:DLogManager = DLogManager(md.source);
			currentLog = lm.currentLog;
		}
		
		private function onTextClick(e:MouseEvent):void 
		{
			var lineIDX:int = _textOutput.getLineIndexAtPoint(_textOutput.mouseX, _textOutput.mouseY);
			var msg:ConsoleMessage = getMessageAtLine(lineIDX);
			if (msg.truncated) {
				//trace(msg.text); //TODO: Display clicked text in some sort of popover
			}
		}
		
		private function onScrollbarChange(e:Event):void 
		{
			scrollIndex = _scrollbar.outValue * maxScroll;
		}
		/**
		 * The number of lines displayable
		 */
		public function get numLines():int {
			return Math.max(1, Math.floor((_textOutput.height - 4) / _lineMetrics.height));
		}
		public function set text(s:String):void {
			_textOutput.text = s;
		}
		public function get text():String {
			return _textOutput.text;
		}
		
		public function setText(s:String):void {
			_textOutput.text = s;
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.gui.layout.IContainable */
		
		public function onParentUpdate(allotedRect:Rectangle):void
		{
			_allotedRect = allotedRect;
			y = allotedRect.y;
			x = allotedRect.x;
			var prevHeight:Number = _textOutput.height;
			_textOutput.width = allotedRect.width - _scrollbar.trackWidth;
			_textOutput.height = allotedRect.height;
			_scrollbar.x = allotedRect.width - _scrollbar.trackWidth;
			drawBackground();
			var r:Rectangle = allotedRect.clone();
			_scrollbar.draw(r.height, _scrollIndex, maxScroll);
			
			if (prevHeight != _textOutput.height) {
				_dirty = true;
				//update(); //introduces latency but avoids clogging when called in a loop
				//drawMessages();
			}
		}
		private function drawBackground():void {
			if (!_allotedRect) return;
			graphics.clear();
			graphics.beginFill(Colors.OUTPUT_BG, Alphas.CONSOLE_CORE_ALPHA);
			graphics.drawRect(0, 0, _allotedRect.width, _allotedRect.height);
		}
		
		public function get minHeight():Number
		{
			return 0;
		}
		
		public function get minWidth():Number
		{
			return 0;
		}
		
		public function get rect():Rectangle
		{
			return _allotedRect;
		}
		
		public function get textOutput():TextField { return _textOutput; }
		
		public function get locked():Boolean { return _locked; }
		
		
		public function goto(line:int):void {
			scrollToLine(line-1);
		}
		public function scrollToLine(line:int):void {
			var diff:int = scrollIndex - line;
			//trace("scrolltoline", scrollIndex, line);
			scroll(diff);
		}
		
		public function lockOutput():void {
			_locked = true;
		}
		public function unlockOutput():void {
			_locked = false;
		}
		/**
		 * Toggle display of message timestamp
		 */
		public function toggleTimestamp(toggle:String = null):void {
			switch(toggle) {
				case "on":
				showTimeStamp = true;
				break;
				case "off":
				showTimeStamp = false;
				break;
				default:
				showTimeStamp = !showTimeStamp;
			}
			if (showTimeStamp) DConsole.print("Timestamp on",ConsoleMessageTypes.SYSTEM)
			else DConsole.print("Timestamp off",ConsoleMessageTypes.SYSTEM);
		}
		private function onMouseWheel(e:MouseEvent):void 
		{
			scroll(e.delta);
		}
		
		public function toggleLineNumbers():void
		{
			(showLineNum = !showLineNum) ? DConsole.print("Line numbers: on", ConsoleMessageTypes.SYSTEM) : DConsole.print("Line numbers: off", ConsoleMessageTypes.SYSTEM);
			_dirty = true;
		}
		public function scroll(deltaY:int = 0, deltaX:int = 0):void {
			_textOutput.scrollH += deltaX;
			if(deltaY!=0){
				if (currentLog.length < numLines) return;
				scrollIndex = scrollIndex - deltaY;
			}
		}
		public function set scrollIndex(i:int):void {
			var _prevIndex:int = _scrollIndex;
			_scrollIndex = Math.max(0, Math.min(i, maxScroll));
			_atBottom = _scrollIndex == maxScroll;
			if (_prevIndex != _scrollIndex) {
				_dirty = true;
			}
		}
		public function get scrollIndex():int {
			return _scrollIndex;
		}
		public function get maxScroll():int {
			if (!currentLog) return 0;
			return Math.max(0, currentLog.messages.length - numLines);
		}
		public function update():void {
			onFrameUpdate();
		}
		public function set currentLog(l:DConsoleLog):void {
			_currentLog = l;
			showTag = _currentLog.manager.rootLog == _currentLog;
			update();
		}
		public function get currentLog():DConsoleLog {
			return _currentLog;
		}
		public function getMessageAtLine(line:int):ConsoleMessage {
			var currentLogVector:Vector.<ConsoleMessage> = currentLog.messages;
			line += _scrollIndex;
			return currentLog.messages[line];
		}
		public function drawMessages():void {
			if (!visible || _locked || !currentLog ) return;
			if (_atBottom) {
				_scrollIndex = maxScroll;
			}
			var currentLogVector:Vector.<ConsoleMessage> = currentLog.messages;
			var date:Date = new Date();
			clear();
			_scrollRange = Math.min(currentLogVector.length, scrollIndex + numLines);
			if (numLines > _scrollRange-scrollIndex) {
				_scrollIndex = maxScroll;
				_atBottom = true;
				_scrollRange = Math.min(currentLogVector.length, scrollIndex + numLines);	
			}
			_scrollbar.visible = numLines < currentLogVector.length;
			if (_scrollbar.visible) {
				_textOutput.width = _allotedRect.width - _scrollbar.trackWidth;
			}else {
				_textOutput.width = _allotedRect.width;
			}
			
			for (var i:int = scrollIndex; i < _scrollRange; i++) 
			{
				var msg:ConsoleMessage = currentLogVector[i];
				var lineLength:int = 0;
				var lineNum:int = i+1;
				if (msg.type == ConsoleMessageTypes.TRACE && !showTraceValues) continue;
				//if ((msg.type == ConsoleMessageTypes.TRACE && !showTraceValues) || !msg.visible) continue;
				var visible:Boolean = msg.visible;
				var fmt:TextFormat;
				textOutput.defaultTextFormat = fmt = TextFormats.outputTformatLineNo;
				var lineNumStr:String = lineNum.toString();
				if (lineNum < 100) {
					lineNumStr = "0" + lineNumStr;
				}
				if (lineNum < 10) {
					lineNumStr = "0" + lineNumStr;
				}
				if (showLineNum) {
					lineLength += lineNumStr.length + 2;
					textOutput.appendText("[" + lineNumStr + "]");
				}
				
				textOutput.defaultTextFormat = fmt = visible?TextFormats.outputTformatOld:TextFormats.outputTformatHidden;
				if (showTimeStamp) {
					textOutput.defaultTextFormat = visible?TextFormats.outputTformatTimeStamp:TextFormats.outputTformatHidden;
					date.setTime(msg.timestamp)
					var dateStr:String = date.toLocaleDateString() + " " + date.toLocaleTimeString() + " ";
					lineLength += dateStr.length;
					textOutput.appendText(dateStr);
				}
				if (showTag && msg.tag != "" && msg.tag != DConsole.TAG && visible) { 
					textOutput.defaultTextFormat = visible?TextFormats.outputTformatTag:TextFormats.outputTformatHidden;
					textOutput.appendText(" " + msg.tag);
					lineLength += (1 + msg.tag.length);
					textOutput.defaultTextFormat = fmt;
				}
				if (msg.type == ConsoleMessageTypes.USER) {
					textOutput.appendText(" < ");
				}else {
					textOutput.appendText(" > ");
				}
				lineLength += 3;
				var _hooray:Boolean = false;
				if (visible||msg.type==ConsoleMessageTypes.USER) {
					switch(msg.type) {
						case ConsoleMessageTypes.USER:
							fmt = TextFormats.outputTformatUser;
						break;
						case ConsoleMessageTypes.SYSTEM:
							fmt = TextFormats.outputTformatSystem;
						break;
						case ConsoleMessageTypes.ERROR:
							fmt = TextFormats.outputTformatError;
						break;
						case ConsoleMessageTypes.WARNING:
							fmt = TextFormats.outputTformatWarning;
						break;
						case ConsoleMessageTypes.FATAL:
							fmt = TextFormats.outputTformatFatal;
						break;
						case ConsoleMessageTypes.HOORAY:
							_hooray = true;
							fmt = TextFormats.hoorayFormat; 
						break;
						case ConsoleMessageTypes.TRACE:
						case ConsoleMessageTypes.DEBUG:
						case ConsoleMessageTypes.INFO:
						default:
							if(i==currentLogVector.length-1){
								fmt = TextFormats.outputTformatNew;
							}else {
								fmt = TextFormats.outputTformatOld;
							}
						break;
					}
				}else {
					fmt = TextFormats.outputTformatHidden;
				}
				var idx:int = text.length;
				var str:String = msg.text;
				if (msg.repeatcount > 0) {
					var str2:String = " x" + (msg.repeatcount+1);
					str += str2;
				}	
				
				//determine length of current line
				lineLength += str.length;
				msg.truncated = false;
				if(TRUNCATE){
					if (lineLength * _lineMetrics.width > width) {
						//truncate
						var diff:int = lineLength - (width / _lineMetrics.width);
						//str = (str.length-diff).toString()
						str = str.substr(0, Math.max(1, (str.length - diff) - 4));
						str += "...";
						msg.truncated = true; //flag this message as truncated for future reference
					}
				}
				
				if (i != _scrollRange-1) {
					textOutput.appendText(str + "\n");
				}else {
					textOutput.appendText(str);
				}
				try {
					if (_hooray) {
						for (var sindex:int = 0; sindex < str.length; sindex++) {
							//TODO: This is the worst thing in history. Good thing the hooray thing won't be used very much O_o
							fmt.color = Math.random() * 0xFFFFFF;
							textOutput.setTextFormat(fmt, idx + sindex, idx + sindex + str.length - sindex);
						}
					}else{
						textOutput.setTextFormat(fmt, idx, idx + str.length);
					}
				}catch (e:Error) {
					currentLogVector.splice(i, 1);
					DConsole.addErrorMessage("The console encountered a message draw error. Did you attempt to log a ByteArray?");
					drawMessages();
				}
				//_logManager.currentLog.setClean();
			}
			_scrollbar.draw(_textOutput.height, _scrollIndex, maxScroll);
		}
		
		private function clear():void 
		{
			_textOutput.text = "";
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.interfaces.IThemable */
		
		public function onThemeChange(md:MessageData):void
		{
			var sm:StyleManager = StyleManager(md.source);
			drawBackground();
			_scrollbar.draw(_textOutput.height, _scrollIndex, maxScroll);
		}
		
		public function scrollToBottom():void
		{
			scrollToLine(int.MAX_VALUE);
		}
		
	}

}