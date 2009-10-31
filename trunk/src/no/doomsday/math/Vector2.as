package no.doomsday.math {
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Point;
	public class Vector2 {
		public static function get up():Vector2 {
			return new Vector2(0, -1);
		}
		public static function get down():Vector2 {
			return new Vector2(0, 1);
		}
		public static function get left():Vector2 {
			return new Vector2(-1, 0);
		}
		public static function get right():Vector2 {
			return new Vector2(1, 0);
		}
		public var x:Number;
		public var y:Number;
		/**
		 * Creates a new 2D vector
		 * @param	x
		 * @param	y
		 */
		function Vector2(x:Number = 0,y:Number = 0){
			this.x = x;
			this.y = y;
		}
		/**
		 * Set both components to 0
		 */
		public function zero():void{
			x = y = 0;
		}
		/**
		 * Reverses both components
		 */
		public function inverse():void { //legacy
			x = -x;
			x = -y;
		}
		/**
		 * Reverses both components
		 */
		public function reverse(fastIntMode:Boolean = false):void {
			if (fastIntMode) {
				x = ~x + 1;
				y = ~y + 1;
				return;
			}
			x = -x;
			x = -y;
		}
		/**
		 * Gets the pythagorean magnitude of the vector
		 */
		public function get magnitude():Number{
			return Math.sqrt(x*x+y*y);
		}
		/**
		 * Gets the squared space magnitude of the vector
		 */
		public function get magnitudeSqrd():Number{
			return x * x + y * y;
		}
		/**
		 * Retrieve this vector's unit vector
		 * @return
		 * A new Vector2 instance
		 */
		public function getUnit():Vector2{
			return new Vector2(x/magnitude, y/magnitude);
		}
		/**
		 * Retrieve this vector's normal vector
		 * @return
		 * A new Vector2 instance
		 */
		public function getNormal():Vector2{
			return new Vector2(-y,x);
		}
		/**
		 * Truncates the vector to a maximum magnitude
		 * Positive values also count when truncating negative values (-10 truncated to 5 becomes -5)
		 * @param	max
		 * The maximum magnitude of this vector
		 */
		public function truncate(max:Number):void {
			var mag:Number = Math.sqrt(x*x+y*y);
			if((mag ^ (mag >> 31)) - (mag >> 31) > (max ^ (max >> 31)) - (max >> 31)){
				var v:Vector2 = getUnit();
				x = v.x*max;
				y = v.y*max;
			}
		}
		/**
		 * Rotates the vector by an angle
		 * @param	radians
		 * An angle in radians
		 */
		public function rotate(radians:Number):void {
			//using fast sin/cos approximation as described at http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/
			var sin:Number;
			var cos:Number;
			//always wrap input angle to -PI..PI
			if (radians < -3.14159265) {
				radians += 6.28318531;
			}else if (radians >  3.14159265) {
				radians -= 6.28318531;
			}
			//compute sine
			if (radians < 0){
				sin = 1.27323954 * radians + .405284735 * radians * radians;
				if (sin < 0) {
					sin = .225 * (sin *-sin - sin) + sin;
				}else {
					sin = .225 * (sin * sin - sin) + sin;
				}
			}else{
				sin = 1.27323954 * radians - 0.405284735 * radians * radians;
				if (sin < 0) {
					sin = .225 * (sin *-sin - sin) + sin;
				}else {
					sin = .225 * (sin * sin - sin) + sin;
				}
			}
			//compute cosine: sin(x + PI/2) = cos(x)
			radians += 1.57079632;
			if (radians >  3.14159265) {
				radians -= 6.28318531;
			}
			if (radians < 0){
				cos = 1.27323954 * radians + 0.405284735 * radians * radians
				if (cos < 0) {
					cos = .225 * (cos *-cos - cos) + cos;
				}else {
					cos = .225 * (cos * cos - cos) + cos;
				}
			}else{
				cos = 1.27323954 * x - 0.405284735 * x * x;
				if (cos < 0) {
					cos = .225 * (cos *-cos - cos) + cos;
				}else {
					cos = .225 * (cos * cos - cos) + cos;
				}
			}
			
			x += cos;
			y += sin;
		}
		/**
		 * Sets the vector direction and magnitude by comparing an origin point to another
		 * @param	origin
		 * The point to draw a comparison from
		 * @param	target
		 * The point you want to solve for a direction for
		 */
		public function setByPoints(origin:Point, target:Point):void {
			var diffx:Number = origin.x - target.x;
			var diffy:Number = origin.y - target.y;
			var radians:Number = Math.atan2(diffy, diffx);
			var sin:Number;
			var cos:Number;
			//always wrap input angle to -PI..PI
			if (radians < -3.14159265) {
				radians += 6.28318531;
			}else if (radians >  3.14159265) {
				radians -= 6.28318531;
			}

			//compute sine
			if (radians < 0){
				sin = 1.27323954 * radians + .405284735 * radians * radians;
				if (sin < 0) {
					sin = .225 * (sin *-sin - sin) + sin;
				}else {
					sin = .225 * (sin * sin - sin) + sin;
				}
			}else{
				sin = 1.27323954 * radians - 0.405284735 * radians * radians;
				if (sin < 0) {
					sin = .225 * (sin *-sin - sin) + sin;
				}else {
					sin = .225 * (sin * sin - sin) + sin;
				}
			}

			//compute cosine: sin(x + PI/2) = cos(x)
			radians += 1.57079632;
			if (radians >  3.14159265) {
				radians -= 6.28318531;
			}
			if (radians < 0){
				cos = 1.27323954 * radians + 0.405284735 * radians * radians
				if (cos < 0) {
					cos = .225 * (cos *-cos - cos) + cos;
				}else {
					cos = .225 * (cos * cos - cos) + cos;
				}
			}else{
				cos = 1.27323954 * x - 0.405284735 * x * x;
				if (cos < 0) {
					cos = .225 * (cos *-cos - cos) + cos;
				}else {
					cos = .225 * (cos * cos - cos) + cos;
				}
			}
			x = diffx;
			y = diffy;
		}
		/**
		 * Clone this vector
		 * @return
		 * A duplicate Vector2
		 */
		public function clone():Vector2{
			return new Vector2(x,y);
		}
		/**
		 * Multiply both vector components by a scalar
		 * @param	scalar
		 */
		public function scale(scalar:Number):void{
			x*=scalar;
			y*=scalar;
		}
		/**
		 * Get a string representation of this vector
		 * @return
		 * A string
		 */
		public function toString():String{
			return "Vector2 x:"+x+" y:"+y;
		}
		/**
		 * Get a shape representation of this vector
		 * @return
		 * A shape instance
		 */
		public function render(g:Graphics):void{
			g.lineStyle(1,0);
			//direction
			g.moveTo(0, 0);
			g.lineTo(x,y);
			//normal
			g.moveTo(0,0);
			g.lineStyle(1,0xFF0000);
			var n:Vector2 = getNormal();
			g.lineTo(n.x,n.y);
		}
		private static function getComponent(vector:Vector2,directionVector:Vector2):Number{
			var alpha:Number = Math.atan2(directionVector.y,directionVector.x);
			var theta:Number = Math.atan2(vector.y,vector.x);
			var mag:Number = vector.magnitude;
			var a:Number = mag*Math.cos(theta-alpha);
			return a;
		}
		/**
		 * Get a component vector from a source vector and a direction
		 * @param	vector
		 * The source Vector2
		 * @param	directionVector
		 * A Vector2 representing a direction
		 * @return
		 */
		public static function getComponentVector(vector:Vector2,directionVector:Vector2):Vector2{
			var v:Vector2 = directionVector.getUnit();
			var component:Number = getComponent(vector,directionVector);
			var vec:Vector2 = new Vector2();
			vec.x = v.x*component;
			vec.y = v.y*component;
			return vec;
		}
		/**
		 * Subtract one Vector2 from another
		 * @param	v1
		 * A Vector2 instance
		 * @param	v2
		 * A Vector2 instance
		 * @return
		 * A new Vector2 instance
		 */
		public static function manhattanSubtract(v1:Vector2, v2:Vector2):Vector2 {
			return new Vector2(v1.x - v2.x, v1.y - v2.y);
		}
		
		/**
		 * Subtract one Vector2 from another
		 * @param	v1
		 * A Vector2 instance
		 * @param	v2
		 * A Vector2 instance
		 * @return
		 * A new Vector2 instance
		 */
		public static function subtract(v1:Vector2,v2:Vector2):Vector2{
			//v-u = -u+v
			var v:Vector2 = v1;
			var u:Vector2 = v2.clone();
			u.inverse();
			return new Vector2(u.x + v.x, u.y + v.y);
		}
		/**
		 * Add two Vector2 instances together
		 * @param	v1
		 * A Vector2 instance
		 * @param	v2
		 * A Vector2 instance
		 * @return
		 * A new Vector2 instance
		 */
		public static function add(v1:Vector2,v2:Vector2):Vector2{
			return new Vector2(v1.x+v2.x,v1.y+v2.y);
		}
		/**
		 * Get the dot product of two vectors
		 * @param	v1
		 * A Vector2 instance
		 * @param	v2
		 * A Vector2 instance
		 * @return
		 * The dot product as a number
		 */
		public static function dot(v1:Vector2,v2:Vector2):Number{
			var n1:Vector2 = v1.getUnit();
			var n2:Vector2 = v2.getUnit();
			return n1.x*n2.x+n1.y*n2.y;
		}
		/**
		 * Returns the distance between two points described by Vector2 instances
		 * @param	v1
		 * A Vector2 instance
		 * @param	v2
		 * A Vector2 instance
		 * @return
		 * The distance according to the pythagorean theorem
		 */
		public static function distance(v1:Vector2, v2:Vector2):Number {
			var diffX:Number = v1.x - v2.x;
			var diffY:Number = v1.y - v2.y;
			return Math.sqrt(diffX * diffX + diffY * diffY);
		}
		/**
		 * Returns the distance between two points described by Vector2 instances
		 * @param	v1
		 * A Vector2 instance
		 * @param	v2
		 * A Vector2 instance
		 * @return
		 * The distance in squared space
		 */
		public static function distanceSquared(v1:Vector2, v2:Vector2):Number {
			var diffX:Number = v1.x - v2.x;
			var diffY:Number = v1.y - v2.y;
			return diffX * diffX + diffY * diffY;
		}
		public static function radiansBetween(v1:Vector2, v2:Vector2):Number {
			var diffX:Number = v1.x - v2.x;
			var diffY:Number = v1.y - v2.y;
			return Math.atan2(diffY, diffX);
		}
		

	}
}
