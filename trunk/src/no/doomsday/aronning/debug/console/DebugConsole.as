package no.doomsday.aronning.debug.console
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import no.doomsday.aronning.debug.console.bitmap.*;
	import no.doomsday.aronning.debug.console.commands.*;
	import no.doomsday.aronning.debug.console.cpu.CPU;
	import no.doomsday.aronning.debug.console.events.*;
	import no.doomsday.aronning.debug.console.framerate.FramerateCheck;
	import no.doomsday.aronning.debug.console.measurement.MeasurementTool;
	import no.doomsday.aronning.debug.console.messages.*;
	import no.doomsday.aronning.debug.console.testbuttons.TestButtonContainer;
	import no.doomsday.aronning.debug.console.text.autocomplete.AutocompleteManager;
	import no.doomsday.aronning.debug.console.objectwatching.*;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class DebugConsole extends Sprite
	{
		private static const GLOBAL:String = "global";
		private static const LOCAL:String = "local";
		private static const STAGE:String = "stage";
		
		private static var INSTANCE:DebugConsole;
		private var displayObject:Sprite;
		private var inspectionTargetDict:Dictionary;
		private var consoleBg:Shape;
		private var pluginBg:Shape;
		private var textOutput:TextField;
		private var inputTextField:TextField;
		private var infoField:TextField;
		private var debugTformatInput:TextFormat;
		private var debugTformatOld:TextFormat;
		private var debugTformatNew:TextFormat;
		private var debugTformatSystem:TextFormat;
		private var targetY:Number;
		private var pluginTargetY:Number;
		private var infoTargetY:Number;
		private var debugTformatTimeStamp:TextFormat;
		private var debugTformatError:TextFormat;
		private var scrollIndex:int = 0;
		private var scrollRange:int = 0;
		private var previousCommands:Array;
		private var commandIndex:int = 0;
		private var numLines:int = 10;
		private var consoleHeight:Number = 120;
		private var autoCompleteManager:AutocompleteManager;
		private var historySO:SharedObject;
		private var debugTformatHelp:TextFormat;
		
		private var messageLog:Vector.<Message>;
		private var commands:Vector.<ConsoleCommand>;
		private var objectWatchers:Vector.<WatcherFieldAssociation>;
		
		private var mainConsole:Sprite;
		private var pluginContainer:Sprite;
		
		private var pluginsEnabled:Boolean = true;
		private var saveState:Boolean = false;
		private var traceValues:Boolean = true;
		private var showTraceValues:Boolean = true;
		private var echo:Boolean = true;
		private var timeStamp:Boolean = false;
		private var waitingForClick:Boolean;
		private var prevHeight:int;
		private var measurementBox:MeasurementTool;
		private var selectionOverlay:Sprite;
		
		private var parentTabEnabled:Boolean = true;
		private var parentTabChildren:Boolean = true;
		private var tabTimer:Timer;
		private var monitoringMemory:Boolean = false;
		private var fileRef:FileReference;
		private var framerateMonitor:FramerateCheck;
		private var testButtonContainer:TestButtonContainer;
		private var routingToJS:Boolean;
		private var alertingErrors:Boolean;
		private var menu:ContextMenu;
		private var storingCoordinates:Boolean;
		private var mousePosDoc:XML;
		private var workingCoordinateSpace:String = STAGE;
		private var positionNodeName:String;
		
		/**
		 * Get the singleton instance of DebugConsole
		 * @return
		 */
		public static function getInstance():DebugConsole {
			if (!INSTANCE) {
				INSTANCE = new DebugConsole();
			}
			return INSTANCE;
		}
		/**
		 * Creates a new DebugConsole instance. 
		 * This class is intended to always be on top of the stage of the application it is associated with.
		 * A static singleton retrieval method is available, optional but recommended
		 * To toggle console visibility, hit shift+tab 
		 */
		public function DebugConsole() 
		{
			historySO = SharedObject.getLocal("consoleHistory");
			if (!historySO.data.history) historySO.data.history = [];
			if (!historySO.data.numLines) historySO.data.numLines = numLines;
			numLines = historySO.data.numLines;
			previousCommands = historySO.data.history;
			commandIndex = previousCommands.length;
			visible = false;
			
			inspectionTargetDict = new Dictionary(true);
			
			pluginContainer = new Sprite();
			addChild(pluginContainer);
			
			mainConsole = new Sprite();
			addChild(mainConsole);
			
			consoleBg = new Shape();
			var dropshadow:DropShadowFilter = new DropShadowFilter(4, 90, 0, 0.3, 0, 10);
			consoleBg.filters = [dropshadow];
			mainConsole.addChild(consoleBg);
			
			framerateMonitor = new FramerateCheck();
			
			pluginBg = new Shape();
			pluginBg.filters = [dropshadow];
			pluginContainer.addChild(pluginBg);
			
			testButtonContainer = new TestButtonContainer();
			pluginContainer.addChild(testButtonContainer);
			
			textOutput = new TextField();
			textOutput.gridFitType = GridFitType.PIXEL;
			mainConsole.addChild(textOutput);
			inputTextField = new TextField();
			
			autoCompleteManager = new AutocompleteManager(inputTextField);
			
			debugTformatInput = new TextFormat("_typewriter", 11, 0xFFD900, null, null, null, null, null, null, 0, 0, 0,0);
			debugTformatError = new TextFormat("_typewriter", 11, 0xEE0000, null, null, null, null, null, null, 0, 0, 0, 0);
			debugTformatOld = new TextFormat("_typewriter", 11, 0xBBBBBB, null, null, null, null, null, null, 0, 0, 0, 0);
			debugTformatTimeStamp = new TextFormat("_typewriter", 11, 0xAAAAAA, null, null, null, null, null, null, 0, 0, 0, 0);
			debugTformatNew = new TextFormat("_typewriter", 11, 0xFFFFFF, null, null, null, null, null, null, 0, 0, 0, 0);
			debugTformatSystem = new TextFormat("_typewriter", 11, 0x00DD00, null, null, null, null, null, null, 0, 0, 0, 0);
			debugTformatHelp = new TextFormat("_typewriter", 10, 0xbbbbbb, null, null, null, null, null, null, 0, 0, 0, 0);
			
			infoField = new TextField();
			infoField.background = true;
			infoField.backgroundColor = 0x222222;
			infoField.tabEnabled = false;
			infoField.mouseEnabled = false;
			infoField.selectable = false;
			infoField.defaultTextFormat = debugTformatHelp;
			mainConsole.addChild(infoField);
			
			menu = new ContextMenu();
			var logItem:ContextMenuItem = new ContextMenuItem("Log");
			logItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, log);
			var screenshotItem:ContextMenuItem = new ContextMenuItem("Screenshot");
			screenshotItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, screenshot);
			var toggleDisplayItem:ContextMenuItem = new ContextMenuItem("Hide");
			toggleDisplayItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleDisplay);
			
			menu.customItems.push(logItem, screenshotItem,toggleDisplayItem);
			
			contextMenu = menu;
			
			inputTextField.defaultTextFormat = debugTformatInput;
			inputTextField.multiline = false;
			inputTextField.type = TextFieldType.INPUT;
			inputTextField.background = true;
			inputTextField.backgroundColor = 0;
			inputTextField.tabEnabled = false;
			mainConsole.addChild(inputTextField);
			
			tabTimer = new Timer(50, 1);
			tabTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetTab, false, 0, true);
			
			messageLog = new Vector.<Message>;
			objectWatchers = new Vector.<WatcherFieldAssociation>;
			commands = new Vector.<ConsoleCommand>();
			//default commands
			//addMessage("AS3 Debug Console", Capabilities.version,MessageTypes.SYSTEM);
			//addMessage("	Primary dev by Andreas Rønning at creuna.no", Capabilities.version,MessageTypes.SYSTEM);
			addMessage("Initializing console for player version " + Capabilities.version,MessageTypes.SYSTEM);
			addCommand(new ConsoleCallbackCommand("consoleheight", setHeight, "View", "Change the number of lines to display. Example: setHeight 5"));
			addCommand(new ConsoleCallbackCommand("commands", listCommands, "Utility", "Output a list of available commands"));
			addCommand(new ConsoleCallbackCommand("help", getHelp, "Utility", "Output basic instructions"));
			addCommand(new ConsoleCallbackCommand("clear", clear, "View", "Clear the console"));
			addCommand(new ConsoleCallbackCommand("echo", toggleEcho, "View", "Toggle display of user commands"));
			addCommand(new ConsoleCallbackCommand("timestampDisplay", toggleTimestamp, "View", "Toggle display of message timestamp"));
			var v:Number = Number(Capabilities.version.split(" ")[1].split(",")[0]);
			if (v > 9) {
				addMessage("	Flash player 10 commands added", MessageTypes.SYSTEM);
				addCommand(new ConsoleCallbackCommand("log", log, "Utility", "Save the complete console log for this session to an xml document"));
				addCommand(new ConsoleCallbackCommand("screenshot", screenshot, "Utility", "Save a png screenshot (sans console)"));
				addCommand(new ConsoleCallbackCommand("screenshotTarget", screenshotTarget, "Utility", "Saves a screenshot of the current target alone (see 'target')"));
			}
			addCommand(new ConsoleCallbackCommand("toggleTrace", toggleTrace, "Trace", "Toggle reception of trace values"));
			addCommand(new ConsoleCallbackCommand("toggleTraceDisplay", toggleTraceDisplay, "Trace", "Toggle display of trace values"));
			addCommand(new ConsoleCallbackCommand("clearTrace", clearTrace, "Trace", "Clear trace cache"));
			addCommand(new ConsoleCallbackCommand("pluginDisplay", togglePlugins, "Plugins", "Toggles the plugin display bar"));
			addCommand(new ConsoleCallbackCommand("inspect", inspectTarget, "Inspection", "Inspects specified or all properties on the current target"));
			addCommand(new ConsoleCallbackCommand("listChildNames", listChildNames, "Inspection", "Outputs a list of the names of child DisplayObjects on the current target (see 'target')"));
			addCommand(new ConsoleCallbackCommand("target", startInspectionTargetSelection, "Targeting", "Starts a process by which you select a target for inspection by clicking on it"));
			addCommand(new ConsoleCallbackCommand("setTargetProperty", setTargetProperty, "Utility", "Sets a property on the current target (see 'target'), for instance 'setTargetProperty x 200'"));
			addCommand(new ConsoleCallbackCommand("enumerateFonts", enumerateFonts, "Utility", "Lists font names available to this swf"));
			addCommand(new ConsoleCallbackCommand("buildMousePosXML", buildPositionXML, "Utility", "Generates an xml document of the positions of mouse clicks"));
			
			addCommand(new ConsoleCallbackCommand("coordinatespace", setCoordinateSpace, "System", "Sets working space to 'global','local' or 'stage'"));
			
			addCommand(new ConsoleCallbackCommand("measure", setupMeasureBox, "Measuring", "Shows the measurement tool. Append a number to set an optional snap increment"));
			addCommand(new ConsoleCallbackCommand("measureTarget", measureTarget, "Measuring", "Shows the measurement tool and brackets the currently targeted display object (see command 'target')"));
			addCommand(new ConsoleCallbackCommand("capabilities", getCapabilities, "System", "Prints the system capabilities"));
			addCommand(new ConsoleCallbackCommand("cpu", benchmarkCPU, "System", "Does a rudimentary CPU benchmarking"));
			addCommand(new ConsoleCallbackCommand("monitorMemory", toggleMemoryMonitor, "Monitoring", "Toggles memory monitoring"));
			addCommand(new ConsoleCallbackCommand("monitorFramerate", toggleFramerateMonitor, "Monitoring", "Toggles framerate monitoring"));
			addCommand(new ConsoleCallbackCommand("setupStage", setupStageAlignAndScale, "Stage", "Sets stage.align to TOP_LEFT and stage.scaleMode to NO_SCALE"));
			addCommand(new ConsoleCallbackCommand("setFrameRate", setFramerate, "Stage", "Sets stage.frameRate"));
			addCommand(new ConsoleCallbackCommand("showMouse", Mouse.show, "UI", "Shows the mouse cursor"));
			addCommand(new ConsoleCallbackCommand("hideMouse", Mouse.hide, "UI", "Hides the mouse cursor"));
			//addCommand(new ConsoleCallbackCommand("alias", makeAlias, "Utility", "Create a command alias by appending the name of the command followed by an alias, for instance 'alias measure m'"));
			if(ExternalInterface.available){
				addMessage("	Externalinterface commands added", MessageTypes.SYSTEM);
				addCommand(new ConsoleCallbackCommand("routeToJS", routeToJS, "ExternalInterface", "Toggle output to JS console"));
				addCommand(new ConsoleCallbackCommand("alertErrors", alertErrors, "ExternalInterface", "Toggle JS alert on errors"));
			}
			if (Capabilities.isDebugger) {
				addMessage("	Debugplayer commands added", MessageTypes.SYSTEM);
				addCommand(new ConsoleCallbackCommand("debug_gc", System.gc, "System", "Forces a garbage collection cycle"));
				addCommand(new ConsoleCallbackCommand("debug_pause", System.pause, "System", "Pauses the Flash Player. After calling this method, nothing in the player continues except the delivery of Socket events"));
				addCommand(new ConsoleCallbackCommand("debug_resume", System.resume, "System", "Resumes the Flash Player after using 'pause'"));
			}
			if (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "External") {
				addMessage("	Standalone commands added", MessageTypes.SYSTEM);
				addCommand(new ConsoleCallbackCommand("quitapp", quitCommand, "System", "Quit the application"));
			}
			
			
			fileRef = new FileReference();
			
			addMessage("Console initialized", MessageTypes.SYSTEM);
			
			calcHeight();
			inputTextField.addEventListener(Event.CHANGE, onInputFieldChange);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function setCoordinateSpace(space:String):void
		{
			if (space != LOCAL && space != GLOBAL && space != STAGE) throw new ArgumentError("No such coordinate space. Use 'local','global' or 'stage'");
			workingCoordinateSpace = space;
			addMessage("Working coordinate space set to " + workingCoordinateSpace, MessageTypes.SYSTEM);
		}
		
		private function listChildNames():void
		{
			try{
				var t:DisplayObjectContainer = inspectionTargetDict["target"];
				addMessage("Children of " + t.name + ":");
				for (var i:int = 0; i < t.numChildren; i++) 
				{
					addMessage("	Depth: " + i + ", ToString:" + t.getChildAt(i).toString() + ", Name:" + t.getChildAt(i).name);
				}
			}catch (e:Error) {
				addMessage("Target has no children, or is not a DisplayObjectContainer", MessageTypes.ERROR);
			}
		}
		
		private function setTargetProperty(...args):void
		{
			try {
				for (var i:int = 0; i < args.length; i += 2) {
					var t:Object = inspectionTargetDict["target"];
					var prop:String = args[i];
					var val:* = args[i + 1];
					t[prop] = val;
					addMessage("Set "+prop+" on "+t+" to "+val, MessageTypes.SYSTEM);
				}
			}catch (e:Error) {
				addMessage("Invalid number of arguments, or invalid arguments", MessageTypes.ERROR);
			}
		}
		
		private function screenshotTarget():void
		{
			try {
				var bounds:Rectangle = (inspectionTargetDict["target"] as DisplayObject).getBounds(inspectionTargetDict["target"].parent);
				var bmd:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
				bmd.draw(inspectionTargetDict["target"]);
				fileRef.save(PNGEncoder.encode(bmd), "Screenshot_"+inspectionTargetDict["target"].name+".png");
				addMessage(bmd.width+"x"+bmd.height+" png screenshot created", MessageTypes.SYSTEM);
			}catch (e:Error) {
				addMessage("Screenshot failed : "+e.message, MessageTypes.ERROR);
			}
		}
		
		private function calculate(...args):Number
		{
			if (args.length < 1) {
				throw new Error("Invalid math arguments");
				return 0;
			}
			var operators:Array = ["+", "/", "*", "-"];
			var fullString:String = args.join("");
			var result:Number = 0;
			var iterations:int = 0;
			var maxIterations:int = 100;
			while (fullString.length > 0) {
				iterations++;
				if (iterations > maxIterations) return result;
				//find the first instance of the next valid operator...
				var opIndex:int = 0xFFFFFF;
				var op:String = "";
				for (var i:int = operators.length; i--; ) 
				{
					var thisOperatorIndex:int = fullString.indexOf(operators[i]);
					if (thisOperatorIndex < opIndex) {
						opIndex = thisOperatorIndex;
						op = operators[i]; //store it..
					}
				}
				//grab the preceding string
				var slice:String = fullString.slice(0, opIndex-1);
				trace("this slice",slice);
				fullString = fullString.slice(opIndex);
				trace("new fullstring",fullString);
			}
			return result;
		}
		
		private function onMenuSelect(e:ContextMenuEvent):void 
		{
			trace(e);
		}
		
		private function quitCommand():void
		{
			System.exit(0);
		}
		private function routeToJS():void {
			if (ExternalInterface.available) {
				routingToJS = !routingToJS;
				if (routingToJS) {
					addMessage("Routing console to JS", MessageTypes.OUTPUT);
				}else {
					addMessage("No longer routing console to JS", MessageTypes.OUTPUT);
				}
			}else {
				addMessage("ExternalInterface not available", MessageTypes.ERROR);
			}
		}
		private function alertErrors():void {
			if (ExternalInterface.available) {
				alertingErrors = !alertingErrors;
				if (alertingErrors ) {
					addMessage("Alerting errors through JS", MessageTypes.OUTPUT);
				}else {
					addMessage("No longer alerting errors through JS", MessageTypes.OUTPUT);
				}
			}else {
				addMessage("ExternalInterface not available", MessageTypes.ERROR);
			}
		}
		public function addTestButton(label:String, func:Function, ...params):void {
			if (testButtonContainer.addButton(label, func, params)) {
				addMessage("Added button '" + label + "'", MessageTypes.SYSTEM);
			}else {
				addMessage("Button with label'" + label + "' already present", MessageTypes.ERROR);
			}
		}
		public function removeTestButton(label:String):void {
			testButtonContainer.removeButton(label);
		}
		private function screenshot(e:Event = null):void
		{
			var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			visible = false;
			try {
				bmd.draw(stage);
				fileRef.save(PNGEncoder.encode(bmd), "Screenshot.png");
				addMessage(bmd.width+"x"+bmd.height+" png screenshot created", MessageTypes.SYSTEM);
			}catch (e:Error) {
				addMessage("Screenshot failed : "+e.message, MessageTypes.ERROR);
			}
			visible = true;
		}
		
		private function benchmarkCPU():void {
			addMessage("Educated guess of cpu performance compared to Intel Core2 Quad 2.66ghz: " + CPU.calculate(), MessageTypes.SYSTEM);
		}
		
		private function toggleFramerateMonitor():void
		{
			if (contains(framerateMonitor)) {
				removeChild(framerateMonitor);
				removeObjectWatcher(framerateMonitor);
				addMessage("Stopped monitoring framerate", MessageTypes.SYSTEM);
			}else {
				addChild(framerateMonitor);
				addObjectWatcher(new ObjectWatcher(framerateMonitor, ["framerate"], "Target framerate " + stage.frameRate));
				addMessage("Monitoring framerate", MessageTypes.SYSTEM);
			}
		}
		
		private function toggleMemoryMonitor():void
		{
			monitoringMemory = !monitoringMemory;
			if (monitoringMemory) {
				addObjectWatcher(new ObjectWatcher(System,["totalMemory"],"",30));
			}else {
				removeObjectWatcher(System);
			}
		}
				
		private function setFramerate(rate:int = 60):void
		{
			stage.frameRate = rate;
			addMessage("Framerate set to " + stage.frameRate, MessageTypes.SYSTEM);
		}
		
		private function getCapabilities():void
		{
			addMessage("System capabilities info:",MessageTypes.SYSTEM);
			addMessage("	Capabilities.avHardwareDisable : "+Capabilities.avHardwareDisable);
			addMessage("	Capabilities.hasAccessibility : "+Capabilities.hasAccessibility);
			addMessage("	Capabilities.hasAudio : "+Capabilities.hasAudio);
			addMessage("	Capabilities.hasAudioEncoder : "+Capabilities.hasAudioEncoder);
			addMessage("	Capabilities.hasEmbeddedVideo : "+Capabilities.hasEmbeddedVideo);
			addMessage("	Capabilities.hasIME : "+Capabilities.hasIME);
			addMessage("	Capabilities.hasMP3 : "+Capabilities.hasMP3);
			addMessage("	Capabilities.hasPrinting : "+Capabilities.hasPrinting);
			addMessage("	Capabilities.hasScreenBroadcast : "+Capabilities.hasScreenBroadcast);
			addMessage("	Capabilities.hasStreamingAudio : "+Capabilities.hasStreamingAudio);
			addMessage("	Capabilities.hasStreamingVideo : "+Capabilities.hasStreamingVideo);
			addMessage("	Capabilities.hasTLS : "+Capabilities.hasTLS);
			addMessage("	Capabilities.hasVideoEncoder : "+Capabilities.hasVideoEncoder);
			addMessage("	Capabilities.isDebugger : "+Capabilities.isDebugger);
			addMessage("	Capabilities.language : "+Capabilities.language);
			addMessage("	Capabilities.localFileReadDisable : "+Capabilities.localFileReadDisable);
			addMessage("	Capabilities.manufacturer : "+Capabilities.manufacturer);
			addMessage("	Capabilities.os : "+Capabilities.os);
			addMessage("	Capabilities.pixelAspectRatio : "+Capabilities.pixelAspectRatio);
			addMessage("	Capabilities.playerType : "+Capabilities.playerType);
			addMessage("	Capabilities.screenColor : "+Capabilities.screenColor);
			addMessage("	Capabilities.screenDPI : "+Capabilities.screenDPI);
			addMessage("	Capabilities.screenResolutionX : "+Capabilities.screenResolutionX);
			addMessage("	Capabilities.screenResolutionY : "+Capabilities.screenResolutionY);
			addMessage("	Capabilities.version : "+Capabilities.version);
		}
		
		private function measureTarget():void
		{
			if (inspectionTargetDict["target"]) {
				if(!measurementBox||!measurementBox.visible) setupMeasureBox();
				measurementBox.bracket(inspectionTargetDict["target"])
				addMessage("Target measurements: " + measurementBox.getMeasurements(), MessageTypes.SYSTEM);
			}else {
				addMessage("No current target", MessageTypes.ERROR);
			}
		}
		
		private function hideMeasureBox():void
		{
			if (contains(measurementBox)) removeChild(measurementBox);
		}
		
		private function setupMeasureBox(range:Number = -1 ):void
		{
			if (!measurementBox) {
				measurementBox = new MeasurementTool();
				addChildAt(measurementBox, pluginContainer.numChildren - 1);
			}
			if (range == -1) {
				measurementBox.visible = !measurementBox.visible;
				if (measurementBox.increment > 0) {
					addMessage("Measurement box toggled, current snapping: "+measurementBox.increment, MessageTypes.SYSTEM);
				}else {
					addMessage("Measurement box toggled", MessageTypes.SYSTEM);
				}
			}else {
				measurementBox.visible = true;
				measurementBox.increment = range;
			}
		}
		
		private function enumerateFonts():void
		{
			var fnts:Array = Font.enumerateFonts();
			if (fnts.length < 1) {
				addMessage("Only system fonts available");
			}
			for (var i:int = 0; i < fnts.length; i++) 
			{
				addMessage("	" + fnts[i].fontName);
			}
		}
		
		private function togglePlugins():void
		{
			pluginsEnabled = !pluginsEnabled;
			var i:int;
			if (pluginsEnabled) {
				pluginContainer.visible = true;
				for (i = objectWatchers.length; i--; ) 
				{
					if(visible)	objectWatchers[i].watcher.start();
				}
				addMessage("Plugins enabled", MessageTypes.SYSTEM);
			}else {
				pluginContainer.visible = false;
				for (i = objectWatchers.length; i--; ) 
				{
					objectWatchers[i].watcher.stop();
				}
				addMessage("Plugins disabled", MessageTypes.SYSTEM);
			}
		}
		/**
		 * Add a new object watcher
		 * @param	p
		 */
		public function addObjectWatcher(p:ObjectWatcher):void {
			for (var i:int = objectWatchers.length; i--; ) 
			{
				if (objectWatchers[i].watcher == p) return;
			}
			var tf:TextField = new TextField();
			tf.width = 400;
			tf.height = 20;
			tf.x = 5;
			tf.defaultTextFormat = debugTformatOld;
			tf.selectable = false;
			pluginContainer.addChild(tf);
			
			var association:WatcherFieldAssociation = new WatcherFieldAssociation(p, tf);
			objectWatchers.push(association);
			tf.y = (objectWatchers.length - 1) * 20;
			
			if (visible) {
				p.start();
				p.forceUpdate();
				redraw();
			}
			
		}
		/**
		 * Remove an object watcher
		 * @param	obj
		 * The object for which you want the watcher removed
		 */
		public function removeObjectWatcher(obj:Object):void {
			for (var i:int = objectWatchers.length; i--; ) 
			{
				if (objectWatchers[i].watcher.objectToWatch == obj) {
					objectWatchers[i].destroy();
					objectWatchers.splice(i, 1);
					redraw();
					return;
				}
			}
			throw new Error("That object isn't being watched");
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
				addMessage(str, MessageTypes.TRACE);
			}
			drawMessages();
		}
		private function toggleTrace():void
		{
			traceValues = !traceValues;
			if (traceValues) {
				addMessage("Trace log enabled", MessageTypes.SYSTEM);
			}else {
				addMessage("Trace log disabled", MessageTypes.SYSTEM);
			}
		}
		private function toggleTraceDisplay():void
		{
			showTraceValues = !showTraceValues;
			if (showTraceValues) {
				addMessage("Trace display enabled", MessageTypes.SYSTEM);
			}else {
				addMessage("Trace display disabled", MessageTypes.SYSTEM);
			}
			drawMessages();
		}
		
		private function clearTrace():void
		{
			for (var i:int = messageLog.length; i--; ) 
			{
				if (messageLog[i].type == MessageTypes.TRACE) messageLog.splice(i, 1);
			}
			addMessage("Trace cache cleared", MessageTypes.SYSTEM);
			drawMessages();
		}
		
		private function getHelp():void
		{
			addMessage("Help", MessageTypes.SYSTEM);
			addMessage("	Keyboard commands", MessageTypes.SYSTEM);
			addMessage("		Shift-Tab -> Toggle console", MessageTypes.SYSTEM);
			addMessage("		Tab -> (When out of focus) Set the keyboard focus to the input field", MessageTypes.SYSTEM);
			addMessage("		Tab -> (When in focus) Skip to end of line and append a space", MessageTypes.SYSTEM);
			addMessage("		Enter -> Execute line", MessageTypes.SYSTEM);
			addMessage("		Page up/Page down -> Vertical scroll", MessageTypes.SYSTEM);
			addMessage("		Arrow up -> Recall the previous executed line", MessageTypes.SYSTEM);
			addMessage("		Arrow down -> Recall the more recent executed line", MessageTypes.SYSTEM);
			addMessage("		Shift+backspace -> Clear the input field", MessageTypes.SYSTEM);
			addMessage("	Misc", MessageTypes.SYSTEM);
			addMessage("		Use the 'commands' command to list available commmands", MessageTypes.SYSTEM);
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
				//TweenLite.to(infoField, 0.2, { y:inputTextField.y + 18 } );
				infoTargetY = inputTextField.y+18;
				infoField.text = "?	" + cmd.trigger + ": " + cmd.helpText;
				addEventListener(Event.ENTER_FRAME, updateInfoMotion);
			}else {
				//TweenLite.to(infoField, 0.2, { y:inputTextField.y } );
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
			calcHeight();
			redraw();
		}
		private function calcHeight():void {
			consoleHeight = numLines * 14+22;
		}
		/**
		 * Toggle echo (command confirmation) on and off
		 */
		public function toggleEcho():void {
			echo = !echo;
			if (echo) addMessage("Echo on",MessageTypes.SYSTEM)
			else addMessage("Echo off",MessageTypes.SYSTEM);
		}
		/**
		 * Toggle display of message timestamp
		 */
		public function toggleTimestamp():void {
			timeStamp = !timeStamp;
			if (timeStamp) addMessage("Timestamp on",MessageTypes.SYSTEM)
			else addMessage("Timestamp off",MessageTypes.SYSTEM);
		}
		/**
		 * Add a custom command to the console
		 * @param	command
		 * An instance of ConsoleCallbackCommand or ConsoleEventCommand
		 */
		public function addCommand(command:ConsoleCommand):void {
			autoCompleteManager.addToDictionary(command.trigger);
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
			addMessage("Event: "+e.toString(),MessageTypes.OUTPUT);
		}
		/**
		 * Add a message to the console
		 * @param	str
		 * The string to be added. A timestamp is automaticaly prefixed
		 */
		public function addMessage(str:String, type:uint = MessageTypes.OUTPUT):void {
			var msg:Message = new Message(str, String(new Date().getTime()), type);
			messageLog.push(msg);
			scrollIndex = Math.max(0, messageLog.length - numLines);
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
			addMessage(str,MessageTypes.SYSTEM);
			for (var i:int = 0; i < commands.length; i++) 
			{
				addMessage("	--> "+commands[i].grouping+" : "+commands[i].trigger,MessageTypes.SYSTEM);
			}
			/*+"	"+commands[i].grouping+"	"+commands[i].helpText*/
		}
		private function drawMessages():void {
			if (!visible) return;
			textOutput.text = "";
			textOutput.defaultTextFormat = debugTformatOld;
			scrollRange = Math.min(messageLog.length, scrollIndex + numLines);
			
			for (var i:int = scrollIndex; i < scrollRange; i++) 
			{
				if (messageLog[i].type == MessageTypes.USER && !echo) continue;
				if (messageLog[i].type == MessageTypes.TRACE && !showTraceValues) continue;
				textOutput.defaultTextFormat = debugTformatOld;
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
					textOutput.defaultTextFormat = debugTformatTimeStamp;
					textOutput.appendText(messageLog[i].timestamp + " ");
				}
				var fmt:TextFormat;
				switch(messageLog[i].type) {
					case MessageTypes.USER:
						fmt = debugTformatInput;
					break;
					case MessageTypes.SYSTEM:
						fmt = debugTformatSystem;
					break;
					case MessageTypes.ERROR:
						fmt = debugTformatError;
					break;
					case MessageTypes.OUTPUT:
					default:
						if(i==messageLog.length-1){
							fmt = debugTformatNew;
						}else {
							fmt = debugTformatOld;
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
			addMessage("StageAlign set to TOP_LEFT, StageScaleMode set to NO_SCALE", MessageTypes.SYSTEM);
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
				addMessage("Warning: stage.align is not set to TOP_LEFT; This might cause scaling issues",MessageTypes.ERROR);
				score++;
			}
			if (stage.scaleMode != StageScaleMode.NO_SCALE) {
				addMessage("Warning: stage.scaleMode is not set to NO_SCALE; This might cause scaling issues",MessageTypes.ERROR);
				score++;
			}
			if (score > 0) {
				addMessage("Use the setupStage command to temporarily alleviate these problems",MessageTypes.SYSTEM);
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onStageResize);	
		}
		
		private function onStageResize(e:Event):void 
		{
			redraw();
		}
		
		
		/**
		 * Save the current console contents to a text file
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
				//msg += messageLog[i].text + "\n";
				node.appendChild(<message>{messageLog[i].text}</message>);
				//str += msg;
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
					if (inputTextField.text.charAt(inputTextField.text.length-1) == " " || inputTextField.text.length<1) return;
					inputTextField.appendText(" ");
					inputTextField.setSelection(inputTextField.length, inputTextField.length);
				}else {
				}
			}
			if (e.keyCode == Keyboard.BACKSPACE && e.shiftKey) {
				inputTextField.text = "";
				onInputFieldChange();
			}
			if (e.keyCode == Keyboard.ESCAPE && waitingForClick) {
				abortTargetClick();
			}
			if (visible) {
				if (e.keyCode == Keyboard.ENTER) {
					if (inputTextField.text.length < 1) {
						stage.focus = inputTextField;
						return;
					}
					var success:Boolean = false;
					if (echo) addMessage("'"+inputTextField.text+"'",MessageTypes.USER);
					if (tryCommand()) {
						success = true;
					}else {
						addMessage("Invalid command " + inputTextField.text,MessageTypes.ERROR);
					}
					inputTextField.text = "";
					onInputFieldChange();
				}else if (e.keyCode == Keyboard.PAGE_DOWN) {
					if(messageLog.length>numLines){
						scrollIndex = Math.min(messageLog.length - numLines, scrollIndex += numLines);
						drawMessages();
					}
				}else if (e.keyCode == Keyboard.PAGE_UP) {
					scrollIndex = Math.max(0, scrollIndex -= numLines);
					drawMessages();
				}
				
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
		
		private function tryCommand():Boolean
		{
			var cmdStr:String = stripWhitespace(inputTextField.text);
			if (previousCommands[previousCommands.length - 1] != cmdStr) {
				previousCommands.push(cmdStr);
			}
			if (previousCommands.length > 10) {
				previousCommands.shift();
			}
			commandIndex = previousCommands.length;
			var str:String = cmdStr.toLowerCase().split(" ")[0];
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
			var val:*;
			if (command is ConsoleCallbackCommand) {
				try {
					val = (command as ConsoleCallbackCommand).callback.apply(this, args);
					if(val) addMessage("return value: "+val);
				}catch (e:Error) {
					//try again with all args as string
					try {
						val = (command as ConsoleCallbackCommand).callback.call(this, args.join(" "));
						if(val) addMessage("return value: "+val);
					}catch (e:Error) {
						addMessage("Argument error: "+e.message,MessageTypes.ERROR);
					}
				}
			}else if (command is ConsoleEventCommand) {
				var event:ConsoleEvent = new ConsoleEvent((command as ConsoleEventCommand).event);
				event.args = args;
				dispatchEvent(event);
			}else if (command is ConsoleDiagnosticCommand) {
				var out:String = "";
				for (var obj:String in (command as ConsoleDiagnosticCommand).dictionary) {
					out += "" + (command as ConsoleDiagnosticCommand).dictionary[obj];
					for (var i:int = 0; i < args.length; i++) 
					{
						var arg:String = args[i];
						try{
						out += "," + args[i] + ":" + (command as ConsoleDiagnosticCommand).dictionary[obj][arg];
						}catch (e:Error) {
							out += "," + args[i] + ": no such property";
						}
					}
					addMessage(out,MessageTypes.OUTPUT);
				}
			}else {
				addMessage("Abstract command, no action",MessageTypes.ERROR);
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
				mainConsole.y = -consoleHeight+1;
				targetY = 0;
				addEventListener(Event.ENTER_FRAME, updateMainMotion);
				if(pluginsEnabled){
					for (i = objectWatchers.length; i--;) 
					{
						objectWatchers[i].watcher.start();
					}
					pluginContainer.y = bounds.height;
					pluginTargetY = bounds.height - pluginContainer.height;
					addEventListener(Event.ENTER_FRAME, updatePluginMotion);
				}
			}else {
				reenableTab();
				for (i = objectWatchers.length; i--;) 
				{
					objectWatchers[i].watcher.stop();
				}
			}
			inputTextField.text = "";
			onInputFieldChange();
			stage.focus = inputTextField;
		}
		
		private function updateMainMotion(e:Event):void 
		{
			var diffY:Number = targetY-mainConsole.y;
			mainConsole.y += diffY / 4;
			if (Math.abs(diffY) < 0.01) {
				mainConsole.y = targetY;
				removeEventListener(Event.ENTER_FRAME, updateMainMotion);
			}
		}
		private function updatePluginMotion(e:Event):void 
		{
			var diffY:Number = pluginTargetY-pluginContainer.y;
			pluginContainer.y += diffY / 4;
			if (Math.abs(diffY) < 0.01) {
				pluginContainer.y = pluginTargetY;
				removeEventListener(Event.ENTER_FRAME, updatePluginMotion);
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
		
		private function redraw(e:Event = null ):Rectangle
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
			
			for (var i:int = objectWatchers.length; i--;)
			{
				objectWatchers[i].field.width = w-5;
			}
			
			testButtonContainer.y = objectWatchers.length * 20;
			testButtonContainer.redraw();
			
			pluginBg.graphics.clear();
			pluginBg.graphics.beginFill(0);
			pluginBg.graphics.drawRect(0, 0, w, pluginContainer.height);
						
			pluginContainer.y = h - pluginContainer.height;
			
			return new Rectangle(0, 0, w, h);
			
		}
		private function inspectTarget(...args):void {
			if (!inspectionTargetDict["target"]) {
				addMessage("No target set", MessageTypes.ERROR);
				return;
			}
			var tgt:Object = inspectionTargetDict["target"];
			var out:String = "";
			if (args.length < 1) {
				addMessage("No properties specified",MessageTypes.ERROR);
				return;
			}
			for (var i:int = 0; i < args.length; i++) 
			{
				var arg:String = args[i];
				try{
					out += arg + ":" + tgt[arg]+". ";
				}catch (e:Error) {
					out += arg + ": no such property. ";
				}
			}
			addMessage(out,MessageTypes.OUTPUT);
		}
		private function startInspectionTargetSelection():void {
			addMessage("Click on the displayObject you wish to inspect (esc to abort)", MessageTypes.SYSTEM);
			prevHeight = numLines;
			setHeight(1);
			waitingForClick = true;
			stage.addEventListener(MouseEvent.CLICK, setInspectionTargetFromClick, true, 0xFFFFFF, true);
		}
		private function buildPositionXML(positionNodeName:String = "position"):void {
			storingCoordinates ? stopStoringCoordinates() : startStoringCoordinates(positionNodeName);
		}
		private function startStoringCoordinates(positionNodeName:String = "position"):void {
			addMessage("Click anywhere on stage to store mouse coordinates. Enter command again to stop", MessageTypes.SYSTEM);
			this.positionNodeName = positionNodeName;
			mousePosDoc = <data/>;
			stage.addEventListener(MouseEvent.CLICK, storeMousePosition);
			storingCoordinates = true;
		}
		private function stopStoringCoordinates():void {
			addMessage("No longer storing mouse coordinates, creating document", MessageTypes.SYSTEM);
			stage.removeEventListener(MouseEvent.CLICK, storeMousePosition);
			storingCoordinates = false;
			fileRef.save(mousePosDoc, "positions.xml");
			mousePosDoc = <data/>;
		}
		
		private function storeMousePosition(e:MouseEvent):void 
		{
			var p:Point;
			trace(e.target.name);
			switch(workingCoordinateSpace) {
				case GLOBAL:
					p = new Point(e.target.mouseX, e.target.mouseY);
					p = e.target.localToGlobal(p);
				break;
				case LOCAL:
					p = new Point(e.target.mouseX, e.target.mouseY);
				break;
				case STAGE:
					p = new Point(stage.mouseX,stage.mouseY);
				break;
			}
			trace(p);
			mousePosDoc.appendChild(<{positionNodeName}><x>{p.x}</x><y>{p.y}</y></{positionNodeName}>);
		}
		
		private function setInspectionTargetFromClick(e:MouseEvent):void 
		{
			e.stopPropagation();
			if (!visible) {
				toggleDisplay();
			}
			setHeight(prevHeight);
			waitingForClick = false;
			setInspectionTarget(e.target);
			stage.removeEventListener(MouseEvent.CLICK, setInspectionTargetFromClick, true);
		}
		public function setInspectionTarget(obj:Object):void {
			inspectionTargetDict["target"] = obj;
			addMessage("Target set to: " + obj, MessageTypes.SYSTEM);
			stage.focus = inputTextField;
		}
		
		private function abortTargetClick():void
		{
			setHeight(prevHeight);
			waitingForClick = false;
			stage.removeEventListener(MouseEvent.CLICK, setInspectionTargetFromClick, true);
			stage.focus = inputTextField;
			addMessage("Aborted", MessageTypes.ERROR);
		}
		/**
		 * Resets the console completely, removing custom commands, listeners, the works
		 */
		public function reset():void {
			//TODO reset all
		}
		
	}
	
}