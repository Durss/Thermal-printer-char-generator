package fr.durss.thermal.components {
	import fr.durss.thermal.graphics.ButtonGraphic;
	import fr.durss.thermal.graphics.ButtonSelectedGraphic;

	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.FrameVisitor;
	import com.nurun.components.button.visitors.FrameVisitorOptions;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.components.vo.Margin;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	/**
	 *
	 * @author durss
	 * @date 7 mars 2012;
	 */
	public class TToggleButton extends ToggleButton {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TToggleButton</code>.
		 */
		public function TToggleButton(label:String, css:String = "button", icon:DisplayObject = null) {
			super(label, css, css+"_selected", new ButtonGraphic(), new ButtonSelectedGraphic(), icon, icon);
			var fv:FrameVisitor = new FrameVisitor();
			var options:FrameVisitorOptions = new FrameVisitorOptions("out", "over", "down", "disabled", true, .25);
			fv.addTarget(defaultBackground as MovieClip, options);
			fv.addTarget(selectedBackground as MovieClip, options);
			
			if(icon != null && icon is MovieClip) {
				iconAlign = IconAlign.LEFT;
				iconSpacing = 10;
				fv.addTarget(icon as MovieClip);
			}
			accept(fv);
			accept(new CssVisitor());
			contentMargin = new Margin(12, 4, 12, 4);
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
		
	}
}