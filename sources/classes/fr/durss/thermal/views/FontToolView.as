package fr.durss.thermal.views {
	import fr.durss.thermal.components.TButton;
	import fr.durss.thermal.components.TComboBox;
	import fr.durss.thermal.components.TInput;
	import fr.durss.thermal.controler.FrontControler;
	import fr.durss.thermal.model.Model;
	import fr.durss.thermal.vo.Metrics;
	import fr.durss.thermal.vo.Mode;

	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
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
	import flash.text.TextFieldAutoSize;
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
	public class FontToolView extends AbstractView {
		private var _comboFont:TComboBox;
		private var _holder:Sprite;
		private var _input:TInput;
		private var _submitBt:TButton;
		private var _comboSize:TComboBox;
		private var _bmd:BitmapData;
		private var _tf:TextField;
		private var _comboStyle:TComboBox;
		private var _intervalCompute:uint;
		private var _width:Number;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FontToolView</code>.
		 */
		public function FontToolView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the currently selected font
		 */
		public function get bitmapData():BitmapData{ return _bmd; }
		
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
			_input.textfield.maxChars = model.currentMode == Mode.MODE_FONT_GLYPH? 1 : 100;
			if(_input.text != _input.defaultLabel && _input.text.length > _input.textfield.maxChars ) {
				_input.text = _input.text.substr(0, _input.textfield.maxChars);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_width		= 800;
			_tf			= addChild(new TextField()) as TextField;//Need to add it to the stage !! Read bellow
			_holder		= addChild(new Sprite()) as Sprite;
			_comboFont	= _holder.addChild(new TComboBox(Label.getLabel('fontListTitle'))) as TComboBox;
			_comboSize	= _holder.addChild(new TComboBox(Label.getLabel('fontSizeTitle'))) as TComboBox;
			_comboStyle	= _holder.addChild(new TComboBox(Label.getLabel('fontTypeTitle'))) as TComboBox;
			_input		= _holder.addChild(new TInput(Label.getLabel('defaultChar'), 'inputChar')) as TInput;
			_submitBt	= _holder.addChild(new TButton(Label.getLabel('generateChar'))) as TButton;
			
			_input.text = "A";
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_comboFont.listHeight = 300;
			//If the textfield isn't added to the stage, the rendering
			//of ALL the buttons is fucked up. Probably a bug due to
			//textfield + textformat drawing to a BitmapData...dunno.
			//What's sure is that if the textfield isn't on the stage
			//everything exploses when buttons states are refreshed (on roll)
			_tf.visible = false;
			
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
			for(i = 6; i <= 100; ++i) {
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
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			var margin:int		= 10;
			_holder.x			= _holder.y = margin;
			_comboSize.width	= 100;
			_comboStyle.width	= 135;
			
			var items:Array = [_comboFont, _comboStyle, _comboSize, _input, _submitBt];
			PosUtils.hDistribute(items, _width, margin, margin);
			_comboFont.height = _comboStyle.height = _comboSize.height = _input.height = _submitBt.height = _input.height;
			
			_holder.y = Math.round((Metrics.TOP_BAR_HEIGHT - _submitBt.height) * .5);
			
			var h:int = _submitBt.y + _submitBt.height + margin + _holder.y;
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
		 * Called when submit button is clicked
		 */
		private function submitHandler(event:MouseEvent):void {
			if (_bmd != null) _bmd.dispose();
			var font:Font = _comboFont.selectedData as Font;
			if(font == null || _input.text.length == 0 || _input.text == _input.defaultLabel) return;

			var format:TextFormat = new TextFormat();
			format.font		= font.fontName;
			format.bold		= _comboStyle.selectedData == 'bold' || _comboStyle.selectedData == 'bold italic';
			format.italic	= _comboStyle.selectedData == 'italic' || _comboStyle.selectedData == 'bold italic';
			format.size		= _comboSize.selectedData;
			
			_tf.text = _input.text;
			_tf.setTextFormat(format);

			_tf.visible = true;//TextBounds checks for textfield's visibility (which sounds stupid..)
			var bounds:Rectangle = TextBounds.getBounds(_tf);
			_tf.visible = false;//Read initialize() for more info
			
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
			
			FrontControler.getInstance().generateFontBitmapData( _bmd );
		}
		
		/**
		 * Sorts fonts on their names
		 */
		private function sortOnNames(a:Font, b:Font):int {
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