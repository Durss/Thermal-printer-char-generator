/*
	Halftone.as
	v0.9
	By Lee Felarca
	http://www.zeropointnine.com/blog 
	4-3-2007

	Some Rights Reserved.
	Source code licensed under a Creative Commons Attribution 3.0 License.
	http://creativecommons.org/licenses/by/3.0/
*/

package fr.durss.thermal.utils
{
	import flash.display.*;

	public class Halftone extends Sprite
	{
		static public function draw(s:Sprite, bmpSource:BitmapData, pointRadius:int, fgColor:uint, isReversed:Boolean, pointMultiplier:Number, isAlreadyGrayscale:Boolean):void
		{
			/*
				Draws a 'halftone' version of a bitmap onto a sprite.
				
				Parameters:
				-----------------------------
				s					Sprite onto which the halftone image will be drawn
				bmpSource			The source bitmapdata object which will be 'converted'
				pointRadius			Defines the area each point in the halftone image will occupy (think "degree of magnification")
				fgColor				Color of the halftone image
				isReversed			When true, points are drawn based on white level instead of black level
				pointMultiplier		The value that the radius of each point in the halftone image will be multiplied by.
									Default is 1.				
				isAlreadyGrayscale	Set to true when the source bitmap is already grayscale. Otherwise, the function will 
									calculate the grayscale value of each pixel in the source bitmap, which takes extra 
									processing time. For optimal performance, convert the source bitmap to grayscale using 
									a ColorMatrix or by editing the source image file directly and then set 
									"isAlreadyGrayscale" to true.
			*/
			
			if (bmpSource==null || s==null) return;
			
			if (pointRadius <= 0) pointRadius = 5; else pointRadius = int(Math.abs(pointRadius));
			if (pointMultiplier <= 0) pointMultiplier = 1; else pointMultiplier = Math.abs(pointMultiplier);

			// ==========================================

			var pointRadiusHalf:Number = int(pointRadius / 2);

			var ratio:Number = pointRadius / 256 / 2 * (pointMultiplier * 1.25);
			var ptX:int, ptY:int;
			var thisPx:int, lastPx:int;
		
			ptY = pointRadiusHalf;			
			
			for (var y:int = 0; y < bmpSource.height; y+= 2)
			{				
				// even row:
				ptX = pointRadiusHalf;
				for (var x0:int = 0; x0 < bmpSource.width-1; x0++)
				{
					var sca0:int = getBlackLevel( bmpSource.getPixel(x0,y), isReversed, isAlreadyGrayscale );

					var rad0:Number = sca0 * ratio;					
					s.graphics.beginFill( fgColor,1);
					s.graphics.drawCircle(ptX,ptY, rad0);
					s.graphics.endFill();

					ptX +=  pointRadius;
				}

				// odd row:
				if (y+1 == bmpSource.height) continue;
				
				ptX = pointRadius;
				thisPx = getBlackLevel(bmpSource.getPixel(0,y+1), isReversed, isAlreadyGrayscale);
				for (var x1:int = 1; x1 < bmpSource.width-1; x1++)
				{
					lastPx = thisPx;
					thisPx = getBlackLevel(bmpSource.getPixel(x1,y+1), isReversed, isAlreadyGrayscale);
					var sca1:int = (thisPx + lastPx) / 2;

					var rad1:Number = sca1 * ratio;					
					s.graphics.beginFill( fgColor,1);
					s.graphics.drawCircle(ptX, ptY + pointRadius, rad1);
					s.graphics.endFill();

					ptX +=  pointRadius;
				}
				ptY += pointRadius * 2;
			}		
		}
	
		static private function getBlackLevel(v:uint, isReversed:Boolean, isAlreadyGrayscale:Boolean) : int
		{	
			if (isAlreadyGrayscale) {
				if (!isReversed) return 255 - (v & 0xff); else return (v & 0xff);	
			}
			var red:Number = v >> 16;
			var green:Number = v >> 8 & 0xff;
			var blue:Number = v & 0xff;
			
			if (!isReversed) return 255 - int((red + green + blue)/3); else return int((red + green + blue)/3);
		}
	}
}