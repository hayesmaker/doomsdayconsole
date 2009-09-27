package no.doomsday.console.controller 
{
	import no.doomsday.console.text.TextFormats;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ControlField extends Sprite
	{
		private var tf:TextField;
		public var targetProperty:String;
		public function ControlField(property:String,type:String = "String") 
		{
			targetProperty = property;
			tf = new TextField();
			tf.defaultTextFormat = TextFormats.debugTformatNew;
			tf.height = 20;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = true;
			tf.type = TextFieldType.INPUT;
			addChild(tf);
			switch(type) {
				case "uint":
				tf.restrict = "0123456789";
				break;
				case "int":
				tf.restrict = "0123456789-";
				break;
				case "Number":
				tf.restrict = "0123456789.-";
				break;
			}
			tf.addEventListener(Event.CHANGE, onTextfieldChange, false, 0, true);
			tf.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			var d:Number = Math.max( -1, Math.min(1, e.delta));
			var num:Number = Number(tf.text);
			if (e.shiftKey) {
				d *= 0.1;
			}
			if (e.ctrlKey) {
				d *= 0.1;
			}
			num += d;
			tf.text = num.toString();
			onTextfieldChange();
		}
		public function get value():*{
			return tf.text;
		}
		public function set value(n:*):void {
			tf.text = n.toString();
		}
		
		private function onTextfieldChange(e:Event = null):void 
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}

}