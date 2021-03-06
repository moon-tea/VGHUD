package com.vrl.utils {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.*;
	
	import com.vrl.UIElement;
	import com.vrl.buttons.AbstractButton;
	
	/////////////////////
	// ScrollerMC Class //
	/////////////////////
	public class ScrollerMC extends UIElement {
	
		var target:Sprite;
		var track:Sprite;
		var handle:AbstractButton;
		var yOffset:Number;
		var TAB_SIZE:int;
		var stageRef:Stage;
		var scrollMax:int;
		var scrollIncrement:Number;
		
		/**
		* This class is actually just a sprite scroller. 
		* FIXME: We should abstract this class with Scroller to make them more more DRY
		*/	
		public function ScrollerMC(target:Sprite, TAB_SIZE:int, stageRef:Stage, windowHeight:Number) {
			
			this.target = target;
			this.TAB_SIZE = TAB_SIZE;
			this.stageRef = stageRef;
			
			//Track
			track = new Sprite();
			track.graphics.beginFill(0xcccccc, 0.1); 
			track.graphics.drawRect(0, 0, TAB_SIZE/2, windowHeight); 
			track.graphics.endFill();
			
			//Handle
			handle = new AbstractButton("", "", TAB_SIZE, TAB_SIZE);
			handle.color = 0x000000;
			handle.maxAlpha = 0.8;
			handle.minAlpha = 0.6;
			handle.currentAlpha = handle.minAlpha;
			handle.myHeight = TAB_SIZE/2;
			handle.myWidth = TAB_SIZE/2;
			handle.draw();
			scrollIncrement = 50;
			//A negative number
			//handle.graphics.beginFill(0x000000, 0.6); 
			//handle.graphics.drawRect(0, 0, TAB_SIZE/2, TAB_SIZE/2); 
			//handle.graphics.endFill();
			
			this.addEventListener (Event.ENTER_FRAME, sethandle);
			handle.addEventListener (MouseEvent.MOUSE_DOWN, startScroll);
			stageRef.addEventListener (MouseEvent.MOUSE_UP, stopScroll);
			addEventListener (Event.ENTER_FRAME, moveHandle);
			init();
		}
		
		public function init() {
			addChild(track);
			addChild(handle);
		}
		
		//set the height of the handle dynamically on enter frame
		public function sethandle (e:Event):void {
			//trace("doing this every frame");
			//get the ratio of the track to the max scroll of the textbox.
			var ratio:Number = track.height / target.height;
			//trace(ratio);
			if(ratio > 1.0) {
				handle.visible = false;
				track.visible = false;
			} else {
				handle.height = ratio * track.height; 
				handle.visible = true;
				track.visible = true;
				target.addEventListener (MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			}
			//assign the ratio to the height of the handle + 40 pixels, to give it a decent initial size. 
		}
		
		//set the position of the handle dynamically on enter frame
		public function moveHandle (e:Event):void {		
			var yMax:Number = track.height - handle.height;
			handle.y = (-1)*target.y;//(((target.y)*yMax)/target.height);
			if (handle.y <= 0) {
				handle.y = 0;
			} 
			if (handle.y >= yMax) {
				handle.y = yMax;
			}
		}
		
		//this is a mouse wheel handler for movieclips
		private function handleMouseWheel(e:MouseEvent):void {
			if (e.delta > 0 ) {
				doScrollUp();
			} else {
				doScrollDown();
			}
		}
		
		//This is a generic scroll up function
		private function doScrollUp() {
			if( target.y >= 0 ) {
				target.y = 0;
				//stage.removeEventListener(Event.ENTER_FRAME, doScrollUp);
			} else {
				target.y += scrollIncrement;
			}
			trace(target.y);
		}

		//This is a generic scroll down function
		private function doScrollDown() {
			scrollMax = (target.height * (-1)) + track.height;
			if( target.y <= scrollMax ) {
				target.y = scrollMax;
			} else {
				target.y -= scrollIncrement;
			}
			trace(target.y);
		}

		public function startScroll (e:MouseEvent):void {
			stageRef.addEventListener (MouseEvent.MOUSE_MOVE, handlemove);
			yOffset = mouseY - handle.y;
			handle.minAlpha = .8;
			handle.highlight();
			removeEventListener (Event.ENTER_FRAME, moveHandle);
		}
		
		public function stopScroll (e:MouseEvent):void {
			stageRef.removeEventListener (MouseEvent.MOUSE_MOVE, handlemove);
			handle.minAlpha = .6;
			handle.unHighlight();
			addEventListener (Event.ENTER_FRAME, moveHandle); 
		}
		
		public function handlemove (e:MouseEvent):void { 
			var yMin:Number = 0;
			var yMax:Number = track.height - handle.height;
			//this scrolls the text
			//target.y = -(handle.y * (target.height - yMax)/yMax) - target.y;
			target.y = (((handle.y - yMin)/yMax)*(target.height-track.height+TAB_SIZE/4))*-1;
			//Here, when scrolling is activated, and handle move...we then set the handle Y to the mouse Y - the
			//Y offset we made earlier to prevent snapping.
			handle.y = mouseY - yOffset; 
			
			if (handle.y <= yMin) {
				handle.y = yMin;
			} 
			if (handle.y >= yMax) {
				handle.y = yMax;
			}
		}
	}
}