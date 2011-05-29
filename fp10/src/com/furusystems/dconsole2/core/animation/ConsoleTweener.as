package com.furusystems.dconsole2.core.animation 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleTweener
	{
		private static var tweens:Dictionary = new Dictionary();
		public static function tween(object:Object, property:String, targetValue:Number, tweenTime:Number,onComplete:Function,tweenType:Class):void {
			if (tweens[object]) {
				IConsoleTweenProcess(tweens[object]).stop();
				delete(tweens[object]);
			}
			tweens[object] = new tweenType(object, property, targetValue, tweenTime, onComplete);
		}
		internal static function removeTween(t:IConsoleTweenProcess):void {
			delete tweens[t.object];
		}
	}

}