package fr.durss.thermal.components {
	import com.nurun.components.button.visitors.applyDefaultFrameVisitor;
	import com.nurun.trombi.graphics.CheckBoxSelectedGraphic;
	import com.nurun.trombi.graphics.CheckBoxDefaultGraphic;
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