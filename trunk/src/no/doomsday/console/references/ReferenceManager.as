package no.doomsday.console.references 
{
	import flash.utils.Dictionary;
	import no.doomsday.console.DConsole;
	import no.doomsday.console.introspection.ScopeManager;
	import no.doomsday.console.messages.MessageTypes;
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
		public function ReferenceManager(console:DConsole, scopeManager:ScopeManager) 
		{
			this.scopeManager = scopeManager;
			this.console = console;
		}
		public function clearReferenceByName(name:String):void
		{
			try{
				delete(referenceDict[name])
				console.print("Cleared reference " + name, MessageTypes.SYSTEM);
				printReferences();
			}catch (e:Error) {
				console.print("No such reference", MessageTypes.ERROR);
			}
		}
		
		public function getReferenceByName(name:String,id:String):void
		{
			try{
				referenceDict[id] = scopeManager.getScopeByName(name);
				printReferences();
			}catch (e:Error) {
				console.print(e.message, MessageTypes.ERROR);
			}
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
			console.print("References cleared", MessageTypes.SYSTEM);
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
			}
		}
		public function parseForReferences(args:Array):Array {
			for (var i:int = 0; i < args.length; i++) 
			{
				if (args[i].indexOf("<") > -1) {
					//contains a reference
					var s:Array = args[i].split("<").join(">").split(">");
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