package com.furusystems.dconsole2.core.commands 
{
	import com.furusystems.dconsole2.core.commands.utils.ArgumentSplitterUtil;
	import com.furusystems.dconsole2.core.errors.CommandError;
	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	import com.furusystems.dconsole2.core.persistence.PersistenceManager;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	import com.furusystems.dconsole2.core.references.ReferenceManager;
	import com.furusystems.dconsole2.core.text.TextUtils;
	import com.furusystems.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public final class CommandManager
	{
		private var _console:DConsole;
		private var _persistence:PersistenceManager;
		private var	_commands:Vector.<ConsoleCommand>;
		private var _referenceManager:ReferenceManager;
		private const _EMPTY_ARGS:Vector.<CommandArgument> = new Vector.<CommandArgument>();
		private var _pluginManager:PluginManager;
		public function CommandManager(console:DConsole,persistence:PersistenceManager,referenceManager:ReferenceManager,pluginManager:PluginManager) 
		{
			_pluginManager = pluginManager;
			_persistence = persistence;
			_console = console;
			_referenceManager = referenceManager;
			_commands = new Vector.<ConsoleCommand>();
		}
		public function addCommand(c:ConsoleCommand,includeInHistory:Boolean = true):void {
			for (var i:int = 0; i < _commands.length; i++) 
			{
				if (_commands[i].trigger == c.trigger) {
					throw new ArgumentError("Duplicate command trigger phrase: " + c.trigger + " already in use");
				}
			}
			c.includeInHistory = includeInHistory;
			_commands.push(c);
			_commands.sort(sortCommands);
		}
		public function removeCommand(trigger:String):void {
			for (var i:int = 0; i < _commands.length; i++) 
			{
				if (_commands[i].trigger == trigger) {
					_commands.splice(i, 1);
					return;
				}
			}
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
				_console.print(e.getStackTrace(), ConsoleMessageTypes.ERROR);
				throw e;
				return;
			}
			var str:String = args.shift().toLowerCase();
			
			var commandArgs:Vector.<CommandArgument> = new Vector.<CommandArgument>();
			for (var i:int = 0; i < args.length; i++) 
			{
				commandArgs.push(new CommandArgument(args[i], this, _referenceManager, _pluginManager));
			}
			
			for (i = 0; i < _commands.length; i++) 
			{
				if (_commands[i].trigger.toLowerCase() == str) {
					try {
						var val:* = doCommand(_commands[i], commandArgs, sub);
						if (!sub) {
							if (_commands[i].includeInHistory) _persistence.addtoHistory(input);
						}
					}catch (e:Error) {
						throw(e);
						return;
					}
					if(!sub && val!=null && val!=undefined) _console.print(val);
					return val;
				}
			}
			throw new CommandError("'"+str+"' is not a command.");
		}
		public function doCommand(command:ConsoleCommand,commandArgs:Vector.<CommandArgument> = null,sub:Boolean = false):*
		{
			if (!commandArgs) commandArgs = _EMPTY_ARGS;
			var args:Array = [];
			for (var i:int = 0; i < commandArgs.length; i++) 
			{
				args.push(commandArgs[i].data);
			}
			var val:*;
			if (command is FunctionCallCommand) {
				var func:FunctionCallCommand = (command as FunctionCallCommand);
				try {
					//trace("try once");
					val = func.callback.apply(this, args);
					return val;
				}catch (e:ArgumentError) {
					//try again with all args as string
					//trace(e.getStackTrace());
					try {
						var joint:String = args.join(" ");
						//trace("try again");
						if (joint.length > 0) {
							val = func.callback.call(this, joint);
						}else {
							val = func.callback.call(this);
						}
						return val;
					}catch (e:Error) {
						_console.print(e.message, ConsoleMessageTypes.ERROR);
						return null;
					}
					throw new Error(e.message);
				}catch (e:Error) {
					_console.print(e.getStackTrace(), ConsoleMessageTypes.ERROR);
					return null;
				}
			}else {
				_console.print("Abstract command, no action", ConsoleMessageTypes.ERROR);
				return null;
			}
		}
		
		/**
		 * List available command phrases
		 */
		public function listCommands(searchStr:String = null):void {
			var str:String = "Available commands: ";
			if (searchStr) str += " (search for '" + searchStr+"')";
			_console.print(str,ConsoleMessageTypes.SYSTEM);
			for (var i:int = 0; i < _commands.length; i++) 
			{
				if (searchStr) {
					var joint:String = _commands[i].grouping + _commands[i].trigger + _commands[i].helpText + _commands[i].returnType;
					if (joint.toLowerCase().indexOf(searchStr) == -1) continue;
				}
				_console.print("	--> "+_commands[i].grouping+" : "+_commands[i].trigger,ConsoleMessageTypes.SYSTEM);
			}
		}
		public function parseForCommand(str:String):ConsoleCommand {
			for (var i:int = _commands.length; i--; ) 
			{
				if (_commands[i].trigger.toLowerCase() == str.split(" ")[0].toLowerCase()) {
					return _commands[i];
				}
			}
			throw new Error("No command found");
		}
		public function parseForSubCommand(arg:String):* {
			
			return arg;
		}
		
		public function doSearch(search:String):Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>;
			var s:String = search.toLowerCase();
			for (var i:int = 0; i < _commands.length; i++) 
			{
				var c:ConsoleCommand = _commands[i];
				if (c.trigger.toLowerCase().indexOf(s, 0) > -1) {
					result.push(c.trigger);
				}
			}
			return result;
		}
		
		
	}

}