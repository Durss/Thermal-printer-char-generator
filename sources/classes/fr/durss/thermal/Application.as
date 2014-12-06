package fr.durss.thermal {
	import com.nurun.utils.math.MathUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author Durss
	 * @date 6 déc. 2014;
	 */
	 
	[SWF(width="800", height="600", backgroundColor="0xFFFFFF", frameRate="31")]
	[Frame(factoryClass="fr.durss.thermal.ApplicationLoader")]
	public class Application extends MovieClip {
		private var _grid:Sprite;
		private var _pattern:BitmapData;
		private var _lastPos:Point;
		private var _currPos:Point;
		private var _cellSize:int;
		private var _pressed:Boolean;
		private var _bmd:BitmapData;
		private var _bitmap:Bitmap;
		private var _limits : Shape;
		private var _form : FormPanel;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function Application() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			_cellSize = 20;
			var src:Shape = new Shape();
			src.graphics.beginFill(0xaaaaaa, 1);
			src.graphics.drawRect(0, 0, 1, _cellSize);
			src.graphics.beginFill(0xaaaaaa, 1);
			src.graphics.drawRect(1, 0, _cellSize - 1, 1);
			src.graphics.beginFill(0xff0000, 0);
			src.graphics.drawRect(1, 1, _cellSize - 1, _cellSize - 1);
			
			_lastPos = new Point(int.MAX_VALUE,int.MAX_VALUE);
			_currPos = new Point();
			_pattern = new BitmapData(src.width, src.height, true,0);
			_pattern.draw(src);
			
			_bitmap	= addChild(new Bitmap()) as Bitmap;
			_grid	= addChild(new Sprite()) as Sprite;
			_limits	= addChild(new Shape()) as Shape;
			_form	= addChild(new FormPanel()) as FormPanel;
			
			stage.addEventListener(Event.RESIZE, computePositions);
			_grid.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownGridhandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_form.addEventListener(Event.CLEAR, clearGridHandler);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_grid.graphics.clear();
			_grid.graphics.beginBitmapFill(_pattern);
			_grid.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_bmd = new BitmapData(Math.ceil(stage.stageWidth/_cellSize), Math.ceil(stage.stageHeight/_cellSize));
			if(_bitmap.bitmapData != null) {
				_bmd.draw(_bitmap.bitmapData);
				_bitmap.bitmapData.dispose();
			}
			_bitmap.bitmapData = _bmd;
			
			_bitmap.scaleX = _bitmap.scaleY = _cellSize;
			generateBin();
		}
		
		/**
		 * Called when clear button is clicked
		 */
		private function clearGridHandler(event:Event):void {
			_bmd.fillRect(_bmd.rect, 0);
			generateBin();
		}
		
		/**
		 * Called when grid is pressed
		 */
		private function mouseDownGridhandler(event:MouseEvent):void {
			_pressed = true;
		}

		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			_pressed = false;
			_lastPos.x = int.MAX_VALUE;
		}
		
		/**
		 * Draws the pixels
		 */
		private function enterFrameHandler(event:Event):void {
			_currPos.x = Math.floor(_grid.mouseX/_cellSize);
			_currPos.y = Math.floor(_grid.mouseY/_cellSize);
			if(_pressed && !_currPos.equals(_lastPos)) {
				
				if(_bmd.getPixel32(_currPos.x, _currPos.y) != 0xffff0000) {
					_bmd.setPixel32(_currPos.x, _currPos.y, 0xffff0000);
				}else{
					_bmd.setPixel32(_currPos.x, _currPos.y, 0);
				}
				
				_lastPos.x = _currPos.x;
				_lastPos.y = _currPos.y;
				
				generateBin();
			}
		}
		
		/**
		 * Generates the binary data.
		 */
		private function generateBin():void {
			_limits.graphics.clear();
			
			//search for first pixel
			var rect:Rectangle = _bmd.getColorBoundsRect(0xFFFFFFFF, 0xFFFF0000, true);
			if (rect.width == 0 || rect.height == 0) {
				//bug with getColorBoundsRect if top/left pixel is filled, it doesn't
				//find it..
				if(_bmd.getPixel32(0, 0) !== 0xffff0000) return;
				else rect.width = rect.height = 1;
			}
			
			rect.height = 3 * 8;//Math.ceil(rect.height / 8) * 8;
			rect.width = MathUtils.restrict(rect.width, 0, 12);
			
			
			_limits.graphics.beginFill(0xffffff, .8);
			_limits.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_limits.graphics.lineStyle(2, 0x0000cc);
			_limits.graphics.drawRect(	rect.x * _cellSize,
										rect.y * _cellSize,
										rect.width * _cellSize + 1,
										rect.height * _cellSize + 1);
			
			var ba:ByteArray = new ByteArray();
			var i:int, len:int, px:int, py:int, byte:int, v:int;
			len = rect.width * rect.height;
			for(i = 0; i < len; ++i) {
				if(i%8 == 0 && i > 0) {
					ba.writeByte(byte);
					byte = 0;
				}
				px = Math.floor(i / rect.height) + rect.x;
				py = i % rect.height + rect.y;
				v = _bmd.getPixel32(px, py) === 0xffff0000? 1 : 0;
				byte += v << (8 - (i%8 + 1));
			}
			
			ba.writeByte(byte);
			
			_form.populate(ba, rect.width, rect.height);
		}
		
	}
}