package fr.durss.thermal.components {
	import fr.durss.thermal.graphics.ToolTipArrowGraphic;
	import fr.durss.thermal.graphics.ToolTipBackgroundGraphic;

	import com.nurun.components.text.CssTextField;
	import com.nurun.utils.text.TextBounds;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author durss
	 * @date 20 sept. 2011;
	 */
	public class Tooltip extends Sprite {

		private var _back:ToolTipBackgroundGraphic;
		private var _arrow:ToolTipArrowGraphic;
		private var _label:CssTextField;
		private var _target:Point;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Tooltip</code>.
		 */
		public function Tooltip() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function set targetPoint(value:Point):void {
			_target = value.clone();
			move();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(label:String):void {
			_label.text = label;
			computePositions();
		}
		
		/**
		 * Makes the tooltip following the mouse
		 */
		public function startMouseFollow():void {
			if(!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			enterFrameHandler();
		}
		
		/**
		 * Stops the tooltip following the mouse
		 */
		public function stopMouseFollow():void {
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_back = addChild(new ToolTipBackgroundGraphic()) as ToolTipBackgroundGraphic;
			_arrow = addChild(new ToolTipArrowGraphic()) as ToolTipArrowGraphic;
			_label = addChild(new CssTextField("tooltip")) as CssTextField;
			
			filters = [new DropShadowFilter(2,45,0,.5,5,5,.7,2)];
			mouseEnabled = mouseChildren = false;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			if(_target != null) computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			var bounds:Rectangle = TextBounds.getBounds(_label);
			var margin:int = 5;
			_back.width = bounds.width + margin * 2;
			_back.height = bounds.height + margin * 2;
			_label.x = -bounds.x + margin;
			_label.y = -bounds.y + margin;
		}
		
		/**
		 * moves the tooltip to point the target
		 */
		private function move():void {
			x = _target.x - _arrow.getBounds(_arrow).x;
			y = _target.y - height;
			_arrow.x = 0;
			_arrow.y = _back.height;
			_arrow.scaleX = 1;
			var p:Point = localToGlobal(new Point(_back.width, 0));
			if(p.x > stage.stageWidth) {
				_arrow.scaleX = -1;
				_arrow.x = _back.width;
				x = _target.x - width;
			}
			if(p.y < 0) {
				y -= p.y;
			}
			if(x < -10) {
				x = -10;
			}
		}
		
		/**
		 * Called on ENTER_FRAME to follow the mouse
		 */
		private function enterFrameHandler(event:Event = null):void {
			if(_target == null) _target = new Point();
			_target.x = parent.mouseX;
			_target.y = parent.mouseY - 10;
			move();
		}
		
	}
}