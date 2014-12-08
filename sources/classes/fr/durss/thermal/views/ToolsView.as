package fr.durss.thermal.views {
	import fr.durss.thermal.graphics.ClearIconGraphic;
	import flash.events.MouseEvent;
	import fr.durss.thermal.components.TButton;
	import fr.durss.thermal.graphics.DrawIconGraphic;
	import fr.durss.thermal.vo.Tool;
	import fr.durss.thermal.components.TToggleButton;
	import fr.durss.thermal.controler.FrontControler;
	import fr.durss.thermal.graphics.AreaIconGraphic;
	import fr.durss.thermal.graphics.ImageIconGraphic;
	import fr.durss.thermal.graphics.TextIconGraphic;
	import fr.durss.thermal.model.Model;
	import fr.durss.thermal.vo.Metrics;
	import fr.durss.thermal.vo.Mode;
	import gs.TweenLite;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import flash.display.Shape;
	import flash.events.Event;

	/**
	 * Displays the toolsselector and sub menus
	 * 
	 * @author Durss
	 * @date 8 déc. 2014;
	 */
	public class ToolsView extends AbstractView {
		private var _font:FontToolView;
		private var _textBt:TToggleButton;
		private var _imageBt:TToggleButton;
		private var _label:CssTextField;
		private var _background:Shape;
		private var _group:FormComponentGroup;
		private var _image:ImageToolView;
		private var _zoneBt:TToggleButton;
		private var _zone:ByteZoneToolView;
		private var _pencilBt : TToggleButton;
		private var _clearBt : TButton;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolsView</code>.
		 */
		public function ToolsView() {
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
			_zoneBt.enabled = model.currentMode == Mode.MODE_BITMAP_DRAW;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_font			= addChild(new FontToolView()) as FontToolView;
			_image			= addChild(new ImageToolView()) as ImageToolView;
			_zone			= addChild(new ByteZoneToolView()) as ByteZoneToolView;
			_background		= addChild(new Shape()) as Shape;
			_label			= addChild(new CssTextField('title')) as CssTextField;
			_pencilBt		= addChild(new TToggleButton(Label.getLabel('pencil'), 'button', new DrawIconGraphic())) as TToggleButton;
			_textBt			= addChild(new TToggleButton(Label.getLabel('calkText'), 'button', new TextIconGraphic())) as TToggleButton;
			_imageBt		= addChild(new TToggleButton(Label.getLabel('calkImage'), 'button', new ImageIconGraphic())) as TToggleButton;
			_zoneBt			= addChild(new TToggleButton(Label.getLabel('zoneTool'), 'button', new AreaIconGraphic())) as TToggleButton;
			_clearBt		= addChild(new TButton(Label.getLabel('clearGrid'), 'button', new ClearIconGraphic())) as TButton;
			_group			= new FormComponentGroup();
			
			_label.text						= Label.getLabel('toolsTitle');
			_pencilBt.textAlign				= TextAlign.RIGHT;
			_textBt.textAlign				= TextAlign.RIGHT;
			_imageBt.textAlign				= TextAlign.RIGHT;
			_zoneBt.textAlign				= TextAlign.RIGHT;
			_clearBt.textAlign				= TextAlign.RIGHT;
			_group.allowMultipleSelection	= false;
			_group.allowNoSelection			= false;
			_group.addItem(_pencilBt);
			_group.addItem(_textBt);
			_group.addItem(_imageBt);
			_group.addItem(_zoneBt);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_clearBt.addEventListener(MouseEvent.CLICK, clearHandler);
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			_font.y = Metrics.TOP_BAR_HEIGHT - _font.height - 10;
			_image.y = Metrics.TOP_BAR_HEIGHT - _image.height - 10;
			_zone.y = Metrics.TOP_BAR_HEIGHT - _zone.height - 10;
			_font.visible = false;
			_image.visible = false;
			_zone.visible = false;
			
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			var offset:int = (Metrics.TOP_BAR_HEIGHT - _imageBt.height) * .5;
			_label.x = offset;
			PosUtils.hPlaceNext(10, _label, _pencilBt, _textBt, _imageBt, _zoneBt, _clearBt);
			PosUtils.vAlign(PosUtils.V_ALIGN_CENTER, offset, _label, _pencilBt, _imageBt, _textBt, _zoneBt, _clearBt);
			
			var form:OutputPanelView = ViewLocator.getInstance().locateViewByType(OutputPanelView) as OutputPanelView;
			_font.width = _image.width = _zone.width = stage.stageWidth - form.width + 4;
			
			_background.graphics.clear();
			_background.graphics.beginFill(0xffffff, 1);
			_background.graphics.drawRect(0, 0, stage.stageWidth, Metrics.TOP_BAR_HEIGHT);
			_background.graphics.beginFill(0, .2);
			_background.graphics.drawRect(0, Metrics.TOP_BAR_HEIGHT, width, 2);
			_background.graphics.beginFill(0, .1);
			_background.graphics.drawRect(0, Metrics.TOP_BAR_HEIGHT + 2, width, 2);
			_background.graphics.endFill();
		}
		
		/**
		 * Called when a new tool is selected
		 */
		private function changeSelectionHandler(event:FormComponentGroupEvent):void {
			_font.mouseChildren = false;
			_image.mouseChildren = false;
			_zone.mouseChildren = false;
			
			if(event.selectedItem == _pencilBt) {
				TweenLite.to(_font, .25, {y: Metrics.TOP_BAR_HEIGHT - _font.height - 10, visible:false});
				TweenLite.to(_image, .25, {y: Metrics.TOP_BAR_HEIGHT - _image.height - 10, visible:false});
				TweenLite.to(_zone, .25, {y: Metrics.TOP_BAR_HEIGHT - _zone.height - 10, visible:false});
				FrontControler.getInstance().setCurrentTool(Tool.PENCIL);
			
			}else if (event.selectedItem == _textBt) {
				_font.mouseChildren = true;
				_font.visible = true;
				TweenLite.to(_font, .25, {y: Metrics.TOP_BAR_HEIGHT});
				TweenLite.to(_image, .25, {y: Metrics.TOP_BAR_HEIGHT - _image.height - 10, visible:false});
				TweenLite.to(_zone, .25, {y: Metrics.TOP_BAR_HEIGHT - _zone.height - 10, visible:false});
				FrontControler.getInstance().setCurrentTool(Tool.CALK);
			
			}else if(event.selectedItem == _imageBt){
				_image.mouseChildren = true;
				_image.visible = true;
				TweenLite.to(_font, .25, {y: Metrics.TOP_BAR_HEIGHT - _font.height - 10, visible:false});
				TweenLite.to(_image, .25, {y: Metrics.TOP_BAR_HEIGHT});
				TweenLite.to(_zone, .25, {y: Metrics.TOP_BAR_HEIGHT - _zone.height - 10, visible:false});
				FrontControler.getInstance().setCurrentTool(Tool.CALK);
				
			}else if(event.selectedItem == _zoneBt){
				_zone.mouseChildren = true;
				_zone.visible = true;
				TweenLite.to(_font, .25, {y: Metrics.TOP_BAR_HEIGHT - _font.height - 10, visible:false});
				TweenLite.to(_image, .25, {y: Metrics.TOP_BAR_HEIGHT - _image.height - 10, visible:false});
				TweenLite.to(_zone, .25, {y: Metrics.TOP_BAR_HEIGHT});
				FrontControler.getInstance().setCurrentTool(Tool.ZONE);
			}
		}
		
		/**
		 * Called when clear button is clicked.
		 */
		private function clearHandler(event : MouseEvent) : void {
			FrontControler.getInstance().clearGrid();
		}
		
	}
}