package no.doomsday.console.introspection 
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ContextManager
	{
		//private var cache:Dictionary = new Dictionary(true);
		private var _currentContext:IntrospectionContext = setContext( { } );
		private var _previousContext:IntrospectionContext;
		public function ContextManager() 
		{
			
		}
		public function setContext(o:*):IntrospectionContext {
			var c:IntrospectionContext = new IntrospectionContext();
			c.autoCompleteDict = InspectionUtils.getAutoCompleteDictionary(o);
			c.children = TreeUtils.getChildren(o);
			c.accessors = InspectionUtils.getAccessors(o);
			c.methods = InspectionUtils.getMethods(o);
			c.variables = InspectionUtils.getVariables(o);
			c.obj = o;
			_currentContext = c;
			return _currentContext;
		}
		
		public function up():void {
			if (!_currentContext) return;
			if (_currentContext.obj is DisplayObject) {
				setContext(_currentContext.obj.parent);
			}
		}
		public function get currentContext():IntrospectionContext { return _currentContext; }
		
	}

}