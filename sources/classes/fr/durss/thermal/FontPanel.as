package fr.durss.thermal {
	import fr.durss.thermal.components.TButton;
	import fr.durss.thermal.components.TComboBox;
	import fr.durss.thermal.components.TInput;

	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.text.TextBounds;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.FontType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	[Event(name="onSubmitForm", type="com.nurun.components.form.events.FormComponentEvent")]
	
	/**
	 * Displays the font panel to generate a character from a font's char
	 * 
	 * @author Durss
	 * @date 6 déc. 2014;
	 */
	public class FontPanel extends Sprite {
		private var _comboFont:TComboBox;
		private var _holder:Sprite;
		private var _input:TInput;
		private var _submitBt:TButton;
		private var _comboSize:TComboBox;
		private var _bmd:BitmapData;
		private var _tf:TextField;
		private var _comboStyle:TComboBox;
		private var _intervalCompute : uint;
		private var _height : Number;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FontPanel</code>.
		 */
		public function FontPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the currently selected font
		 */
		public function get bitmapData():BitmapData{ return _bmd; }
		
		/**
		 * Gets the currently selected font
		 */
		override public function get height():Number{ return _height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_tf			= new TextField();
			_holder		= addChild(new Sprite()) as Sprite;
			_comboFont	= _holder.addChild(new TComboBox(Label.getLabel('fontListTitle'))) as TComboBox;
			_comboSize	= _holder.addChild(new TComboBox(Label.getLabel('fontSizeTitle'))) as TComboBox;
			_comboStyle	= _holder.addChild(new TComboBox(Label.getLabel('fontTypeTitle'))) as TComboBox;
			_input		= _holder.addChild(new TInput(Label.getLabel('defaultChar'), 'inputChar')) as TInput;
			_submitBt	= _holder.addChild(new TButton(Label.getLabel('generateChar'))) as TButton;
			
			_input.text = "A";
			_input.textfield.maxChars = 1;
			_comboFont.listHeight = 300;
			
			//Build fonts list
			var fonts:Array = Font.enumerateFonts(true);
			var i:int, len:int;
			len = fonts.length;
			fonts.sort( sortOnNames );
			for(i = 0; i < len; ++i) {
				if(Font(fonts[i]).fontType == FontType.EMBEDDED) continue;//skip embedded fonts
				
				//Spread items creation over time to prevent from freeze on init.
				setTimeout(_comboFont.addSkinnedItem, i * 20, Font(fonts[i]).fontName, fonts[i]);
			}
			_intervalCompute = setInterval(computePositions, 20);
			setTimeout(stopComputePosition, len * 20);
			
			//Build sizes list
			for(i = 6; i <= 20; ++i) {
				_comboSize.addSkinnedItem(i.toString(), i);
			}
			_comboSize.validate();
			_comboSize.selectedIndex = 10;
			
			_comboStyle.addSkinnedItem("Regular", "regular");
			_comboStyle.addSkinnedItem("Italic", "italic");
			_comboStyle.addSkinnedItem("Bold", "bold");
			_comboStyle.addSkinnedItem("Bold  Italic", "bold italic");
			_comboSize.selectedIndex = 0;
			
			_submitBt.addEventListener(MouseEvent.CLICK, submitHandler);
			
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
			var margin:int = 10;
			_holder.x = _holder.y = margin;
			_comboSize.width = 100;
			_comboStyle.width = 200;
			
			PosUtils.hPlaceNext(10, _comboFont, _comboStyle, _comboSize, _input, _submitBt);
			_comboFont.height = _comboStyle.height = _comboSize.height = _input.height = _submitBt.height = _input.height;
//			PosUtils.vAlign(PosUtils.V_ALIGN_CENTER, 0, _comboFont, _comboSize, _input, _submitBt);
			
			_height = _submitBt.height + margin * 2;
			graphics.clear();
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect(0, 0, stage.stageWidth, _submitBt.height + margin * 2);
			graphics.beginFill(0, .2);
			graphics.drawRect(0, _height, width, 2);
			graphics.beginFill(0, .1);
			graphics.drawRect(0, _height + 2, width, 2);
			graphics.endFill();
		}
		
		/**
		 * Called when submit button is clicked
		 */
		private function submitHandler(event:MouseEvent):void {
			if (_bmd != null) _bmd.dispose();
			var font:Font = _comboFont.selectedData as Font;
			if(font == null || _input.text.length == 0 || _input.text == _input.defaultLabel) return;

			var format:TextFormat = new TextFormat();
			format.font = font.fontName;
			format.bold = _comboStyle.selectedData == 'bold' || _comboStyle.selectedData == 'bold italic';
			format.italic = _comboStyle.selectedData == 'italic' || _comboStyle.selectedData == 'bold italic';
			format.size = _comboSize.value;
			
			_tf.defaultTextFormat = format;
			_tf.text = _input.text;

			var bounds:Rectangle = TextBounds.getBounds(_tf);
			var m:Matrix = new Matrix();
			m.translate(-bounds.x, -bounds.y);
			if(bounds.width == 0 || bounds.height == 0) return;
			
			_bmd = new BitmapData(bounds.width, bounds.height, true, 0);
			_bmd.draw(_tf,m);
			
			//Passes the bitmap into monochrome (removes any transparency)
			var i:int, len:int, px:int, py:int, color:uint;
			var threshold:uint = 0x4A;
			len = _bmd.width * _bmd.height;
			for(i = 0; i < len; ++i) {
				px = i%_bmd.width;
				py = Math.floor(i/_bmd.width);
				color = (_bmd.getPixel32(px, py)>>24) & 0xff;
				color = (color < threshold)? 0 : 0xffFF0000;
				_bmd.setPixel32(px, py, color);
			}
			
//			var scale:Number = 20;
//			m = new Matrix();
//			m.scale(scale, scale);
//			m.translate(20, 100);
//			graphics.clear();
//			computePositions();
//			graphics.beginBitmapFill(_bmd, m);
//			graphics.drawRect(20, 100, _bmd.width * scale, _bmd.height * scale);
			
			dispatchEvent(new FormComponentEvent(FormComponentEvent.SUBMIT));
		}
		
		/**
		 * Sorts fonts on their names
		 */
		function sortOnNames(a:Font, b:Font):int {
			if(a.fontName < b.fontName) return -1;
			if(a.fontName > b.fontName) return 1;
			return 0;
		}
		
		/**
		 * Stops auto positionning when fonts list is fully built
		 */
		private function stopComputePosition():void {
			clearInterval(_intervalCompute);
		}
		
	}
}