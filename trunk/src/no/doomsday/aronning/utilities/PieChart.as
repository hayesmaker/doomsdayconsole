/*
PieChart class, adapted from ActionScript by Helen Triolo, god bless her soul
I've done very little to this aside from reorganize and clean up a little bit and get all AS2.0 with it, as well as removing a segment
that handled mouseover and other lovely things completely, simply because i felt it was something i'd rather handle with a separate
class entirely.

I added a very basic animation function that i find very useful.

Currently, it's operated like this.
myPie = new PieChart(clip,radius,percentages,threshold)
	clip:MovieClip - 
		The movieclip instance in which to draw the pie chart
	radius:Number - 
		The radius of the pie chart
	percentages:Array - 
		The percentages you want displayed (the sum of which should always be 100, or you'll get wacky results)
	threshold:Number (optional) - 
		the animation is based on the difference between the current value and the target value. 
		This threshold dictates when to stop animating, and defaults at 0.01;
		
once created, the following options MAGICALLY APPEAR

myPie.reDraw(percentages)
	percentages:Array - Simply redraws the chart to reflect a new set of percentages without requiring all the arguments from the constructor
	
myPie.newGoal(percentages)
	percentages:Array - Animates from the current percentages to a new one. Very basic, interval based, but it works lovely.

myPie.colors = Array
	A getter/setter that lets you change the color array used by the pie chart. For instance, percentages[0] will use colors[0]
	This can be updated at any time but requires a redraw
*/
class no.rayon.aronning.utilities.PieChart{
	private var parentClip:MovieClip;
	private var threshold:Number;
	private var RAD = Math.PI/180;
	private var sourceClip:MovieClip;
	private var myRadius:Number;
	private var animInt:Number;
	private var prevValues:Array;
	private var nextValues:Array;
	private var pieClip:MovieClip;
	private var fillColors:Array;
	private function sumTo(array:Array,elem:Number):Number {
		var sum = 0;
		for (var i = 0; i<=elem; i++) {
			sum += array[i];
		}
		return (sum);
	};
	private function drawWedge(clip:MovieClip, r:Number, x:Number, y:Number, angle:Number, rotation:Number):Void {
		clip.moveTo(0, 0);
		clip.lineTo(r, 0);
		var nSeg = Math.floor(angle/30);
		var pSeg = angle-nSeg*30;
		var a = 0.268;
		var endx:Number;
		var endy:Number;
		var ax:Number;
		var ay:Number;
		var i:Number;
		for (i = 0; i<nSeg; i++) {
			endx = r*Math.cos((i+1)*30*RAD);
			endy = r*Math.sin((i+1)*30*RAD);
			ax = endx+r*a*Math.cos(((i+1)*30-90)*RAD);
			ay = endy+r*a*Math.sin(((i+1)*30-90)*RAD);
			clip.curveTo(ax, ay, endx, endy);
		}
		if (pSeg>0) {
			a = Math.tan(pSeg/2*RAD);
			endx = r*Math.cos((i*30+pSeg)*RAD);
			endy = r*Math.sin((i*30+pSeg)*RAD);
			ax = endx+r*a*Math.cos((i*30+pSeg-90)*RAD);
			ay = endy+r*a*Math.sin((i*30+pSeg-90)*RAD);
			clip.curveTo(ax, ay, endx, endy);
		}
		clip.lineTo(0, 0);
		clip._rotation = rotation;
		clip._x = x;
		clip._y = y;
	};
	private function drawPie(clip:MovieClip,radius:Number,percentages:Array) {
		var angles = [];
		for (var x = 0; x<percentages.length; x++) {
			angles.push((percentages[x]/100)*360);
		}
		for (var a = 0; a<angles.length; a++) {
			var c = clip.createEmptyMovieClip("arc"+a, a*10);
			c.beginFill(fillColors[a], 100);
			drawWedge(c, radius, radius, radius, angles[a], sumTo(angles, a-1));
			c.endFill();
		}
	}
	private function startAnim():Void{
		clearInterval(animInt);
		animInt = setInterval(this,"anim",20);
	}
	private function stopAnim():Void{
		clearInterval(animInt);
	}
	private function anim():Void{
		var pv = prevValues;
		var nv = nextValues;
		if(Math.abs(nv[0]-pv[0])>threshold||Math.abs(nv[1]-pv[1])>threshold||Math.abs(nv[2]-pv[2])>threshold||Math.abs(nv[3]-pv[3])>threshold){
			pv[0]+=(nv[0]-pv[0])/8;
			pv[1]+=(nv[1]-pv[1])/8;
			pv[2]+=(nv[2]-pv[2])/8;
			pv[3]+=(nv[3]-pv[3])/8;
			reDraw(pv);
		}else{
			stopAnim();
		}
	}
	public function newGoal(percentages:Array):Boolean{
		if(percentages!=nextValues){
			nextValues = percentages;
			startAnim();
			return true;
		}
		return false;
	}
	public function reDraw(percentages:Array):Boolean{
		if(!percentages){
			return false;
		}
		drawPie(sourceClip,myRadius,percentages);
		return true;
	}
	public function set colors(colorArray:Array):Void{
		fillColors = colorArray;
	}
	public function get colors():Array{
		return fillColors;
	}
	public function PieChart(clip:MovieClip,radius:Number,percentages:Array,colors:Array,threshold:Number){
		parentClip = clip;
		if(!colors){
			colors = [0x0C64FF, 0xFFA200, 0xD40000, 0x20AA00];
		}
		fillColors = colors;
		if(!threshold){
			threshold = 0.01;
		}
		this.threshold = threshold;
		pieClip = clip.createEmptyMovieClip("pie",0);
		prevValues = [];
		var val = 100/percentages.length;
		for(var i = 0;i<percentages.length;i++){
			prevValues.push(val);
		}
		nextValues = percentages;
		sourceClip = pieClip;
		myRadius = radius;
		drawPie(sourceClip,radius,prevValues);
		startAnim();
	}
}