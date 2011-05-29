package no.doomsday.dconsole2.plugins.dialog 
{
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import com.furusystems.messaging.pimp.IMessageReceiver;
	import com.furusystems.messaging.pimp.Message;
	import com.furusystems.messaging.pimp.MessageData;
	import com.furusystems.messaging.pimp.PimpCentral;
	import flash.events.KeyboardEvent;
	import no.doomsday.dconsole2.core.Notifications;
	import no.doomsday.dconsole2.core.output.ConsoleMessageTypes;
	import no.doomsday.dconsole2.core.plugins.IDConsolePlugin;
	import no.doomsday.dconsole2.core.plugins.PluginManager;
	import no.doomsday.dconsole2.DConsole;
	import no.doomsday.dconsole2.plugins.dialog.DialogDesc;
	/**
	 * ...
	 * @author Andreas Ronning
	 */
	public class DialogUtil implements IDConsolePlugin, IMessageReceiver
	{
		static private const L:ILogger = Logging.getLogger(DialogPlug);
		private var _currentDialog:DialogSequence;
		public function DialogUtil() 
		{
			
		}
		
		private function abortDialog():void 
		{
			_currentDialog = null;
			DConsole.print("Dialog aborted", ConsoleMessageTypes.SYSTEM);
			DConsole.clearOverrideCallback();
			PimpCentral.send(DialogNotifications.ABORT_DIALOG, null, this);
			PimpCentral.removeReceiver(this, Notifications.ESCAPE_KEY);
		}
		
		private function startDialog(dialog:DialogDesc):void 
		{
			_currentDialog = new DialogSequence(dialog);
			_currentDialog.next();
			PimpCentral.addReceiver(this, Notifications.ESCAPE_KEY);
		}
		
		
		
		/* INTERFACE no.doomsday.dconsole2.core.plugins.IDConsolePlugin */
		
		public function get descriptionText():String 
		{
			return "Offers a scripted request/response system for querying the user for data";
		}
		
		public function initialize(pm:PluginManager):void 
		{
			PimpCentral.addReceiver(this, DialogNotifications.START_DIALOG);
		}
		
		public function shutdown(pm:PluginManager):void 
		{
			PimpCentral.removeReceiver(this, DialogNotifications.START_DIALOG);
			PimpCentral.removeReceiver(this, Notifications.ESCAPE_KEY);
		}
		
		/* INTERFACE com.furusystems.messaging.pimp.IMessageReceiver */
		
		public function onMessage(md:MessageData):void 
		{
			switch(md.message) {
				case DialogNotifications.START_DIALOG:
					var dialog:DialogDesc = md.data as DialogDesc;
					startDialog(dialog);
				break;
				case Notifications.ESCAPE_KEY:
					abortDialog();
				break;
			}
		}
		
	}

}