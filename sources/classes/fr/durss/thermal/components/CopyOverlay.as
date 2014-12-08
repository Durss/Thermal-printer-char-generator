package fr.durss.thermal.components {
	import flash.display.Shape;
	import flash.display.BlendMode;
	import gs.TweenLite;
	import flash.filters.DropShadowFilter;
	import fr.durss.thermal.graphics.CancelBubbleGraphic;
	import fr.durss.thermal.graphics.SubmitBubbleGraphic;

	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitor;
	import com.nurun.utils.draw.drawDashedLine;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Durss
	 * @date 7 déc. 2014;
	 */
	public class CopyOverlay extends Sprite {
		private var _width:Number;
		private var _height:Number;
		private var _drawBt:GraphicButton;
		private var _eraseBt:GraphicButton;
		private var _submitCallback:Function;
		private var _cancelCallback:Function;
		private var _draw:Shape;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CopyOverlay</code>.
		 */
		public function CopyOverlay(submitCallback:Function, cancelCallback:Function) {
			_submitCallback = submitCallback;
			_cancelCallback = cancelCallback;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _width; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(bmd:BitmapData, scale:int):void {
			_width	= bmd.width * scale;
			_height	= bmd.height * scale;
			visible	= true;
			
			//Draw overlay
			var dashMargin:int = _width < _eraseBt.width + _drawBt.width? 15 + (_eraseBt.width + _drawBt.width - _width) * .5 : 15;
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			_draw.graphics.clear();
			//Draw red background around bitmap
			_draw.graphics.beginFill(0x990000,.1);
			_draw.graphics.drawRect(-dashMargin, -dashMargin, bmd.width * scale + dashMargin * 2, bmd.height * scale + dashMargin * 2);
			_draw.graphics.drawRect(0, 0, bmd.width * scale, bmd.height * scale);//Empty center
			_draw.graphics.endFill();
			//Draw bitmap
			_draw.graphics.beginBitmapFill(bmd, m);
			_draw.graphics.drawRect(0, 0, bmd.width * scale, bmd.height * scale);
			_draw.graphics.lineStyle(2, 0x990000, 1);
			//Draw dashed borders
			drawDashedLine(_draw.graphics, new Point(-dashMargin,-dashMargin), new Point(bmd.width * scale + dashMargin,-dashMargin));
			drawDashedLine(_draw.graphics, new Point(bmd.width * scale + dashMargin,-dashMargin), new Point(bmd.width * scale + dashMargin, bmd.height * scale + dashMargin));
			drawDashedLine(_draw.graphics, new Point(-dashMargin,bmd.height * scale + dashMargin), new Point(bmd.width * scale + dashMargin,bmd.height * scale + dashMargin));
			drawDashedLine(_draw.graphics, new Point(-dashMargin,-dashMargin), new Point(-dashMargin, bmd.height * scale + dashMargin));
			
			PosUtils.centerIn(_drawBt, this);
			PosUtils.centerIn(_eraseBt, this);
			_eraseBt.x -= _eraseBt.width * .5;
			_drawBt.x += _drawBt.width * .5;
			
			roundPos(_eraseBt, _drawBt);
		}
		
		/**
		 * Clears the overlay's content
		 */
		public function clear():void {
			visible = false;
			_draw.graphics.clear();
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			visible		= false;
			_draw		= addChild(new Shape()) as Shape;
			_drawBt		= addChild(new GraphicButton(new SubmitBubbleGraphic())) as GraphicButton;
			_eraseBt	= addChild(new GraphicButton(new CancelBubbleGraphic())) as GraphicButton;
			
			applyDefaultFrameVisitor(_drawBt, _drawBt.background);
			applyDefaultFrameVisitor(_eraseBt, _eraseBt.background);
			
			_draw.blendMode = BlendMode.INVERT;
			_drawBt.filters = _eraseBt.filters = [new DropShadowFilter(0,0,0,.3,5,5,2)];
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		/**
		 * Displays buttons on roll over
		 */
		private function rollOverHandler(event:MouseEvent):void {
			TweenLite.to(_eraseBt, .2, {autoAlpha:1});
			TweenLite.to(_drawBt, .2, {autoAlpha:1});
		}
		
		/**
		 * Hides buttons on roll out
		 */
		private function rollOutHandler(event:MouseEvent):void {
			TweenLite.to(_eraseBt, .2, {autoAlpha:0});
			TweenLite.to(_drawBt, .2, {autoAlpha:0});
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _drawBt) {
				_submitCallback();
			}else if(event.target == _eraseBt) {
				_cancelCallback();
			}
		}
		
	}
}