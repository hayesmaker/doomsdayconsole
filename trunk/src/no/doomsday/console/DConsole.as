package no.doomsday.console
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import no.doomsday.console.bitmap.PNGEncoder;
	import no.doomsday.console.commands.ConsoleCommand;
	import no.doomsday.console.commands.FunctionCallCommand;
	import no.doomsday.console.controller.ControllerManager;
	import no.doomsday.console.gui.ScaleHandle;
	import no.doomsday.console.introspection.AccessorDesc;
	import no.doomsday.console.introspection.ChildScopeDesc;
	import no.doomsday.console.introspection.ScopeManager;
	import no.doomsday.console.introspection.InspectionUtils;
	import no.doomsday.console.introspection.MethodDesc;
	import no.doomsday.console.introspection.VariableDesc;
	import no.doomsday.console.measurement.MeasurementTool;
	import no.doomsday.console.messages.Message;
	import no.doomsday.console.messages.MessageTypes;
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
	import flash.events.ContextMenuEvent;
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
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class DConsole extends Sprite
	{
		//[Embed(source='../../../buildnumber.txt', mimeType='application/octet-stream')]
		//public static var BuildNumberFile:Class;
		private static var BUILD:int = 1;
		
		private static var INSTANCE:DConsole;
		
		private var consoleBg:Shape;
		private var textOutput:TextField;
		private var inputTextField:TextField;
		private var infoField:TextField;
		private var targetY:Number;
		private var infoTargetY:Number;
		private var scrollIndex:int = 0;
		private var scrollRange:int = 0;
		private var previousCommands:Array;
		private var commandIndex:int = 0;
		private var numLines:int = 10;
		private var consoleHeight:Number = 120;
		private var autoCompleteManager:AutocompleteManager;
		private var historySO:SharedObject;
		
		private var referenceDict:Dictionary = new Dictionary(true);
		
		private var messageLog:Vector.<Message>;
		private var commands:Vector.<ConsoleCommand>;
		
		private var mainConsoleContainer:Sprite;
		
		private var traceValues:Boolean = true;
		private var showTraceValues:Boolean = true;
		private var echo:Boolean = true;
		private var timeStamp:Boolean = false;
		private var prevHeight:int;
		
		private var measureBracket:MeasurementTool = new MeasurementTool();
		
		private var parentTabEnabled:Boolean = true;
		private var parentTabChildren:Boolean = true;
		private var tabTimer:Timer;
		private var fileRef:FileReference;
		
		private var routingToJS:Boolean;
		private var alertingErrors:Boolean;
		
		private var globalDictionary:AutocompleteDictionary = new AutocompleteDictionary();
		
		private var menu:ContextMenu;
		
		private var scopeManager:ScopeManager;
		
		private var scaleHandle:ScaleHandle;
		
		private var controllerManager:ControllerManager;
		private var password:String = "";
		private var authenticated:Boolean = true;
		private var authCommand:FunctionCallCommand = new FunctionCallCommand("authorize", authenticate, "System", "Input password to gain console access");
		private var deAuthCommand:FunctionCallCommand = new FunctionCallCommand("deauthorize", lock, "System", "Lock the console from unauthorized user access");
		private var authenticationSetup:Boolean;
		
		private var locked:Boolean = false;
		
		/**
		 * Get the singleton instance of DConsole
		 * @return
		 */
		public static function get instance():DConsole {
			if (!INSTANCE) {
				INSTANCE = new DConsole();
			}
			return INSTANCE;
		}
		/**
		 * Creates a new DConsole instance. 
		 * This class is intended to always be on top of the stage of the application it is associated with.
		 * A static singleton retrieval method is available, optional but recommended
		 * To toggle console visibility, hit shift+tab 
		 */
		public function DConsole() 
		{
			//var ob:ByteArray = new BuildNumberFile as ByteArray;
			visible = false;
			
			addChild(measureBracket);
			measureBracket.visible = false;
			
			historySO = SharedObject.getLocal("consoleHistory");
			if (!historySO.data.history) historySO.data.history = [];
			if (!historySO.data.numLines) historySO.data.numLines = numLines;
			numLines = historySO.data.numLines;
			previousCommands = historySO.data.history;
			commandIndex = previousCommands.length;
			
			mainConsoleContainer = new Sprite();
			addChild(mainConsoleContainer);
			
			consoleBg = new Shape();
			var dropshadow:DropShadowFilter = new DropShadowFilter(4, 90, 0, 0.3, 0, 10);
			consoleBg.filters = [dropshadow];
			mainConsoleContainer.addChild(consoleBg);			
			
			textOutput = new TextField();
			textOutput.gridFitType = GridFitType.PIXEL;
			mainConsoleContainer.addChild(textOutput);
			inputTextField = new TextField();
			
			autoCompleteManager = new AutocompleteManager(inputTextField);
			autoCompleteManager.setDictionary(globalDictionary);
			
			scopeManager = new ScopeManager();
			
			infoField = new TextField();
			infoField.background = true;
			infoField.backgroundColor = 0x222222;
			infoField.tabEnabled = false;
			infoField.mouseEnabled = false;
			infoField.selectable = false;
			infoField.defaultTextFormat = TextFormats.debugTformatHelp;
			mainConsoleContainer.addChild(infoField);
			
			menu = new ContextMenu();
			var logItem:ContextMenuItem = new ContextMenuItem("Log");
			logItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, log);
			var screenshotItem:ContextMenuItem = new ContextMenuItem("Screenshot");
			screenshotItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, screenshot);
			var toggleDisplayItem:ContextMenuItem = new ContextMenuItem("Hide");
			toggleDisplayItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleDisplay);
			menu.customItems.push(logItem, screenshotItem, toggleDisplayItem);
			contextMenu = menu;
			
			inputTextField.defaultTextFormat = TextFormats.debugTformatInput;
			inputTextField.multiline = false;
			inputTextField.type = TextFieldType.INPUT;
			inputTextField.background = true;
			inputTextField.backgroundColor = 0;
			inputTextField.tabEnabled = false;
			mainConsoleContainer.addChild(inputTextField);
			
			scaleHandle = new ScaleHandle();			
			scaleHandle.addEventListener(Event.CHANGE, onScaleHandleDrag, false, 0, true);
			
			mainConsoleContainer.addChild(scaleHandle);
			
			controllerManager = new ControllerManager();
			addChild(controllerManager);
			
			
			tabTimer = new Timer(50, 1);
			tabTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetTab, false, 0, true);
			
			messageLog = new Vector.<Message>;
			commands = new Vector.<ConsoleCommand>();
			//default commands
			print("Welcome",MessageTypes.SYSTEM);
			print("Today is " + new Date().toString(),MessageTypes.SYSTEM);
			print("Player version " + Capabilities.version, MessageTypes.SYSTEM);
			
			addCommand(new FunctionCallCommand("consoleheight", setHeight, "View", "Change the number of lines to display. Example: setHeight 5"));
			addCommand(new FunctionCallCommand("version", printVersion, "System", "Prints the welcome message"));
			addCommand(new FunctionCallCommand("clearhistory", clearHistory, "System", "Clears the stored command history"));
			addCommand(new FunctionCallCommand("commands", listCommands, "Utility", "Output a list of available commands"));
			addCommand(new FunctionCallCommand("help", getHelp, "Utility", "Output basic instructions"));
			addCommand(new FunctionCallCommand("clear", clear, "View", "Clear the console"));
			addCommand(new FunctionCallCommand("echo", toggleEcho, "View", "Toggle display of user commands"));
			addCommand(new FunctionCallCommand("timestampDisplay", toggleTimestamp, "View", "Toggle display of message timestamp"));
			addCommand(new FunctionCallCommand("log", log, "Utility", "Save the complete console log for this session to an xml document"));
			addCommand(new FunctionCallCommand("measure", toggleMeasureBracket, "Utility", "Creates a scalable measurement bracket widget. Hold shift to snap to 10s."));
			addCommand(new FunctionCallCommand("screenshot", screenshot, "Utility", "Save a png screenshot (sans console)"));
			addCommand(new FunctionCallCommand("toggleTrace", toggleTrace, "Trace", "Toggle reception of trace values"));
			addCommand(new FunctionCallCommand("toggleTraceDisplay", toggleTraceDisplay, "Trace", "Toggle display of trace values"));
			addCommand(new FunctionCallCommand("clearTrace", clearTrace, "Trace", "Clear trace cache"));
			addCommand(new FunctionCallCommand("enumerateFonts", enumerateFonts, "Utility", "Lists font names available to this swf"));

			addCommand(new FunctionCallCommand("capabilities", getCapabilities, "System", "Prints the system capabilities"));
			addCommand(new FunctionCallCommand("setupStage", setupStageAlignAndScale, "Stage", "Sets stage.align to TOP_LEFT and stage.scaleMode to NO_SCALE"));
			addCommand(new FunctionCallCommand("setFrameRate", setFramerate, "Stage", "Sets stage.frameRate"));
			addCommand(new FunctionCallCommand("showMouse", Mouse.show, "UI", "Shows the mouse cursor"));
			addCommand(new FunctionCallCommand("hideMouse", Mouse.hide, "UI", "Hides the mouse cursor"));
						
			addCommand(new FunctionCallCommand("call", callMethodOnObject, "Introspection", "Calls a method with args within the current introspection scope"));
			addCommand(new FunctionCallCommand("set", setAccessorOnObject, "Introspection", "Sets a variable within the current introspection scope"));
			addCommand(new FunctionCallCommand("get", getAccessorOnObject, "Introspection", "Prints a variable within the current introspection scope"));
			addCommand(new FunctionCallCommand("root", selectBaseScope, "Introspection", "Selects the stage as the current introspection scope"));
			addCommand(new FunctionCallCommand("select", setScopeByName, "Introspection", "Selects the specified object as the current introspection scope"));
			addCommand(new FunctionCallCommand("selectByReference", setScopeByReferenceKey, "Introspection", "Gets a stored reference and sets it as the current introspection scope"));
			addCommand(new FunctionCallCommand("back", up, "Introspection", "(if the current scope is a display object) changes scope to the parent object"));
			addCommand(new FunctionCallCommand("children", printChildren, "Introspection", "Get available children in the current scope"));
			addCommand(new FunctionCallCommand("variables", printVariables, "Introspection", "Get available variables in the current scope"));
			addCommand(new FunctionCallCommand("complex", printComplexObjects, "Introspection", "Get available complex variables in the current scope"));
			addCommand(new FunctionCallCommand("scopes", printDownPath, "Introspection", "List available scopes in the current scope"));
			addCommand(new FunctionCallCommand("methods", printMethods, "Introspection", "Get available methods in the current scope"));
			addCommand(new FunctionCallCommand("updateScope", updateScope, "Introspection", "Gets changes to the current scope tree"));
			addCommand(new FunctionCallCommand("alias", alias, "Introspection", "'alias methodName triggerWord' Create a new command shortcut to the specified function"));
			
			//experimental stuff
			addCommand(new FunctionCallCommand("getReference", getReference, "Referencing", "Stores a weak reference to the current scope in a specified id (getReference 1)"));
			addCommand(new FunctionCallCommand("getReferenceByName", getReferenceByName, "Referencing", "Stores a weak reference to the specified scope in the specified id (getReferenceByName scopename 1)"));
			addCommand(new FunctionCallCommand("listReferences", printReferences, "Referencing", "Lists all stored references and their IDs"));
			addCommand(new FunctionCallCommand("clearReferences", clearReferences, "Referencing", "Clears all stored references"));
			addCommand(new FunctionCallCommand("clearReference", clearReferenceByName, "Referencing", "Clears the specified reference"));
			
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
			
			
			fileRef = new FileReference();
			
			print("Ready. Type help to get started.", MessageTypes.SYSTEM);
			
			calcHeight();
			inputTextField.addEventListener(Event.CHANGE, onInputFieldChange);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			textOutput.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function clearReferenceByName(name:String):void
		{
			try{
			delete(referenceDict[name])
			print("Cleared reference " + name, MessageTypes.SYSTEM);
			printReferences();
			}catch (e:Error) {
				print("No such reference", MessageTypes.ERROR);
			}
		}
		
		private function getReferenceByName(name:String,id:String):void
		{
			try{
				referenceDict[id] = getScopeByName(name);
				printReferences();
			}catch (e:Error) {
				print(e.message, MessageTypes.ERROR);
			}
		}
		
		private function updateScope():void
		{
			setScope(scopeManager.currentScope.obj, true);
		}
		
		private function getReference(id:String):void
		{
			referenceDict[id] = scopeManager.currentScope.obj;
			printReferences();
		}
		private function clearReferences():void {
			referenceDict = new Dictionary(true);
			print("References cleared", MessageTypes.SYSTEM);
		}
		private function printReferences():void {
			print("Stored references: ");
			for (var b:* in referenceDict) {
				print("	"+b.toString() + " : " + referenceDict[b].toString());
			}
		}
		
		private function clearHistory():void
		{
			historySO.data.history = [];
		}
		
		private function printVersion():void
		{
			print("Player version " + Capabilities.version, MessageTypes.SYSTEM);
			print("Console build number " + BUILD, MessageTypes.SYSTEM);
		}
		
		private function toggleMeasureBracket():void
		{
			measureBracket.visible = !measureBracket.visible;
			print("Measuring bracket active: " + measureBracket.visible, MessageTypes.SYSTEM);
		}
		
		private function createController(...properties:Array):void
		{
			controllerManager.createController(scopeManager.currentScope.obj, properties);
		}
		
		private function onScaleHandleDrag(e:Event):void 
		{
			var y:Number = stage.mouseY-22;
			var eh:Number = 14;
			setHeight(Math.floor(y / eh));
			infoTargetY = inputTextField.y;
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			var d:int = Math.max( -1, Math.min(1, e.delta));
			scroll(d);
		}
		
		
		
		private function quitCommand(code:int = 0):void
		{
			System.exit(code);
		}
		private function routeToJS():void {
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
		private function alertErrors():void {
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
		private function screenshot(e:Event = null):void
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
		
		private function enumerateFonts():void
		{
			TextUtils.listFonts(this);
		}
		/**
		 * Alternative trace method
		 * @param	...values
		 */
		public function trace(...values):void {
			if (traceValues) {
				var str:String = "trace: ";
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
		
		private function clearTrace():void
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
			print("		Enter -> Execute line", MessageTypes.SYSTEM);
			print("		Page up/Page down -> Vertical scroll by page", MessageTypes.SYSTEM);
			print("		Arrow up -> Recall the previous executed line", MessageTypes.SYSTEM);
			print("		Arrow down -> Recall the more recent executed line", MessageTypes.SYSTEM);
			print("		Shift+backspace -> Clear the input field", MessageTypes.SYSTEM);
			print("	Mouse functions", MessageTypes.SYSTEM);
			print("		Mousewheel -> Scroll line by line", MessageTypes.SYSTEM);
			print("		Click drag below the input line -> Change console height", MessageTypes.SYSTEM);
			print("	Misc", MessageTypes.SYSTEM);
			print("		Use the 'commands' command to list available commmands", MessageTypes.SYSTEM);
		}
		
		private function onInputFieldChange(e:Event = null):void 
		{
			var cmd:ConsoleCommand;
			for (var i:int = commands.length; i--; ) 
			{
				if (commands[i].trigger.toLowerCase() == inputTextField.text.split(" ")[0].toLowerCase()) {
					cmd = commands[i];
					break;
				}
			}
			if (cmd && cmd.helpText != "") {
				infoTargetY = inputTextField.y+18;
				infoField.text = "?	" + cmd.trigger + ": " + cmd.helpText;
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
			numLines = int(Math.max(1, lines));
			historySO.data.numLines = numLines;
			scrollIndex = Math.max(0, messageLog.length - numLines);
			if (calcHeight()>stage.stageHeight) {
				setHeight(3);
				return print("Out of bounds, setting to safe range");
			}
			redraw();
		}
		private function calcHeight():Number {
			return consoleHeight = numLines * 14+22;
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
			commands.push(command);
			commands.sort(sortCommands);
		}
		
		private function sortCommands(a:ConsoleCommand,b:ConsoleCommand):int
		{
			if (a.grouping == b.grouping) return -1;
			return 1;
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
		public function print(str:String, type:uint = MessageTypes.OUTPUT):void {
			var split:Array = str.split("\n").join("\r").split("\r");
			var date:String = String(new Date().getTime());
			var msg:Message;
			for (var i:int = 0; i < split.length; i++) 
			{
				msg = new Message(split[i], date, type);
				messageLog.push(msg);
				scrollIndex = Math.max(0, messageLog.length - numLines);
			}			
			if (type == MessageTypes.ERROR&&alertingErrors) {
				ExternalInterface.call("alert", str);
			}
			if (routingToJS&&ExternalInterface.available){
				ExternalInterface.call("console.log", str);
			}
			drawMessages();
		}
		/**
		 * Clear the console
		 */
		public function clear():void {
			messageLog = new Vector.<Message>;
			drawMessages();
		}
		/**
		 * List available command phrases
		 */
		public function listCommands():void {
			var str:String = "Available commands: ";
			print(str,MessageTypes.SYSTEM);
			for (var i:int = 0; i < commands.length; i++) 
			{
				print("	--> "+commands[i].grouping+" : "+commands[i].trigger,MessageTypes.SYSTEM);
			}
			/*+"	"+commands[i].grouping+"	"+commands[i].helpText*/
		}
		private function drawMessages():void {
			if (!visible||locked) return;
			textOutput.text = "";
			textOutput.defaultTextFormat = TextFormats.debugTformatOld;
			scrollRange = Math.min(messageLog.length, scrollIndex + numLines);
			
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
				textOutput.appendText("["+lineNumStr+"] > ");
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
				textOutput.appendText(messageLog[i].text + "\n");
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
			//scope menu test
			var selectionMenuItem:ContextMenuItem = new ContextMenuItem("Set console scope", true);
			selectionMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSelectionMenu,false,0,true);
			var controllerMenuItem:ContextMenuItem = new ContextMenuItem("Create controller");
			controllerMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onControllerMenu,false,0,true);
			if (!parent.contextMenu) {
				parent.contextMenu = new ContextMenu();
			}
			parent.contextMenu.customItems.push(selectionMenuItem);
			parent.contextMenu.customItems.push(controllerMenuItem);
			
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
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onStageResize);
			setScope(parent);
		}
		
		private function onControllerMenu(e:ContextMenuEvent):void 
		{
			if (e.mouseTarget is DisplayObject) {
				setScope(e.mouseTarget);
				var properties:Array = ["name","x", "y", "width", "height", "rotation", "scaleX", "scaleY"];
				controllerManager.createController(scopeManager.currentScope.obj, properties, e.mouseTarget.x, e.mouseTarget.y);
				print("Controller created. Type values to alter, or use the mousewheel on numbers.");
			}
		}
		
		private function onSelectionMenu(e:ContextMenuEvent):void 
		{
			setScope(e.mouseTarget);
		}
		
		private function onStageResize(e:Event):void 
		{
			redraw();
		}
		
		
		/**
		 * Save the current console contents to an xml file
		 */
		public function log(e:Event = null ):void {
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
				var cmd:String;
				if (e.keyCode == Keyboard.UP) {
					if(previousCommands.length>0){
						commandIndex = Math.max(commandIndex-=1,0);
						cmd = previousCommands[commandIndex];
					}
					
				}else if (e.keyCode == Keyboard.DOWN) {
					if(commandIndex<previousCommands.length-1){
						commandIndex = Math.min(commandIndex += 1, previousCommands.length - 1);
						cmd = previousCommands[commandIndex];
					}
				}
				if (cmd) {
					if(cmd){
						inputTextField.text = cmd;
						stage.focus = inputTextField;
						var spaceIndex:int = inputTextField.text.indexOf(" ");
						//TODO: strip trailing whitespace when adding to command history
						if (spaceIndex>-1) {
							inputTextField.setSelection(inputTextField.text.indexOf(" ") + 1, inputTextField.text.length);
						}else{
							inputTextField.setSelection(0, inputTextField.text.length);
						}
					}
				}
			}
		}
		private function onKeyDown(e:KeyboardEvent):void 
		{
			
			//if (e.charCode == 124) {
			if (e.keyCode == Keyboard.TAB && e.shiftKey) {
				disableTab();
				toggleDisplay();
			}else if (visible && e.keyCode == Keyboard.TAB) {
				disableTab();
				if (visible&&stage.focus!=inputTextField) stage.focus = inputTextField;
				if (autoCompleteManager.suggestionActive) {
					//TODO: Make tab only append a space if there isn't already one
					inputTextField.appendText(" ");
					inputTextField.setSelection(inputTextField.length, inputTextField.length);
				}else {
				}
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
					if (echo) print("'"+inputTextField.text+"'",MessageTypes.USER);
					if (tryCommand()) {
						success = true;
					}else {
						print("Invalid command " + inputTextField.text,MessageTypes.ERROR);
					}
					inputTextField.text = "";
					onInputFieldChange();
				}else if (e.keyCode == Keyboard.PAGE_DOWN) {
					scroll(-numLines);
				}else if (e.keyCode == Keyboard.PAGE_UP) {
					scroll(numLines);
				}
				
			}
		}
		private function scroll(delta:int):void {
			
			if (delta < 0 && messageLog.length < numLines) return;
			scrollIndex = delta < 0 ? Math.min(messageLog.length - numLines, scrollIndex - delta) : Math.max(0, scrollIndex - delta);
			//scrollIndex = delta < 0 ? Math.min(messageLog.length - numLines, scrollIndex + numLines) : Math.max(0, scrollIndex - numLines);
			drawMessages();
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
		
		private function tryCommand(input:String = null):Boolean
		{
			var cmdStr:String;
			if (input) {
				cmdStr = stripWhitespace(input);
			}else {
				cmdStr = stripWhitespace(inputTextField.text);
			}
			var str:String = cmdStr.toLowerCase().split(" ")[0];
			if (!authenticated&&str!=authCommand.trigger) {
				print("Not authenticated", MessageTypes.ERROR);
				return false;
			}
			if (previousCommands[previousCommands.length - 1] != cmdStr && str!=authCommand.trigger) {
				previousCommands.push(cmdStr);
				if (previousCommands.length > 10) {
					previousCommands.shift();
				}
			}
			commandIndex = previousCommands.length;
			for (var i:int = 0; i < commands.length; i++) 
			{
				if (commands[i].trigger.toLowerCase() == str) {
					doCommand(commands[i]);
					return true;
				}
			}
			return false;
		}
		private function stripWhitespace(str:String):String {
			while (str.charAt(str.length - 1) == " ") 
			{
				str = str.substr(0, str.length - 1);
			}
			return str;
		}
		
		private function doCommand(command:ConsoleCommand):void
		{
			var args:Array = stripWhitespace(inputTextField.text).split(" ");
			args.shift();
			args = parseForReferences(args);
			var val:*;
			if (command is FunctionCallCommand) {
				try {
					val = (command as FunctionCallCommand).callback.apply(this, args);
					if(val) print("		"+val);
				}catch (e:ArgumentError) {
					//try again with all args as string
					try {
						val = (command as FunctionCallCommand).callback.call(this, args.join(" "));
						if(val) print("		"+val);
					}catch (e:Error) {
						print("Error: "+e.message,MessageTypes.ERROR);
					}
				}catch (e:Error) {
					print("Error: "+e.message,MessageTypes.ERROR);
				}
			}else {
				print("Abstract command, no action",MessageTypes.ERROR);
			}
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
				mainConsoleContainer.y = -consoleHeight+1;
				targetY = 0;
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
			consoleBg.graphics.clear();
			consoleBg.graphics.beginFill(0, 0.8);
			consoleBg.graphics.drawRect(0, 0, w, consoleHeight);
			consoleBg.graphics.lineStyle(0, 0);
			consoleBg.graphics.moveTo(0, consoleHeight);
			consoleBg.graphics.lineTo(w, consoleHeight);
			
			textOutput.height = consoleHeight-18;
			textOutput.width = w;
			inputTextField.width = w;
			inputTextField.height = 18;
			inputTextField.y = consoleHeight-18;
			infoField.y = inputTextField.y;
			infoField.height = 17;
			infoField.width = w;
			drawMessages();
			
			scaleHandle.x = 0;
			scaleHandle.width = w;
			scaleHandle.y = inputTextField.y + inputTextField.height;
			
			return new Rectangle(0, 0, w, h);
		}
		
		
		//introspection stuff, wip
		private function up():void {
			scopeManager.up();
			printScope();
			printDownPath();
		}
		private function setScopeByReferenceKey(key:String):void {
			if (referenceDict[key]) {
				setScope(referenceDict[key]);
			}
		}
		private function setScopeByName(str:String):void {
			try {
				setScope(getScopeByName(str));
			}catch (e:Error) {
				print(e.message, MessageTypes.ERROR);
			}
		}
		private function getScopeByName(str:String):*{
			try {
				return scopeManager.currentScope.obj[str];
			}catch (e:Error) {
				try {
					return(scopeManager.currentScope.obj.getChildByName(str));
				}catch (e:Error) {
				}
			}
			throw new Error("No such scope");
		}
		private function setScope(o:*,force:Boolean = false):void {
			if (!force&&scopeManager.currentScope.obj === o) return;
			try{
				scopeManager.setScope(o);
				autoCompleteManager.scopeDict = scopeManager.currentScope.autoCompleteDict;
			}catch (e:Error) {
				print("No such scope",MessageTypes.ERROR);
			}
			printScope();
			printDownPath();
		}
		private function printMethods():void {
			var m:Vector.<MethodDesc> = scopeManager.currentScope.methods;
			print("	methods:");
			var i:int
			for (i = 0; i < m.length; i++) 
			{
				var md:MethodDesc = m[i];
				print("		" + md.name + " : " + md.returnType);
			}
		}
		private function printVariables():void {
			var a:Vector.<VariableDesc> = scopeManager.currentScope.variables;
			var cv:*;
			print("	variables:");
			var i:int
			for (i = 0; i < a.length; i++) 
			{
				var vd:VariableDesc = a[i];
				print("		" + vd.name + ": " + vd.type);
				try{
					cv = scopeManager.currentScope.obj[vd.name];
					print("			value: " + cv.toString());
				}catch (e:Error) {
					
				}
			}
			var b:Vector.<AccessorDesc> = scopeManager.currentScope.accessors;
			for (i = 0; i < b.length; i++) 
			{
				var ad:AccessorDesc = b[i];
				print("		" + ad.name + ": " + ad.type);
				try{
					cv = scopeManager.currentScope.obj[ad.name];
					print("			value: " + cv.toString());
				}catch (e:Error) {
					
				}
			}
		}
		private function printChildren():void {
			var c:Vector.<ChildScopeDesc> = scopeManager.currentScope.children;
			if (c.length < 1) return;
			print("	children:");
			for (var i:int = 0; i < c.length; i++) 
			{
				var cc:ChildScopeDesc = c[i];
				print("		" + cc.name + " : " + cc.type);
			}
		}
		
		private function printDownPath():void {
			printChildren();
			printComplexObjects();
		}
		
		private function printComplexObjects():void
		{
			var a:Vector.<VariableDesc> = scopeManager.currentScope.variables;
			var cv:*;
			if (a.length < 1) return;
			print("	complex types:");
			var i:int
			for (i = 0; i < a.length; i++) 
			{
				var vd:VariableDesc = a[i];
				switch(vd.type) {
					case "Number":
					case "Boolean":
					case "String":
					case "int":
					case "uint":
					case "Array":
					continue;
					break;
					default:
					break;
				}
				print("		" + vd.name + ": " + vd.type);
			}
		}
		
		private function printScope():void {
			print("scope : " + scopeManager.currentScope.obj.toString());
		}
		private function setAccessorOnObject(accessorName:String, arg:*):*
		{
			if (arg == "true") {
				arg = true;
			}else if (arg == "false") {
				arg = false;
			}
			scopeManager.currentScope.obj[accessorName] = arg;
			return accessorName + ": " + scopeManager.currentScope.obj[accessorName];
		}
		private function getAccessorOnObject(accessorName:String):String{
			return scopeManager.currentScope.obj[accessorName].toString();
		}
		private function selectBaseScope():void {
			setScope(stage);
		}
		private function clearScope():void {
			selectBaseScope(); //temp
		}
		private function parseForReferences(args:Array):Array {
			for (var i:int = 0; i < args.length; i++) 
			{
				if (args[i].indexOf("<") > -1) {
					//contains a reference
					var s:Array = args[i].split("<").join(">").split(">");
					var key:String = s[1];
					args[i] = referenceDict[key];
				}
			}
			return args;
		}
		private function callMethodOnObject(...args:Array):* {
			//var split:Array = stripWhitespace(commandstring).split(" ");
			//for (var i:int = 0; i < split.length; i++) 
			//{
				//trace(split[i]);
			//}
			var cmd:String = args.shift();
			//split = parseForReferences(split);
			var func:Function = scopeManager.currentScope.obj[cmd];
			return func.apply(scopeManager.currentScope.obj, args);
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
		
		//batch
		public function runBatch(batch:String):Boolean {
			locked = true;
			print("Starting batch", MessageTypes.SYSTEM);
			var split:Array = batch.split("\n").join("\r").split("\r");
			var result:Boolean = false;
			for (var i:int = 0; i < split.length; i++) 
			{
				result = tryCommand(split[i])
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
		
		//authentication
		public function setupAuthentication(password:String):void {
			this.password = password;
			authenticated = false;
			if (authenticationSetup) return;
			authenticationSetup = true;
			addCommand(authCommand);
			addCommand(deAuthCommand);
		}
		
		private function lock():void
		{
			authenticated = false;
			print("Deauthorized", MessageTypes.SYSTEM);
		}
		public function authenticate(password:String):void {
			if (password == this.password) {
				authenticated = true;
				print("Authorized", MessageTypes.SYSTEM);
			}else {
				print("Not authorized", MessageTypes.ERROR);
			}
		}
		
	}
	
}