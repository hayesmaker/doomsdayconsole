﻿package no.doomsday.console
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.adobe.images.PNGEncoder;
	import flash.utils.getTimer;
	import net.hires.debug.ConsoleStats;
	import no.doomsday.console.commands.CommandManager;
	import no.doomsday.console.commands.ConsoleCommand;
	import no.doomsday.console.commands.FunctionCallCommand;
	import no.doomsday.console.controller.ControllerManager;
	import no.doomsday.console.gui.KeyStroke;
	import no.doomsday.console.gui.ScaleHandle;
	import no.doomsday.console.introspection.AccessorDesc;
	import no.doomsday.console.introspection.ChildScopeDesc;
	import no.doomsday.console.introspection.ScopeManager;
	import no.doomsday.console.introspection.InspectionUtils;
	import no.doomsday.console.introspection.MethodDesc;
	import no.doomsday.console.introspection.VariableDesc;
	import no.doomsday.console.math.MathUtils;
	import no.doomsday.console.measurement.MeasurementTool;
	import no.doomsday.console.messages.Message;
	import no.doomsday.console.messages.MessageRepeatMode;
	import no.doomsday.console.messages.MessageTypes;
	import no.doomsday.console.persistence.PersistenceManager;
	import no.doomsday.console.references.ReferenceManager;
	import no.doomsday.console.text.autocomplete.AutocompleteDictionary;
	import no.doomsday.console.text.autocomplete.AutocompleteManager;
	import no.doomsday.console.text.TextFormats;
	import no.doomsday.console.text.TextUtils;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import no.doomsday.input.keyboard.KeyboardManager;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class DConsole extends Sprite
	{
		//[Embed(source='../../../buildnumber.txt', mimeType='application/octet-stream')]
		//public static var BuildNumberFile:Class;
		private static var VERSION:String = "1.03a";
			
		private var consoleBg:Shape;
		private var textOutput:TextField;
		private var inputTextField:TextField;
		private var infoField:TextField;
		private var targetY:Number;
		private var infoTargetY:Number;
		private var scrollIndex:int = 0;
		private var scrollRange:int = 0;
		private var consoleHeight:Number = 5;
			
		private var messageLog:Vector.<Message>;
		private var commands:Vector.<ConsoleCommand>;
		
		private var mainConsoleContainer:Sprite;
		
		private var traceValues:Boolean = true;
		private var showTraceValues:Boolean = true;
		private var echo:Boolean = true;
		private var timeStamp:Boolean = false;
		private var prevHeight:int;
		
		private var measureBracket:MeasurementTool;
		
		private var parentTabEnabled:Boolean = true;
		private var parentTabChildren:Boolean = true;
		private var tabTimer:Timer;
		private var fileRef:FileReference;
		
		private var routingToJS:Boolean;
		private var alertingErrors:Boolean;
		
		private var autoCompleteManager:AutocompleteManager;
		private var globalDictionary:AutocompleteDictionary = new AutocompleteDictionary();
		
		private var scaleHandle:ScaleHandle;
		
		private var referenceManager:ReferenceManager;
		private var controllerManager:ControllerManager;
		private var scopeManager:ScopeManager;
		private var commandManager:CommandManager;
		
		private var locked:Boolean = false;
		private var persistence:PersistenceManager;
		
		private var callCommand:FunctionCallCommand;
		private var getCommand:FunctionCallCommand;
		private var setCommand:FunctionCallCommand;
		private var selectCommand:FunctionCallCommand;
		
		private var stats:ConsoleStats;
			
		public var tabSearchEnabled:Boolean = true;
		private var backgroundColor:uint = 0;
		private var backgroundAlpha:Number = 0.8;
		
		//temp; rough mechanic to ignore repeated prints
		private var previousPrintValues:String;
		private var previousMessage:Message;
		private var repeatMessageMode:int = MessageRepeatMode.STACK;
		private var keyboardManager:KeyboardManager;
		
		public var invokeKeyStroke:KeyStroke;
		
		private var DOCK_TOP:int = 0;
		private var DOCK_BOTTOM:int = 1;
		
		/**
		 * Creates a new DConsole instance. 
		 * This class is intended to always be on top of the stage of the application it is associated with.
		 * Using the ConsoleUtil.instance getter is recommended
		 * To toggle console visibility, hit shift+tab 
		 */
		public function DConsole() 
		{
			keyboardManager = new KeyboardManager();
			invokeKeyStroke = new KeyStroke(keyboardManager, Keyboard.TAB, Keyboard.SHIFT);
			
			visible = false;
			mainConsoleContainer = new Sprite();
			
			consoleBg = new Shape();
			var dropshadow:DropShadowFilter = new DropShadowFilter(4, 90, 0, 0.3, 0, 10);
			consoleBg.filters = [dropshadow];		
			
			textOutput = new TextField();
			textOutput.gridFitType = GridFitType.PIXEL;
			inputTextField = new TextField();
			inputTextField.border = true;
			inputTextField.borderColor = 0x333333;
			
			autoCompleteManager = new AutocompleteManager(inputTextField);
			autoCompleteManager.setDictionary(globalDictionary);
			
			persistence = new PersistenceManager(this);
			controllerManager = new ControllerManager();
			scopeManager = new ScopeManager(this, autoCompleteManager);
			referenceManager = new ReferenceManager(this,scopeManager);
			commandManager = new CommandManager(this, persistence, referenceManager);
			
			tabTimer = new Timer(50, 1);
			messageLog = new Vector.<Message>;
			fileRef = new FileReference();
			scaleHandle = new ScaleHandle();	
			
			infoField = new TextField();
			infoField.background = true;
			infoField.backgroundColor = 0x151515;
			infoField.tabEnabled = false;
			infoField.mouseEnabled = false;
			infoField.selectable = false;
			infoField.defaultTextFormat = TextFormats.debugTformatHelp;
			
			inputTextField.defaultTextFormat = TextFormats.debugTformatInput;
			inputTextField.multiline = false;
			inputTextField.type = TextFieldType.INPUT;
			inputTextField.background = true;
			inputTextField.backgroundColor = 0;
			inputTextField.tabEnabled = false;
					
			scaleHandle.addEventListener(Event.CHANGE, onScaleHandleDrag, false, 0, true);
			
			measureBracket = new MeasurementTool(this);
			measureBracket.visible = false;
			
			addChild(measureBracket);
			addChild(mainConsoleContainer);
			addChild(controllerManager);
			
			mainConsoleContainer.addChild(consoleBg);	
			mainConsoleContainer.addChild(textOutput);
			mainConsoleContainer.addChild(infoField);
			mainConsoleContainer.addChild(inputTextField);
			mainConsoleContainer.addChild(scaleHandle);
						
			stats = new ConsoleStats(this);
			
			tabTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetTab, false, 0, true);
			
			callCommand = new FunctionCallCommand("call", scopeManager.callMethodOnScope, "Introspection", "Calls a method with args within the current introspection scope");
			setCommand = new FunctionCallCommand("set", scopeManager.setAccessorOnObject, "Introspection", "Sets a variable within the current introspection scope");
			getCommand = new FunctionCallCommand("get", scopeManager.getAccessorOnObject, "Introspection", "Prints a variable within the current introspection scope");
			selectCommand = new FunctionCallCommand("select", doSelect, "Introspection", "Selects the specified object as the current introspection scope");
			
			print("Welcome",MessageTypes.SYSTEM);
			print("Today is " + new Date().toString(),MessageTypes.SYSTEM);
			print("Console version " + VERSION, MessageTypes.SYSTEM);
			print("Player version " + Capabilities.version, MessageTypes.SYSTEM);
			
			setupDefaultCommands();
			
			setRepeatFilter(MessageRepeatMode.STACK);
			print("Ready. Type help to get started.", MessageTypes.SYSTEM);
			
			calcHeight();
			
			inputTextField.addEventListener(Event.CHANGE, onInputFieldChange);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			textOutput.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		public function dock(value:String):void {
			value = value.toLowerCase();
			if (value == "bot" || value == "bottom") {
				persistence.dockState = DOCK_BOTTOM;
				print("Docking to bottom", MessageTypes.SYSTEM);
			}else {
				persistence.dockState = DOCK_TOP;
				print("Docking to top", MessageTypes.SYSTEM);
			}
			redraw();
		}
		
		public function setInvokeKeys(...keyCodes:Array):void {
			if (keyCodes.length > 0) {
				invokeKeyStroke.keyCodes = keyCodes;
			}
		}
		
		/**
		 * Sets the handling method for repeated messages with identical values
		 * @param	filter
		 * One of the 3 modes described in the no.doomsday.console.messages.MessageRepeatMode enum
		 */
		public function setRepeatFilter(filter:int):void {
			switch(filter) {
				case MessageRepeatMode.IGNORE:
				print("Repeat mode: Repeated messages are now ignored",MessageTypes.SYSTEM);
				break;
				case MessageRepeatMode.PASSTHROUGH:
				print("Repeat mode: Repeated messages are now allowed",MessageTypes.SYSTEM);
				break;
				case MessageRepeatMode.STACK:
				print("Repeat mode: Repeated messages are now stacked",MessageTypes.SYSTEM);
				break;
				default:
				throw new Error("Unknown filter type");
			}
			repeatMessageMode = filter;
		}
		public function getManagerRefs():Array {
			var a:Array = [];
			return [scopeManager, referenceManager, controllerManager, measureBracket];
		}
		
		
		
		
		private function setupDefaultCommands(addMath:Boolean = true):void {
			addCommand(new FunctionCallCommand("consoleheight", setHeight, "View", "Change the number of lines to display. Example: setHeight 5"));
			addCommand(new FunctionCallCommand("version", printVersion, "System", "Prints the welcome message"));
			addCommand(new FunctionCallCommand("dock", dock, "System", "Docks the console to either 'top'(default) or 'bottom'"));
			
			
			addCommand(new FunctionCallCommand("clearhistory", persistence.clearHistory, "System", "Clears the stored command history"));
			addCommand(new FunctionCallCommand("commands", commandManager.listCommands, "Utility", "Output a list of available commands"));
			addCommand(new FunctionCallCommand("help", getHelp, "Utility", "Output basic instructions"));
			addCommand(new FunctionCallCommand("stats", toggleStats, "Utility", "Toggles display of mrdoob Stats"));
			addCommand(new FunctionCallCommand("clear", clear, "View", "Clear the console"));
			addCommand(new FunctionCallCommand("echo", toggleEcho, "View", "Toggle display of user commands"));
			addCommand(new FunctionCallCommand("timestampDisplay", toggleTimestamp, "View", "Toggle display of message timestamp"));
			addCommand(new FunctionCallCommand("log", log, "Utility", "Save the complete console log for this session to an xml document"));
			addCommand(new FunctionCallCommand("measure", measureBracket.toggle, "Utility", "Creates a scalable measurement bracket widget. Hold shift to snap to 10s."));
			addCommand(new FunctionCallCommand("screenshot", screenshot, "Utility", "Save a png screenshot (sans console)"));
			addCommand(new FunctionCallCommand("toggleTrace", toggleTrace, "Trace", "Toggle reception of trace values"));
			addCommand(new FunctionCallCommand("toggleTraceDisplay", toggleTraceDisplay, "Trace", "Toggle display of trace values"));
			addCommand(new FunctionCallCommand("clearTrace", clearTrace, "Trace", "Clear trace cache"));
			addCommand(new FunctionCallCommand("enumerateFonts", TextUtils.listFonts, "Utility", "Lists font names available to this swf"));
			addCommand(new FunctionCallCommand("toggleTabSearch", toggleTabSearch, "Utility", "Toggles tabbing to search commands and methods for the current word"));
			addCommand(new FunctionCallCommand("setRepeatFilter", setRepeatFilter, "Utility", "Sets the repeat message filter; 0 - Stack, 1 - Ignore, 2 - Passthrough"));
			addCommand(new FunctionCallCommand("find", searchLog, "Utility", "Searches the log for a specified string and scrolls to the first matching line"));
			addCommand(new FunctionCallCommand("goto", goto, "Utility", "Scrolls to the specified line, if possible"));
			
			if (addMath) {	
				addCommand(new FunctionCallCommand("random", MathUtils.random, "Math", "Returns a number between X and Y. If Z is true, the value will be rounded. Defaults to 0 1 false"));
				addCommand(new FunctionCallCommand("sin", Math.sin, "Math", "Returns the sine of an angle measured in radians"));
				addCommand(new FunctionCallCommand("cos", Math.cos, "Math", "Returns the cosine of an angle measured in radians"));
				addCommand(new FunctionCallCommand("add", MathUtils.add, "Math", "Returns X + Y"));
				addCommand(new FunctionCallCommand("subtract", MathUtils.subtract, "Math", "Returns X - Y"));
				addCommand(new FunctionCallCommand("divide", MathUtils.divide, "Math", "Returns X / Y"));
				addCommand(new FunctionCallCommand("multiply", MathUtils.multiply, "Math", "Returns X * Y"));
			}

			addCommand(new FunctionCallCommand("capabilities", getCapabilities, "System", "Prints the system capabilities"));
			addCommand(new FunctionCallCommand("setupStage", setupStageAlignAndScale, "Stage", "Sets stage.align to TOP_LEFT and stage.scaleMode to NO_SCALE"));
			addCommand(new FunctionCallCommand("setFrameRate", setFramerate, "Stage", "Sets stage.frameRate"));
			
			addCommand(new FunctionCallCommand("showMouse", Mouse.show, "UI", "Shows the mouse cursor"));
			addCommand(new FunctionCallCommand("hideMouse", Mouse.hide, "UI", "Hides the mouse cursor"));
						
			addCommand(callCommand);
			addCommand(getCommand);
			addCommand(setCommand);
			addCommand(new FunctionCallCommand("root", scopeManager.selectBaseScope, "Introspection", "Selects the stage as the current introspection scope"));
			addCommand(selectCommand);
			//addCommand(new FunctionCallCommand("selectByReference", referenceManager.setScopeByReferenceKey, "Introspection", "Gets a stored reference and sets it as the current introspection scope"));
			addCommand(new FunctionCallCommand("parent", scopeManager.up, "Introspection", "(if the current scope is a display object) changes scope to the parent object"));
			addCommand(new FunctionCallCommand("children", scopeManager.printChildren, "Introspection", "Get available children in the current scope"));
			addCommand(new FunctionCallCommand("variables", scopeManager.printVariables, "Introspection", "Get available simple variables in the current scope"));
			addCommand(new FunctionCallCommand("complex", scopeManager.printComplexObjects, "Introspection", "Get available complex variables in the current scope"));
			addCommand(new FunctionCallCommand("scopes", scopeManager.printDownPath, "Introspection", "List available scopes in the current scope"));
			addCommand(new FunctionCallCommand("methods", scopeManager.printMethods, "Introspection", "Get available methods in the current scope"));
			addCommand(new FunctionCallCommand("updateScope", scopeManager.updateScope, "Introspection", "Gets changes to the current scope tree"));
			addCommand(new FunctionCallCommand("alias", alias, "Introspection", "'alias methodName triggerWord' Create a new command shortcut to the specified function"));
			
			addCommand(new FunctionCallCommand("referenceThis", referenceManager.getReference, "Referencing", "Stores a weak reference to the current scope in a specified id (referenceThis 1)"));
			addCommand(new FunctionCallCommand("getReference", referenceManager.getReferenceByName, "Referencing", "Stores a weak reference to the specified scope in the specified id (getReference scopename 1)"));
			addCommand(new FunctionCallCommand("listReferences", referenceManager.printReferences, "Referencing", "Lists all stored references and their IDs"));
			addCommand(new FunctionCallCommand("clearAllReferences", referenceManager.clearReferences, "Referencing", "Clears all stored references"));
			addCommand(new FunctionCallCommand("clearReference", referenceManager.clearReferenceByName, "Referencing", "Clears the specified reference"));
			
			addCommand(new FunctionCallCommand("maximizeConsole", maximize,"System","Sets console height to fill the screen"));
			addCommand(new FunctionCallCommand("minimizeConsole", minimize,"System","Sets console height to 1"));
			
			addCommand(new FunctionCallCommand("createController", createController, "Controller", "Create a widget for changing properties on the current scope (createController width height for instance)"));
				
			if(ExternalInterface.available){
				print("	Externalinterface available, commands added", MessageTypes.SYSTEM);
				addCommand(new FunctionCallCommand("routeToJS", routeToJS, "ExternalInterface", "Toggle output to JS console"));
				addCommand(new FunctionCallCommand("alertErrors", alertErrors, "ExternalInterface", "Toggle JS alert on errors"));
			}
			if (Capabilities.isDebugger) {
				print("	Debugplayer commands added", MessageTypes.SYSTEM);
				addCommand(new FunctionCallCommand("debug_gc", System.gc, "System", "Forces a garbage collection cycle"));
				addCommand(new FunctionCallCommand("debug_pause", System.pause, "System", "Pauses the Flash Player. After calling this method, nothing in the player continues except the delivery of Socket events"));
				addCommand(new FunctionCallCommand("debug_resume", System.resume, "System", "Resumes the Flash Player after using 'pause'"));
			}
			if (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "External") {
				print("	Standalone commands added", MessageTypes.SYSTEM);
				addCommand(new FunctionCallCommand("quitapp", quitCommand, "System", "Quit the application"));
			}
		}
	
		private function doSelect(target:String):void
		{
			try{
				scopeManager.setScopeByName(target);
			}catch (e:Error) {
				try{
					referenceManager.setScopeByReferenceKey(target);
				}catch (e:Error) {
					print("No such scope", MessageTypes.ERROR);
				}
			}
		}
		
		private function toggleTabSearch():void
		{
			setTabSearch(!tabSearchEnabled);
		}
		
		private function printVersion():void
		{
			print("Player version " + Capabilities.version, MessageTypes.SYSTEM);
			print("Console version " + VERSION, MessageTypes.SYSTEM);
		}
		
		private function createController(...properties:Array):void
		{
			controllerManager.createController(scopeManager.currentScope.obj, properties);
		}
		
		private function onScaleHandleDrag(e:Event):void 
		{
			var my:Number;
			var eh:Number = 14;
			switch(persistence.dockState) {
				case DOCK_TOP:
					my = stage.mouseY-22;
					setHeight(Math.floor(my / eh));
				break;
				case DOCK_BOTTOM:
					my = stage.mouseY+22;
					var inv:Number = stage.stageHeight - my;
					setHeight(Math.floor(inv / eh));
				break;
			}
			infoTargetY = inputTextField.y;
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			var d:int = Math.max( -1, Math.min(1, e.delta));
			if (e.ctrlKey) d *= persistence.numLines;
			scroll(d);
		}		
		private function quitCommand(code:int = 0):void
		{
			System.exit(code);
		}
		/**
		 * Toggle: Route all print statements to javascript console.log through externalinterface
		 */
		public function routeToJS():void {
			if (ExternalInterface.available) {
				routingToJS = !routingToJS;
				if (routingToJS) {
					print("Routing console to JS", MessageTypes.OUTPUT);
				}else {
					print("No longer routing console to JS", MessageTypes.OUTPUT);
				}
			}else {
				print("ExternalInterface not available", MessageTypes.ERROR);
			}
		}
		/**
		 * Route errors to javascript console.log through externalinterface
		 */
		public function alertErrors():void {
			if (ExternalInterface.available) {
				alertingErrors = !alertingErrors;
				if (alertingErrors ) {
					print("Alerting errors through JS", MessageTypes.OUTPUT);
				}else {
					print("No longer alerting errors through JS", MessageTypes.OUTPUT);
				}
			}else {
				print("ExternalInterface not available", MessageTypes.ERROR);
			}
		}
		/**
		 * Toggle display of mrDoob stats
		 */
		public function toggleStats(e:Event = null):void {
			if (mainConsoleContainer.contains(stats)) {
				mainConsoleContainer.removeChild(stats);
				print("Stats off", MessageTypes.SYSTEM);
			}else {
				mainConsoleContainer.addChild(stats);
				stats.x = textOutput.width - stats.width;
				print("Stats on", MessageTypes.SYSTEM);
			}
			redraw();
		}
		/**
		 * Get a screenshot of the stage and save as a png
		 * @param	e
		 */
		public function screenshot(e:Event = null):void
		{
			var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			visible = false;
			try {
				bmd.draw(stage);
				fileRef.save(PNGEncoder.encode(bmd), "Screenshot.png");
				print(bmd.width+"x"+bmd.height+" png screenshot created", MessageTypes.SYSTEM);
			}catch (e:Error) {
				print("Screenshot failed : "+e.message, MessageTypes.ERROR);
			}
			visible = true;
		}
				
		private function setFramerate(rate:int = 60):void
		{
			stage.frameRate = rate;
			print("Framerate set to " + stage.frameRate, MessageTypes.SYSTEM);
		}
		
		private function getCapabilities():void
		{
			print("System capabilities info:",MessageTypes.SYSTEM);
			print("	Capabilities.avHardwareDisable : "+Capabilities.avHardwareDisable);
			print("	Capabilities.hasAccessibility : "+Capabilities.hasAccessibility);
			print("	Capabilities.hasAudio : "+Capabilities.hasAudio);
			print("	Capabilities.hasAudioEncoder : "+Capabilities.hasAudioEncoder);
			print("	Capabilities.hasEmbeddedVideo : "+Capabilities.hasEmbeddedVideo);
			print("	Capabilities.hasIME : "+Capabilities.hasIME);
			print("	Capabilities.hasMP3 : "+Capabilities.hasMP3);
			print("	Capabilities.hasPrinting : "+Capabilities.hasPrinting);
			print("	Capabilities.hasScreenBroadcast : "+Capabilities.hasScreenBroadcast);
			print("	Capabilities.hasStreamingAudio : "+Capabilities.hasStreamingAudio);
			print("	Capabilities.hasStreamingVideo : "+Capabilities.hasStreamingVideo);
			print("	Capabilities.hasTLS : "+Capabilities.hasTLS);
			print("	Capabilities.hasVideoEncoder : "+Capabilities.hasVideoEncoder);
			print("	Capabilities.isDebugger : "+Capabilities.isDebugger);
			print("	Capabilities.language : "+Capabilities.language);
			print("	Capabilities.localFileReadDisable : "+Capabilities.localFileReadDisable);
			print("	Capabilities.manufacturer : "+Capabilities.manufacturer);
			print("	Capabilities.os : "+Capabilities.os);
			print("	Capabilities.pixelAspectRatio : "+Capabilities.pixelAspectRatio);
			print("	Capabilities.playerType : "+Capabilities.playerType);
			print("	Capabilities.screenColor : "+Capabilities.screenColor);
			print("	Capabilities.screenDPI : "+Capabilities.screenDPI);
			print("	Capabilities.screenResolutionX : "+Capabilities.screenResolutionX);
			print("	Capabilities.screenResolutionY : "+Capabilities.screenResolutionY);
			print("	Capabilities.version : "+Capabilities.version);
		}
		/**
		 * Alternative trace method
		 * @param	...values
		 */
		public function trace(...values):void {
			if (traceValues) {
				var str:String = "";
				for (var i:int = 0; i < values.length; i++) 
				{
					str += values[i].toString();
					if (i != values.length - 1) str += ", ";
				}
				print(str, MessageTypes.TRACE);
			}
			drawMessages();
		}
		private function toggleTrace():void
		{
			traceValues = !traceValues;
			if (traceValues) {
				print("Trace log enabled", MessageTypes.SYSTEM);
			}else {
				print("Trace log disabled", MessageTypes.SYSTEM);
			}
		}
		private function toggleTraceDisplay():void
		{
			showTraceValues = !showTraceValues;
			if (showTraceValues) {
				print("Trace display enabled", MessageTypes.SYSTEM);
			}else {
				print("Trace display disabled", MessageTypes.SYSTEM);
			}
			drawMessages();
		}
		
		public function clearTrace():void
		{
			for (var i:int = messageLog.length; i--; ) 
			{
				if (messageLog[i].type == MessageTypes.TRACE) messageLog.splice(i, 1);
			}
			print("Trace cache cleared", MessageTypes.SYSTEM);
			drawMessages();
		}
		
		private function getHelp():void
		{
			print("Help", MessageTypes.SYSTEM);
			print("	Keyboard commands", MessageTypes.SYSTEM);
			print("		Shift-Tab -> Toggle console", MessageTypes.SYSTEM);
			print("		Tab -> (When out of focus) Set the keyboard focus to the input field", MessageTypes.SYSTEM);
			print("		Tab -> (When in focus) Skip to end of line and append a space", MessageTypes.SYSTEM);
			print("		Tab -> (While caret is on an unknown term) Context sensitive search of commands, methods and accessors", MessageTypes.SYSTEM);
			print("		Enter -> Execute line", MessageTypes.SYSTEM);
			print("		Page up/Page down -> Vertical scroll by page", MessageTypes.SYSTEM);
			print("		Arrow up -> Recall the previous executed line", MessageTypes.SYSTEM);
			print("		Arrow down -> Recall the more recent executed line", MessageTypes.SYSTEM);
			print("		Ctrl + Arrow keys -> Scroll", MessageTypes.SYSTEM);
			print("		Shift+backspace -> Clear the input field", MessageTypes.SYSTEM);
			print("	Mouse functions", MessageTypes.SYSTEM);
			print("		Mousewheel -> Vertical scroll line by line (hold ctrl to scroll by pages)", MessageTypes.SYSTEM);
			print("		Click drag below the input line -> Change console height", MessageTypes.SYSTEM);
			print("	Misc", MessageTypes.SYSTEM);
			print("		Use the 'commands' command to list available commmands", MessageTypes.SYSTEM);
		}
		
		private function onInputFieldChange(e:Event = null):void 
		{
			var cmd:ConsoleCommand;
			try {
				cmd = commandManager.parseForCommand(inputTextField.text);
			}catch (e:Error) {
				infoTargetY = inputTextField.y;
				addEventListener(Event.ENTER_FRAME, updateInfoMotion);
				return;
			}
			var helpText:String = cmd.helpText;
			var secondElement:String = TextUtils.parseForSecondElement(inputTextField.text);
			if(secondElement){
				if (cmd == callCommand) {
					//arrgh
					try{
						helpText = InspectionUtils.getMethodTooltip(scopeManager.currentScope.obj, secondElement);
					}catch (e:Error) {
						helpText = cmd.helpText;
					}
				}else if (cmd == setCommand || cmd == getCommand) {
					try {
						helpText = InspectionUtils.getAccessorTooltip(scopeManager.currentScope.obj, secondElement);
					}catch (e:Error) {
						helpText = cmd.helpText;
					}
				}
			}
			if (helpText != "") {
				switch(persistence.dockState) {
					case DOCK_TOP:
						infoTargetY = inputTextField.y+18;
					break;
					case DOCK_BOTTOM:
						infoTargetY = inputTextField.y-17;
					break;
				}
				infoField.text = "?	" + cmd.trigger + ": " + helpText;
				addEventListener(Event.ENTER_FRAME, updateInfoMotion);
			}else {
				infoTargetY = inputTextField.y;
				addEventListener(Event.ENTER_FRAME, updateInfoMotion);
			}
		}
		/**
		 * Set the number of lines to display
		 * @param	lines
		 */
		public function setHeight(lines:Number = 6):void {
			persistence.numLines = int(Math.max(1, lines));
			scrollIndex = Math.max(0, messageLog.length - persistence.numLines);
			if (calcHeight()>stage.stageHeight) {
				maximize();
				return;
			}
			redraw();
		}
		private function calcHeight():Number {
			return consoleHeight = persistence.numLines * 14+22;
		}
		/**
		 * Toggle echo (command confirmation) on and off
		 */
		public function toggleEcho(toggle:String = null):void {
			switch(toggle) {
				case "on":
				echo = true;
				break;
				case "off":
				echo = false;
				break;
				default:
				echo = !echo;
			}
			if (echo) print("Echo on",MessageTypes.SYSTEM)
			else print("Echo off",MessageTypes.SYSTEM);
		}
		/**
		 * Toggle display of message timestamp
		 */
		public function toggleTimestamp(toggle:String = null):void {
			switch(toggle) {
				case "on":
				timeStamp = true;
				break;
				case "off":
				timeStamp = false;
				break;
				default:
				timeStamp = !timeStamp;
			}
			if (timeStamp) print("Timestamp on",MessageTypes.SYSTEM)
			else print("Timestamp off",MessageTypes.SYSTEM);
		}
		/**
		 * Add a custom command to the console
		 * @param	command
		 * An instance of FunctionCallCommand or ConsoleEventCommand
		 */
		public function addCommand(command:ConsoleCommand):void {
			globalDictionary.addToDictionary(command.trigger);
			commandManager.addCommand(command);
		}
		
		/**
		 * A generic function to add as listener to events you want logged
		 * @param	e
		 */
		public function onEvent(e:Event):void {
			print("Event: "+e.toString(),MessageTypes.OUTPUT);
		}
		/**
		 * Add a message to the console
		 * @param	str
		 * The string to be added. A timestamp is automaticaly prefixed
		 */
		public function print(str:String, type:uint = MessageTypes.OUTPUT):Message{
			var split:Array = str.split("\n").join("\r").split("\r");
			if (split.join("").length < 1) return new Message("", "", 0);
			var date:String = String(new Date().getTime());
			var msg:Message;
			for (var i:int = 0; i < split.length; i++) 
			{
				if (split[i].indexOf("no.doomsday.console") > -1 || split[i].indexOf("adobe.com/AS3") > -1) continue;
				var txt:String = split[i];
				if (previousPrintValues == txt && previousMessage) {
					switch(repeatMessageMode) {
						case MessageRepeatMode.STACK:
							previousMessage.repeatcount++;
							previousMessage.timestamp = date;
							continue;
						break;
						case MessageRepeatMode.IGNORE:
							continue;
						break;
						default:
					}
				}
				previousPrintValues = txt;
				msg = new Message(split[i], date, type);
				previousMessage = msg;
				messageLog.push(msg);
				scrollIndex = Math.max(0, messageLog.length - persistence.numLines);
			}			
			if (type == MessageTypes.ERROR&&alertingErrors) {
				ExternalInterface.call("alert", str);
			}
			if (routingToJS&&ExternalInterface.available){
				ExternalInterface.call("console.log", str);
			}
			drawMessages();
			return msg;
		}
		/**
		 * Clear the console
		 */
		public function clear():void {
			messageLog = new Vector.<Message>;
			drawMessages();
		}
		private function drawMessages():void {
			if (!visible||locked) return;
			textOutput.text = "";
			textOutput.defaultTextFormat = TextFormats.debugTformatOld;
			scrollRange = Math.min(messageLog.length, scrollIndex + persistence.numLines);
			
			for (var i:int = scrollIndex; i < scrollRange; i++) 
			{
				if (messageLog[i].type == MessageTypes.USER && !echo) continue;
				if (messageLog[i].type == MessageTypes.TRACE && !showTraceValues) continue;
				textOutput.defaultTextFormat = TextFormats.debugTformatOld;
				var lineNum:int = i+1;
				var lineNumStr:String = lineNum.toString();
				if (lineNum < 100) {
					lineNumStr = "0" + lineNumStr;
				}
				if (lineNum < 10) {
					lineNumStr = "0" + lineNumStr;
				}
				textOutput.appendText("[" + lineNumStr + "] > ");
				if (timeStamp) {
					textOutput.defaultTextFormat = TextFormats.debugTformatTimeStamp;
					textOutput.appendText(messageLog[i].timestamp + " ");
				}
				var fmt:TextFormat;
				switch(messageLog[i].type) {
					case MessageTypes.USER:
						fmt = TextFormats.debugTformatInput;
					break;
					case MessageTypes.SYSTEM:
						fmt = TextFormats.debugTformatSystem;
					break;
					case MessageTypes.ERROR:
						fmt = TextFormats.debugTformatError;
					break;
					case MessageTypes.TRACE:
						fmt = TextFormats.debugTformatTrace
					break;
					case MessageTypes.OUTPUT:
					default:
						if(i==messageLog.length-1){
							fmt = TextFormats.debugTformatNew;
						}else {
							fmt = TextFormats.debugTformatOld;
						}
					break;
				}
				var idx:int = textOutput.text.length;
				var str:String = messageLog[i].text;
				if (messageLog[i].repeatcount > 0) {
					var str2:String = " x" + messageLog[i].repeatcount;
					str += str2;
				}	
				textOutput.appendText(str+"\n");
				textOutput.setTextFormat(fmt, idx, idx + messageLog[i].text.length);
			}
		}
		private function setupStageAlignAndScale():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			print("StageAlign set to TOP_LEFT, StageScaleMode set to NO_SCALE", MessageTypes.SYSTEM);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			try{
				parentTabChildren = parent.tabChildren;
				parentTabEnabled = parent.tabEnabled;
			}catch (e:Error) {
				
			}
			var score:int = 0;
			if (stage.align != StageAlign.TOP_LEFT) {
				print("Warning: stage.align is not set to TOP_LEFT; This might cause scaling issues",MessageTypes.ERROR);
				score++;
			}
			if (stage.scaleMode != StageScaleMode.NO_SCALE) {
				print("Warning: stage.scaleMode is not set to NO_SCALE; This might cause scaling issues",MessageTypes.ERROR);
				score++;
			}
			if (score > 0) {
				print("Use the setupStage command to temporarily alleviate these problems",MessageTypes.ERROR);
			}
			keyboardManager.setup(stage);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onStageResize);
			scopeManager.selectBaseScope();
		}	
		
		private function onStageResize(e:Event = null):void 
		{
			redraw();
			if(mainConsoleContainer.contains(stats)) stats.x = textOutput.width - stats.width;
		}
		
		
		/**
		 * Save the current console contents to an xml file
		 */
		public function log(e:Event = null):void {
			var logDoc:XML = <log/>;
			for (var i:int = 0; i < messageLog.length; i++) 
			{
				var node:XML = <entry/>;
				node.@time_ms = messageLog[i].timestamp;
				//var msg:String = messageLog[i].timestamp + " ";
				switch(messageLog[i].type) {
					case MessageTypes.ERROR:
					//msg += "error";
					node.@type = "error";
					break;
					case MessageTypes.SYSTEM:
					//msg += "system";
					node.@type = "system";
					break;
					case MessageTypes.OUTPUT:
					//msg += "output";
					node.@type = "output";
					break;
					case MessageTypes.TRACE:
					//msg += "trace";
					node.@type = "trace";
					break;
					case MessageTypes.USER:
					//msg += "user";
					node.@type = "user";
					break;
					default:
					break;
				}
				node.appendChild(<message>{messageLog[i].text}</message>);
				logDoc.appendChild(node);
			}
			var date:String = new Date().toString().split(" ").join("_");
			date = date.split(":").join("-");
			logDoc.@date = date;
			fileRef.save(logDoc, "ConsoleLog_" + date + ".xml");
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if (visible) {
				var cmd:String = "";
				if (e.keyCode == Keyboard.UP) {
					if (!e.ctrlKey) cmd = persistence.historyUp();
					else return;
					
				}else if (e.keyCode == Keyboard.DOWN) {
					if (!e.ctrlKey) cmd = persistence.historyDown();
					else return;
				}
				if (cmd.length>0) {
					inputTextField.text = cmd;
					stage.focus = inputTextField;
					var spaceIndex:int = inputTextField.text.indexOf(" ");
					
					if (spaceIndex>-1) {
						inputTextField.setSelection(inputTextField.text.indexOf(" ") + 1, inputTextField.text.length);
					}else{
						inputTextField.setSelection(0, inputTextField.text.length);
					}
				}
			}
		}
		private function doTab():void
		{
			var flag:Boolean = false; //TODO: Temporary flag until this whole tab business has been sorted out
			
			if (inputTextField.text.length < 1) return;
			var word:String = TextUtils.getWordAtCaretIndex(inputTextField);
			
			var isFirstWord:Boolean = inputTextField.text.lastIndexOf(word) < 1;
			var firstWord:String;
			if (isFirstWord) {
				firstWord = word;
			}else {
				firstWord = TextUtils.getWordAtIndex(inputTextField, 0);
			}
			if (autoCompleteManager.isKnown(word, !isFirstWord, isFirstWord)||!isNaN(Number(word))) {
				//this word is okay, so accept the tab
				var wordIndex:int = TextUtils.getFirstIndexOfWordAtCaretIndex(inputTextField);
					
				//is there currently a selection?
				if (inputTextField.selectedText.length > 0) {
					moveCaretToIndex(inputTextField.selectionBeginIndex);
					wordIndex = inputTextField.selectionBeginIndex;
				}else if(inputTextField.text.charAt(inputTextField.caretIndex)==" "&&inputTextField.caretIndex!=inputTextField.text.length-1){
					moveCaretToIndex(inputTextField.caretIndex - 1);
				}
				
				word = TextUtils.getWordAtCaretIndex(inputTextField);
				wordIndex = inputTextField.caretIndex;
				
				//case correction
				var temp:String = inputTextField.text;
				try {
					temp = temp.replace(word, autoCompleteManager.correctCase(word));
					inputTextField.text = temp;
				}catch (e:Error) {
				}
				
				//is there a word after the current word?
				if (wordIndex + word.length < inputTextField.text.length - 1) {
					moveCaretToIndex(wordIndex + word.length);
					TextUtils.selectWordAtCaretIndex(inputTextField);
					
				}else {
					//if it's the last word
					if (inputTextField.text.charAt(inputTextField.text.length-1)!=" ") {
						inputTextField.appendText(" ");
					}
					moveCaretToIndex();
				}
			}else{
				var getSet:Boolean = (firstWord == getCommand.trigger || firstWord == setCommand.trigger);
				var call:Boolean = (firstWord == callCommand.trigger);
				var select:Boolean = (firstWord == selectCommand.trigger);
				tabSearch(word, !isFirstWord||select, isFirstWord, call);
				
				if (flag) {
					TextUtils.selectWordAtCaretIndex(inputTextField);
				}else{
					word = TextUtils.getWordAtCaretIndex(inputTextField);
					wordIndex = TextUtils.getFirstIndexOfWordAtCaretIndex(inputTextField);
					moveCaretToIndex(wordIndex + word.length);
				}
			}
		}
		
		private function moveCaretToIndex(index:int = -1):void
		{
			if (index == -1) {
				index = inputTextField.length;
			}
			inputTextField.setSelection(index, index);
		}
		private function tabSearch(searchString:String,includeAccessors:Boolean = false, includeCommands:Boolean = true,includeScopeMethods:Boolean = false):void
		{
			if (searchString.length < 1) return;
			var found:Boolean = false;
			var result:Vector.<String>;
			var maxrow:int = 4;
			if(includeScopeMethods){
				result = scopeManager.doSearch(searchString,ScopeManager.SEARCH_METHODS);
				var out:String = "";
				var count:int = 0;
				if(result.length>0){
					print("Scope methods matching '" + searchString + "'", MessageTypes.SYSTEM);
					for (var i:int = 0; i < result.length; i++) 
					{
						out += result[i] + " ";
						count++;
						if (count > maxrow) {
							count = 0;
							print(out, MessageTypes.OUTPUT);
							out = "";
						}
					}
					if (out != "") print(out, MessageTypes.OUTPUT);
					found = true;
				}
			}
			if(includeCommands){
				result = commandManager.doSearch(searchString);
				count = 0;
				out = "";
				if(result.length>0){
					print("Commands matching '" + searchString + "'", MessageTypes.SYSTEM);
					for (i = 0; i < result.length; i++) 
					{
						out += result[i] + " ";
						count++;
						if (count > maxrow) {
							count = 0;
							print(out, MessageTypes.OUTPUT);
							out = "";
						}
					}
					if (out != "") print(out, MessageTypes.OUTPUT);
					found = true;
				}
			}
			if (!includeAccessors) return;
			result = scopeManager.doSearch(searchString,ScopeManager.SEARCH_ACCESSORS);
			count = 0;
			out = "";
			if(result.length>0){
				print("Scope accessors matching '" + searchString + "'", MessageTypes.SYSTEM);
				for (i = 0; i < result.length; i++) 
				{
					out += result[i] + " ";
					count++;
					if (count > maxrow) {
						count = 0;
						print(out, MessageTypes.OUTPUT);
						out = "";
					}
				}
				if (out != "") print(out, MessageTypes.OUTPUT);
				found = true;
			}
			result = scopeManager.doSearch(searchString,ScopeManager.SEARCH_CHILDREN);
			count = 0;
			out = "";
			if(result.length>0){
				print("Children matching '" + searchString + "'", MessageTypes.SYSTEM);
				for (i = 0; i < result.length; i++) 
				{
					out += result[i] + " ";
					count++;
					if (count > maxrow) {
						count = 0;
						print(out, MessageTypes.OUTPUT);
						out = "";
					}
				}
				if (out != "") print(out, MessageTypes.OUTPUT);
				found = true;
			}
			if (!found) {
				print("No matches for '" + searchString + "'",MessageTypes.ERROR);
			}
		
		}
		
		private function singleTab():void
		{
			if (autoCompleteManager.suggestionActive) {
				inputTextField.appendText(" ");
				inputTextField.setSelection(inputTextField.length, inputTextField.length);
			}
		}
		private function onKeyDown(e:KeyboardEvent):void 
		{
			
			if (e.ctrlKey) {
				switch(e.keyCode) {
					case Keyboard.UP:
					scroll(1);
					return
					case Keyboard.DOWN:
					scroll(-1);
					return;
					case Keyboard.LEFT:
					//scroll(0,-textOutput.width*.5);
					return
					case Keyboard.RIGHT:
					//scroll(0,textOutput.width*.5);
					return;
				}
			}
			
			//TODO: Customizable invocation keystroke
			//if (e.keyCode == Keyboard.TAB && e.shiftKey) {
			if (invokeKeyStroke.valid) {
				disableTab();
				toggleDisplay();
				return;
			}
			if (visible && e.keyCode == Keyboard.TAB) {
				disableTab();
				if (visible && stage.focus != inputTextField) stage.focus = inputTextField;
				doTab();
				
			}
			if (e.keyCode == Keyboard.BACKSPACE && e.shiftKey) {
				inputTextField.text = "";
				onInputFieldChange();
			}
			if (visible) {
				if (e.keyCode == Keyboard.ENTER) {
					if (inputTextField.text.length < 1) {
						stage.focus = inputTextField;
						return;
					}
					var success:Boolean = false;
					if (echo) print("'" + inputTextField.text + "'", MessageTypes.USER);
					try{
						var attempt:* = commandManager.tryCommand(inputTextField.text);
						success = true;
					}catch (error:Error) {
						print(error.message,MessageTypes.ERROR);
					}
						
					inputTextField.text = "";
					onInputFieldChange();
				}else if (e.keyCode == Keyboard.PAGE_DOWN) {
					scroll(-persistence.numLines);
				}else if (e.keyCode == Keyboard.PAGE_UP) {
					scroll(persistence.numLines);
				}
				
			}
		}
		
		
		private function scroll(deltaY:int = 0,deltaX:int = 0):void {
			var prevScrollH:int = textOutput.scrollH;
			if(deltaY!=0){
				if (deltaY < 0 && messageLog.length < persistence.numLines) return;
				scrollIndex = deltaY < 0 ? Math.min(messageLog.length - persistence.numLines, scrollIndex - deltaY) : Math.max(0, scrollIndex - deltaY);
				drawMessages();
				textOutput.scrollH = prevScrollH;
			}
			if (deltaX != 0) {
				textOutput.scrollH = Math.max(0, textOutput.scrollH + deltaX);
			}
		}
		private function resetTab(e:TimerEvent):void 
		{
			try{
				parent.tabChildren = parentTabChildren;
				parent.tabEnabled = parentTabEnabled;
			}catch (e:Error) {
				
			}
		}
		private function disableTab():void
		{
			try{
				parent.tabChildren = parent.tabEnabled = false;
			}catch (e:Error) {
				
			}
		}
		private function reenableTab():void {
			tabTimer.reset();
			tabTimer.start();
		}
		
		
		public function getApproxMessagesSize():int {
			var totalText:String = "";
			for (var i:int = messageLog.length; i--; ) 
			{
				totalText += messageLog[i].text + messageLog[i].timestamp;
			}
			var b:ByteArray = new ByteArray();
			b.writeUTF(totalText);
			b.position = 0;
			return b.bytesAvailable;
		}
		
		public function show():void {
			if(!visible) toggleDisplay();
		}
		public function hide():void {
			if (visible) toggleDisplay();
		}
		public function toggleDisplay(e:Event = null):void
		{
			visible = !visible;
			var i:int;
			var bounds:Rectangle = redraw();
			if (visible) {
				if (parent) parent.addChild(this);
				switch(persistence.dockState) {
					case DOCK_BOTTOM:
						mainConsoleContainer.y = stage.stageHeight+1;
						if(stats.visible){
							stats.x = textOutput.width - stats.width;
						}
						targetY = stage.stageHeight - consoleHeight;
					break;
					case DOCK_TOP:
						mainConsoleContainer.y = -consoleHeight + 1;
						if(stats.visible){
							stats.x = textOutput.width - stats.width;
						}
						targetY = 0;
					break;
				}
				addEventListener(Event.ENTER_FRAME, updateMainMotion);
			}else {
				reenableTab();
			}
			inputTextField.text = "";
			onInputFieldChange();
			stage.focus = inputTextField;
		}
		
		private function updateMainMotion(e:Event):void 
		{
			var diffY:Number = targetY-mainConsoleContainer.y;
			mainConsoleContainer.y += diffY / 4;
			if (Math.abs(diffY) < 0.01) {
				mainConsoleContainer.y = targetY;
				removeEventListener(Event.ENTER_FRAME, updateMainMotion);
			}
		}
		private function updateInfoMotion(e:Event):void {
			var diffY:Number = infoTargetY-infoField.y;
			infoField.y += diffY / 4;
			if (Math.abs(diffY) < 0.01) {
				infoField.y = infoTargetY;
				removeEventListener(Event.ENTER_FRAME, updateInfoMotion);
			}
		}
		
		private function redraw(e:Event = null):Rectangle
		{
			
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			if (parent.scrollRect) {
				w = parent.scrollRect.width;
				h = parent.scrollRect.height;
			}
			switch(persistence.dockState) {
				case DOCK_TOP:
					consoleBg.graphics.clear();
					consoleBg.graphics.beginFill(backgroundColor, backgroundAlpha);
					consoleBg.graphics.drawRect(0, 0, w, consoleHeight);
					consoleBg.graphics.lineStyle(0, 0);
					consoleBg.graphics.moveTo(0, consoleHeight);
					consoleBg.graphics.lineTo(w, consoleHeight);
					consoleBg.y = 0;
					
					textOutput.height = consoleHeight-18;
					textOutput.width = w;
					textOutput.y = 0;
					inputTextField.width = w;
					inputTextField.height = 18;
					inputTextField.y = consoleHeight - 18;
					infoField.y = inputTextField.y;
					infoField.height = 17;
					infoField.width = w;
					drawMessages();
					
					scaleHandle.x = 0;
					scaleHandle.width = w;
					scaleHandle.y = inputTextField.y + inputTextField.height;
					
					stats.y = 0;
					mainConsoleContainer.y = 0;
					
					stats.scrollRect = new Rectangle(0,0,stats.width,textOutput.height);	
				break;
				case DOCK_BOTTOM:
					consoleBg.graphics.clear();
					consoleBg.graphics.beginFill(backgroundColor, backgroundAlpha);
					consoleBg.graphics.drawRect(0, 0, w, consoleHeight);
					consoleBg.graphics.lineStyle(0, 0);
					consoleBg.graphics.moveTo(0, consoleHeight);
					consoleBg.graphics.lineTo(w, consoleHeight);
					consoleBg.y = 0;
					
					textOutput.height = consoleHeight-18;
					textOutput.width = w;
					textOutput.y = 0;
					inputTextField.width = w;
					inputTextField.height = 18;
					inputTextField.y = consoleHeight - 18;
					infoField.y = inputTextField.y;
					infoField.height = 17;
					infoField.width = w;
					drawMessages();
					
					scaleHandle.x = 0;
					scaleHandle.width = w;
					scaleHandle.y = -scaleHandle.height;
					
					stats.y = 0;
					
					mainConsoleContainer.y = stage.stageHeight - consoleHeight;
					
					stats.scrollRect = new Rectangle(0,0,stats.width,textOutput.height);	
				break;
			}
			return new Rectangle(x, y, w, h);
		}
		
		private function alias(methodName:String, commandString:String):void {
			var ob:* = scopeManager.currentScope.obj;
			if (!ob[methodName]) throw new ArgumentError("No such method on current scope");
			if (ob[methodName]is Function) {
				var func:Function = ob[methodName] as Function;
				addCommand(new FunctionCallCommand(commandString, func, "Aliases", "Calls the function " + methodName + " on the object " + ob.toString()));
				return;
			}
			throw new ArgumentError("Identifier is not a method");
		}
		
		public function setPassword(pwd:String):void {
			commandManager.setupAuthentication(pwd);
		}
		
		public function setTabSearch(newvalue:Boolean = true):void {
			tabSearchEnabled = newvalue;
			print("Tab searching: " + tabSearchEnabled, MessageTypes.SYSTEM);
		}
		
		//batch
		public function runBatch(batch:String):Boolean {
			locked = true;
			print("Starting batch", MessageTypes.SYSTEM);
			var split:Array = batch.split("\n").join("\r").split("\r");
			var result:Boolean = false;
			for (var i:int = 0; i < split.length; i++) 
			{
				result = commandManager.tryCommand(split[i])
			}
			if (result) {
				print("Batch completed", MessageTypes.SYSTEM);
			}else {
				print("Batch completed with errors", MessageTypes.ERROR);
			}
			locked = false;
			drawMessages();
			return result;
		}
		public function runBatchFromUrl(url:String):void {
			var batchLoader:URLLoader = new URLLoader(new URLRequest(url));
			batchLoader.addEventListener(Event.COMPLETE, onBatchLoaded, false, 0, true);
		}
		private function onBatchLoaded(e:Event):void 
		{
			runBatch(e.target.data);
		}
		
		private function goto(line:int):void {
			scrollToLine(line-1);
		}
		private function scrollToLine(line:int):void {
			var diff:int = scrollIndex - line;
			scroll(diff);
		}
		
		private function searchLog(str:String):void {
			for (var i:int = 0; i < messageLog.length; i++) 
			{
				if (messageLog[i].text.toLowerCase().indexOf(str) > -1) {
					scrollToLine(i);
					print("'"+str + "' found at line " + i);
					break;
				}
			}
		}
		
		//minmaxing size
		public function maximize():void {
			if (!stage) return;
			var maxHeight:int = Math.floor(stage.stageHeight / 14)-1;
			setHeight(maxHeight-1);
		}
		private function minimize():void
		{
			setHeight(1);
		}
		
		//theming
		public function setChromeTheme(backgroundColor:uint = 0, backgroundAlpha:Number = 0.8, borderColor:uint = 0x333333, inputBackgroundColor:uint = 0, helpBackgroundColor:uint = 0x222222):void {
			
			inputTextField.borderColor = borderColor;
			inputTextField.backgroundColor = inputBackgroundColor;
			infoField.backgroundColor = helpBackgroundColor;
			this.backgroundColor = backgroundColor;
			this.backgroundAlpha = backgroundAlpha;
			if (visible) {
				redraw();
			}
		}
		public function setTextTheme(input:uint = 0xFFD900, oldMessage:uint = 0xBBBBBB, newMessage:uint = 0xFFFFFF, system:uint = 0x00DD00, timestamp:uint = 0xAAAAAA, error:uint = 0xEE0000, help:uint = 0xbbbbbb, trace:uint = 0x9CB79B):void {
			TextFormats.setTheme(input, oldMessage, newMessage, system, timestamp, error, help, trace);
			inputTextField.defaultTextFormat = TextFormats.debugTformatInput;
			infoField.defaultTextFormat = TextFormats.debugTformatHelp;
			drawMessages();
		}
	}
	
}