package fr.durss.thermal.controler {
	import fr.durss.thermal.model.Model;
	import fr.durss.thermal.vo.ZoneData;

	import flash.display.BitmapData;
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	
	/**
	 * Singleton FrontControler
	 * 
	 * @author Durss
	 * @date 7 déc. 2014;
	 */
	public class FrontControler {
		
		private static var _instance:FrontControler;
		private var _model:Model;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FrontControler</code>.
		 */
		public function FrontControler(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():FrontControler {
			if(_instance == null)_instance = new  FrontControler(new SingletonEnforcer());
			return _instance;	
		}
		
		/**
		 * Initialize the controler.
		 */
		public function initialize(model:Model):void {
			_model = model;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		public function setFontGlyphMode():void {
			_model.setFontGlyphMode();
		}
		
		public function setBitmapMode():void {
			_model.setBitmapMode();
		}
		
		/**
		 * Generates the grid from a bitmap data
		 */
		public function generateFontBitmapData(bmd:BitmapData):void {
			_model.generateFontBitmapData(bmd);
		}
		
		/**
		 * Clears the grid
		 */
		public function clearGrid():void {
			_model.clearGrid();
		}
		
		/**
		 * Called when "force size" button state changes
		 */
		public function forceSizeChange(enabled:Boolean):void {
			_model.forceSizeChange(enabled);
		}
		
		/**
		 * Sets the current grid's data
		 */
		public function setCurrentData(data:ByteArray, areaSource:Rectangle, bmd:BitmapData):void {
			_model.setCurrentData(data, areaSource, bmd);
		}
		
		/**
		 * Starts a browsing session to load an image
		 */
		public function browseForImage():void {
			_model.browseForImage();
		}
		
		/**
		 * Defines the currently selected tool
		 */
		public function setCurrentTool(tool:String):void {
			_model.setCurrentTool(tool);
		}
		
		/**
		 * Registers a new zone
		 */
		public function registerZone(zone:Rectangle):void {
			_model.registerZone(zone);
		}
		
		/**
		 * Deletes a zone
		 */
		public function deleteZone(zone:ZoneData):void {
			_model.deleteZone(zone);
		}
		
		/**
		 * Forces a refresh of the zones on the output panel
		 */
		public function refreshZones():void {
			_model.refreshZones();
		}
		
		/**
		 * Loads a configuration file
		 */
		public function load():void {
			_model.load();
		}
		
		/**
		 * Saves the current configurations to an external file
		 */
		public function save():void {
			_model.save();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}