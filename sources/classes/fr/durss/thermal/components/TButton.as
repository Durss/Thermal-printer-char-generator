package fr.durss.thermal.components {
	import com.nurun.graphics.common.LoaderSpinningSmallGraphic;
	import com.nurun.components.button.visitors.FrameVisitorOptions;
	import com.nurun.components.button.IconAlign;
	import flash.display.DisplayObject;
	import com.nurun.components.vo.Margin;
	import flash.display.MovieClip;
	import com.nurun.components.button.visitors.FrameVisitor;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.trombi.graphics.ButtonGraphic;
	import com.nurun.components.button.BaseButton;
	
	/**
	 * 
	 * @author durss
	 * @date 15 sept. 2011;
	 */
	public class TButton extends BaseButton {
		private var _spin:LoaderSpinningSmallGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TButton</code>.
		 */
		public function TButton(label:String, css:String = "button", icon:DisplayObject = null, back:Boolean = true) {
			super(label, css, back? new ButtonGraphic() : null, icon);
			var fv:FrameVisitor = new FrameVisitor();
			var options:FrameVisitorOptions = new FrameVisitorOptions("out", "over", "down", "disabled", true, .25);
			options.pressFrameFrom = "down";
			if(back) fv.addTarget(background as MovieClip, options);
			if(icon != null && icon is MovieClip) {
				iconAlign = IconAlign.LEFT;
				iconSpacing = 10;
				fv.addTarget(icon as MovieClip);
			}
			accept(fv);
			accept(new CssVisitor());
			contentMargin = new Margin(back? 12 : 0, 4, back? 12 : 0, 4);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function set spinMode(value:Boolean):void {
			if(_spin == null) {
				_spin = new LoaderSpinningSmallGraphic();
			}
			enabled = !value;
			if(value) {
				addChild(_spin);
			}else if(contains(_spin)){
				removeChild(_spin);
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function computePositions():void {
			super.computePositions();
			if(_spin !=null) {
				_spin.x = width * .5;
				_spin.y = height * .5;
			}
		}
		
	}
}