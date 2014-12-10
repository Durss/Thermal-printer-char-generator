package fr.durss.thermal.views {
	import fr.durss.thermal.controler.FrontControler;
	import flash.events.MouseEvent;
	import fr.durss.thermal.components.ZoneItem;
	import fr.durss.thermal.events.ViewEvent;
	import fr.durss.thermal.model.Model;
	import fr.durss.thermal.vo.ZoneData;

	import gs.TweenLite;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * This tool allows to define editable zones on a bitmap.
	 * This mainly define the byte offsetand its sizes.
	 * 
	 * This way it's then easier to inject images inside these
	 * areas from C code.  
	 * 
	 * @author Durss
	 * @date 8 déc. 2014;
	 */
	public class ByteZoneToolView extends AbstractView {
		private var _width:Number;
		private var _infos:CssTextField;
		private var _zones:Vector.<ZoneItem>;
		private var _btHolder:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ByteZoneView</code>.
		 */
		public function ByteZoneToolView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			model;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_width		= 800;
			_zones		= new Vector.<ZoneItem>();
			_infos		= addChild(new CssTextField('infos')) as CssTextField;
			_btHolder	= addChild(new Sprite()) as Sprite;
			
			_infos.text = Label.getLabel('zoneInfos') + Label.getLabel('zoneHelp');
			
			ViewLocator.getInstance().addEventListener(ViewEvent.LOAD_CONF, loadConfHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.NEW_ZONE, newZoneHandler);
			_btHolder.addEventListener(Event.CHANGE, computePositions);
			_btHolder.addEventListener(MouseEvent.CLICK, clickItemHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			var margin:int	= 10;
			_infos.x		= _infos.y = margin;
			_infos.width	= Math.max(50, _width);
			_btHolder.x		= margin;
			_btHolder.y		= _infos.y + _infos.height + margin;
			
			if (_zones.length > 0) {
				PosUtils.hDistribute(_zones, _width, 5, 5);
			}
			
			var h:int = _btHolder.y + _btHolder.height + margin;
			graphics.clear();
			graphics.beginFill(0xfcfcfc, 1);
			graphics.drawRect(0, 0, _width, h);
			graphics.beginFill(0, .2);
			graphics.drawRect(0, h, width, 2);
			graphics.beginFill(0, .1);
			graphics.drawRect(0, h + 2, width, 2);
			graphics.endFill();
		}
		
		/**
		 * Called when a new zone is created
		 */
		private function newZoneHandler(event:ViewEvent):void {
			_infos.text = Label.getLabel('zoneInfos');
			
			var data:ZoneData = event.data as ZoneData;
			var bt:ZoneItem = new ZoneItem(data.name, data);
			_zones.push(bt);
			_btHolder.addChild(bt);
			
			computePositions();
			
			TweenLite.from(bt, .25, {transformAroundCenter:{scaleX:2, scaleY:2}, onComplete:computePositions});
		}
		
		/**
		 * Called when a zone item is clicked
		 */
		private function clickItemHandler(event:MouseEvent):void {
			var bt:ZoneItem = event.target as ZoneItem;
			if(bt.mouseX < bt.textfield.x) {
				var i:int, len:int;
				len = _zones.length;
				for(i = 0; i < len; ++i) {
					if(_zones[i] == bt) {
						_zones.splice(i, 1);
						break;
					}
				}
				FrontControler.getInstance().deleteZone(bt.data);
				
				bt.dispose();
				_btHolder.removeChild(bt);
				
				if(_zones.length == 0) {
					_infos.text = Label.getLabel('zoneInfos') + Label.getLabel('zoneHelp');
				}else{
					_infos.text = Label.getLabel('zoneInfos');
				}
				
				computePositions();
			}
		}
		
		/**
		 * Called when loading a configuration file.
		 * Clear all the zones !
		 */
		private function loadConfHandler(event:ViewEvent):void {
			var i:int, len:int;
			len = _zones.length;
			for(i = 0; i < len; ++i) {
				_zones[0].dispose();
				_btHolder.removeChild(_zones[0]);
				_zones.splice(0, 1);
			}
		}
		
	}
}