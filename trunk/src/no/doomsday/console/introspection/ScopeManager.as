package no.doomsday.console.introspection 
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ScopeManager
	{
		//private var cache:Dictionary = new Dictionary(true);
		private var _currentScope:IntrospectionScope = setScope( { } );
		private var _previousScope:IntrospectionScope;
		public function ScopeManager() 
		{
			
		}
		public function setScope(o:*):IntrospectionScope {
			if (!o) throw new ArgumentError("Invalid scope");
			var c:IntrospectionScope = new IntrospectionScope();
			c.autoCompleteDict = InspectionUtils.getAutoCompleteDictionary(o);
			c.children = TreeUtils.getChildren(o);
			c.accessors = InspectionUtils.getAccessors(o);
			c.methods = InspectionUtils.getMethods(o);
			c.variables = InspectionUtils.getVariables(o);
			c.obj = o;
			_currentScope = c;
			return _currentScope;
		}
		
		public function up():void {
			if (!_currentScope) return;
			if (_currentScope.obj is DisplayObject) {
				setScope(_currentScope.obj.parent);
			}
		}
		public function get currentScope():IntrospectionScope { return _currentScope; }
		
	}

}