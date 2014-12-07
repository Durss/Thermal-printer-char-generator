package fr.durss.thermal {
	import com.nurun.utils.string.StringUtils;
	import flash.events.FocusEvent;
	import fr.durss.thermal.components.TScrollbar;
	import com.nurun.components.scroll.scrollable.ScrollableTextField;
	import com.nurun.components.scroll.ScrollPane;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.Clipboard;
	import flash.events.MouseEvent;
	import fr.durss.thermal.components.TButton;
	import fr.durss.thermal.components.TInput;
	import fr.durss.thermal.components.TCheckBox;

	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	/**
	 * Displays the form panel
	 * 
	 * @author Durss
	 * @date 6 déc. 2014;
	 */
	public class FormPanel extends Sprite {
		private var _cbUserDefineCommands:TCheckBox;
		private var _cbCharHeaderCmdCommands:TCheckBox;
		private var _cbFormatCodeCommands:TCheckBox;
		private var _hexaValues:TCheckBox;
		private var _currentData:ByteArray;
		private var _inputCharIndex:TInput;
		private var _width:int;
		private var _height:int;
		private var _copyBt:TButton;
		private var _currentFormatedData:String;
		private var _clearGridBt:TButton;
		private var _textArea:ScrollPane;
		private var _textfield:ScrollableTextField;
		private var _holder:Sprite;
		private var _cbMinimizeParams:TCheckBox;
		private var _cbForceSize:TCheckBox;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Panel</code>.
		 */
		public function FormPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function set y(value:Number):void {
			super.y = value;
			computePositions();
		}
		
		/**
		 * Gets if the full size has been forced
		 */
		public function get forceFullSize():Boolean {
			return _cbForceSize.selected;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(data:ByteArray, width:int, height:int):void {
			_width = width;
			_height = height;
			_currentData = data;
			data.position = 0;
			var result:Array = [];
			
			if(_cbUserDefineCommands.selected) {
				result.push('//Enable user defined chars');
				result.push(formatByte(27), formatByte(37), formatByte(1));
				result.push('');
			}
			
			if(_cbCharHeaderCmdCommands.selected) {
				result.push('//Define custom char header');
				var char:int = _inputCharIndex.text == _inputCharIndex.defaultLabel? 33 : parseInt(_inputCharIndex.text);
				if(isNaN(char)) char = 33;
				
				result.push(formatByte(27),
							formatByte(38),
							formatByte(height/8),
							formatByte(char),
							formatByte(char),
							formatByte(width));
				result.push('');
			}
			
			result.push('//Custom char data');
			while (data.bytesAvailable) {
				var b:int = data.readUnsignedByte();
				result.push( formatByte(b) );
			}
			
			_currentFormatedData = result.join("\n");
			
			if(_cbMinimizeParams.selected && _cbFormatCodeCommands.selected) {
				//Concatenate 4 consecutive commands into one
				_currentFormatedData = _currentFormatedData.replace(/printer.writeBytes\(([^)]{1,4})\);\nprinter.writeBytes\(([^)]{1,4})\);\nprinter.writeBytes\(([^)]{1,4})\);\nprinter.writeBytes\(([^)]{1,4})\);/gmi, 'printer.writeBytes($1, $2, $3, $4);');
				//Concatenate 3 consecutive commands into one
				_currentFormatedData = _currentFormatedData.replace(/printer.writeBytes\(([^)]{1,4})\);\nprinter.writeBytes\(([^)]{1,4})\);\nprinter.writeBytes\(([^)]{1,4})\);/gmi, 'printer.writeBytes($1, $2, $3);');
				//Concatenate 2 consecutive commands into one
				_currentFormatedData = _currentFormatedData.replace(/printer.writeBytes\(([^)]{1,4})\);\nprinter.writeBytes\(([^)]{1,4})\);/gmi, 'printer.writeBytes($1, $2);');
			}
			
			_textfield.text = _currentFormatedData;
			_textArea.validate();
			_copyBt.enabled = _currentFormatedData.length > 0;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_holder						= addChild(new Sprite()) as Sprite;
			_hexaValues					= _holder.addChild(new TCheckBox(Label.getLabel("hexaValues"))) as TCheckBox;
			_cbUserDefineCommands		= _holder.addChild(new TCheckBox(Label.getLabel("userDefineCmd"))) as TCheckBox;
			_cbCharHeaderCmdCommands	= _holder.addChild(new TCheckBox(Label.getLabel("charHeaderCmd"))) as TCheckBox;
			_cbFormatCodeCommands		= _holder.addChild(new TCheckBox(Label.getLabel("formatCode"))) as TCheckBox;
			_cbMinimizeParams			= _holder.addChild(new TCheckBox(Label.getLabel("minimizeParams"))) as TCheckBox;
			_cbForceSize				= _holder.addChild(new TCheckBox(Label.getLabel("forceSize"))) as TCheckBox;
			_inputCharIndex				= _holder.addChild(new TInput(Label.getLabel('charToreplace'))) as TInput;
			_copyBt						= _holder.addChild(new TButton(Label.getLabel('copyData'))) as TButton;
			_clearGridBt				= _holder.addChild(new TButton(Label.getLabel('clearGrid'))) as TButton;
			_textfield					= new ScrollableTextField('', 'code');
			_textArea					= _holder.addChild(new ScrollPane(_textfield, new TScrollbar())) as ScrollPane;
			
			_copyBt.enabled							= false;
			_textfield.selectable					= true;
			_textArea.autoHideScrollers				= true;
			_cbUserDefineCommands.selected			= 
			_cbCharHeaderCmdCommands.selected		= 
			_cbMinimizeParams.selected				= 
			_cbForceSize.selected					= 
			_cbFormatCodeCommands.selected			= true; 
			_inputCharIndex.textfield.restrict		= '[0-9]';
			_inputCharIndex.textfield.maxChars		= 3;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_hexaValues.addEventListener(Event.CHANGE, updateFormHandler);
			_cbUserDefineCommands.addEventListener(Event.CHANGE, updateFormHandler);
			_cbCharHeaderCmdCommands.addEventListener(Event.CHANGE, updateFormHandler);
			_cbFormatCodeCommands.addEventListener(Event.CHANGE, updateFormHandler);
			_cbMinimizeParams.addEventListener(Event.CHANGE, updateFormHandler);
			_cbForceSize.addEventListener(Event.CHANGE, updateFormHandler);
			_inputCharIndex.addEventListener(Event.CHANGE, updateFormHandler);
			_inputCharIndex.addEventListener(FocusEvent.FOCUS_OUT, focusOutInputHandler);
			_copyBt.addEventListener(MouseEvent.CLICK, copyHandler);
			_clearGridBt.addEventListener(MouseEvent.CLICK, clearGridHandler);
		}
		
		/**
		 * Called when clear button is clicked to clear the grid
		 */
		private function clearGridHandler(event:MouseEvent):void {
			_copyBt.enabled = false;
			_textfield.text = "";
			_textArea.validate();
			dispatchEvent(new Event(Event.CLEAR));
		}
		
		/**
		 * Called when copy button is clicked to copy the data
		 */
		private function copyHandler(event:MouseEvent):void {
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _currentFormatedData);
		}
		
		/**
		 * Forces a refresh of the data
		 */
		private function updateFormHandler(event:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Called when input looses focus
		 */
		private function focusOutInputHandler(event:FocusEvent):void {
			if(_inputCharIndex.text.length == 0 || _inputCharIndex.text == _inputCharIndex.defaultLabel) return;
			
			var char:int = parseInt(_inputCharIndex.text);
			if(isNaN(char)) char = 33;
			if(char < 32) char = 33;
			if(char > 126) char = 126;
			_inputCharIndex.text = char.toString();
			
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
			PosUtils.vPlaceNext(10, _hexaValues, _cbUserDefineCommands, _cbCharHeaderCmdCommands, _cbFormatCodeCommands, _cbMinimizeParams, _cbForceSize, _inputCharIndex, _clearGridBt, _copyBt, _textArea);
			_inputCharIndex.width = Math.max(_hexaValues.width, _cbUserDefineCommands.width, _cbCharHeaderCmdCommands.width, _cbFormatCodeCommands.width);
			
			PosUtils.hCenterIn(_clearGridBt, _inputCharIndex); 
			PosUtils.hCenterIn(_copyBt, _inputCharIndex);
			
			_textArea.width = _inputCharIndex.width;
			_textArea.height = stage.stageHeight - y - _textArea.y - margin * 2;
			_textArea.validate();
			
			graphics.clear();
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect(0, 0, width + margin * 2, height + margin * 2);
			graphics.beginFill(0, .2);
			graphics.drawRect(-2, 0, 2, height + margin * 2);
			graphics.beginFill(0, .1);
			graphics.drawRect(-4, 0, 2, height + margin * 2);
			
			_textArea.graphics.clear();
			_textArea.graphics.beginFill(0xf5f5f5, 1);
			_textArea.graphics.drawRect(0, 0, _textArea.width, _textArea.height);
			
			x = stage.stageWidth - width + 4;
		}
		
		/**
		 * Formats a byte value
		 */
		private function formatByte(data:int):String {
			var prefix:String = _hexaValues.selected? "0x" : "";
			var base:int = _hexaValues.selected? 16 : 10;
			var value:String = data.toString(base);
			if(_hexaValues.selected) value = StringUtils.toDigit(value);
			if(_cbFormatCodeCommands.selected) {
				return "printer.writeBytes(" + prefix + value + ");";
			}else{
				return prefix + value;
			}
		}
		
	}
}