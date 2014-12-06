package fr.durss.thermal.components {
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.visitors.FrameVisitor;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	/**
	 * 
	 * @author durss
	 * @date 15 sept. 2011;
	 */
	public class TGraphicButton extends GraphicButton {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TGraphicButton</code>.
		 */
		public function TGraphicButton(background:DisplayObject) {
			super(background);
			if(background is MovieClip) {
				var fv:FrameVisitor = new FrameVisitor();
				fv.addTarget(background as MovieClip);
				accept(fv);
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
		
	}
}