package com.furusystems.dconsole2.plugins.remote
{

	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	import com.furusystems.dconsole2.core.plugins.IDConsolePlugin;
	import com.furusystems.dconsole2.core.plugins.PluginManager;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;

	/**
	 * In combination with RemoteConsoleMasterPlugin allows remote execution
	 * of commands, log reading, etc.
	 * 
	 * @author Juan Delgado
	 */
	public class RemoteConsoleSlavePlugin implements IDConsolePlugin
	{
		private var _pm : PluginManager;

		private var _socket : Socket;
		
		private var _clientId : String;
		
		private static const COMMAND_CONNECT : String = "slaveconnect";
		
		private static const COMMAND_CATEGORY : String = "RemoteConsole";
		
		private static const PRINT_TAG : String = "RemoteConsoleSlave";
		
		/**
		 * @inheritDoc
		 */
		public function initialize(pm : PluginManager) : void
		{
			_pm = pm;
			
			_socket = new Socket();
			_socket.addEventListener(Event.CONNECT, onConnect);
			_socket.addEventListener(Event.CLOSE, onClose);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, onIOerror);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			_pm.console.createCommand(COMMAND_CONNECT, connect, COMMAND_CATEGORY, "Connects to the master console. Expects IP and PORT as parameters");	
		}

		/**
		 * @inheritDoc
		 */
		public function shutdown(pm : PluginManager) : void
		{
			_pm.console.removeCommand(COMMAND_CONNECT);
			_pm = null;
			
			_socket.removeEventListener(Event.CONNECT, onConnect);
			_socket.removeEventListener(Event.CLOSE, onClose);
			_socket.removeEventListener(ProgressEvent.SOCKET_DATA, onData);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOerror);
			_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			if(_socket.connected)
			{
				_socket.close();
			}
			
			_socket = null;
		}

		/**
		 * @inheritDoc
		 */
		public function get descriptionText() : String
		{
			return "Remote Console Slave Plugin";
		}

		/**
		 * @inheritDoc
		 */
		public function get dependencies() : Vector.<Class>
		{
			return null;
		}
		
		private function connect(ip : String, port : int) : void
		{
			// TODO: validate IP and PORT
			
			if(!_socket.connected)
			{
				print("About to connect to: " + ip + ":" + port);
				_socket.connect(ip, port);
			}
		}
		
		private function onClose(event : Event) : void
		{
			print("ON CLOSE");
		}

		private function onConnect(event : Event) : void
		{
			print("ON CONNECT");
		}
		
		private function onData(event : ProgressEvent) : void
		{
			const bits : Array = _socket.readUTF().split(RemoteCommands.TOKEN);
			
			const masterCommand : String = bits[0];
			
			switch(masterCommand)
			{
				case RemoteCommands.SET_ID:
					
					_clientId = bits[1];
					print("Got client id from master (" + _clientId + ")");
					break;
			}			
		}
		
		private function onSecurityError(event : SecurityErrorEvent) : void
		{
			print("ON SECURITY ERROR: " + event.errorID + ", " + event.text, ConsoleMessageTypes.ERROR);
		}

		private function onIOerror(event : IOErrorEvent) : void
		{
			print("ON IO ERROR: " + event.errorID + ", " + event.text, ConsoleMessageTypes.ERROR);
		}
		
		private function print(txt : String, type : String = ConsoleMessageTypes.DEBUG) : void
		{
			_pm.console.print(txt, type, PRINT_TAG);
			
			if(_socket.connected && null != _clientId)
			{
				// already connected to the master, so pass all the logs
				_socket.writeUTF([_clientId, RemoteCommands.LOG, txt, type].join(RemoteCommands.TOKEN));
			}
		}
	}
}
