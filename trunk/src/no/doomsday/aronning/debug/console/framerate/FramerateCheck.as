package no.doomsday.aronning.debug.console.framerate {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	public class FramerateCheck extends Sprite {
		private var lastFrameTime:int = 0;
		public var framerate:Number = 0;
		public function FramerateCheck() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(e:Event):void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFramerate);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			addEventListener(Event.ENTER_FRAME, checkFramerate,false,0,true);
		}
		private function checkFramerate(e:Event):void {
			var now:Number = getTimer();
			var elapsed:Number = now - lastFrameTime;
			framerate = Math.round(1000 / elapsed);
			lastFrameTime = now;
		}
	}
}