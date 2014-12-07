package fr.durss.thermal {
	import flash.filters.DropShadowFilter;
	import com.nurun.components.form.events.FormComponentEvent;
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
		private var _limits:Shape;
		private var _form:FormPanel;
		private var _font:FontPanel;
		private var _rightPressed:Boolean;
		private var _dragOffset:Point;
		
		
		
		
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
			_dragOffset = new Point();
			_pattern = new BitmapData(src.width, src.height, true,0);
			_pattern.draw(src);
			
			_bitmap	= addChild(new Bitmap()) as Bitmap;
			_grid	= addChild(new Sprite()) as Sprite;
			_limits	= addChild(new Shape()) as Shape;
			_font	= addChild(new FontPanel()) as FontPanel;
			_form	= addChild(new FormPanel()) as FormPanel;
			
			_bitmap.filters = [new DropShadowFilter(0,0,0,.35,5,5,1,3)];
			
			stage.addEventListener(Event.RESIZE, computePositions);
			_grid.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownGridhandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			if(MouseEvent.RIGHT_MOUSE_UP != null) {
				stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseUpHandler);
				_grid.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightDownHandler);
			}
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_form.addEventListener(Event.CHANGE, changeFormDataHandler);
			_form.addEventListener(Event.CLEAR, clearGridHandler);
			_font.addEventListener(FormComponentEvent.SUBMIT, generateFromFontHandler);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginFill(0xF5F5F5, 1);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			_grid.graphics.clear();
			_grid.graphics.beginBitmapFill(_pattern);
			_grid.graphics.drawRect(0, 0, 12 * _cellSize + 1, 3*8*_cellSize + 1);
			_bmd = new BitmapData(Math.floor(_grid.width / _cellSize), Math.floor(_grid.height/ _cellSize), true, 0);
			if(_bitmap.bitmapData != null) {
				_bmd.draw(_bitmap.bitmapData);
				_bitmap.bitmapData.dispose();
			}
			_bitmap.bitmapData = _bmd;
			
			_bitmap.scaleX = _bitmap.scaleY = _cellSize;
			
			_grid.x = _bitmap.x = Math.round((stage.stageWidth - _form.width - _grid.width) * .5);
			_grid.y = _bitmap.y = Math.round((stage.stageHeight - _font.height - _grid.height) * .5) + _font.height;
			
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect(_grid.x, _grid.y, _grid.width, _grid.height);
			
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
		 * Called when right button is pressed
		 */
		private function rightDownHandler(event:MouseEvent):void {
			_rightPressed = true;
			_dragOffset.x = _grid.mouseX;
			_dragOffset.y = _grid.mouseY;
		}

		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			if(event.type == MouseEvent.MOUSE_UP){
				 _pressed = false;
				_lastPos.x = int.MAX_VALUE;
			}else if(event.type == MouseEvent.RIGHT_MOUSE_UP){
				_rightPressed = false;
				//Crop bitmap when stoppping to drag it.
				var copy:BitmapData = _bmd.clone();
				_bmd.fillRect(_bmd.rect, 0);
				_bmd.copyPixels(copy, copy.rect, new Point((_bitmap.x - _grid.x) / _cellSize, (_bitmap.y - _grid.y) / _cellSize));
				computePositions();
				generateBin();
			}
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
			
			if(_rightPressed) {
				_bitmap.x = Math.floor((_grid.mouseX - _dragOffset.x)/_cellSize) * _cellSize + _grid.x;
				_bitmap.y = Math.floor((_grid.mouseY - _dragOffset.y)/_cellSize) * _cellSize + _grid.y;
			}
			
			_form.y = _font.height;
		}
		
		/**
		 * Generates the binary data.
		 */
		private function generateBin():void {
			_limits.graphics.clear();
			
			//search for first pixel
			var rect:Rectangle = _bmd.getColorBoundsRect(0xffffffff, 0xFFFF0000, true);
			if(!_form.forceFullSize) {
				rect.y = 0;
			}else{
				rect = _bmd.rect;
			}
			if (rect.width == 0 || rect.height == 0) {
				//bug with getColorBoundsRect if top/left pixel is filled, it doesn't
				//find it..
				if(_bmd.getPixel32(0, 0) !== 0xffff0000) {
					_form.populate(new ByteArray(), rect.width, rect.height);
					return;
				}
				else rect.width = rect.height = 1;
			}
			
			rect.height = 3 * 8;//Math.ceil(rect.height / 8) * 8;
			rect.width = MathUtils.restrict(rect.width, 0, 12);
			
			if(!_form.forceFullSize) {
				_limits.graphics.beginFill(0xffffff, .8);
				_limits.graphics.drawRect(_bitmap.x, _bitmap.y, _grid.width, _grid.height);
				_limits.graphics.lineStyle(2, 0x0000cc);
				_limits.graphics.drawRect(	rect.x * _cellSize + _bitmap.x,
											rect.y * _cellSize + _bitmap.y,
											rect.width * _cellSize + 1,
											rect.height * _cellSize + 1);
			}
			
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
		
		/**
		 * Generates a char from an existing font
		 */
		private function generateFromFontHandler(event:FormComponentEvent):void {
			_bmd.fillRect(_bmd.rect, 0);

			var pos:Point = new Point();
			pos.x = Math.round((_bmd.width - _font.bitmapData.width) * .5);
			pos.y = Math.round((_bmd.height - _font.bitmapData.height) * .5);
			_bmd.copyPixels(_font.bitmapData, _font.bitmapData.rect, pos);
			
			generateBin();
		}
		
		/**
		 * Called when a form's input's value changes
		 */
		private function changeFormDataHandler(event:Event):void {
			generateBin();
		}
		
	}
}