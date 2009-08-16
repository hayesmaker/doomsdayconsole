/**
* ...
* @author Default
* @version 0.1
*/

package no.doomsday.aronning.utilities {
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class PositionUtils{
		public static const ALIGN_ALL:uint = 2;
		public static const ALIGN_X:uint = 0;
		public static const ALIGN_Y:uint = 1;
		public static const DEGREES:uint = 2;
		public static const RADIANS:uint = 3;
		public static const PI:Number = 3.14;
		public static const ROUND:uint = 4;
		public static const CEIL:uint = 5;
		public static const FLOOR:uint = 6;
		public static function centerAlignToObject(alignThis:DisplayObject, withThis:DisplayObject, axis:uint = ALIGN_ALL):void{
			switch(axis){
				case ALIGN_X:
				alignThis.x = withThis.x+alignThis.width/2-withThis.width/2;
				break;
				case ALIGN_Y:
				alignThis.y = withThis.y+alignThis.height/2-withThis.height/2;
				break;
				default:
				alignThis.x = withThis.x+alignThis.width/2-withThis.width/2;
				alignThis.y = withThis.y+alignThis.height/2-withThis.height/2;
				break;
			}
		}
		/**
		 * Centers a DisplayObject on stage
		 * @param	displayObject
		 */
		public static function centerOnStage(displayObject:DisplayObject):void {
			
			displayObject.x = displayObject.stage.stageWidth/2-displayObject.width/2;
			displayObject.y = displayObject.stage.stageHeight/2-displayObject.height/2;
		}
		/**
		 * Rounds off a displayObject's position
		 * @param	displayObject
		 * @param	roundType
		 * wether to round, ceil or floor the position
		 */
		public static function roundPixels(displayObject:DisplayObject, roundType:int = ROUND):void {
			switch(roundType) {
				case CEIL:
				displayObject.x = Math.ceil(displayObject.x);
				displayObject.y = Math.ceil(displayObject.y);
				break;
				case FLOOR:
				displayObject.x = Math.floor(displayObject.x);
				displayObject.y = Math.floor(displayObject.y);
				break;
				default:
				displayObject.x = Math.round(displayObject.x);
				displayObject.y = Math.round(displayObject.y);
			}
		}
		/**
		 * Gets the local space distance between two displayobjects
		 * @param	displayObject1
		 * @param	displayObject2
		 * @param	squaredSpace
		 * If true, no square root is calculated (good for "loose" distance threshold checks)
		 * @return
		 * The distance in pixels
		 */
		public static function distance(displayObject1:DisplayObject,displayObject2:DisplayObject,squaredSpace:Boolean = false):Number{
			var dx:Number = displayObject1.x - displayObject2.x;
			var dy:Number = displayObject1.y - displayObject2.y;
			if (squaredSpace) return dx * dx + dy * dy;
			return Math.sqrt(dx*dx+dy*dy);
		}
		/**
		 * Returns the angle between two DisplayObjects in radians or degrees
		 * @param	displayObject1
		 * @param	displayObject2
		 * @param	unitType
		 * @return
		 */
		public static function angleBetweenObjects(displayObject1:DisplayObject,displayObject2:DisplayObject,unitType:uint = RADIANS):Number{
			var dx:Number = displayObject1.x-displayObject2.x;
			var dy:Number = displayObject1.y-displayObject2.y;
			if(unitType==RADIANS){
				return Math.atan2(dy,dx);
			}
			var angRad:Number = Math.atan2(dy,dx);
			return (180/PI)*angRad;
		}
		
	}
	
}
