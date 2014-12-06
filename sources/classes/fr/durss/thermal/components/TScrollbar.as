package fr.durss.thermal.components {
	import fr.durss.thermal.graphics.ScrollBackGraphic;
	import fr.durss.thermal.graphics.ScrollDownButtonGraphic;
	import fr.durss.thermal.graphics.ScrollUpButtonGraphic;
	import fr.durss.thermal.graphics.ScrolltrackButtonGraphic;
	import fr.durss.thermal.graphics.ScrolltrackButtonIconGraphic;

	import com.nurun.components.scroll.scroller.scrollbar.Scrollbar;
	import com.nurun.components.scroll.scroller.scrollbar.ScrollbarClassicSkin;
	
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