package fr.durss.thermal.views {
	import fr.durss.thermal.controler.FrontControler;
	import flash.events.MouseEvent;
	import fr.durss.thermal.components.TButton;
	import fr.durss.thermal.vo.Mode;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;

	/**
	 * 
	 * @author Durss
	 * @date 8 déc. 2014;
	 */
	public class ImageToolView extends AbstractView {
		private var _label:CssTextField;
		private var _browseBt:TButton;
		private var _width:Number;
		private var _infos:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ImageToolView</code>.
		 */
		public function ImageToolView() {
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
			var model:Mode = event.model as Mode;
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
			_label		= addChild(new CssTextField('title')) as CssTextField;
			_infos		= addChild(new CssTextField('infos')) as CssTextField;
			_browseBt	= addChild(new TButton(Label.getLabel('browse'))) as TButton;
			
			_label.text = Label.getLabel('browseLabel');
			_infos.text = Label.getLabel('browseInfos');
			_browseBt.textBoundsMode = false;
			
			computePositions();
			_browseBt.addEventListener(MouseEvent.CLICK, browseHandler);
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			var margin:int	= 10;
			_label.x		= margin;
			PosUtils.hPlaceNext(margin, _label, _browseBt, _infos);
			_infos.width	= Math.max(50, _width - _infos.x -margin);
			PosUtils.vAlign(PosUtils.V_ALIGN_CENTER, margin, _label, _browseBt, _infos);
			
			var h:int = Math.max(_browseBt.height, _infos.height) + margin * 2;
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
		 * Called when browse button is clicked.
		 */
		private function browseHandler(event:MouseEvent):void {
			FrontControler.getInstance().browseForImage();
		}
		
	}
}