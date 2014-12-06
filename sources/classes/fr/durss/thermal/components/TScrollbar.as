package fr.durss.thermal.components {

	import com.nurun.trombi.graphics.ScrollBackGraphic;
	import com.nurun.trombi.graphics.ScrolltrackButtonIconGraphic;
	import com.nurun.trombi.graphics.ScrolltrackButtonGraphic;
	import com.nurun.trombi.graphics.ScrollDownButtonGraphic;
	import com.nurun.components.scroll.scroller.scrollbar.Scrollbar;
	import com.nurun.components.scroll.scroller.scrollbar.ScrollbarClassicSkin;
	import com.nurun.trombi.graphics.ScrollUpButtonGraphic;
	
	/**
	 * 
	 * @author durss
	 * @date 15 sept. 2011;
	 */
	public class TScrollbar extends Scrollbar {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TScrollbar</code>.
		 */
		public function TScrollbar(resizeScroller:Boolean = true) {
			var skin:ScrollbarClassicSkin = new ScrollbarClassicSkin(
														new ScrollUpButtonGraphic(),
														new ScrollDownButtonGraphic(),
														new ScrolltrackButtonGraphic(),
														new ScrolltrackButtonIconGraphic(),
														new ScrollBackGraphic()
												);
			super(skin, resizeScroller);
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