package 
{
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.dconsole2.plugins.plugcollections.AllPlugins;
	import com.furusystems.logging.slf4as.global.debug;
	import com.furusystems.logging.slf4as.global.error;
	import com.furusystems.logging.slf4as.global.fatal;
	import com.furusystems.logging.slf4as.global.info;
	import com.furusystems.logging.slf4as.global.warn;
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * Hello world and intro to DConsole64
	 * @author Andreas Rønning
	 */
	public class ConsoleMain extends Sprite 
	{
	
		//[Embed(source='bin/222493312.jpg')]
		//private var BgImage:Class;
		
		public function ConsoleMain():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			//addChild(new BgImage());
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//Other code in your initializer here; We want our console setup at the bottom
			
			
			//DConsole.clearPersistentData();
			/**
			 * Add the console view to your stage
			 * It's pretty key that this be added on top of everything else, and be allowed to stay on top
			 */
			addChild(DConsole.view);
			
			/**
			 * By default, the console has a fairly limited feature set
			 * To enable plugins, call registerPlugins() with class references
			 * In this case we'll use the AllPlugins convenience class
			 */
			//DConsole.registerPlugins(BasicPlugins);
			DConsole.registerPlugins(AllPlugins);
			
			/**
			 * To toggle the console, you will typically use the default 
			 * keyboard shortcut, ctrl+shift+enter
			 */
			DConsole.show();
			
			/**
			 * Before we can start logging, we need to create a logger to correctly tag our messages
			 * The tag is a string representation of the class type that created the log message
			 */
			//return;
			var L:ILogger = Logging.getLogger(ConsoleMain); //Typically you'll create this as a static constant in your classes
			
			/**
			 * Printing to the console is done through the ILogger logging methods
			 * info(), error(), warn(), fatal() and debug()
			 * Debug is for your regular trace messages
			 */
			L.debug("Hello debug!");
			
			/**
			 * By default, the console will "stack" repeated messages so it doesn't get flooded
			 * It keeps a numeric tally of the number of repeated messages though
			 */
			L.debug("Hello debug!");
			
			/**
			 * Info is the next step up, and these messages describe the flow and progress of your application
			 */
			L.info("Hello info!");
			
			/**
			 * Warnings are effectively errors that aren't critical
			 * All logging methods work much like trace(), taking multiple args
			 */
			L.warn("Hello warning!", this, 552);
			
			/**
			 * Error is obviously for when something breaks
			 * Note that each logging method input is colored differently in the output
			 */
			L.error("Hello error!");
			
			/**
			 * Fatal is when something REALLY breaks. Reserve fatal messages for conditions when
			 * your application literally can not recover.
			 */
			L.fatal("Hello fatal");
			
			/**
			 * If you don't desire tagging and unique loggers, you can use the package level logging methods
			 */
			debug("Hello package level debug");
			info("Hello package level info");
			warn("Hello package level warn");
			error("Hello package level error");
			fatal("Hello package level fatal");

			
			/**
			 * While the console has a bunch of built-in stuff, you only really
			 * gain something special when you create your own commands
			 */
			DConsole.createCommand("myCommand", myMethod, "My commands", "My helpful string"); 
			
			/**
			 * In this case we've created a command that takes a string and returns 
			 * it as an array of characters. When a command returns something, the 
			 * console will try to display the result.
			 * 
			 * To execute our command, keep the console open, and type its trigger string
			 * into the input field. In our case, our method needs an argument, so we 
			 * follow the trigger string with it, like this:
			 * myCommand hello world
			 * 
			 * Then we hit the enter key to execute.
			 */
			
			/**
			 * Finally, let's set the console header to something a little more personal :-)
			 */
			//DConsole.setTitle("Hello console!");
		}
		
		private function myMethod(input:String):Array
		{
			return input.split("");
		}
		
	}
	
}