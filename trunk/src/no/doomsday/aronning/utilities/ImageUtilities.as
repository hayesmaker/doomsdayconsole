package no.doomsday.aronning.utilities{
	import flash.geom.Rectangle;
	public class ImageUtilities{
		public static function scaleToFit(target:Object,clipRect:Rectangle,maintainAspect:Boolean = true,compensatePosition:Object = true):void{
			var w:Number = clipRect.width;
			var h:Number = clipRect.height;
			var ratio:Number;
			var scalew:Number;
			var scaleh:Number;
			if(maintainAspect){
				//height
				ratio = target.width/target.height;
				scalew = w;
				scaleh = scalew/ratio;
				if(scaleh>h){
					//width
					ratio = target.height/target.width;
					scaleh = h;
					scalew = scaleh/ratio;
				}
			}else{
				scalew = w;
				scaleh = h;
			}
			target.width = scalew;
			target.height = scaleh;
			if(compensatePosition==true){
				target.y = h/2-scaleh/2;
				target.x = w/2-scalew/2;
			}else if(compensatePosition=="x"){
				target.x = w/2-scalew/2;
			}else if(compensatePosition=="y"){
				target.y = h/2-scaleh/2;
			}
		}
	}
}