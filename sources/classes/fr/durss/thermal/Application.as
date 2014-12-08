package fr.durss.thermal {
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import com.nurun.utils.pos.roundPos;
	import fr.durss.thermal.graphics.GitIconGraphic;
	import fr.durss.thermal.components.TButton;
	import fr.durss.thermal.utils.initSerializableClasses;
	import gs.plugins.TransformAroundCenterPlugin;
	import gs.plugins.TweenPlugin;
	import fr.durss.thermal.controler.FrontControler;
	import fr.durss.thermal.model.Model;
	import fr.durss.thermal.views.GridView;
	import fr.durss.thermal.views.ModeView;
	import fr.durss.thermal.views.OutputPanelView;
	import fr.durss.thermal.views.ToolsView;

	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author Durss
	 * @date 6 déc. 2014;
	 */
	 
	[SWF(width="1280", height="600", backgroundColor="0xFFFFFF", frameRate="31")]
	[Frame(factoryClass="fr.durss.thermal.ApplicationLoader")]
	public class Application extends MovieClip {
		private var _model : Model;
		private var _git : TButton;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function Application() {
			initialize();
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
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			initSerializableClasses();
			
			TweenPlugin.activate([TransformAroundCenterPlugin]);
			
			_model = new Model();
			FrontControler.getInstance().initialize(_model);
			ViewLocator.getInstance().initialise(_model);
			
			addChild(new GridView());
			addChild(new ToolsView());
			addChild(new OutputPanelView());
			addChild(new ModeView());
			_git = addChild(new TButton('View on Github', 'button', new GitIconGraphic())) as TButton;
			_git.filters = [new DropShadowFilter(0,0,0,.3,5,5,1,2)]
			
//			_form.addEventListener(Event.CHANGE, changeFormDataHandler);
//			_form.addEventListener(Event.CLEAR, clearGridHandler);
//			_font.addEventListener(FormComponentEvent.SUBMIT, generateFromFontHandler);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_git.addEventListener(MouseEvent.CLICK, clickGitHandler);
		}

		private function clickGitHandler(event : MouseEvent) : void {
			navigateToURL(new URLRequest('https://github.com/Durss/Thermal-printer-char-generator'), '_blank');
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			
			_model.start();
			
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginFill(0xF5F5F5, 1);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			_git.y = stage.stageHeight - _git.height;
			roundPos(_git);
		}
		
	}
}