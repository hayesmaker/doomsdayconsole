package no.doomsday.dconsole2.plugins.mediatester
{
	import flash.display.Sprite;
	import no.doomsday.dconsole2.core.plugins.IDConsolePlugin;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	import no.doomsday.dconsole2.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MediaTesterUtil extends Sprite implements IDConsolePlugin
	{
		private var _videoPlayers:Vector.<SimpleVideoPlayer>;
		internal var _console:DConsole;
		
		private function playVideo(url:String = "-1", application:String = ""):void
		{
			if (url == "-1") {
				throw new ArgumentError("No media url supplied");
			}
			var player:SimpleVideoPlayer = new SimpleVideoPlayer(this,url,application);
			_videoPlayers.push(player);
			addChild(player);
		}
		internal function destroy(player:SimpleVideoPlayer):void {
			player.close();
			removeChild(player);
			_videoPlayers.splice(_videoPlayers.indexOf(player), 1);
		}
		internal function log(msg:String):void {
			_console.print("MediaPlayer: " + msg);
		}
		private function clearAllPlayers():void
		{
			for each(var p:SimpleVideoPlayer in _videoPlayers) {
				destroy(p);
			}
		}
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IDConsolePlugin */
		
		public function initialize(pm:PluginManager):void
		{
			_videoPlayers = new Vector.<SimpleVideoPlayer>;
			_console = pm.console;
			_console.createCommand("playVideo", playVideo, "Media", "Creates a rudimentary video player for testing a stream or url X");
			pm.topLayer.addChild(this);
		}
			
		public function shutdown(pm:PluginManager):void
		{
			clearAllPlayers();
			pm.topLayer.removeChild(this);
			_console = null;
		}
		
		public function get descriptionText():String
		{
			return "Enables the creation of rudimentary media players for testing streamed/progressive content";
		}
		
	}

}