package com.vrl.controls {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Shape;	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import flash.events.TimerEvent;	
	import flash.utils.Timer;
	
	import com.vrl.UIElement;
	import com.vrl.TabInfo;	
	import com.vrl.buttons.Tab;	
	import com.vrl.panels.Panel;	
	import com.vrl.panels.AvatarPanel;	
	import com.vrl.panels.ChatPanel;	
	
	////////////////
	// Menu Class //
	////////////////
	public class Menu extends UIElement {
		
		//Properties
		public var menuPeekX:int; 
		public var menuPeekY:int;
		//variables
		public var currentPanel:String = "";
		var outPanel:String = "";
		var activePanel:String="";
		var TAB_SIZE:Number;
		var addOne:Function;
		var deleteOne:Function;
		
		//Objects
		public var tabs:Array = new Array();
		public var panels:Array = new Array();
		public var buffer:Array = new Array();
		var panelMasks:Array = new Array();
		
		//Menu initializes objects and gives them values
		public function Menu(width:int, height:int, tabInfos:Array, TAB_SIZE:Number, leftSide:Boolean, stageRef:Stage):void {
			//Set up paramaters that differ from the default
			this.easing = .25;
			this.myWidth = width;
			this.myHeight = height;
			this.currentAlpha = .5;
			this.TAB_SIZE = TAB_SIZE;
			this.tabChildren = false;
						
			//This variable is used with the menu is on the left or right. 
			//It isn't very elegant. Maybe we can do away with the Bool all together
			//FIXME: Time permiting, try to make this more elegant 
			var pos:int = -1;
			if(leftSide) {
				pos = 1;
			}
			
			draw();
			//This variable will be incremented to put the tabs in vertical order						
			var tabY:Number = 0;
			var tabNumber = 1;
			for each(var tabInfo:TabInfo in tabInfos) {
				
				//A series of tabs is generated based on the list of tab names
				var tab = new Tab(tabInfo.name, tabInfo.title, tabInfo.name, width, TAB_SIZE, tabInfo.leftSide, tabInfo.scaleForm, tabInfo.accordian);
				tab.x = 0;
				tab.y = tabY;
				
				tabs.push(tab);
				
				//Accordians need panels
				if(tabInfo.accordian) {
					//add event listener for tabs with accordians
					tab.addEventListener(MouseEvent.CLICK, tabAccordian(tabInfo.name));
					//set up a panel mask
					var panelMask:Sprite = new Sprite();
					panelMask.graphics.beginFill(0xffFF00, .2); 
					panelMask.graphics.drawRect(0, 0, width, TAB_SIZE);//height-TAB_SIZE*tabInfos.length); 
					panelMask.graphics.endFill(); 
					panelMask.x = 0;
					panelMask.y = tab.y + tab.myHeight;
										 
					//set up a panel
					var panel = new Panel(tabInfo.name, width, TAB_SIZE, TAB_SIZE, tabInfo.leftSide, true, stageRef, height-TAB_SIZE*(tabInfos.length));
					if(tabInfo.name == "Chat") {
						panel = new ChatPanel(tabInfo.name, myWidth, myHeight-TAB_SIZE*tabInfos.length, TAB_SIZE, tabInfo.leftSide, true, stageRef);
						panelMask.height = myHeight-TAB_SIZE*tabInfos.length;
					}
					panel.x = 0;
					panel.y = tab.y + tab.myHeight - panel.myHeight;
					panel.closeY = panel.y;
					panel.openY = panel.y + panel.myHeight;
					panel.tabNumber = tabNumber;
					panel.mask = panelMask;
					panelMasks[tabInfo.name] = panelMask;
					panels[tabInfo.name] = panel;
				}
				
				if(tabInfo.peek) {
					//Add Event Listen
					tab.addEventListener(MouseEvent.CLICK, tabAccordian(tabInfo.name));
					//A mask for the panels
					panelMask = new Sprite();
					panelMask.graphics.beginFill(0xffFF00); 
					panelMask.graphics.drawRect(0, 0, TAB_SIZE*17, height); 
					panelMask.graphics.endFill(); 
					panelMask.x = panelMask.width*(-1);
					panelMask.y = 0;
					
					//This creates a series of panels. 				
					var panel = new AvatarPanel(tabInfo.name, TAB_SIZE*17, height, TAB_SIZE, tabInfo.leftSide, false, stageRef, panelMask.height);			
					panel.x = 0;
					panel.y = 0;
					panel.closeX = panel.x;
					panel.openX = panel.x - panelMask.width;
					panel.tabNumber = tabNumber;
					panel.mask = panelMask;
					panelMasks[tabInfo.name] = panelMask;
					panels[tabInfo.name] = panel;
					
				}
				
				tab.maxOpenY = tab.y+height-TAB_SIZE*tabInfos.length;
				tab.minCloseY = tab.y;
				tabY += TAB_SIZE+1;
				tabNumber++;
			}
			
			init();
		}
		
		//Init Adds resources to stage and sets up initial event listeners
		private function init():void {
			for (var ke:String in panelMasks){
				addChild(panelMasks[ke]);
			}
			for (var key:String in tabs){
				//trace(key);
				addChild(tabs[key]);
				tabs[key].draw();
			}
			for (var k:String in panels){
				addChild(panels[k]);
			}
		}
		
		//Accordian tabs do some very special things, so this is our function for that
		private function tabAccordian(panelName:String):Function {
			return function(e:MouseEvent):void {
				for each(var tab:Tab in tabs) {
					//If the tab -> currentPanel, we close it
					if(tab.id == currentPanel) {
						tab.minAlpha = 0.0;
						//tab.setShadow = true;
						tab.unHighlight();
						tab.rotateIconUp();
					}
					//If the tab -> is our panel, let's open the panel
					if(tab.id == panelName) {
						if(tab.minAlpha < 0.5) {
							tab.minAlpha = 0.5;
							tab.unHighlight();
						}
						tab.rotateIconDown();
					}
					//If we have another tab open, let's unhighlight it.
					if(currentPanel == panelName)  {
						tab.minAlpha = 0.0;
						tab.unHighlight();
						tab.rotateIconUp();
					}
				}
				//Try to animate something out, before we animate something in
				animateOut(panelName);
			};
		}
		
		public function animateOut(panelName:String):void {
			//If no current panel, just open the panel and make it the current
			if(currentPanel == "") {
				currentPanel = panelName;
				animateIn();
			} else {
				outPanel = currentPanel;
				panels[outPanel].moveY = panels[outPanel].closeY;
				panels[outPanel].moveX = panels[outPanel].closeX;
				if(!hasEventListener(Event.ENTER_FRAME)) {
					activePanel = outPanel;
					if(panels[outPanel].verticalMover) {
						addEventListener(Event.ENTER_FRAME, onEasePanelY);
					} else {
						addEventListener(Event.ENTER_FRAME, onEasePanelX);
					}
					//onEaseOut = onEasePanelY(outPanel);
					//addEventListener(Event.ENTER_FRAME, onEaseOut);
				}
				//if the current panel is the one we clicked, close it and set the state to stable
				if(currentPanel == panelName)  {
					currentPanel = "";
				} else {
				//if not, get ready to close the panel
					currentPanel = panelName;
				}
			}
		}
		
		//Only called once it knows everything else was animated out
		//or didn't need to be animated out
		public function animateIn():void {
			//trace("Animate in: " + currentPanel);
			panels[currentPanel].visible = true;
			panels[currentPanel].moveY = panels[currentPanel].openY;
			panels[currentPanel].moveX = panels[currentPanel].openX;
			if(!hasEventListener(Event.ENTER_FRAME)) {
				activePanel = currentPanel;
				if(panels[activePanel].verticalMover) {
					addEventListener(Event.ENTER_FRAME, onEasePanelY);
				} else {
					addEventListener(Event.ENTER_FRAME, onEasePanelX);					
				}
				//onEaseIn = onEasePanelY(currentPanel);
				//addEventListener(Event.ENTER_FRAME, onEasePanelY);
			}
		}
		
		//This handles closing the Panel frame by frame, until is it done 
		//This is arbitrary Y movement, but could allow for any type of movement
		public function onEasePanelY(e:Event):void {
			trace(panels[activePanel].frameCounter + " -- " + (panels[activePanel].moveX - x) * panels[activePanel].easing);
			//My distance = (where I want to go) - where I am
			panels[activePanel].dy = ( panels[activePanel].moveY - panels[activePanel].y);
			//If where I want to go is less than 1, I will stay there
			//Otherwise move a proportional distance to my target "easing" my way there
			if(Math.abs(panels[activePanel].dy) < 1) {
				if(panels[activePanel].dy < 0) {
					removeEventListener(Event.ENTER_FRAME, onEasePanelY);
					panels[activePanel].visible = false;
					if(currentPanel != "") {
						animateIn();
					}
				} else {
					/*
					panels[activePanel].graphics.lineStyle(1, 0x00FF00, .75);
					panels[activePanel].graphics.moveTo(panels[activePanel].labelContainer.x, 			panels[activePanel].labelContainer.y); 
					panels[activePanel].graphics.lineTo(panels[activePanel].labelContainer.width, 	panels[activePanel].labelContainer.y); 
					panels[activePanel].graphics.lineTo(panels[activePanel].labelContainer.width, 	panels[activePanel].labelContainer.height); 
					panels[activePanel].graphics.lineTo(panels[activePanel].labelContainer.x, 			panels[activePanel].labelContainer.height); 
					panels[activePanel].graphics.lineTo(panels[activePanel].labelContainer.x, panels[activePanel].labelContainer.y); panels[activePanel].graphics.lineStyle(1, 0x00FF00, .75);
					
					panels[activePanel].graphics.lineStyle(1, 0xFFFF00, .75);
					panels[activePanel].graphics.moveTo(panels[activePanel].mask.x, 			panels[activePanel].mask.y); 
					panels[activePanel].graphics.lineTo(panels[activePanel].mask.width, 	panels[activePanel].mask.y); 
					panels[activePanel].graphics.lineTo(panels[activePanel].mask.width, 	panels[activePanel].mask.height); 
					panels[activePanel].graphics.lineTo(panels[activePanel].mask.x, 			panels[activePanel].mask.height); 
					panels[activePanel].graphics.lineTo(panels[activePanel].mask.x, panels[activePanel].mask.y); 
					*/
					removeEventListener(Event.ENTER_FRAME, onEasePanelY);
				}
				//removeEventListener(Event.ENTER_FRAME, arguments.callee);
				panels[activePanel].frameCounter = 0;
			} else {
				var limit:Number;
				var compare:Boolean;
				var startingPoint:int = panels[activePanel].tabNumber * -1;
				var newPos:int;
				panels[activePanel].y += panels[activePanel].dy * panels[activePanel].easing;
				for(var i:int = panels[activePanel].tabNumber; i < tabs.length; i++) {
					if(panels[activePanel].dy < 0) {
						limit = tabs[i].minCloseY;
						compare = tabs[i].y > limit;
						newPos = panels[activePanel].y + panels[activePanel].myHeight + tabs[i].height*2*(startingPoint+i) * panels[activePanel].easing;
					} else {
						limit = tabs[i].maxOpenY;
						compare = tabs[i].y < limit;
						newPos = tabs[i].y + (panels[activePanel].dy + TAB_SIZE/16) * panels[activePanel].easing;
					}
					//trace("move tab " + i)
					if(compare) {
						tabs[i].y = newPos;//panels[activePanel].y + panels[activePanel].myHeight + tabs[i].height*2*(startingPoint+i) * panels[activePanel].easing;
					} else {
						tabs[i].y = limit;
					}
				}
			}
			panels[activePanel].frameCounter++;
		}
		
		//This handles closing the Panel frame by frame, until is it done 
		//This is arbitrary Y movement, but could allow for any type of movement
		public function onEasePanelX(e:Event):void {
			//trace(panels[activePanel].frameCounter + " moveX: " + (panels[activePanel].moveX) + " x: " + (panels[activePanel].x));
			//My distance = (where I want to go) - where I am
			panels[activePanel].dx = ( panels[activePanel].moveX - panels[activePanel].x);
			//If where I want to go is less than 1, I will stay there
			//Otherwise move a proportional distance to my target "easing" my way there
			if(Math.abs(panels[activePanel].dx) < 1) {
				if(panels[activePanel].dx > 0) {
					removeEventListener(Event.ENTER_FRAME, onEasePanelX);
					panels[activePanel].visible = false;
					if(currentPanel != "") {
						animateIn();
					}
				} else {
					removeEventListener(Event.ENTER_FRAME, onEasePanelX);
				}
				//removeEventListener(Event.ENTER_FRAME, arguments.callee);
				panels[activePanel].frameCounter = 0;
			} else {
				panels[activePanel].x += panels[activePanel].dx * panels[activePanel].easing;
			}
			panels[activePanel].frameCounter++;
		}
		
		//This adds a label to a panel
		public function addToList(id:String, labelName:String, panelName:String, buttonText:String, onClick:Function):void {
			//if(!panels[panelName].labels.hasOwnProperty(labelName)) {
				var lastTabNum:int = tabs.length-1;
				if( panels[panelName].visible == true) {
					if(!hasEventListener(Event.ENTER_FRAME)) {
						panels[panelName].addButtonLabel(id, labelName, buttonText, onClick, TAB_SIZE);
						tabs[lastTabNum].openY = tabs[lastTabNum].y+TAB_SIZE * 5/4;	
						tabs[lastTabNum].moveY = tabs[lastTabNum].openY;
						addOne = squish( true, id, panelName);
						addEventListener(Event.ENTER_FRAME, addOne);
					} else {
						var tryThatAgain:Function = tryAgain(arguments.callee, id, labelName, panelName, buttonText, onClick);
						buffer.push(tryThatAgain);
					}
				} else {
					panels[panelName].addButtonLabel(id, labelName, buttonText, onClick, TAB_SIZE);
				}
			//}
		}
		
		//This is a buffer that tries to run a function over and over again until 
		//there is not an enterframe anymore
		public function tryAgain(callee:Function, id:String, labelName:String, panelName:String, buttonText:String = "", onClick:Function = null):Function {
			return function(/*e:TimerEvent*/):void {
				if(onClick != null){
					callee(id, labelName, panelName, buttonText, onClick);
				} else {
					callee(id, labelName, panelName);
				}
				//addPlayertoPlayerList(labelName, panelName);
			}
		}
		
		//This removes a label from a list
		public function deleteFromList(id:String, labelName:String, panelName:String):void {
			//trace("panels[panelName].labels.hasOwnProperty(labelName): " + panels[panelName].labels.hasOwnProperty(labelName));
			for (var key:String in panels[panelName].labels){
				if(key == id) {
					var lastTabNum:int = tabs.length-1;
					if(!hasEventListener(Event.ENTER_FRAME)) {
						panels[panelName].removeButtonLabel(id);
						tabs[lastTabNum].openY = tabs[lastTabNum].y-TAB_SIZE * 5/4;	
						tabs[lastTabNum].moveY = tabs[lastTabNum].openY;
						if( panels[panelName].visible == true) {
							deleteOne = squish( false, id, panelName);
							addEventListener(Event.ENTER_FRAME, deleteOne);
						}
					} else {
						// AS3
						var tryThatAgain:Function = tryAgain(arguments.callee, id, labelName, panelName);
						buffer.push(tryThatAgain);
						//var myTimer:Timer = new Timer(100, 1); // .1 second
						//myTimer.addEventListener(TimerEvent.TIMER, tryThatAgain);
						//myTimer.start();
					}
				}
			}
		}
		
		//This removes a label from a list
		public function isInList(id:String, labelName:String, panelName:String):Boolean {
			//trace("panels[panelName].labels.hasOwnProperty(labelName): " + panels[panelName].labels.hasOwnProperty(labelName));
			trace(id);
			for (var key:String in panels[panelName].labels){
				if(key == id) {
					//trace("yes");
					return true;
				}
			}
			return false;
		}
				
		//This squishes tabs up or down based on the neighbor tabs.
		public function squish(isAdding:Boolean, id:String, panelName:String):Function {
			return function():void {
				//trace(( tabs[tabs.length-1].moveY - tabs[tabs.length-1].y));
				//My distance = (where I want to go) - where I am
				var lastTabNum:int = tabs.length-1;
				tabs[lastTabNum].dy = ( tabs[lastTabNum].moveY - tabs[lastTabNum].y);
				//If where I want to go is less than 1, I will stay there
				//Otherwise move a proportional distance to my target "easing" my way there
				if(Math.abs(tabs[lastTabNum].dy) < 1) {
					for(var i:int = panels[panelName].tabNumber; i < tabs.length; i++) {
						//trace("move tab " + i)
						//tabs[i].y = tabs[i].openY;
					}
					if(isAdding == true) {
						panels[panelName].labels[id].visible = true;
						removeEventListener(Event.ENTER_FRAME, addOne);
						
					} else {
						removeEventListener(Event.ENTER_FRAME, deleteOne);							
					}
					if(buffer.length != 0){
						buffer[0]();
						buffer.shift();	
					}
				} else {
					//panels[currentPanel].y += panels[currentPanel].dy * panels[currentPanel].easing;
					for(var i:int = lastTabNum; i >= panels[panelName].tabNumber; i--) {
						//trace("move tab " + i)
						trace(tabs[i].y < tabs[i].maxOpenY);
						if(tabs[i].y < tabs[i].maxOpenY) {
							tabs[i].y += tabs[lastTabNum].dy * tabs[lastTabNum].easing;
						} else {
							tabs[i].y = tabs[i].maxOpenY;
							tabs[i].moveY = tabs[i].y;
						}
					}
				}
			}
		}
	}
}