package {
	
	import flash.display.Sprite;	
	import flash.display.MovieClip;
	import flash.display.Shape;	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.Font;
	import flash.text.TextFormat;
		
	/////////////////
	// Description //
	/////////////////
	/**
	 * The Accordian is one of many objects in a menu
	 *
	 * @category   root.menu.panel[]
	 * @package    src
	 * @author     Monte Nichols (Original Author) <monte.nichols.ii@gmail.com>
	 * @copyright  Virtual Reality Labs at the Center for Brainhealth
	 * @version    1.2 (12/29/2014)
	 */

	/////////////////
	// Accordian Class //
	/////////////////
	public class Accordian extends UIElement {
		
		var panelName:String;
		public var text:TextField;
		public var nextY:int = 0;
				
		public function Accordian(panelName:String, menuWidth:int, panelWidth:int, height:int, TAB_SIZE:Number, leftSide:Boolean):void {		
			//Variables that are not the default
			this.easing = .2;
			this.color = 0x222222;
			this.x = 0;
			this.y = 0;
			this.currentAlpha = .5;			
			this.visible = false;
			
			//This is needed for right/left side
			if(leftSide) {
				this.closeX = panelWidth*(-1);
				this.openX = menuWidth;
			} else {
				this.closeX = 0;
				this.openX = panelWidth*(-1);
			}
								
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = TAB_SIZE/2;
			myFormat.font = "Arial";
			//A title. This is fairly standard
			text = new TextField();
			text.text = panelName;
			text.textColor = 0xFFFFFF;
			text.x = 15;
			text.y = 15;
			text.width = panelWidth-text.x;
			text.embedFonts = true;  
			text.setTextFormat(myFormat);
			text.selectable = false;
			nextY = text.y + text.height/2;
			
			this.myWidth = panelWidth;
			this.myHeight = height;
			this.panelName = panelName;
			init();
		}
		
		private function init():void {
			addChild(text);
			draw();
		}
		
		public function addSureLabel(sureTitle:String, sureText:String, TAB_SIZE:Number) {
			var sureLabel:SureLabel = new SureLabel(sureTitle, sureText, TAB_SIZE);
			sureLabel.x = TAB_SIZE/2;	
			sureLabel.y = nextY;
			nextY = sureLabel.y + sureLabel.myHeight + TAB_SIZE/4;
			addChild(sureLabel);	
		}				
	}	
}