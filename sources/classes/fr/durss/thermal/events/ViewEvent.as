package fr.durss.thermal.events {
	import flash.events.Event;
	
	/**
	 * Event fired by model to views through ViewLocator
	 * 
	 * @author Durss
	 * @date 7 déc. 2014;
	 */
	public class ViewEvent extends Event {
		
		public static const CLEAR_GRID:String = 'clearGrid'; 
		public static const FORCE_SIZE_CHANGE:String = 'forceSizeChange'; 
		public static const GENERATE_FROM_BMD:String = 'generateFromBmd';
		public static const GRID_DATA_UPDATE:String = 'gridDataUpdate';
		public static const TOOL_CHANGE:String = 'toolChange';
		public static const NEW_ZONE:String = 'newZone';
		public static const ZONE_LIST_UPDATE:String = 'zoneListUpdate';
		public static const ZONE_HIGHLIGHT:String = 'zoneHighlight';
		public static const ZONE_LOWLIGHT:String = 'zoneLowlight';
		private var _data:*;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ViewEvent</code>.
		 */
		public function ViewEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			_data = data;
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get data():* {
			return _data;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new ViewEvent(type, data, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}