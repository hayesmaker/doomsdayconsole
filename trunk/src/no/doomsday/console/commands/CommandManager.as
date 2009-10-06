package no.doomsday.console.commands 
{
	import no.doomsday.console.DConsole;
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
				console.print(e.message, MessageTypes.ERROR);
				return false;
			}
			var str:String = args.shift().toLowerCase();
			if (!authenticated&&str!=authCommand.trigger) {
				if(!sub) console.print("Not authenticated", MessageTypes.ERROR);
				return false;
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
					var val:* = doCommand(commands[i], commandArgs, sub);
					if(!sub) console.print(val);
					return val;
				}
			}
			return false;
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
				try {
					val = (command as FunctionCallCommand).callback.apply(this, args);
					//if ((val || isNaN(val)) && val != undefined) { 
						//if (!sub) console.print(val);
					//}
					return val == undefined ? true : val;
				}catch (e:ArgumentError) {
					//try again with all args as string
					//return;
					try {
						var joint:String = args.join(" ");
						if (joint.length>0){
							val = (command as FunctionCallCommand).callback.call(this, joint);
						}else {
							val = (command as FunctionCallCommand).callback.call(this);
						}
						//if (val || isNaN(val)) {
							//if(!sub) console.print(val);
						//}
						return val == undefined ? true : val;
					}catch (e:Error) {
						console.print("Error: " + e.message, MessageTypes.ERROR);
						return null;
					}
				}catch (e:Error) {
					console.print("Error: " + e.message, MessageTypes.ERROR);
					return null;
				}
			}else {
				console.print("Abstract command, no action", MessageTypes.ERROR);
				return null;
			}
		}
		
		private function parseForSubCommands(args:Array):Array
		{
			for (var i:int = 0; i < args.length; i++) 
			{
				if (args[i].charAt(0) == "%") {
					trace("subcommand!");
					var split:Array = args[i].split("");
					split.pop();
					split.shift();
					var cmdStr:String = split.join("");
					args[i] = tryCommand(cmdStr,true);
				}
			}
			return args;
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
		
		
	}

}