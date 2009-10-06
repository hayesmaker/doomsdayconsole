﻿package no.doomsday.console.commands 
{
	import no.doomsday.console.references.ReferenceManager;
	import no.doomsday.console.text.ParseUtils;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class CommandArgument
	{
		public var data:*;
		public function CommandArgument(data:String,commandManager:CommandManager,referenceManager:ReferenceManager) 
		{
			var tmp:* = data;
			
			switch(data.charAt(0)) {
				case "[":
				case "{":
				tmp = ParseUtils.parseForJson(data);
				break;
				case "(":
				tmp = tmp.slice(1, tmp.length - 1);
				tmp = commandManager.tryCommand(tmp, true);
				break;
			}
			if (tmp is String) {
				if (tmp == "false") {
					tmp = false;
				}else if (tmp == "true") {
					tmp = true;
				}
				try{
					tmp = referenceManager.parseForReferences([tmp])[0];
				}catch (e:Error) {
					
				}
			}
			this.data = tmp;
		}
		public function toString():String {
			return data.toString();
		}
		
	}

}