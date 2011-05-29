package no.doomsday.console
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.utils.describeType;
	
	import no.doomsday.console.core.AbstractConsole;
	import no.doomsday.console.core.DConsole;
	import no.doomsday.console.core.commands.FunctionCallCommand;
	import no.doomsday.console.core.gui.Window;
	import no.doomsday.console.core.input.KeyBindings;
	import no.doomsday.console.core.input.KeyboardManager;
	import no.doomsday.console.core.messages.MessageTypes;
	import no.doomsday.console.utilities.ContextMenuUtil;
	import no.doomsday.console.utilities.measurement.MeasurementTool;
	import no.doomsday.console.utilities.monitoring.GraphWindow;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleUtil 
	{
		
		public static const MODE_CONSOLE:String = "console";
		private static var _instance:AbstractConsole;
		
		private static var keyboardShortcut:Array = [];
		
		public function ConsoleUtil() 
		{
			throw new Error("Use static methods");
		}
		/**
		 * Get the singleton console instance
		 */
		public static function get instance():AbstractConsole {
			return getInstance();
		}
		
		public static function getInstance():AbstractConsole {
			if (!_instance) {
				_instance = new DConsole();
				if(keyboardShortcut.length > 0){
					instance.changeKeyboardShortcut(keyboardShortcut[0], keyboardShortcut[1]); //TODO: What's this do?
				}
			}
			return _instance;
		}
		public static function select(target:*):void {
			instance.select(target);
		}
		/**
		 * Add a message
		 * @param	msg
		 */
		public static function print(input:Object):void {
			instance.print(input.toString());
		}
		/**
		 * Add a message with system color coding
		 * @param	msg
		 */
		public static function addSystemMessage(msg:String):void {
			instance.print(msg, MessageTypes.SYSTEM);
		}
		/**
		 * Add a message with error color coding
		 * @param	msg
		 */
		public static function addErrorMessage(msg:String):void {
			instance.print(msg, MessageTypes.ERROR);
		}
		/**
		 * Legacy, deprecated. Use "createCommand" instead
		 */
		public static function linkFunction(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
			createCommand(triggerPhrase, func, commandGroup, helpText);
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
		 */
		public static function createCommand(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
			instance.addCommand(new FunctionCallCommand(triggerPhrase, func, commandGroup, helpText));
		}
		/**
		 * Use this to print event messages on dispatch (addEventListener(Event.CHANGE, ConsoleUtil.onEvent))
		 */
		public static function get onEvent():Function {
			return instance.onEvent;
		}
		/**
		 * Add a message to the trace buffer
		 */
		public static function get trace():Function {
			return instance.trace;
		}
		public static function log(...args):void {
			instance.log.apply(instance, args);
		}
		public static function get clear():Function {
			return instance.clear;
		}
		/**
		 * Show the console
		 */
		public static function show():void {
			instance.show();
		}
		/**
		 * Hide the console
		 */
		public static function hide():void {
			instance.hide();
		}
		/**
		 * Sets the console docking position
		 * @param	position
		 * "top" or "bot"/"bottom"
		 */
		public static function dock(position:String):void {
			instance.dock(position);
		}
		
		//TODO: Temp stuff for graph windows. This really needs a lot of work, ignore for now
		/*public static function getGraph(title:String = "Graph"):GraphWindow {
			var w:GraphWindow = new GraphWindow(title);
			instance.pluginContainer.addChild(w);
			w.y = w.x = 50;
			return w;
		}
		public static function destroyWindow(w:Window):Boolean {
			return false;
		}*/
		
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
					instance.changeKeyboardShortcut(keystroke, modifier);
				}
				success = true;
			}
			return success;
		}
		
		/**
		 * Change keyboard shortcut.
		 * 
		 * @param keystroke	The keystroke
		 * @param modifier	The modifier 
		 */ 
		private static function changeKeyboardShortcut(keystroke:uint, modifier:uint):void {
			instance.changeKeyboardShortcut(keystroke, modifier);
		}
		
		
		/**
		 * Lock
		 * 
		 * @param secret The secret to lock the console with.
		 */
		public static function lock(secret:String):void {
			lockWithKeyCodes(KeyBindings.toCharCodes(secret));
		}
		
		/**
		 * Lock with keyCodes
		 * 
		 * @param keyCodes The keyCodes to lock the console with.
		 */ 
		public static function lockWithKeyCodes(keyCodes:Array):void {
			instance.lock.lock(keyCodes, instance.toggleDisplay);
		}
		
	}
}