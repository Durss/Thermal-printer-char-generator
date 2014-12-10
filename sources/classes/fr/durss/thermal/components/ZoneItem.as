package fr.durss.thermal.components {
	import flash.text.TextField;
	import fr.durss.thermal.controler.FrontControler;
	import fr.durss.thermal.events.ViewEvent;
	import fr.durss.thermal.graphics.ZoneItemGraphic;
	import fr.durss.thermal.graphics.ZoneItemIconGraphic;
	import fr.durss.thermal.vo.ZoneData;

	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitor;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	
	/**
	 * Displays a zone item on the list
	 * 
	 * @author Durss
	 * @date 8 déc. 2014;
	 */
	public class ZoneItem extends BaseButton {
		private var _data:ZoneData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ZoneItem</code>.
		 */
		public function ZoneItem(label:String, data:ZoneData) {
			_data = data;
			super(label, 'zoneItem', new ZoneItemGraphic(), new ZoneItemIconGraphic());
			applyDefaultFrameVisitor(this, background, icon);
			textAlign = TextAlign.LEFT;
			iconAlign = IconAlign.LEFT;
			iconSpacing = 6;
			textfield.restrict = "[a-z][A-Z][0-9]_ ";
			contentMargin = new Margin(5, 2, 5, 2);
			
			textfield.addEventListener(Event.CHANGE, changeLabelHandler);
			textfield.addEventListener(FocusEvent.FOCUS_OUT, focusOutTextfieldHandler);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get data():ZoneData {
			return _data;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		override public function dispose():void {
			textfield.removeEventListener(Event.CHANGE, changeLabelHandler);
			textfield.removeEventListener(FocusEvent.FOCUS_OUT, focusOutTextfieldHandler);
			_data = null;
			super.dispose();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function clickHandler(event:MouseEvent):void {
			if(mouseX < textfield.x) return;//Deleting item not editing
			
			super.clickHandler(event);
			textfield.type = TextFieldType.INPUT;
			textfield.border= true;
			textfield.borderColor = 0xffffff;
			stage.focus = textfield;
			textfield.setSelection(0, textfield.length);
			validate();
		}

		override protected function rollOutHandler(event:Event):void {
			super.rollOutHandler(event);
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ZONE_LOWLIGHT, data));
		}

		override protected function rollOverHandler(event:Event):void {
			super.rollOverHandler(event);
			ViewLocator.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ZONE_HIGHLIGHT, data));
		}
		
		private function focusOutTextfieldHandler(event:FocusEvent = null):void {
			textfield.type = TextFieldType.DYNAMIC;
			textfield.border = false;
			textfield.borderColor = 0xffffff;
			validate();
			data.name = textfield.text;
			FrontControler.getInstance().refreshZones();//Updates the output with new name
		}

		private function changeLabelHandler(event:Event):void {
			label = data.name = textfield.text;
			validate();
			dispatchEvent(event);
		}
		
		//prevent from "clicking" the button when space or enter is pressed while writing text
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if(event.target is TextField) return;
			super.keyUpHandler(event);
		}
		
	}
}