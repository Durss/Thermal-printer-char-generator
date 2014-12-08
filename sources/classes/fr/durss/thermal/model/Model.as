package fr.durss.thermal.model {
	import fr.durss.thermal.vo.ZoneData;
	import fr.durss.thermal.events.ViewEvent;
	import fr.durss.thermal.vo.GridData;
	import fr.durss.thermal.vo.Mode;

	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.color.ColorFunctions;
	import com.nurun.utils.commands.BrowseForFileCmd;

	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * Application's model
	 * 
	 * @author Durss
	 * @date 7 déc. 2014;
	 */
	public class Model extends EventDispatcher implements IModel {
		private var _currentMode:String;
		private var _zones:Vector.<ZoneData>;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Modle</code>.
		 */
		public function Model() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the current mode
		 */
		public function get currentMode():String { return _currentMode; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Starts the application
		 */
		public function start():void {
			setFontGlyphMode();
		}
		
		public function setFontGlyphMode():void {
			_currentMode = Mode.MODE_FONT_GLYPH;
			update();
		}
		
		public function setBitmapMode():void {
			_currentMode = Mode.MODE_BITMAP_DRAW;
			update();
		}
		
		/**
		 * Generates the grid from a bitmap data
		 */
		public function generateFontBitmapData(bmd:BitmapData):void {
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GENERATE_FROM_BMD, bmd));
		}
		
		/**
		 * Clears the grid
		 */
		public function clearGrid():void {
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLEAR_GRID));
		}
		
		/**
		 * Called when "force size" button state changes
		 */
		public function forceSizeChange(enabled:Boolean):void {
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FORCE_SIZE_CHANGE, enabled));
		}
		
		/**
		 * Sets the current grid's data
		 */
		public function setCurrentData(data:ByteArray, areaSource:Rectangle):void {
			var d:GridData = new GridData();
			d.data = data;
			d.areaSource = areaSource;
			
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GRID_DATA_UPDATE, d));
		}
		
		/**
		 * Starts a browsing session to load an image
		 */
		public function browseForImage():void {
			var cmd:BrowseForFileCmd = new BrowseForFileCmd("Image", "*.gif;*.jpg;*.jpeg;*.png", true);
			cmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
			cmd.execute();
		}
		
		/**
		 * Defines the currently selected tool
		 */
		public function setCurrentTool(tool:String):void {
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TOOL_CHANGE, tool));
		}
		
		/**
		 * Registers a new zone
		 */
		public function registerZone(zone:Rectangle):void {
			var data:ZoneData = new ZoneData();
			data.area = zone;
			data.name = 'zone_'+ (_zones.length + 1);
			_zones.push(data);
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.NEW_ZONE, data));
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ZONE_LIST_UPDATE, _zones));
		}
		
		/**
		 * Deletes a zone
		 */
		public function deleteZone(zone:ZoneData):void {
			var i:int, len:int;
			len = _zones.length;
			for(i = 0; i < len; ++i) {
				if(_zones[i] == zone) {
					_zones.splice(i, 1);
					break;
				}
			}
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ZONE_LIST_UPDATE, _zones));
		}
		
		/**
		 * Forces a refresh of the zones on the output panel
		 */
		public function refreshZones():void {
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ZONE_LIST_UPDATE, _zones));
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_zones = new Vector.<ZoneData>();
		}
		
		/**
		 * Fires an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
		/**
		 * Called when an image's loading completes
		 */
		private function loadImageCompleteHandler(event:CommandEvent):void {
			var tmp:BitmapData = event.data as BitmapData;
			tmp.lock();

			var bmd:BitmapData = new BitmapData(Math.min(600, tmp.width), Math.min(1000, tmp.height), true, 0);
			bmd.lock();
			
			var i:int, len:int, x:int, y:int;
			len = bmd.width * bmd.height;
			for(i = 0; i < len; ++i) {
				x = i%bmd.width;
				y = Math.round(i/bmd.width);
				if(ColorFunctions.getLuminosity(tmp.getPixel(x, y)) > 200) {
					bmd.setPixel32(x, y, 0);
				}else{
					bmd.setPixel32(x, y, 0xffff0000);
				}
			}
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GENERATE_FROM_BMD, bmd));
		}
		
	}
}