package no.doomsday.dconsole2.plugins.inspectorviews.propertyview 
{
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import no.doomsday.dconsole2.core.inspector.AbstractInspectorView;
	import no.doomsday.dconsole2.core.interfaces.IThemeable;
	import no.doomsday.dconsole2.core.introspection.descriptions.AccessorDesc;
	import no.doomsday.dconsole2.core.introspection.descriptions.ChildScopeDesc;
	import no.doomsday.dconsole2.core.introspection.descriptions.MethodDesc;
	import no.doomsday.dconsole2.core.introspection.descriptions.VariableDesc;
	import no.doomsday.dconsole2.core.introspection.IntrospectionScope;
	import no.doomsday.dconsole2.core.Notifications;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	import no.doomsday.dconsole2.core.style.GUIUnits;
	import no.doomsday.dconsole2.plugins.inspectorviews.propertyview.fieldtypes.*;
	import no.doomsday.dconsole2.plugins.inspectorviews.propertyview.tabs.*;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class PropertyViewUtil extends AbstractInspectorView implements IThemeable
	{
		[Embed(source='assets/magnifierIcon.png')]
		private static var BitmapIcon:Class;
		private static const TAB_ICON:BitmapData = Bitmap(new BitmapIcon()).bitmapData;
		
		private var _tabs:TabCollection;
		public function PropertyViewUtil() 
		{
			_tabs = new TabCollection();
			_tabs.addEventListener(Event.CHANGE, onTabLayoutChange,false,0,true);
			_scrollableContent.addChild(_tabs);
			PimpCentral.addCallback(Notifications.SCOPE_CHANGE_COMPLETE, onScopeChange);
			PimpCentral.addCallback(Notifications.THEME_CHANGED, onThemeChange);
			scrollXEnabled = false;
		}
		override public function initialize(pm:PluginManager):void 
		{
			super.initialize(pm);
			populate(pm.scopeManager.currentScope);
		}
		override public function onFrameUpdate(e:Event = null):void 
		{
			_tabs.updateTabs();
		}
		override public function populate(object:Object):void 
		{
			super.populate(object);
			var scope:IntrospectionScope = IntrospectionScope(object);
			_tabs.clear();
			var t:PropertyTab;
			var i:int;
			t = new OverviewTab(scope);
			_tabs.add(t);
			t = new InheritanceTab(scope);
			_tabs.add(t);
			if (scope.obj is DisplayObject) {
				t = new TransformTab(scope);
				_tabs.add(t);
				t.averageSplits();
			}
			if(scope.children.length>0){
				t = new PropertyTab("Children");
				for (i = 0; i < scope.children.length; i++) 
				{
					var cd:ChildScopeDesc = scope.children[i];
					t.addField(new ChildField(cd));
				}
				_tabs.add(t);
			}
			if(scope.methods.length>0){
				t = new PropertyTab("Methods");
				for (i = 0; i < scope.methods.length; i++) 
				{
					var md:MethodDesc = scope.methods[i];
					t.addField(new MethodField(md));
				}
				t.sortFields();
				_tabs.add(t);
			}
			if(scope.variables.length>0){
				t = new PropertyTab("Variables");
				for (i = 0; i < scope.variables.length; i++) 
				{
					var vd:VariableDesc = scope.variables[i];
					t.addField(new PropertyField(scope.obj, vd.name, vd.type)).width = scrollRect.width;
				}
				t.sortFields();
				_tabs.add(t);
				t.averageSplits();
			}
			if(scope.accessors.length>0){
				t = new PropertyTab("Accessors");
				for (i = 0; i < scope.accessors.length; i++) 
				{
					var ad:AccessorDesc = scope.accessors[i];
					var f:PropertyField;
					//if (ad.access == "writeonly") continue;
					f = new PropertyField(scope.obj, ad.name, ad.type, ad.access);
					t.addField(f);
				}
				t.sortFields();
				_tabs.add(t);
				t.averageSplits();
			}
			scrollY = 0;
			resize();
		}
		private function onTabLayoutChange(e:Event):void 
		{
			scrollByDelta(0, 0);
		}
		private function onScopeChange(md:MessageData):void
		{
			var scope:IntrospectionScope = md.data as IntrospectionScope;
			populate(scope);
		}
		override public function resize():void 
		{
			if (!inspector) return;
			var rect:Rectangle = inspector.dims.clone();
			rect.height -= GUIUnits.SQUARE_UNIT;
			_tabs.width = rect.width;
			var r:Rectangle = scrollRect;
			r.width = rect.width;
			r.height = rect.height;
			scrollRect = r;
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.interfaces.IThemeable */
		
		public function onThemeChange(md:MessageData):void
		{
			_tabs.update(true);
		}
		override public function get tabIcon():BitmapData { return TAB_ICON; }
		
		override public function get descriptionText():String { 
			return "Adds a dynamically updating table of editable properties for the current scope";
		}
	}

}