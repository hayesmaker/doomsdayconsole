﻿package no.doomsday.dconsole2.core.references 
{
	import flash.utils.Dictionary;
	import no.doomsday.dconsole2.core.introspection.ScopeManager;
	import no.doomsday.dconsole2.core.output.ConsoleMessageTypes;
	import no.doomsday.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ReferenceManager
	{
		private var referenceDict:Dictionary = new Dictionary(true);
		private var console:DConsole;
		private var scopeManager:ScopeManager;
		private var uidPool:uint = 0;
		private function get uid():uint {
			return uidPool++;
		}
		//TODO: Add autocomplete for reference names
		public function ReferenceManager(console:DConsole, scopeManager:ScopeManager) 
		{
			this.scopeManager = scopeManager;
			this.console = console;
		}
		public function clearReferenceByName(name:String):void
		{
			try{
				delete(referenceDict[name])
				console.print("Cleared reference " + name, ConsoleMessageTypes.SYSTEM);
				printReferences();
			}catch (e:Error) {
				console.print("No such reference", ConsoleMessageTypes.ERROR);
			}
		}
		
		public function getReferenceByName(target:*,id:String = null):void
		{
			var t:Object;
			try {
				t = scopeManager.getScopeByName(target);
			}catch (e:Error) {
				t = target;
			}
			if (!t) {
				throw new Error("Invalid target");
			}
			if (!id) {
				id = "ref" + uid;
			}
			referenceDict[id] = t;
			printReferences();
		}
		public function getReference(id:String = null):void
		{
			if (!id) {
				id = "ref" + uid;
			}
			referenceDict[id] = scopeManager.currentScope.obj;
			printReferences();
		}
		public function createReference(o:*):void
		{
			var id:String = "ref" + uid;
			referenceDict[id] = o;
			printReferences();
		}
		public function clearReferences():void {
			referenceDict = new Dictionary(true);
			console.print("References cleared", ConsoleMessageTypes.SYSTEM);
		}
		public function printReferences():void {
			console.print("Stored references: ");
			for (var b:* in referenceDict) {
				console.print("	"+b.toString() + " : " + referenceDict[b].toString());
			}
		}
		public function setScopeByReferenceKey(key:String):void {
			if (referenceDict[key]) {
				scopeManager.setScope(referenceDict[key]);
			}else {
				throw new Error("No such reference");	
			}
		}
		public function parseForReferences(args:Array):Array {
			for (var i:int = 0; i < args.length; i++) 
			{
				if (args[i].indexOf("@") > -1) {
					var s:Array = args[i].split("@");
					var key:String = s[1];
					if (referenceDict[key] != null) {
						if (referenceDict[key] is Function) {
							args[i] = referenceDict[key]();
						}else {
							args[i] = referenceDict[key];
						}
					}else {
						try {
							args[i] = scopeManager.getScopeByName(key);
						}catch (e:Error) {
							args[i] = null;
						}
					}
				}
			}
			return args;
		}
		
		
	}

}