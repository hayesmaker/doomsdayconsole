package com.furusystems.dconsole2.plugins.controller 
{
	import flash.display.Sprite;
	import com.furusystems.dconsole2.core.introspection.ScopeManager;
	import com.furusystems.dconsole2.core.plugins.IUpdatingDConsolePlugin;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class ControllerUtil extends Sprite implements IUpdatingDConsolePlugin
	{
		private var _controllers:Vector.<Controller> = new Vector.<Controller>;
		private var _scopeManager:ScopeManager;
		public function ControllerUtil() 
		{
		}
		
		internal function addController(object:*, properties:Array,x:Number = 0,y:Number = 0):void {
			var c:Controller = new Controller(object, properties, this);
			c.x = x;
			c.y = y;
			_controllers.push(addChild(c) as Controller);
		}
		internal function removeController(c:Controller):void {
			for (var i:int = 0; i < _controllers.length; i++) 
			{
				if (_controllers[i] == c) {
					_controllers.splice(i, 1);
					removeChild(c);
					break;
				}
			}
		}
		
		private function createController(...properties:Array):void
		{
			addController(_scopeManager.currentScope.targetObject, properties, 0, 0);
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.plugins.IDConsolePlugin */
		
		public function initialize(pm:PluginManager):void
		{
			pm.topLayer.addChild(this);
			pm.console.createCommand("createController", createController, "Controller", "Create a widget for changing properties on the current scope (createController width height for instance)");
			_scopeManager = pm.scopeManager;
		}
		
		public function shutdown(pm:PluginManager):void
		{
			pm.topLayer.removeChild(this);
			pm.console.removeCommand("createController");
			_scopeManager = null;
		}
		
		public function update(pm:PluginManager):void
		{
			for each(var c:Controller in _controllers) {
				c.update();
			}
		}
		
		public function get descriptionText():String
		{
			return "Enables the creation of GUI widgets for interactive alteration of properties";
		}
		
				
		public function get dependencies():Vector.<Class> 
		{
			return new Vector.<Class>();
		}
		
	}

}