package no.doomsday.console.gui 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.ui.ContextMenuItem;
	import no.doomsday.console.controller.ControllerManager;
	import no.doomsday.console.DConsole;
	import no.doomsday.console.introspection.ScopeManager;
	import no.doomsday.console.measurement.MeasurementTool;
	import no.doomsday.console.messages.MessageTypes;
	import no.doomsday.console.references.ReferenceManager;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ContextMenuManager
	{
		private var console:DConsole;
		private var referenceManager:ReferenceManager;
		private var scopeManager:ScopeManager;
		private var controllerManager:ControllerManager;
		private var consoleMenu:ContextMenu;
		private var measureBracket:MeasurementTool;
		public function ContextMenuManager(console:DConsole,scopeManager:ScopeManager,referenceManager:ReferenceManager,controllerManager:ControllerManager,measureBracket:MeasurementTool) 
		{
			this.measureBracket = measureBracket;
			this.console = console;
			this.scopeManager = scopeManager;
			this.referenceManager = referenceManager;
			this.controllerManager = controllerManager;
		}
		public function setUpMenuItems(shortcuts:Boolean = true):void {
			consoleMenu = new ContextMenu();
			var logItem:ContextMenuItem = new ContextMenuItem("Log");
			logItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, console.log);
			var screenshotItem:ContextMenuItem = new ContextMenuItem("Screenshot");
			screenshotItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, console.screenshot);
			var toggleDisplayItem:ContextMenuItem = new ContextMenuItem("Hide");
			toggleDisplayItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, console.toggleDisplay);
			var toggleStatsItem:ContextMenuItem = new ContextMenuItem("Performance stats");
			toggleStatsItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, console.toggleStats);
			consoleMenu.customItems.push(logItem, screenshotItem, toggleStatsItem, toggleDisplayItem);
			var bi:ContextMenuBuiltInItems = consoleMenu.builtInItems;
			bi.forwardAndBack = bi.loop = bi.play = bi.print = bi.quality = bi.rewind = bi.save = bi.zoom = false;
			console.contextMenu = consoleMenu;
			
			if (!shortcuts) return;
			var toggleMenuItem:ContextMenuItem = new ContextMenuItem("Toggle console", true);
			toggleMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onConsoleToggle,false,0,true);
			var selectionMenuItem:ContextMenuItem = new ContextMenuItem("Set console scope", true);
			selectionMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSelectionMenu,false,0,true);
			var controllerMenuItem:ContextMenuItem = new ContextMenuItem("Create controller");
			controllerMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onControllerMenu,false,0,true);
			var referenceMenuItem:ContextMenuItem = new ContextMenuItem("Create reference");
			referenceMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onReferenceMenu,false,0,true);
			var measureMenuItem:ContextMenuItem = new ContextMenuItem("Get measurements");
			measureMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMeasureMenu,false,0,true);
			if (!console.parent.contextMenu) {
				var newMenu:ContextMenu = new ContextMenu();
				bi = newMenu.builtInItems;
				bi.forwardAndBack = bi.loop = bi.play = bi.print = bi.quality = bi.rewind = bi.save = bi.zoom = false;
				console.parent.contextMenu = newMenu;
				
				
			}
			console.parent.contextMenu.customItems.push(toggleMenuItem);
			console.parent.contextMenu.customItems.push(selectionMenuItem);
			console.parent.contextMenu.customItems.push(controllerMenuItem);
			console.parent.contextMenu.customItems.push(referenceMenuItem);
			console.parent.contextMenu.customItems.push(measureMenuItem);
		}
		
		private function onConsoleToggle(e:ContextMenuEvent):void 
		{
			console.toggleDisplay();
		}
		
		private function onMeasureMenu(e:ContextMenuEvent):void 
		{
			if (e.mouseTarget is DisplayObject) {
				if (e.mouseTarget != console.root) {
					measureBracket.bracket(e.mouseTarget);
				}else {
					console.print("Unable to bracket root", MessageTypes.ERROR);
				}
				console.show();
			}
		}
		private function onReferenceMenu(e:ContextMenuEvent):void 
		{
			if (e.mouseTarget is DisplayObject) {
				console.show();
				referenceManager.createReference(e.mouseTarget);
			}
		}
		
		private function onControllerMenu(e:ContextMenuEvent):void 
		{
			if (e.mouseTarget is DisplayObject) {
				console.show();
				if (e.mouseTarget == console.root) {
					console.print("Unable to create default controller for root", MessageTypes.ERROR);
					return;
				}
				scopeManager.setScope(e.mouseTarget);
				var properties:Array = ["name","x", "y", "width", "height", "rotation", "scaleX", "scaleY"];
				controllerManager.createController(scopeManager.currentScope.obj, properties, e.mouseTarget.x, e.mouseTarget.y);
				console.print("Controller created. Type values to alter, or use the mousewheel on numbers.");
			}
		}
		
		private function onSelectionMenu(e:ContextMenuEvent):void 
		{
			scopeManager.setScope(e.mouseTarget);
		}
		
	}

}