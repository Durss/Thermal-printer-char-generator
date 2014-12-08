package fr.durss.thermal.views {
	import fr.durss.thermal.controler.FrontControler;
	import flash.events.MouseEvent;
	import fr.durss.thermal.components.TToggleButton;
	import fr.durss.thermal.model.Model;
	import fr.durss.thermal.vo.Metrics;
	import fr.durss.thermal.vo.Mode;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;

	import flash.events.Event;

	/**
	 * Allows the user to switch between image and font mode
	 * 
	 * @author Durss
	 * @date 7 déc. 2014;
	 */
	public class ModeView extends AbstractView {
		private var _bitmapMode:TToggleButton;
		private var _fontMode:TToggleButton;
		private var _label:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ModeView</code>.
		 */
		public function ModeView() {
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
			var model:Model = event.model as Model;
			_fontMode.selected = model.currentMode == Mode.MODE_FONT_GLYPH;
			_bitmapMode.selected = model.currentMode == Mode.MODE_BITMAP_DRAW;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label		= addChild(new CssTextField('title')) as CssTextField;
			_bitmapMode	= addChild(new TToggleButton(Label.getLabel('modeImage'))) as TToggleButton;
			_fontMode	= addChild(new TToggleButton(Label.getLabel('modeFont'))) as TToggleButton;
			
			_label.text = Label.getLabel('modeTitle');
			_bitmapMode.textBoundsMode = false;
			_fontMode.textBoundsMode = false;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			PosUtils.hPlaceNext(10, _label, _fontMode, _bitmapMode);
			PosUtils.vAlign(PosUtils.V_ALIGN_CENTER, 0, _label, _fontMode, _bitmapMode);
			y = (Metrics.TOP_BAR_HEIGHT - height) * .5;
			x = stage.stageWidth - width - 10;
			
			roundPos(this);
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _fontMode) {
				FrontControler.getInstance().setFontGlyphMode();
			}else if(event.target == _bitmapMode) {
				FrontControler.getInstance().setBitmapMode();
			}
		}
		
	}
}