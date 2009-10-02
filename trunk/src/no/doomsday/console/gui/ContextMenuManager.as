package no.doomsday.console.gui 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import no.doomsday.console.controller.ControllerManager;
	import no.doomsday.console.DConsole;
	import no.doomsday.console.introspection.ScopeManager;
	import no.doomsday.console.measurement.MeasurementTool;
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
			consoleMenu.customItems.push(logItem, screenshotItem, toggleDisplayItem);
			console.contextMenu = consoleMenu;
			
			if (!shortcuts) return;
			var selectionMenuItem:ContextMenuItem = new ContextMenuItem("Set console scope", true);
			selectionMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSelectionMenu,false,0,true);
			var controllerMenuItem:ContextMenuItem = new ContextMenuItem("Create controller");
			controllerMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onControllerMenu,false,0,true);
			var referenceMenuItem:ContextMenuItem = new ContextMenuItem("Create reference");
			referenceMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onReferenceMenu,false,0,true);
			var measureMenuItem:ContextMenuItem = new ContextMenuItem("Get measures");
			measureMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMeasureMenu,false,0,true);
			if (!console.parent.contextMenu) {
				console.parent.contextMenu = new ContextMenu();
			}
			console.parent.contextMenu.customItems.push(selectionMenuItem);
			console.parent.contextMenu.customItems.push(controllerMenuItem);
			console.parent.contextMenu.customItems.push(referenceMenuItem);
			console.parent.contextMenu.customItems.push(measureMenuItem);
		}
		
		private function onMeasureMenu(e:ContextMenuEvent):void 
		{
			if (e.mouseTarget is DisplayObject) {
				console.show();
				measureBracket.bracket(e.mouseTarget);
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