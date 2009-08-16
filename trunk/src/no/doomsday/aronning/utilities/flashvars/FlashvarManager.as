package no.doomsday.aronning.utilities.flashvars
{
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class FlashvarManager 
	{
		private var properties:Dictionary;
		/**
		 * Loops over and stores flashvars in a dictionary, and throws exceptions when invalid flashvars access is attempted
		 * @param	stage
		 */
		public function FlashvarManager(stage:Stage) 
		{
			properties = new Dictionary(true);
			for (var i:String in stage.loaderInfo.parameters) {
				var propertyName:String = i;
				var propertyValue:String = stage.loaderInfo.parameters[i];
				var parsedValue:*;
				switch(propertyValue.toLowerCase()) {
					case "true":
						parsedValue = true;
					break;
					case "false":
						parsedValue = false;
					break;
					default:
					parsedValue = propertyValue;
					break;
				}
				properties[propertyName] = parsedValue;
			}
		}
		/**
		 * Get the value of a flashvar property. Name is not case intensive
		 * @param	propName
		 * @return
		 * The value
		 */
		public function getFlashvar(propName:String):*{
			if (!properties[propName]) {
				throw new Error("No such flashvar '" + propName+"', available flashvars: "+toString());
			}
			return properties[propName];
		}
		public function toString():String {
			var str:String = "";
			for (var i:String in properties) {
				str+="\r\n"+i+":"+properties[i];
			}
			return str;
		}
		
	}
	
}