﻿package com.furusystems.dconsole2
{
	//{ imports
	import com.furusystems.logging.slf4as.Logging;
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.ui.Keyboard;
	import com.furusystems.dconsole2.core.commands.CommandManager;
	import com.furusystems.dconsole2.core.commands.ConsoleCommand;
	import com.furusystems.dconsole2.core.commands.FunctionCallCommand;
	
	import com.furusystems.dconsole2.core.DSprite;
	import com.furusystems.dconsole2.core.errors.CommandError;
	import com.furusystems.dconsole2.core.errors.ConsoleAuthError;
	import com.furusystems.dconsole2.core.gui.DockingGuides;
	import com.furusystems.dconsole2.core.gui.maindisplay.assistant.Assistant;
	import com.furusystems.dconsole2.core.gui.maindisplay.ConsoleView;
	import com.furusystems.dconsole2.core.gui.maindisplay.filtertabrow.FilterTabRow;
	import com.furusystems.dconsole2.core.gui.maindisplay.input.InputField;
	import com.furusystems.dconsole2.core.gui.maindisplay.output.OutputField;
	import com.furusystems.dconsole2.core.gui.maindisplay.toolbar.ConsoleToolbar;
	import com.furusystems.dconsole2.core.gui.ScaleHandle;
	import com.furusystems.dconsole2.core.gui.ToolTip;
	import com.furusystems.dconsole2.core.input.KeyBindings;
	import com.furusystems.dconsole2.core.input.KeyboardManager;
	import com.furusystems.dconsole2.core.introspection.InspectionUtils;
	import com.furusystems.dconsole2.core.introspection.IntrospectionScope;
	import com.furusystems.dconsole2.core.introspection.ScopeManager;
	import com.furusystems.dconsole2.core.logmanager.DConsoleLog;
	import com.furusystems.dconsole2.core.logmanager.DLogFilter;
	import com.furusystems.dconsole2.core.logmanager.DLogManager;
	import com.furusystems.dconsole2.core.Notifications;
	import com.furusystems.dconsole2.core.output.ConsoleMessage;
	import com.furusystems.dconsole2.core.output.ConsoleMessageRepeatMode;
	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	import com.furusystems.dconsole2.core.persistence.PersistenceManager;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	import com.furusystems.dconsole2.core.references.ReferenceManager;
	import com.furusystems.dconsole2.core.security.ConsoleLock;
	import com.furusystems.dconsole2.core.style.StyleManager;
	import com.furusystems.dconsole2.core.text.autocomplete.AutocompleteDictionary;
	import com.furusystems.dconsole2.core.text.autocomplete.AutocompleteManager;
	import com.furusystems.dconsole2.core.text.TextUtils;
	import com.furusystems.dconsole2.core.Version;
	import com.furusystems.dconsole2.logging.ConsoleLogBinding;
	//}
	/**
	 * ActionScript 3 logger, commandline interface and utility platform
	 * @author Andreas Roenning
	 * @author Cristobal Dabed
	 * @author Furu systems
	 */
	public class DConsole extends DSprite implements IConsole
	{
		
		//{ members
		private var _initialized:Boolean = false;
		private var _autoCompleteManager:AutocompleteManager;
		private var _globalDictionary:AutocompleteDictionary = new AutocompleteDictionary();
		private var _styleManager:StyleManager = new StyleManager();
		private var _referenceManager:ReferenceManager;
		private var _scopeManager:ScopeManager;
		private var _commandManager:CommandManager;
		private var _toolTip:ToolTip;
		private var _visible:Boolean = false;
		private var _isVisible:Boolean = true; //TODO: Fix naming ambiguity; _isVisible refers to the native visibility toggle
		private var _persistence:PersistenceManager;
		private var _callCommand:FunctionCallCommand;
		private var _getCommand:FunctionCallCommand;
		private var _setCommand:FunctionCallCommand;
		private var _selectCommand:FunctionCallCommand;
		private var _quickSearchEnabled:Boolean = true;
		private var _repeatMessageMode:int = ConsoleMessageRepeatMode.STACK;
		private var _bgLayer:Sprite = new Sprite();
		private var _topLayer:Sprite = new Sprite();
		private var _consoleBackground:Sprite = new Sprite();
		public var ignoreBlankLines:Boolean = true;
		private var _keystroke:uint = KeyBindings.ENTER;
		private var _modifier:uint = KeyBindings.CTRL_SHIFT;
		private var _lock:ConsoleLock = new ConsoleLock();
		private var _plugManager:PluginManager;
		private var _logManager:DLogManager;
		private var _autoCreateTagLogs:Boolean = true; //If true, automatically create new logs when a new tag is encountered
		private var _dockingGuides:DockingGuides;
		private var _overrideCallback:Function = null;
		private var _cancelNextSpace:Boolean = false;
		private var _defaultInputCallback:Function;
		private var _mainConsoleView:ConsoleView;
		
		//} end members
		//{ Instance
		/**
		 * Creates a new DConsole instance. 
		 * This class is intended to always be on top of the stage of the application it is associated with.
		 * Using the DConsole.instance getter is recommended
		 */
		public function DConsole() 
		{		
			//Prepare logging
			Logging.logBinding = new ConsoleLogBinding();
			
			_persistence = new PersistenceManager(this);
			
			_logManager = new DLogManager();
			_mainConsoleView = new ConsoleView(this);
			
			output.currentLog = _logManager.currentLog;
			
			input.inputTextField.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			
			tabChildren = tabEnabled = false;
			
			
			_autoCompleteManager = new AutocompleteManager(input.inputTextField);
			_scopeManager = new ScopeManager(this, _autoCompleteManager);
			_autoCompleteManager.setDictionary(_globalDictionary);
			_referenceManager = new ReferenceManager(this, _scopeManager);
			_plugManager = new PluginManager(_scopeManager, _referenceManager, this, _topLayer, _bgLayer, _consoleBackground, _logManager);
			_commandManager = new CommandManager(this, _persistence, _referenceManager, _plugManager);
			
			addChild(_bgLayer);
			addChild(_mainConsoleView);
			addChild(_topLayer);
			_dockingGuides = new DockingGuides();
			addChild(_dockingGuides);
			
			_toolTip = new ToolTip();
			
			input.addEventListener(Event.CHANGE, updateAssistantText);
			scaleHandle.addEventListener(Event.CHANGE, onScaleHandleDrag, false, 0, true);
			
			PimpCentral.addCallback(Notifications.SCOPE_CHANGE_REQUEST, onScopeChangeRequest);
			PimpCentral.addCallback(Notifications.EXECUTE_STATEMENT, onExecuteStatementNotification);
			
			KeyboardManager.instance.addKeyboardShortcut(_keystroke, _modifier, toggleDisplay); //  [CTRL+SHIFT, ENTER]); //default keystroke
			
			_callCommand = new FunctionCallCommand("call", _scopeManager.callMethodOnScope, "Introspection", "Calls a method with args within the current introspection scope");
			_setCommand = new FunctionCallCommand("set", _scopeManager.setPropertyOnObject, "Introspection", "Sets a variable within the current introspection scope");
			_getCommand = new FunctionCallCommand("get", _scopeManager.getPropertyOnObject, "Introspection", "Prints a variable within the current introspection scope");
			_selectCommand = new FunctionCallCommand("select", select, "Introspection", "Selects the specified object or reference by identifier as the current introspection scope");
			
			print("Welcome to Doomsday Console II - www.doomsday.no",ConsoleMessageTypes.SYSTEM);
			print("Today is " + new Date().toString(),ConsoleMessageTypes.SYSTEM);
			print("Console version " + Version.Major+"."+Version.Minor+" rev"+Version.Revision, ConsoleMessageTypes.SYSTEM);
			print("Player version " + Capabilities.version, ConsoleMessageTypes.SYSTEM);
			
			setupDefaultCommands();
			setRepeatFilter(ConsoleMessageRepeatMode.STACK);
			
			
			addChild(_toolTip);
						
			visible = false;
			
			print("Ready. Type help to get started.", ConsoleMessageTypes.SYSTEM);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onTextInput(e:TextEvent):void 
		{
			if (_cancelNextSpace) {
				e.preventDefault();
				_cancelNextSpace = false;
			}
		}
		public function get currentScope():IntrospectionScope {
			return _scopeManager.currentScope;
		}
		
		private function onExecuteStatementNotification(md:MessageData):void
		{
			executeStatement(String(md.data));
		}
		
		private function onScopeChangeRequest(md:MessageData):void
		{
			select(md.data);
		}
		
		private function ceaseFrameUpdates():void
		{
			removeEventListener(Event.ENTER_FRAME, frameUpdate);
		}
		
		private function beginFrameUpdates():void
		{
			addEventListener(Event.ENTER_FRAME, frameUpdate,false,0,true);
		}
		
		private function frameUpdate(e:Event):void 
		{
			_plugManager.update();
			view.inspector.onFrameUpdate(e);
			PimpCentral.send(Notifications.FRAME_UPDATE, null, this);
		}
		
		/**
		 * @readonly lock
		 */ 
		public function get lock():ConsoleLock{
			return _lock;
		}
		
		/**
		 * Change keyboard shortcut
		 */ 
		public function changeKeyboardShortcut(keystroke:uint, modifier:uint):void {
			KeyboardManager.instance.addKeyboardShortcut(keystroke, modifier, this.toggleDisplay, true);
		}
				
		private function setupDefaultCommands():void 
		{
			//addCommand(new FunctionCallCommand("consoleHeight", setHeight, "View", "Change the number of lines to display. Example: setHeight 5"));
			createCommand("about", about, "System", "Credits etc");
			createCommand("clear", clear, "View", "Clear the console");
			createCommand("timestampDisplay", output.toggleTimestamp, "View", "Toggle display of message timestamp");
			createCommand("help", getHelp, "System", "Output basic instructions");
			createCommand("clearhistory", _persistence.clearHistory, "System", "Clears the stored command history");
			//addCommand(new FunctionCallCommand("dock", dock, "System", "Docks the console to either 'top'(default) or 'bottom'"));
			createCommand("maximizeConsole", maximize,"System","Sets console height to fill the screen");
			createCommand("minimizeConsole", minimize, "System", "Sets console height to 1");
			createCommand("toggleQuickSearch", toggleQuickSearch, "System", "Toggles ctrl+space to search commands and methods for the current word");
			createCommand("setRepeatFilter", setRepeatFilter, "System", "Sets the repeat message filter; 0 - Stack, 1 - Ignore, 2 - Passthrough");
			createCommand("toggleLineNumbers", output.toggleLineNumbers, "System", "Toggles the display of line numbers");
			createCommand("repeat", repeatCommand, "System", "Repeats command string X Y times");
			addCommand(new FunctionCallCommand("reset", resetConsole, "System", "Resets and clears the console"), false);

			if (Capabilities.isDebugger) {
				print("	Debugplayer commands added", ConsoleMessageTypes.SYSTEM);
				createCommand("gc", System.gc, "System", "Forces a garbage collection cycle");
			}
			if (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "External") {
				print("	Standalone commands added", ConsoleMessageTypes.SYSTEM);
				createCommand("quitapp", quitCommand, "System", "Quit the application");
			}			
			createCommand("plugins", _plugManager.printPluginInfo, "Plugins", "Lists enabled plugin information");
			
			createCommand("commands", _commandManager.listCommands, "Utility", "Output a list of available commands. Add a second argument to search.");
			createCommand("search", searchCurrentLog, "Utility", "Searches the current log for a string and scrolls to the first matching line");
			createCommand("addSearch", addSearch, "Utility", "Adds a search tab for the given term");
			//createCommand("goto", output.goto, "Utility", "Scrolls to the specified line, if possible"); //TODO: Current enter key behavior overrides this one. Bummer.
			//createCommand("getLoader", getLoader, "Utility", "Returns a 'dumb' Loader getting data from the url X");
			createCommand("toClipboard", toClipBoard, "Utility", "Takes value X and puts it in the system clipboard (great for grabbing command XML output)");
			createCommand("toggleTags", toggleTags, "System", "Toggles the display of tags");
			createCommand("tag", selectTag, "System", "Quick-select a tag [x]");
			
			addCommand(_callCommand);
			addCommand(_getCommand);
			addCommand(_setCommand);
			addCommand(_selectCommand);
			
			createCommand("root", _scopeManager.selectBaseScope, "Introspection", "Selects the stage as the current introspection scope");
			createCommand("parent", _scopeManager.up, "Introspection", "(if the current scope is a display object) changes scope to the parent object");
			createCommand("children", _scopeManager.printChildren, "Introspection", "Get available children in the current scope");
			createCommand("variables", _scopeManager.printVariables, "Introspection", "Get available simple variables in the current scope");
			createCommand("complex", _scopeManager.printComplexObjects, "Introspection", "Get available complex variables in the current scope");
			createCommand("scopes", _scopeManager.printDownPath, "Introspection", "List available scopes in the current scope");
			createCommand("methods", _scopeManager.printMethods, "Introspection", "Get available methods in the current scope");
			createCommand("updateScope", _scopeManager.updateScope, "Introspection", "Gets changes to the current scope tree");
			
			createCommand("referenceThis", _referenceManager.getReference, "Referencing", "Stores a weak reference to the current scope in a specified id (referenceThis 1)");
			createCommand("getReference", _referenceManager.getReferenceByName, "Referencing", "Stores a weak reference to the specified scope in the specified id (getReference scopename 1)");
			createCommand("listReferences", _referenceManager.printReferences, "Referencing", "Lists all stored references and their IDs");
			createCommand("clearAllReferences", _referenceManager.clearReferences, "Referencing", "Clears all stored references");
			createCommand("clearReference", _referenceManager.clearReferenceByName, "Referencing", "Clears the specified reference");
			
			createCommand("loadTheme", _styleManager.load, "Theme", "Loads theme xml from urls; [x] theme [y] color table");
			
		}
		
		private function get toolBar():ConsoleToolbar {
			return _mainConsoleView.toolbar;
		}
		private function get filterTabs():FilterTabRow {
			return _mainConsoleView.filtertabs;
		}
		private function get output():OutputField {
			return _mainConsoleView.output;
		}
		private function get scaleHandle():ScaleHandle {
			return _mainConsoleView.scaleHandle;
		}
		private function get assistant():Assistant {
			return _mainConsoleView.assistant;
		}
		private function get input():InputField {
			return _mainConsoleView.input;
		}		
		
		private function selectTag(tag:String):void 
		{
			
		}
		
		private function toggleTags():void
		{
			view.output.showTag = !view.output.showTag;
			view.output.update();
		}
		
		private function resetConsole():void
		{
			persistence.clearAll();
			view.splitRatio = persistence.verticalSplitRatio.value;
			onStageResize();
			_logManager.currentLog.clear();
			_logManager.clearFilters();
			addSystemMessage("GUI and history reset");
		}
		
		private function about():void
		{
			addSystemMessage("Doomsday Console II");
			addSystemMessage("\t\tversion " + Version.Major + "." + Version.Minor + " revision " + Version.Revision);
			addSystemMessage("\t\tconcept and development by www.doomsday.no & www.furusystems.com");
			addSystemMessage("\t\t\t\tAndreas Ronning, Cristobal Dabed, Richard Oiestad");
			addSystemMessage("\t\t\tSpecial thanks to");
			addSystemMessage("\t\t\t\tJim Cheng, Oyvind Nordhagen, Miha Lunar, Kieran Foster");
			addSystemMessage("\t\t\t\tJohn Davies, and all of IRC EFNet #actionscript");
		}
		
		private function addSearch(term:String):void
		{
			_logManager.addFilter(new DLogFilter(term));
		}
		public function searchCurrentLog(term:String):void
		{
			var idx:int = _logManager.searchCurrentLog(term);
			if(idx>-1){
				output.scrollToLine(idx);
				//print("'" + term + "' found in log "+_logManager.currentLog+" at line " + idx);
			}else {
				addErrorMessage("Not found");
			}
		}
		
		public function get currentLog():DConsoleLog {
			return _logManager.currentLog;
		}
		

		
		private function toClipBoard(str:String):void {
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, str);
		}
			
		private function getLoader(url:String):Loader
		{
			var l:Loader = new Loader();
			l.load(new URLRequest(url));
			return l;
		}
		
		private function repeatCommand(cmd:String,count:int = 1):void
		{
			for (var i:int = 0; i < count; i++) 
			{
				executeStatement(cmd);
			}
		}
		
		public function select(target:*):void
		{
			if (_scopeManager.currentScope == target) return;
			try{
				_scopeManager.setScopeByName(String(target));
			}catch (e:Error) {
				try {
					_referenceManager.setScopeByReferenceKey(target);
				}catch (e:Error) {
					try {
						if (typeof target == "string") {
							throw new Error();
						}
						_scopeManager.setScope(target);
					}catch (e:Error) {
						print("No such scope", ConsoleMessageTypes.ERROR);
					}
				}
			}
		}
		
		private function toggleQuickSearch():void
		{
			setQuickSearch(!_quickSearchEnabled);
		}
		private function onScaleHandleDrag(e:Event):void 
		
		{
			var my:Number;
			var eh:Number = 14;
		}
		private function quitCommand(code:int = 0):void
		{
			System.exit(code);
		}
		
		private function getHelp():void
		{
			addSystemMessage("Help");
			addSystemMessage("\tKeyboard commands");
			addSystemMessage("\t\tControl+Shift+Enter (default) -> Show/hide console");
			addSystemMessage("\t\tControl+Space -> (When out of focus) Set the keyboard focus to the input field");
			addSystemMessage("\t\tControl+Space -> (When in focus) Skip to end of line and append a space");
			addSystemMessage("\t\tControl+Space -> (While caret is on an unknown term) Context sensitive search");
			addSystemMessage("\t\tEnter -> Execute line");
			addSystemMessage("\t\tPage up/Page down -> Vertical scroll by page");
			addSystemMessage("\t\tArrow up -> Recall the previous executed line");
			addSystemMessage("\t\tArrow down -> Recall the more recent executed line");
			addSystemMessage("\t\tCtrl + Arrow keys -> Scroll");
			addSystemMessage("\t\tMouse functions");
			addSystemMessage("\t\tMousewheel -> Vertical scroll line by line");
			addSystemMessage("\t\tClick drag below the input line -> Change console height");
			addSystemMessage("\tMisc");
			addSystemMessage("\t\tUse the 'commands' command to list available commmands");
		}
		public function executeStatement(statement:String, echo:Boolean = false):*{
			if (echo) print(statement, ConsoleMessageTypes.USER);
			try{
				return _commandManager.tryCommand(statement);
			}catch (e:Error) {
				addErrorMessage(e.message+" '"+statement+"'");
			}
		}
		
		private function updateAssistantText(e:Event = null):void 
		{
			if (_overrideCallback != null) return;
			var cmd:ConsoleCommand;
			var helpText:String;
			try {
				cmd = _commandManager.parseForCommand(input.text);
				helpText = cmd.helpText;
			}catch (e:Error) {
				helpText = "";
			}
			var secondElement:String = TextUtils.parseForSecondElement(input.text);
			if(secondElement){
				if (cmd == _callCommand) {
					try{
						helpText = InspectionUtils.getMethodTooltip(_scopeManager.currentScope.obj, secondElement);
					}catch (e:Error) {
						helpText = cmd.helpText;
					}
				}else if (cmd == _setCommand || cmd == _getCommand) {
					try {
						helpText = InspectionUtils.getAccessorTooltip(_scopeManager.currentScope.obj, secondElement);
					}catch (e:Error) {
						helpText = cmd.helpText;
					}
				}
			}
			if (helpText != "") {
				assistant.text = "?	" + cmd.trigger + ": " + helpText;
			}else {
				assistant.clear();
			}
		}
		
		public function setScope(o:Object):void {
			_scopeManager.setScope(o);
		}
		
		public function createCommand(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
			addCommand(new FunctionCallCommand(triggerPhrase, func, commandGroup, helpText));
		}
		/**
		 * Add a custom command to the console
		 * @param	command
		 * An instance of FunctionCallCommand or ConsoleEventCommand
		 */
		public function addCommand(command:ConsoleCommand,includeInHistory:Boolean = true):void {
			try{
				_commandManager.addCommand(command,includeInHistory);
				_globalDictionary.addToDictionary(command.trigger);
			}catch (e:ArgumentError) {
				print(e.message, ConsoleMessageTypes.ERROR);
			}
		}
		public function removeCommand(trigger:String):void {
			_commandManager.removeCommand(trigger);
		}
		
		/**
		 * A generic function to add as listener to events you want logged
		 * @param	e
		 */
		public function onEvent(e:Event):void {
			print("Event: "+e.toString(),ConsoleMessageTypes.INFO);
		}
		private function createMessages(str:String, type:String, tag:String):Vector.<ConsoleMessage> {
			var out:Vector.<ConsoleMessage> = new Vector.<ConsoleMessage>();
			var split:Array = str.split("\n").join("\r").split("\r");
			if (split.join("").length < 1) return out;
			var date:String = String(new Date().getTime());
			var msg:ConsoleMessage;
			for (var i:int = 0; i < split.length; i++) 
			{
				var txt:String = split[i];
				if (txt.indexOf("com.furusystems.dconsole2") > -1 || txt.indexOf("adobe.com/AS3") > -1 || (ignoreBlankLines && txt.length<1)) continue;
				msg = new ConsoleMessage(txt, date, type, tag);
				out.push(msg);
			}
			return out;
		}
		
		public function createTypeFilter(type:String):void {
			_logManager.addFilter(new DLogFilter("", type));
		}
		public function createSearchFilter(term:String):void {
			_logManager.addFilter(new DLogFilter(term));
		}
		
		public function printTo(targetLog:String, str:String, type:String = ConsoleMessageTypes.INFO, tag:String = ""):void {
			var log:DConsoleLog = _logManager.getLog(targetLog);
			var messages:Vector.<ConsoleMessage> = createMessages(str, type, tag);
		}
		/**
		 * Add a message to the current console tab
		 * @param	str
		 * The string to be added. A timestamp is automaticaly prefixed
		 */
		public function print(str:String, type:String = ConsoleMessageTypes.INFO, tag:String = TAG ):void {
			//TODO: Per message, examine filters and append relevant messages to the relevant logs
			var _tagLog:DConsoleLog;
			if(tag!=TAG&&_autoCreateTagLogs){
				_tagLog = _logManager.getLog(tag);
			}
			var _rootLog:DConsoleLog = _logManager.rootLog;
			var messages:Vector.<ConsoleMessage> = createMessages(str, type, tag);
			var msg:ConsoleMessage;
			for (var i:int = 0; i < messages.length; i++) 
			{
				//break;
				msg = messages[i];
				if (_rootLog.prevMessage) {
					if (_rootLog.prevMessage.text == msg.text && _rootLog.prevMessage.tag == msg.tag && _rootLog.prevMessage.type == msg.type) { 
						switch(_repeatMessageMode) {
							case ConsoleMessageRepeatMode.STACK:
								_rootLog.prevMessage.repeatcount++;
								_rootLog.prevMessage.timestamp = msg.timestamp;
								_rootLog.setDirty();
								if (_tagLog) {
									_tagLog.setDirty();
								}
								continue;
							break;
							case ConsoleMessageRepeatMode.IGNORE:
								continue;
							break;
						}
					}
				}
				if (msg.type != ConsoleMessageTypes.USER) {
					var evt:Message;
					if (msg.type == ConsoleMessageTypes.ERROR) {
						evt = Notifications.ERROR;
					}else {
						evt = Notifications.NEW_CONSOLE_OUTPUT;
					}
					PimpCentral.send(evt, msg, this);
				}
				_rootLog.addMessage(msg);
				if (_tagLog) _tagLog.addMessage(msg);
			}
			output.update();
		}
		/**
		 * Clear the console
		 */
		public function clear():void {
			_logManager.currentLog.clear();
			output.drawMessages();
		}
		
		private function setupStageAlignAndScale():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			print("StageAlign set to TOP_LEFT, StageScaleMode set to NO_SCALE", ConsoleMessageTypes.SYSTEM);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			KeyboardManager.instance.setup(stage);
			if (stage.align != StageAlign.TOP_LEFT) {
				print("Warning: stage.align is not set to TOP_LEFT; This might cause scaling issues",ConsoleMessageTypes.ERROR);
			}
			if (stage.scaleMode != StageScaleMode.NO_SCALE) {
				print("Warning: stage.scaleMode is not set to NO_SCALE; This might cause scaling issues",ConsoleMessageTypes.ERROR);
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onStageResize);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_scopeManager.selectBaseScope();
			
			onStageResize(e);
		}
		
		private function onStageResize(e:Event = null):void 
		{
			_mainConsoleView.consolidateView();
			_dockingGuides.resize();
		}
		
		private function doSearch(searchString:String,includeAccessors:Boolean = false, includeCommands:Boolean = true,includeScopeMethods:Boolean = false):void
		{
			if (searchString.length < 1) return;
			var found:Boolean = false;
			var result:Vector.<String>;
			var maxrow:int = 4;
			if(includeScopeMethods){
				result = _scopeManager.doSearch(searchString,ScopeManager.SEARCH_METHODS);
				var out:String = "";
				var count:int = 0;
				if(result.length>0){
					print("Scope methods matching '" + searchString + "'", ConsoleMessageTypes.SYSTEM);
					for (var i:int = 0; i < result.length; i++) 
					{
						out += result[i] + " ";
						count++;
						if (count > maxrow) {
							count = 0;
							print(out, ConsoleMessageTypes.INFO);
							out = "";
						}
					}
					if (out != "") print(out, ConsoleMessageTypes.INFO);
					found = true;
				}
			}
			if(includeCommands){
				result = _commandManager.doSearch(searchString);
				count = 0;
				out = "";
				if(result.length>0){
					print("Commands matching '" + searchString + "'", ConsoleMessageTypes.SYSTEM);
					for (i = 0; i < result.length; i++) 
					{
						out += result[i] + " ";
						count++;
						if (count > maxrow) {
							count = 0;
							print(out, ConsoleMessageTypes.INFO);
							out = "";
						}
					}
					if (out != "") print(out, ConsoleMessageTypes.INFO);
					found = true;
				}
			}
			if (includeAccessors){
				result = _scopeManager.doSearch(searchString,ScopeManager.SEARCH_ACCESSORS);
				count = 0;
				out = "";
				if(result.length>0){
					print("Scope accessors matching '" + searchString + "'", ConsoleMessageTypes.SYSTEM);
					for (i = 0; i < result.length; i++) 
					{
						out += result[i] + " ";
						count++;
						if (count > maxrow) {
							count = 0;
							print(out, ConsoleMessageTypes.INFO);
							out = "";
						}
					}
					if (out != "") print(out, ConsoleMessageTypes.INFO);
					found = true;
				}
			}
			result = _scopeManager.doSearch(searchString,ScopeManager.SEARCH_CHILDREN);
			count = 0;
			out = "";
			if(result.length>0){
				print("Children matching '" + searchString + "'", ConsoleMessageTypes.SYSTEM);
				for (i = 0; i < result.length; i++) 
				{
					out += result[i] + " ";
					count++;
					if (count > maxrow) {
						count = 0;
						print(out, ConsoleMessageTypes.INFO);
						out = "";
					}
				}
				if (out != "") print(out, ConsoleMessageTypes.INFO);
				found = true;
			}
			if (!found) {
				print("No matches for '" + searchString + "'",ConsoleMessageTypes.ERROR);
			}
		
		}
		
		
		private function get currentMessageLogVector():Vector.<ConsoleMessage> {
			return _logManager.currentLog.messages;
		}
		
		public function show():void {
			if (!stage) return;
			if(!visible) toggleDisplay();
		}
		public function hide():void {
			if (!stage) return;
			if (visible) toggleDisplay();
		}
		override public function get visible():Boolean { return _visible; }
		
		override public function set visible(value:Boolean):void 
		{
			_visible = value;
			if (_visible) view.show();
			else view.hide();
		}
		
		public function set isVisible(b:Boolean):void {
			_isVisible = b;
			super.visible = _isVisible;
		}
		public function get isVisible():Boolean {
			return _isVisible;
		}
		public function toggleDisplay(e:Event = null):void
		{
			// Return if locked 
			if(lock.locked){
				return; 
			}
			
			visible = !visible;
			var i:int;
			var bounds:Rectangle = _persistence.rect;
			if (visible) {
				if (!_initialized) {
					initialize();
				}
				if (parent) {
					parent.addChild(this);
				}
				input.focus();
				input.text = "";
				updateAssistantText();
				beginFrameUpdates();
				PimpCentral.send(Notifications.CONSOLE_SHOW, null, this);
			}else {
				ceaseFrameUpdates();
				PimpCentral.send(Notifications.CONSOLE_HIDE, null, this);
			}
		}
		
		private function initialize():void
		{
			_initialized = true;
			if (!_styleManager.themeLoaded) {
				_styleManager.load();
			}
			_mainConsoleView.consolidateView();
		}
		override public function get height():Number { return _mainConsoleView.height; }
		
		override public function set height(value:Number):void 
		{
			_mainConsoleView.height = value;
		}
		override public function get width():Number { return _mainConsoleView.rect.width; }
		
		override public function set width(value:Number):void 
		{
			_mainConsoleView.width = value;
		}
		
		public function setQuickSearch(newvalue:Boolean = true):void {
			_quickSearchEnabled = newvalue;
			print("Quick-searching: " + _quickSearchEnabled, ConsoleMessageTypes.SYSTEM);
		}
		
		//minmaxing size
		public function maximize():void {
			if (!stage) return;
			_mainConsoleView.maximize();
		}
		public function minimize():void
		{
			_mainConsoleView.minimize();
		}
		
		//keyboard event handlers
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if (visible) {
				var cmd:String = "";
				var _testCmd:Boolean = false;
				if (e.keyCode == Keyboard.UP) {
					if (!e.ctrlKey) {
						cmd = _persistence.historyUp();
						_testCmd = true;
					}else {
						return;
					}
					
				}else if (e.keyCode == Keyboard.DOWN) {
					if (!e.ctrlKey) {
						cmd = _persistence.historyDown();
						_testCmd = true;
					}else {
						return;
					}
				}
				if (_testCmd) {
					input.text = cmd;
					input.focus();
					var spaceIndex:int = input.text.indexOf(" ");
					
					if (spaceIndex>-1) {
						input.inputTextField.setSelection(input.text.indexOf(" ") + 1, input.text.length);
					}else{
						input.inputTextField.setSelection(0, input.text.length);
					}
					updateAssistantText();
				}
			}
		}
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (!visible) return; //Ignore if invisible
			if (e.keyCode == Keyboard.SPACE && e.ctrlKey) {
				_cancelNextSpace = true;
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();
				if (visible && stage.focus != input) {
					input.focus();
				}else if (stage.focus == input) {
				}
					
				doComplete();				
				return;
			}
			if (e.keyCode == Keyboard.ESCAPE) {
				PimpCentral.send(Notifications.ESCAPE_KEY, null, this);
				return;
			}
			if (e.ctrlKey) {
				switch(e.keyCode) {
					case Keyboard.UP:
					output.scroll(1);
					return
					case Keyboard.DOWN:
					output.scroll(-1);
					return;
					case Keyboard.LEFT:
					//TODO: previous tab
					break;
					case Keyboard.RIGHT:
					//TODO: next tab
					break;
				}
			}
			if (e.keyCode == Keyboard.ENTER) {
				if (input.text.length < 1) {
					input.focus();
					return;
				}
				var success:Boolean = false;
				print("'" + input.text + "'", ConsoleMessageTypes.USER);
				if (_overrideCallback != null) {
					_overrideCallback(input.text);
					success = true;
				}else{
					try {
						var attempt:* = executeStatement(input.text);
						success = true;
					}catch (error:ConsoleAuthError) {
						//TODO: This needs a more graceful solution. Dual auth error prints = lame
					}catch (error:CommandError) {
						if (_defaultInputCallback != null) {
							var ret:* = _defaultInputCallback(input.text);
							if (ret) {
								print(ret, ConsoleMessageTypes.INFO);
							}
						}else {
							print(error.message, ConsoleMessageTypes.ERROR);
						}
					}catch (error:Error) {
						print(error.message, ConsoleMessageTypes.ERROR);
					}
				}
				output.scrollToBottom();
				input.clear();
				updateAssistantText();
			}else if (e.keyCode == Keyboard.PAGE_DOWN) {
				output.scroll(-output.numLines);
			}else if (e.keyCode == Keyboard.PAGE_UP) {
				output.scroll(output.numLines);
			}else if (e.keyCode == Keyboard.HOME) {
				output.scrollIndex = 0;
			}else if (e.keyCode == Keyboard.END) {
				output.scrollIndex = output.maxScroll;
			}
		}
		
		/**
		 * Sets the handling method for repeated messages with identical values
		 * @param	filter
		 * One of the 3 modes described in the no.doomsday.console.core.output.MessageRepeatMode enum
		 */
		public function setRepeatFilter(filter:int):void {
			switch(filter) {
				case ConsoleMessageRepeatMode.IGNORE:
				print("Repeat mode: Repeated messages are now ignored",ConsoleMessageTypes.SYSTEM);
				break;
				case ConsoleMessageRepeatMode.PASSTHROUGH:
				print("Repeat mode: Repeated messages are now allowed",ConsoleMessageTypes.SYSTEM);
				break;
				case ConsoleMessageRepeatMode.STACK:
				print("Repeat mode: Repeated messages are now stacked",ConsoleMessageTypes.SYSTEM);
				break;
				default:
				throw new Error("Unknown filter type");
			}
			_repeatMessageMode = filter;
		}
		
		private function doComplete():void
		{
			var flag:Boolean = false; 
			
			if (input.text.length < 1) return;
			var word:String = input.wordAtCaret;
			
			var isFirstWord:Boolean = input.text.lastIndexOf(word) < 1;
			var firstWord:String;
			if (isFirstWord) {
				firstWord = word;
			}else {
				firstWord = input.firstWord;
			}
			if (_autoCompleteManager.isKnown(word, !isFirstWord, isFirstWord)||!isNaN(Number(word))) {
				//this word is okay, so accept the completion
				var wordIndex:int = input.firstIndexOfWordAtCaret;
				//is there currently a selection?
				if (input.inputTextField.selectedText.length > 0) {
					input.moveCaretToIndex(input.selectionBeginIndex);
					wordIndex = input.selectionBeginIndex;
				}else if (input.text.charAt(input.caretIndex) == " " && input.caretIndex != input.text.length - 1) { 
					input.moveCaretToIndex(input.caretIndex - 1);
				}
				
				word = input.wordAtCaret;
				wordIndex = input.caretIndex;
				
				//case correction
				var temp:String = input.text;
				try {
					temp = temp.replace(word, _autoCompleteManager.correctCase(word));
					input.text = temp;
				}catch (e:Error) {
				}
				
				//is there a word after the current word?
				if (wordIndex + word.length < input.text.length - 1) {
					input.moveCaretToIndex(wordIndex + word.length);
					input.selectWordAtCaret();
					
				}else {
					//if it's the last word
					if (input.text.charAt(input.text.length-1)!=" ") {
						input.inputTextField.appendText(" ");
					}
					input.caretToEnd();
				}
			}else{
				var getSet:Boolean = (firstWord == _getCommand.trigger || firstWord == _setCommand.trigger);
				var call:Boolean = (firstWord == _callCommand.trigger);
				var select:Boolean = (firstWord == _selectCommand.trigger);
				doSearch(word, !isFirstWord || select, isFirstWord, call);
				
				if (flag) {
					input.selectWordAtCaret();
				}else{
					input.moveCaretToIndex(input.firstIndexOfWordAtCaret + input.wordAtCaret.length);
				}
			}
		}
		
		public function get view():ConsoleView { return _mainConsoleView; }
		
		public function get logs():DLogManager { return _logManager; }
		
		public function get defaultInputCallback():Function { return _defaultInputCallback; }
		
		public function set defaultInputCallback(value:Function):void 
		{
			if (value.length != 1) throw new Error("Default input callback must take exactly one argument");
			_defaultInputCallback = value;
		}
		
		public function lockOutput():void
		{
			output.lockOutput();
		}
		
		public function unlockOutput():void
		{
			output.unlockOutput();
		}
		
		public function loadStyle(themeURI:String = null, colorsURI:String = null):void 
		{
			_styleManager.load(themeURI, colorsURI);
		}
		
		public function get scopeManager():ScopeManager
		{
			return _scopeManager;
		}
		
		public function get persistence():PersistenceManager { return _persistence; }
		
		public function get pluginManager():PluginManager { return _plugManager; }
		
		public function setHeaderText(title:String):void
		{
			_mainConsoleView.toolbar.setTitle(title);
		}
		
		public function setOverrideCallback(callback:Function):void 
		{
			_overrideCallback = callback;
		}
		
		public function clearOverrideCallback():void 
		{
			_overrideCallback = null;
		}
		//}
		
		//{ Statics
		
		/**
		 * If true, the console instance cannot be selected by the console. The default is true, which is recommended.
		 */
		public static var CONSOLE_SAFE_MODE:Boolean = true;
		
		/**
		 * Removes the default input callback
		 * @see setDefaultInputCallback
		 */
		public static function clearDefaultInputCallback():void {
			console.defaultInputCallback = null;
		}
		/**
		 * Declares a default input callback
		 * This callback will receive any input the console doesn't understand
		 * @param	callback
		 */
		public static function setDefaultInputCallback(callback:Function):void {
			if (callback.length != 1) throw new Error("The default input callback must accept exactly 1 string argument");
			console.defaultInputCallback = callback;
		}
		 
		private static var _instance:DConsole;
		private static var keyboardShortcut:Array = [];
		
		/**
		 * The internal tag used as the defalt for logging
		 */
		public static const TAG:String = "DConsole";
		
		/**
		 * Returns the object currently selected as the console scope
		 * @return An object
		 * @see select
		 */
		public static function getCurrentTarget():Object {
			return (console as DConsole).scopeManager.currentScope.obj;
		}
		/**
		 * Get the singleton IConsole instance
		 */
		public static function get console():IConsole {
			if (!_instance) {
				_instance = new DConsole();
				if(keyboardShortcut.length > 0){
					console.changeKeyboardShortcut(keyboardShortcut[0], keyboardShortcut[1]);
				}
			}
			return _instance;
		}
		/**
		 * Sets the console title bar text
		 * @param	title
		 */
		public static function setTitle(title:String):void {
			console.setHeaderText(title);
		}
		/**
		 * Get the singleton console view display object
		 */
		public static function get view():DisplayObject {
			return console as DisplayObject;
		}
		/**
		 * Adds a message
		 * @param	msg
		 * The text to output
		 * @param	type
		 * The message type, one of the options available in ConsoleMessageTypes
		 * @param	tag
		 * The string tag for identifying the source or topic of this message
		 */
		public static function print(msg:String, type:String = ConsoleMessageTypes.INFO,tag:String = TAG):void {
			console.print(msg, type, tag);
		}
		/**
		 * Add a message with system color coding
		 * @param	msg
		 * @param	tag
		 * The string tag for identifying the source or topic of this message
		 */
		public static function addSystemMessage(msg:String,tag:String = TAG):void {
			console.print(msg, ConsoleMessageTypes.SYSTEM, tag);
		}
		
		/**
		 * Add a message with warning color coding
		 * @param	msg
		 * @param	tag
		 * The string tag for identifying the source or topic of this message
		 */
		public static function addWarningMessage(msg:String,tag:String = TAG):void {
			console.print(msg, ConsoleMessageTypes.WARNING, tag);
		}
		/**
		 * Add a message with error color coding
		 * @param	msg
		 * @param	tag
		 * The string tag for identifying the source or topic of this message
		 */
		public static function addErrorMessage(msg:String,tag:String = TAG):void {
			console.print(msg, ConsoleMessageTypes.ERROR, tag);
		}
		
		/**
		 * Add a message with error color coding
		 * @param	msg
		 * @param	tag
		 * The string tag for identifying the source or topic of this message
		 */
		public static function addHoorayMessage(msg:String,tag:String = TAG):void {
			console.print(msg, ConsoleMessageTypes.HOORAY, tag);
		}
		/**
		 * Add a message with fatal error color coding (incredibly vile)
		 * @param	msg
		 * @param	tag
		 * The string tag for identifying the source or topic of this message
		 */
		public static function addFatalMessage(msg:String,tag:String = TAG):void {
			console.print(msg, ConsoleMessageTypes.FATAL,tag)
		}
		/**
		 * Create a command for calling a specific function
		 * @param	triggerPhrase
		 * The trigger word for the command
		 * @param	func
		 * The function to call
		 * @param	commandGroup
		 * Optional: The group name you want the command sorted under
		 * @param	helpText
		 * Optional: Any text you want displayed in the assistant when this command is being typed
		 */
		public static function createCommand(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
			console.createCommand(triggerPhrase, func, commandGroup, helpText);
		}
		/**
		 * Removes a command keyed by its trigger phrase
		 * @param	triggerPhrase
		 */
		public static function removeCommand(triggerPhrase:String):void {
			console.removeCommand(triggerPhrase);
		}
		/**
		 * Use this to print event messages on dispatch 
		 * (addEventListener(Event.CHANGE, ConsoleUtil.onEvent))
		 */
		public static function get onEvent():Function {
			return console.onEvent;
		}
		/**
		 * Clear the console log(s)
		 */
		public static function get clear():Function {
			return console.clear;
		}
		/**
		 * Registers plugins and plugin bundles by their class types
		 * A plugin is an implementor of any interface deriving from IDConsolePlugin
		 * A plugin bundle is an implementor of IPluginBundle
		 * @param	...args
		 * @example 
		 * The following code shows the BasicPlugins bundle being registered, alongside the JSRouterUtil plugin
		 * <listing>
		 * DConsole.registerPlugins(AllPlugins,JSRouterUtil);
		 * </listing>
		 */
		public static function registerPlugins(...args:Array):void {
			for (var i:int = 0; i < args.length; i++) 
			{
				(console as DConsole).pluginManager.registerPlugin(args[i]);
			}
		}
		
		/**
		 * Sets the specified object as the console's current scope
		 * @param	object
		 * @see getCurrentTarget
		 */
		public static function select(object:Object):void {
			console.select(object);
		}
		/**
		 * Show the console
		 * @see hide
		 */
		public static function show():void {
			console.show();
		}
		/**
		 * Hide the console
		 * @see show
		 */
		public static function hide():void {
			console.hide();
		}
		/**
		 * Execute a console command statement
		 * @param	statement
		 * The statement, eg. "setFrameRate 60" etc
		 * @param	echo
		 * Wether to echo this statement in the console (default false)
		 * @return
		 * The return value of the executed statement, if any.
		 */
		public static function executeStatement(statement:String, echo:Boolean = false):* {
			return console.executeStatement(statement, echo);
		}
		
		/**
		 * Set keyboard shortcut
		 * 
		 * @param keystroke	The keystroke
		 * @param modifier	The modifier
		 */ 
		public static function setKeyboardShortcut(keystroke:uint, modifier:uint):Boolean {
			var success:Boolean = false;
			/*
			 * If is a valid keyboard shortcut
			 *
			 * 1. If the console is not initialized store for later, and modify after creation.
			 * 2. If the console is initialized call instance.changeKeyboardShortcut
			 */
			if(KeyboardManager.instance.validateKeyboardShortcut(keystroke, modifier)){
				if(!_instance){
					keyboardShortcut = [keystroke, modifier];
				} else {
					console.changeKeyboardShortcut(keystroke, modifier);
				}
				success = true;
			}
			return success;
		}
		
		/**
		 * Change keyboard shortcut.
		 * 
		 * @param keystroke	The key
		 * @param modifier	The modifier 
		 */ 
		private static function changeKeyboardShortcut(keystroke:uint, modifier:uint):void {
			console.changeKeyboardShortcut(keystroke, modifier);
		}
		
		/**
		 * Declares an overriding callback for all console input
		 * While active, regular console input behavior will cease, and all text input will be passed to the specified callback
		 * @param	callback
		 */
		static public function setOverrideCallback(callback:Function):void 
		{
			console.setOverrideCallback(callback);
		}
		/**
		 * Removes the overriding callback set in setOverrideCallback
		 * @see setOverrideCallback
		 */
		static public function clearOverrideCallback():void {
			console.clearOverrideCallback();
		}
		
		/**
		 * Resets all persistent data (command history, console position, docking etc)
		 */
		static public function clearPersistentData():void 
		{
			DConsole(console).persistence.clearAll();
		}
		
		//TODO: Reimplement at instance level and delegate to static
		/**
		 * Lock
		 * 
		 * @param secret The secret to lock the console with.
		 */
		/*public static function lock(secret:String):void {
			lockWithKeyCodes(KeyBindings.toCharCodes(secret));
		}*/
		
		/**
		 * Lock with keyCodes
		 * 
		 * @param keyCodes The keyCodes to lock the console with.
		 */ 
		/*public static function lockWithKeyCodes(keyCodes:Array):void {
			console.lock.lock(keyCodes, console.toggleDisplay);
		}*/
		
		//}
	}
	
}