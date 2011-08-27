package com.furusystems.dconsole2.plugins.inspectorviews.treeview 
{
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import com.furusystems.dconsole2.core.inspector.AbstractInspectorView;
	import com.furusystems.dconsole2.core.interfaces.IThemeable;
	import com.furusystems.dconsole2.core.Notifications;
	import com.furusystems.dconsole2.core.plugins.PluginManager;
	import com.furusystems.dconsole2.core.style.Alphas;
	import com.furusystems.dconsole2.core.style.Colors;
	import com.furusystems.dconsole2.core.style.GUIUnits;
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.dconsole2.plugins.inspectorviews.treeview.buttons.EyeDropperButton;
	import com.furusystems.dconsole2.plugins.inspectorviews.treeview.dfs.DFS;
	import com.furusystems.dconsole2.plugins.inspectorviews.treeview.noderenderers.ListNode;
	/**
	 * ...
	 * @author Andreas Roenning
	 */
	public class TreeViewUtil extends AbstractInspectorView implements IRenderable,IThemeable
	{
		private var _console:DConsole;
		
		protected var _root:DisplayObjectContainer;
		protected var _rootNode:ListNode;
		
		protected var _mouseSelectButton:EyeDropperButton;
		public function TreeViewUtil() 
		{
			PimpCentral.addCallback(Notifications.THEME_CHANGED, onThemeChange);
			_mouseSelectButton = new EyeDropperButton();
			//addChild(_mouseSelectButton).y = 2; //TODO: Show button when functionality implemented
			_mouseSelectButton.addEventListener(MouseEvent.MOUSE_DOWN, activateMouseSelect);
		}
		
		private function activateMouseSelect(e:MouseEvent):void 
		{
			
		}
		public function setSelection(node:ListNode):void {
			scrollTo(node);
		}
		public function render():void
		{
			if (!_rootNode) return;
			var rect:Rectangle = inspector.dims.clone();
			rect.height -= GUIUnits.SQUARE_UNIT;
			scrollRect = rect;
			_rootNode.render();
			graphics.clear();
			graphics.beginFill(Colors.TREEVIEW_BG, Alphas.TREEVIEW_BG_ALPHA);
			graphics.drawRect(0, 0, scrollRect.width, scrollRect.height);
		}
		
		public function set rootNode(value:DisplayObjectContainer):void 
		{
			if (_rootNode) _scrollableContent.removeChild(_rootNode);
			_rootNode = new ListNode(value, null, this);
			_scrollableContent.addChildAt(_rootNode, 0);
			render();
			scrollByDelta(0, 0);
		}
		override public function scrollByDelta(x:Number, y:Number):void 
		{
			if (!_rootNode) return;
			super.scrollByDelta(x, y);
		}
		override public function get maxScrollY():Number {
			var rect:Rectangle = _rootNode.transform.pixelBounds;
			return rect.height-scrollRect.height;
		}
		override public function get maxScrollX():Number {
			var rect:Rectangle = _rootNode.transform.pixelBounds;
			return rect.width-scrollRect.width;
		}
		override protected function calcBounds():Rectangle 
		{
			return _bounds = _rootNode.transform.pixelBounds;
		}
		override protected function onShow():void 
		{
			populate(stage);	
			if (_console.currentScope.targetObject is DisplayObject) {
				if (DisplayObject(_console.currentScope.targetObject).stage) {
					select(DisplayObject(_console.currentScope.targetObject));
				}
			}
			super.onShow();
		}
		public function select(target:DisplayObject):void {
			var node:ListNode;
			if (ListNode.table[target] != null) {
				//not found
				node = ListNode.table[target];
			}else {
				node = DFS.search(target, _rootNode);
			}
			collapseAll();
			if (!node) return;
			while (node.parentNode != null) {
				node = node.parentNode;
				node.expanded = true;
			}
			render();
			scrollTo(ListNode.table[target]);
		}
		public function collapseAll():void {
			for each (var node:ListNode in ListNode.table) 
			{
				node.expanded = false;
			}
		}
		public function scrollTo(node:ListNode):void {
			//TODO: Refine targeting; Target should be framed center
			var rect:Rectangle = node.getRect(this);
			var s:Rectangle = scrollRect;
			var diffX:Number = rect.x - (s.x + s.width * .5);
			var diffY:Number = (rect.y +node.firstLevelHeight * .5) - (s.y + s.height * .5);
			scrollByDelta(-diffX, -diffY);
		}
		
		public function onDisplayObjectSelected(displayObject:DisplayObject):void
		{
			PimpCentral.send(Notifications.SCOPE_CHANGE_REQUEST, displayObject, this);
		}
		override public function populate(object:Object):void {
			if (object is DisplayObjectContainer) {
				rootNode = DisplayObjectContainer(object);
			}
		}
		override public function resize():void 
		{
			render();
			_mouseSelectButton.x = availableWidth - _mouseSelectButton.width - 2;
		}
		
		/* INTERFACE com.furusystems.dconsole2.core.interfaces.IThemeable */
		
		public function onThemeChange(md:MessageData):void
		{
			render();
			_mouseSelectButton.updateAppearance();
		}
		
		override public function get title():String { return "Display list"; }
		
		override public function get descriptionText():String { 
			return "Adds a tree view representing the current displaylist";
		}
		override public function initialize(pm:PluginManager):void 
		{
			_console = pm.console;
			super.initialize(pm);
		}
	}
}