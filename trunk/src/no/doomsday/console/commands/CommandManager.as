package no.doomsday.console.commands 
{
	import no.doomsday.console.DConsole;
	import no.doomsday.console.introspection.InspectionUtils;
	import no.doomsday.console.messages.MessageTypes;
	import no.doomsday.console.persistence.PersistenceManager;
	import no.doomsday.console.references.ReferenceManager;
	import no.doomsday.console.text.ParseUtils;
	import no.doomsday.console.text.TextUtils;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class CommandManager
	{
		private var console:DConsole;
		private var persistence:PersistenceManager;
		private var	commands:Vector.<ConsoleCommand>;
		private var password:String = "";
		private var authenticated:Boolean = true;
		private var authCommand:FunctionCallCommand = new FunctionCallCommand("authorize", authenticate, "System", "Input password to gain console access");
		private var deAuthCommand:FunctionCallCommand = new FunctionCallCommand("deauthorize", lock, "System", "Lock the console from unauthorized user access");
		private var authenticationSetup:Boolean;
		private var referenceManager:ReferenceManager;
		public function CommandManager(console:DConsole,persistence:PersistenceManager,referenceManager:ReferenceManager) 
		{
			this.persistence = persistence;
			this.console = console;
			this.referenceManager = referenceManager;
			commands = new Vector.<ConsoleCommand>();
		}
		public function addCommand(c:ConsoleCommand):void {
			commands.push(c);
			commands.sort(sortCommands);
		}
		private function sortCommands(a:ConsoleCommand,b:ConsoleCommand):int
		{
			if (a.grouping == b.grouping) return -1;
			return 1;
		}
		public function tryCommand(input:String, sub:Boolean = false ):*
		{
			var cmdStr:String = TextUtils.stripWhitespace(input);
			var args:Array;
			try{
				args = ArgumentSplitterUtil.slice(cmdStr);
			}catch (e:Error) {
				console.print(e.getStackTrace(), MessageTypes.ERROR);
				throw e;
			}
			var str:String = args.shift().toLowerCase();
			if (!authenticated&&str!=authCommand.trigger) {
				if(!sub) console.print("Not authenticated", MessageTypes.ERROR);
				throw new Error("Not authenticated");
			}
			if (str != authCommand.trigger&&!sub) {
				persistence.addtoHistory(input);
			}
			
			var commandArgs:Vector.<CommandArgument> = new Vector.<CommandArgument>();
			for (var i:int = 0; i < args.length; i++) 
			{
				commandArgs.push(new CommandArgument(args[i],this,referenceManager));
			}
			
			for (i = 0; i < commands.length; i++) 
			{
				if (commands[i].trigger.toLowerCase() == str) {
					try{
						var val:* = doCommand(commands[i], commandArgs, sub);
					}catch (e:Error) {
						throw(e);
					}
					if(!sub && val!=null && val!=undefined) console.print(val);
					return val;
				}
			}
			throw new Error("No such command");
		}
		public function doCommand(command:ConsoleCommand,commandArgs:Vector.<CommandArgument> = null,sub:Boolean = false):*
		{
			if (!commandArgs) commandArgs = new Vector.<CommandArgument>();
			var args:Array = [];
			for (var i:int = 0; i < commandArgs.length; i++) 
			{
				args.push(commandArgs[i].data);
			}
			var val:*;
			if (command is FunctionCallCommand) {
				var func:FunctionCallCommand = (command as FunctionCallCommand);
				try {
					for (i = 0; i < args.length; i++) 
					{
						trace(args[i] + ": " + typeof args[i]);
					}
					val = func.callback.apply(null, args);
					return val;
				}catch (e:Error) {
					//try again with all args as string
					try {
						var joint:String = args.join(" ");
						if (joint.length>0){
							val = func.callback.call(null, joint);
						}else {
							val = func.callback.call(null);
						}
						return val;
					}catch (e:Error) {
						console.print(e.getStackTrace(), MessageTypes.ERROR);
						return null;
					}
					throw new Error(e.message);
				}catch (e:Error) {
					console.print(e.getStackTrace(), MessageTypes.ERROR);
					return null;
				}
			}else {
				console.print("Abstract command, no action", MessageTypes.ERROR);
				return null;
			}
		}
		
		/**
		 * List available command phrases
		 */
		public function listCommands():void {
			var str:String = "Available commands: ";
			console.print(str,MessageTypes.SYSTEM);
			for (var i:int = 0; i < commands.length; i++) 
			{
				console.print("	--> "+commands[i].grouping+" : "+commands[i].trigger,MessageTypes.SYSTEM);
			}
		}
		public function parseForCommand(str:String):ConsoleCommand {
			for (var i:int = commands.length; i--; ) 
			{
				if (commands[i].trigger.toLowerCase() == str.split(" ")[0].toLowerCase()) {
					return commands[i];
				}
			}
			throw new Error("No command found");
		}
		public function parseForSubCommand(arg:String):* {
			
			return arg;
		}
		
		//authentication
		public function setupAuthentication(password:String):void {
			this.password = password;
			authenticated = false;
			if (authenticationSetup) return;
			authenticationSetup = true;
			console.addCommand(authCommand);
			console.addCommand(deAuthCommand);
		}
		
		private function lock():void
		{
			authenticated = false;
			console.print("Deauthorized", MessageTypes.SYSTEM);
		}
		public function authenticate(password:String):void {
			if (password == this.password) {
				authenticated = true;
				console.print("Authorized", MessageTypes.SYSTEM);
			}else {
				console.print("Not authorized", MessageTypes.ERROR);
			}
		}
		public function doSearch(search:String):Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>;
			var s:String = search.toLowerCase();
			for (var i:int = 0; i < commands.length; i++) 
			{
				var c:ConsoleCommand = commands[i];
				if (c.trigger.toLowerCase().indexOf(s, 0) > -1) {
					result.push(c.trigger);
				}
			}
			return result;
		}
		
		
	}

}