package fr.durss.thermal.views {
	import fr.durss.thermal.components.CopyOverlay;
	import fr.durss.thermal.controler.FrontControler;
	import fr.durss.thermal.events.ViewEvent;
	import fr.durss.thermal.model.Model;
	import fr.durss.thermal.vo.Metrics;
	import fr.durss.thermal.vo.Mode;
	import fr.durss.thermal.vo.Tool;
	import fr.durss.thermal.vo.ZoneData;

	import gs.TweenLite;

	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.math.MathUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * Displays the grid editor
	 * 
	 * @author Durss
	 * @date 7 déc. 2014;
	 */
	public class GridView extends AbstractView {
		private var _gridWidth:int;
		private var _gridHeight:int;
		private var _cellSize:int;
		
		private var _grid:Sprite;
		private var _pattern:BitmapData;
		private var _lastPos:Point;
		private var _currPos:Point;
		private var _pressed:Boolean;
		private var _bmd:BitmapData;
		private var _bitmap:Bitmap;
		private var _limits:Shape;
		private var _rightPressed:Boolean;
		private var _dragOffset:Point;
		private var _copyOverlay:CopyOverlay;
		private var _dragOverlay:Boolean;
		private var _lastBitmapDataDrawing:BitmapData;
		private var _forceFullSize:Boolean;
		private var _bitmapMode:Boolean;
		private var _timeoutRefresh:uint;
		private var _patternDisable:BitmapData;
		private var _middlePressed:Boolean;
		private var _spacePressed:Boolean;
		private var _board:Sprite;
		private var _currentTool:String;
		private var _zone:Shape;
		private var _zoneData:Rectangle;
		private var _zoneTL:Point;
		private var _zoneBR:Point;
		private var _patternZone:BitmapData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>GridView</code>.
		 */
		public function GridView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model	= event.model as Model;
			_bitmapMode		= model.currentMode == Mode.MODE_BITMAP_DRAW;
			_gridWidth		= _bitmapMode? 384 : 12;
			_gridHeight		= _bitmapMode? 800 : 24;
			_cellSize		= _bitmapMode? 10 : 20;
			
			renderPatterns();
			computePositions(event as Event);
			
			if(_bmd != null && model.currentData != null && model.currentData.bmd != null && model.currentData.bmd.bytesAvailable > 0) {
				model.currentData.bmd.position = 0;
				_bmd.fillRect(_bmd.rect, 0);
				_bmd.setPixels(_bmd.rect, model.currentData.bmd);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_forceFullSize	= true;
			_lastPos		= new Point(int.MAX_VALUE,int.MAX_VALUE);
			_currPos		= new Point();
			_dragOffset		= new Point();
			_zoneTL			= new Point();
			_zoneBR			= new Point();
			_zoneData		= new Rectangle();
			_board			= addChild(new Sprite()) as Sprite;
			_bitmap			= _board.addChild(new Bitmap()) as Bitmap;
			_grid			= _board.addChild(new Sprite()) as Sprite;
			_limits			= _board.addChild(new Shape()) as Shape;
			_zone			= _board.addChild(new Shape()) as Shape;
			_copyOverlay	= _board.addChild(new CopyOverlay(drawOverlayToGrid, cancelOverlay)) as CopyOverlay;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			_copyOverlay.addEventListener(MouseEvent.MOUSE_DOWN, dragOverlayHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownGridhandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			if(MouseEvent.RIGHT_MOUSE_UP != null) {
				stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseUpHandler);
				addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, mouseRightDownHandler);
				stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, mouseUpHandler);
				addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, mouseWheelDownHandler);
			}
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelhandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.CLEAR_GRID, clearGridHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.TOOL_CHANGE, toolChangeHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.GENERATE_FROM_BMD, generateBitmapHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.FORCE_SIZE_CHANGE, forceSizeStateChangehandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.ZONE_HIGHLIGHT, zoneHighLowLightHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.ZONE_LOWLIGHT, zoneHighLowLightHandler);
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_board.graphics.clear();
			_board.graphics.beginFill(0xffffff, 1);
			_board.graphics.drawRect(0,0,_gridWidth * _cellSize + 1, _gridHeight*_cellSize + 1);

			_grid.graphics.clear();
			_grid.graphics.beginBitmapFill(_pattern);
			_grid.graphics.drawRect(0, 0, _gridWidth * _cellSize + 1, _gridHeight*_cellSize + 1);
			_bmd = new BitmapData(Math.floor(_grid.width / _cellSize), Math.floor(_grid.height/ _cellSize), true, 0);
			if(_bitmap.bitmapData != null) {
				_bmd.draw(_bitmap.bitmapData);
				_bitmap.bitmapData.dispose();
			}
			_bitmap.bitmapData = _bmd;
			
			_bitmap.scaleX = _bitmap.scaleY = _cellSize;
			
			if(event != null || (_board.x == 0 && _board.y == 0)) {
				var form:OutputPanelView = ViewLocator.getInstance().locateViewByType(OutputPanelView) as OutputPanelView;
				_board.x	= Math.round((stage.stageWidth - form.width - _grid.width) * .5);
				_board.y	= Math.round((stage.stageHeight - Metrics.TOP_BAR_HEIGHT - _grid.height) * .5) + Metrics.TOP_BAR_HEIGHT;
			}
			
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);//Allows for mouse wheel events to be catched anywhere over the board
			
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
			if (event.target == _grid || event.target == this) _pressed = true;
			_dragOffset.x = _board.mouseX;
			_dragOffset.y = _board.mouseY;
		}
		
		/**
		 * Called when right button is pressed
		 */
		private function mouseRightDownHandler(event:MouseEvent):void {
			_rightPressed = true;
			_dragOffset.x = _board.mouseX;
			_dragOffset.y = _board.mouseY;
		}
		
		/**
		 * Called when user scrolls
		 */
		private function mouseWheelhandler(event:MouseEvent):void {
			zoomBy( MathUtils.sign(event.delta) );
		}
		
		/**
		 * Called when mouse's wheel is pressed
		 */
		private function mouseWheelDownHandler(event:MouseEvent):void {
			_middlePressed = true;
			_dragOffset.x = _board.mouseX;
			_dragOffset.y = _board.mouseY;
		}

		/**
		 * Called when mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			if(event.type == MouseEvent.MOUSE_UP){
				 _pressed = false;
				 _dragOverlay = false;
				_lastPos.x = int.MAX_VALUE;
				if(_currentTool == Tool.ZONE && contains(event.target as DisplayObject)) {
					var tmp:int;
					if(_zoneData.width < 0) {
						tmp = _zoneData.x;
						_zoneData.x += _zoneData.width;
						_zoneData.width = Math.abs(_zoneData.width);
					}
					if(_zoneData.height < 0) {
						tmp = _zoneData.y;
						_zoneData.y += _zoneData.height;
						_zoneData.height = Math.abs(_zoneData.height);
					}
					if(_zoneData.width > 0 && _zoneData.height > 0) {
						TweenLite.to(_zone, .25, {alpha:0, delay:.25});
						FrontControler.getInstance().registerZone(_zoneData.clone());
						_zoneData.width = _zoneData.height = 0;//Reset area
					}
				}
			}else if(event.type == MouseEvent.MIDDLE_MOUSE_UP){
				_middlePressed = false;
			}else if(event.type == MouseEvent.RIGHT_MOUSE_UP){
				_rightPressed = false;
				//Crop bitmap when stoppping to drag it.
				var copy:BitmapData = _bmd.clone();
				_bmd.fillRect(_bmd.rect, 0);
				_bmd.copyPixels(copy, copy.rect, new Point(_bitmap.x / _cellSize, _bitmap.y / _cellSize));
				_bitmap.x = _bitmap.y = 0;
				computePositions();
				doGenerateBin();
			}
		}
		
		/**
		 * Called when starting to drag the overlay
		 */
		private function dragOverlayHandler(event:MouseEvent):void {
			event.stopPropagation();//prevents from overriding offset on mouseDownGridHandler
			_dragOverlay = true;
			_dragOffset.x = _copyOverlay.mouseX;
			_dragOffset.y = _copyOverlay.mouseY;
		}
		
		/**
		 * Draws the pixels
		 */
		private function enterFrameHandler(event:Event):void {
			_currPos.x = Math.floor(_board.mouseX/_cellSize);
			_currPos.y = Math.floor(_board.mouseY/_cellSize);
			if(_pressed) {
				if(_spacePressed) {
					//If dragging board
					_board.x = mouseX - _dragOffset.x;
					_board.y = mouseY - _dragOffset.y;
					
				}else if(_currentTool == Tool.ZONE) {
					_zoneTL.x			= Math.min(_dragOffset.x, _board.mouseX);
					_zoneTL.y			= Math.min(_dragOffset.y, _board.mouseY);
					_zoneBR.x			= Math.max(_dragOffset.x, _board.mouseX);
					_zoneBR.y			= Math.max(_dragOffset.y, _board.mouseY);
					_zoneData.x			= Math.floor(_zoneTL.x/_cellSize);
					_zoneData.y			= Math.floor(_zoneTL.y/_cellSize);
					_zoneData.width		= Math.ceil((_zoneBR.x - _zoneData.x * _cellSize)/_cellSize);
					_zoneData.height	= Math.ceil((_zoneBR.y - _zoneData.y * _cellSize)/_cellSize);
					_zone.alpha = 1;
					_zone.graphics.clear();
					_zone.graphics.beginBitmapFill(_patternZone);
					_zone.graphics.drawRect(_zoneData.x * _cellSize, _zoneData.y * _cellSize, _zoneData.width * _cellSize, _zoneData.height * _cellSize);
					_zone.graphics.endFill();
					
				}else if(!_currPos.equals(_lastPos)) {
					//If drawing
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
			
			if(_rightPressed) {
				_bitmap.x = Math.floor((_board.mouseX - _dragOffset.x)/_cellSize) * _cellSize;
				_bitmap.y = Math.floor((_board.mouseY - _dragOffset.y)/_cellSize) * _cellSize;
			}
			
			if(_dragOverlay) {
				_copyOverlay.x = Math.floor((_board.mouseX - _dragOffset.x)/_cellSize) * _cellSize;
				_copyOverlay.y = Math.floor((_board.mouseY - _dragOffset.y)/_cellSize) * _cellSize;
			}
			
			if(_middlePressed) {
				_board.x = mouseX - _dragOffset.x;
				_board.y = mouseY - _dragOffset.y;
			}
		}
		
		/**
		 * Schedule bin's generation
		 */
		private function generateBin():void {
			if(_bitmapMode) {
				clearTimeout(_timeoutRefresh);
				_timeoutRefresh = setTimeout(doGenerateBin, 100);
			}else{
				doGenerateBin();
			}
		}
		
		/**
		 * Generates the binary data.
		 */
		private function doGenerateBin():void {
			clearTimeout(_timeoutRefresh);
			_limits.graphics.clear();
			
			//search for first pixel
			var rect:Rectangle = _bmd.getColorBoundsRect(0xffffffff, 0xFFFF0000, true);
			if (_forceFullSize && !_bitmapMode) rect.y = 0;
			
			if (rect.width == 0 || rect.height == 0) {
				//bug with getColorBoundsRect if top/left pixel is filled, it doesn't
				//find it..
				if(_bmd.getPixel32(0, 0) !== 0xffff0000) {
					FrontControler.getInstance().setCurrentData(new ByteArray(), rect, _bmd);
					return;
				}
				else rect.width = rect.height = 1;
			}
			
			//Restric rect's sizes and position depending on printer's contraints
			if(!_bitmapMode) {
				rect.height = 3 * 8;//Math.ceil(rect.height / 8) * 8;
				rect.width = MathUtils.restrict(rect.width, 0, _gridWidth);
			}else{
				rect.width = Math.ceil(rect.width/8) * 8;
			}
			if(rect.x + rect.width > _bmd.width) rect.x = _bmd.width - rect.width;
			if(rect.y + rect.height> _bmd.height) rect.y = _bmd.height- rect.height;
			
			//Draw limitrect
			if(!_forceFullSize || _bitmapMode) {
				// Draw white layer
				var m:Matrix = new Matrix();
				m.translate(_bitmap.x, _bitmap.y);
				_limits.graphics.beginBitmapFill(_patternDisable, m);
				_limits.graphics.drawRect(_bitmap.x, _bitmap.y, _grid.width, _grid.height);
				//Draw border
				_limits.graphics.lineStyle(2, 0x0000cc);
				_limits.graphics.drawRect(	rect.x * _cellSize + _bitmap.x,
											rect.y * _cellSize + _bitmap.y,
											rect.width * _cellSize + 1,
											rect.height * _cellSize + 1);
			}
			
			var ba:ByteArray = new ByteArray();
			var i:int, len:int, px:int, py:int, byte:int, v:int;
			len = rect.width * rect.height;
			if(!_bitmapMode) {
				//Generate font glyph's binary data 
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
			}else{
				
				//Generate bitmap's binary data 
				for(i = 0; i < len; ++i) {
					if(i%8 == 0 && i > 0) {
						ba.writeByte(byte);
						byte = 0;
					}
					px = i % rect.width + rect.x;
					py = Math.floor(i / rect.width) + rect.y;
					v = _bmd.getPixel32(px, py) === 0xffff0000? 1 : 0;
					byte += v << (8 - (i%8 + 1));
				}
				
				ba.writeByte(byte);
			}
			
			FrontControler.getInstance().setCurrentData(ba, rect, _bmd);
		}
		
		/**
		 * Generates a char from an existing font
		 */
		private function generateBitmapHandler(event:ViewEvent):void {
			var bmd:BitmapData = event.data as BitmapData;
			_lastBitmapDataDrawing = bmd;
			
			_copyOverlay.populate(bmd, _cellSize);
			
			//Compute the center of the screen relative to the grid
			var form:OutputPanelView = ViewLocator.getInstance().locateViewByType(OutputPanelView) as OutputPanelView;
			var point:Point = localToGlobal(new Point((stage.stageWidth - form.width) * .5, (stage.stageHeight-Metrics.TOP_BAR_HEIGHT) * .5));
			point.y += Metrics.TOP_BAR_HEIGHT;
			point = _grid.globalToLocal(point);
			
			//Put the overlay at the center of the visible zone
			_copyOverlay.x = point.x - _copyOverlay.width * .5;
			_copyOverlay.y = point.y - _copyOverlay.height * .5;
			_copyOverlay.x = Math.round(_copyOverlay.x/_cellSize) * _cellSize;
			_copyOverlay.y = Math.round(_copyOverlay.y/_cellSize) * _cellSize;
		}
		
		/**
		 * Called when akey is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.SPACE && !(event.target is TextField)) {
				_spacePressed = true;
			}
		}
		
		/**
		 * Called when a key is released
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.target is TextField) return;
			
			if(event.keyCode == Keyboard.ENTER && _lastBitmapDataDrawing != null) {
				//Draw bitmap to grid
				drawOverlayToGrid();
			}else
			
			if(event.keyCode == Keyboard.ESCAPE) {
				cancelOverlay();
			}else
			
			if(event.keyCode == Keyboard.NUMPAD_ADD) {
				zoomBy(1);
			}else
			
			if(event.keyCode == Keyboard.NUMPAD_SUBTRACT) {
				zoomBy(-1);
			}else
			
			if(event.keyCode == Keyboard.SPACE) {
				_spacePressed = false;
			}
		}
		
		/**
		 * Renders the patterns to be used for grid's drawing
		 */
		private function renderPatterns():void {
			_cellSize = MathUtils.restrict(_cellSize, 1, 30);
			
			//Creates/updates the grid's pattern
			var src:Shape = new Shape();
			if(_cellSize >= 5) { 
				src.graphics.beginFill(0xcccccc, 1);
				src.graphics.drawRect(0, 0, 1, _cellSize);
				src.graphics.beginFill(0xcccccc, 1);
				src.graphics.drawRect(1, 0, _cellSize - 1, 1);
				src.graphics.beginFill(0xff0000, 0);
				src.graphics.drawRect(1, 1, _cellSize - 1, _cellSize - 1);
				_pattern	= new BitmapData(src.width, src.height, true,0);
				_pattern.draw(src);
			}else{
				_pattern	= new BitmapData(1, 1, true, 0);
			}
			_pattern.lock();
			
			
			//Creates/updates the disable zone pattern
			src.graphics.clear();
			src.graphics.lineStyle(0, 0xcccccc, 1, true);
			src.graphics.moveTo(10, 0);
			src.graphics.lineTo(0, 10);
			_patternDisable	= new BitmapData(src.width, src.height, true,0);
			_patternDisable.draw(src);
			_patternDisable.lock();
			
			
			//Creates/updates zone pattern
			src.graphics.clear();
			src.graphics.beginFill(0x5CB864, .1);
			src.graphics.drawRect(0, 0, 15, 15);
			src.graphics.lineStyle(1, 0x5CB864, 1, true);
			src.graphics.moveTo(16-7.5, -1);
			src.graphics.lineTo(-1-7.5, 16);
			src.graphics.moveTo(16+7.5, -1);
			src.graphics.lineTo(-1+7.5, 16);
			_patternZone	= new BitmapData(15, 15, true,0);
			_patternZone.draw(src);
			_patternZone.lock();
			
			
			//Refresh copy overlay if necessary
			if(_lastBitmapDataDrawing != null) {
				_copyOverlay.populate(_lastBitmapDataDrawing, _cellSize);
			}
		}
		
		/**
		 * Called when asking to draw the overlay.
		 * Copies the temp bitmap data to the main one.
		 */
		private function drawOverlayToGrid():void {
			_bmd.copyPixels(_lastBitmapDataDrawing, _lastBitmapDataDrawing.rect, new Point((_copyOverlay.x - _grid.x) / _cellSize, (_copyOverlay.y - _grid.y) / _cellSize), null, null, true);
			generateBin();
		}
		
		/**
		 * Called when overlay is canceld
		 */
		private function cancelOverlay():void {
			_lastBitmapDataDrawing = null;
			_dragOverlay = false;
			_copyOverlay.clear();
		}
		
		/**
		 * Called when "force size" checkbox state changes on right side panel
		 */
		private function forceSizeStateChangehandler(event:ViewEvent):void {
			_forceFullSize = event.data as Boolean;
			generateBin();
		}
		
		/**
		 * Zooms the board by an increment
		 */
		private function zoomBy(value:int):void {
			var prevSize:int	= _cellSize;
			var rX:Number		= _board.mouseX/_board.width;
			var rY:Number		= _board.mouseY/_board.height;
			_cellSize			+= value;
			_cellSize			= MathUtils.restrict(_cellSize, 1, 30);
			if(_cellSize == prevSize) return;
			
			var ratio:Number	= _cellSize / prevSize;
			_copyOverlay.x		*= ratio;
			_copyOverlay.y		*= ratio;
			_board.x			+= (_board.width - _board.width * ratio) * rX;
			_board.y			+= (_board.height - _board.height * ratio) * rY;
			
			_zone.graphics.clear();
			_zone.graphics.beginBitmapFill(_patternZone);
			_zone.graphics.drawRect(_zoneData.x * _cellSize, _zoneData.y * _cellSize, _zoneData.width * _cellSize, _zoneData.height * _cellSize);
			_zone.graphics.endFill();
			
			renderPatterns();
			computePositions();
			doGenerateBin();
		}
		
		/**
		 * Called when a new tool is selected
		 */
		private function toolChangeHandler(event:ViewEvent):void {
			var tool:String = event.data as String;
			_currentTool = tool;
		}
		
		/**
		 * Called when a zone needs to be highlighted or cleared
		 */
		private function zoneHighLowLightHandler(event:ViewEvent):void {
			var d:ZoneData = event.data as ZoneData;
			_zone.graphics.clear();
			if (event.type == ViewEvent.ZONE_HIGHLIGHT) {
				_zone.alpha = 1;
				_zone.graphics.beginBitmapFill(_patternZone);
				_zone.graphics.drawRect(d.area.x * _cellSize, d.area.y * _cellSize, d.area.width * _cellSize, d.area.height * _cellSize);
				_zone.graphics.endFill();
			}
		}
		
	}
}