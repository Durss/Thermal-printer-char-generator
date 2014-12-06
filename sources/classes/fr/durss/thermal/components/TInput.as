package fr.durss.thermal.components {
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.display.DisplayObject;
	import com.nurun.trombi.graphics.InputErrorGraphic;
	import flash.events.FocusEvent;
	import com.nurun.components.vo.Margin;
	import com.nurun.trombi.graphics.InputGraphic;
	import com.nurun.components.form.Input;
	
	/**
	 * 
	 * @author durss
	 * @date 15 sept. 2011;
	 */
	public class TInput extends Input {
		
		private var _regTest:RegExp;
		private var _errorSkin:InputErrorGraphic;
		private var _defaultSkin:DisplayObject;
		private var _timeout:uint;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TInput</code>.
		 */
		public function TInput(defaultLabel:String = "", regTest:RegExp = null) {
			_regTest = regTest;
			super("input", new InputGraphic(), defaultLabel, "inputDefault", new Margin(4, 0, 4, 0));
			if(regTest != null) {
				_defaultSkin = background;
				_errorSkin = new InputErrorGraphic();
				addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

		private function focusOutHandler(event:FocusEvent):void {
			background = !_regTest.test(text)? _errorSkin : _defaultSkin;
			clearTimeout(_timeout);
			if(background == _errorSkin) {
				_timeout = setTimeout(resetBackground, 1000);
			}
		}

		private function resetBackground():void {
			background = _defaultSkin;
		}
		
	}
}