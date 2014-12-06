package fr.durss.thermal.components {
	import fr.durss.thermal.graphics.CheckBoxDefaultGraphic;
	import fr.durss.thermal.graphics.CheckBoxSelectedGraphic;

	import com.nurun.components.button.visitors.applyDefaultFrameVisitor;
	import com.nurun.components.form.Checkbox;
	
	/**
	 * 
	 * @author durss
	 * @date 18 juin 2012;
	 */
	public class TCheckBox extends Checkbox {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TCheckBox</code>.
		 */
		public function TCheckBox(label:String) {
			super(label, "checkbox", "checkbox_selected", new CheckBoxDefaultGraphic(), new CheckBoxSelectedGraphic());
			applyDefaultFrameVisitor(this, _selectedIcon, _defaultIcon);
			yLabelOffset = -2;
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