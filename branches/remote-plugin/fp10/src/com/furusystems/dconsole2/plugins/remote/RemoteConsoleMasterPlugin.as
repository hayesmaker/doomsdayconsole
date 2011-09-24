package com.furusystems.dconsole2.plugins.remote
{

	import com.furusystems.dconsole2.core.output.ConsoleMessageTypes;
	import com.furusystems.dconsole2.core.plugins.IDConsolePlugin;
	import com.furusystems.dconsole2.core.plugins.PluginManager;

	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.Dictionary;

	/**
	 * RemoteConsoleMasterPlugin allows you in combination with RemoteConsoleSlavePlugin to 
	 * execute commands on a console that's running on a different machine, as long as the slave
	 * machine can connect via sockets to the master machine.
	 * 
	 * @author Juan Delgado
	 */
	public class RemoteConsoleMasterPlugin implements IDConsolePlugin
	{
		private var _pm : PluginManager;
		
		private var _server : ServerSocket;
		
		private var _clients : Dictionary;
		
		private var _index : int = 0;
		
		private static const COMMAND_STOP : String = "remotestop";
		
		private static const COMMAND_START : String = "remotestart";
		
		private static const COMMAND_LIST_CLIENTS : String = "remotelist";
		
		private static const COMMAND_CLOSE_CLIENT : String = "remotecloseclient";
		
		private static const COMMAND_CATEGORY : String = "RemoteConsole";
		
		private static const PRINT_TAG : String = "RemoteConsoleMaster";
		
		/**
		 * @inheritDoc
		 */
		public function initialize(pm : PluginManager) : void
		{
			_pm = pm;
			
			if(ServerSocket.isSupported)
			{
				_clients = new Dictionary(true);
				
				_server = new ServerSocket();
				_server.addEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
				
				// TODO: listen to IOError and RangeError events as per spec: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/ServerSocket.html
				
				_pm.console.createCommand(COMMAND_START, onStart, COMMAND_CATEGORY, "Starts the master console server. Expects IP and PORT as parameters.");
				_pm.console.createCommand(COMMAND_STOP, onStop, COMMAND_CATEGORY, "Stops the the master server, ignored if not running.");
				_pm.console.createCommand(COMMAND_LIST_CLIENTS, onListClients, COMMAND_CATEGORY, "List the current clients connected.");
				_pm.console.createCommand(COMMAND_CLOSE_CLIENT, onCloseClient, COMMAND_CATEGORY, "Closes a client. Expects client ID as parameter.");
			}
			else
			{
				print("ServerSocket is not supported in your system, nothing to do here :/", ConsoleMessageTypes.FATAL);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function shutdown(pm : PluginManager) : void
		{
			if(ServerSocket.isSupported)
			{
				_pm.console.removeCommand(COMMAND_START);
				_pm.console.removeCommand(COMMAND_STOP);
				_pm.console.removeCommand(COMMAND_LIST_CLIENTS);
				_pm.console.removeCommand(COMMAND_CLOSE_CLIENT);
				
				_server.removeEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
				
				if(_server.listening)
				{
					onStop();
				}
				
				_server = null;
			}
			
			_pm = null;
		}

		/**
		 * @inheritDoc
		 */
		public function get descriptionText() : String
		{
			return "Remote Console Master Plugin";
		}

		/**
		 * @inheritDoc
		 */
		public function get dependencies() : Vector.<Class>
		{
			return null;
		}
		
		private function onStart(ip : String = "0.0.0.0", port : int = 0) : void
		{
			// TODO: check that we get valid a valid ip and port.
			
			print("About to start listening on " + ip + ":" + port, ConsoleMessageTypes.INFO);
			
			if(!_server.listening)
			{
				_server.bind(port, ip);
				_server.listen();
			}
		}
		
		private function onStop() : void
		{
			if(_server.listening)
			{
				closeClients();
				
				_server.close();
				
				print("Stopped master console", ConsoleMessageTypes.INFO);
			}
		}
		
		private function onListClients() : void
		{
			for(var clientId : String in _clients)
			{
				const client : Socket = _clients[clientId];
				print("client: " + clientId + ", connected: " + client.connected);
			}
		}
		
		/**
		 * Kick everyone out!
		 */
		private function closeClients() : void
		{
			for(var clientId : String in _clients)
			{
				onCloseClient(clientId);
			}
		}
		
		/**
		 * This is the master closing a specific client.
		 */
		private function onCloseClient(clientId : String) : void
		{
			const client : Socket = _clients[clientId];
			
			if(null != client)
			{
				client.removeEventListener(ProgressEvent.SOCKET_DATA, onClientData);
				client.removeEventListener(Event.CLOSE, onClientClose);
				client.close();
				
				_clients[clientId] = null;
				delete _clients[clientId];
				
				print("Client " + clientId + " closed connection",ConsoleMessageTypes.INFO);
			}
			else
			{
				print("Cannot find client with id: " + clientId, ConsoleMessageTypes.ERROR);
			}
		}
		
		/**
		 * New client kicking in.
		 */
		private function onConnect(event : ServerSocketConnectEvent) : void
		{
			const socket : Socket = event.socket;
			
			// FIXME: client id should be more of a random hash for security reasons
			const clientId : String = "client_" + _index++;
			_clients[clientId] = socket;
						
			print("Socket connected: " + clientId, ConsoleMessageTypes.INFO);
			
			// add listeners to client just connected
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onClientData);
			socket.addEventListener(Event.CLOSE, onClientClose);
			
			// send the new generated client id
			socket.writeUTF([RemoteCommands.SET_ID, clientId].join(RemoteCommands.TOKEN));
		}

		/**
		 * This is typically triggered by the client, when it closes.
		 */
		private function onClientClose(event : Event) : void
		{
			const socket : Socket = event.target as Socket;
			
			for(var clientId : String in _clients)
			{
				const client : Socket = _clients[clientId];
				
				if(client == socket)
				{
					onCloseClient(clientId);
					break;
				}
			}
		}
		
		/**
		 * Client wants to tell us something.
		 */
		private function onClientData(event : ProgressEvent) : void
		{
			const socket : Socket = event.target as Socket;
			
			const bits : Array = socket.readUTF().split(RemoteCommands.TOKEN);
			
			const clientId : String = bits[0];
			
			// we only accept commands from known clients
			if(null != _clients[clientId])
			{
				const command : String = bits[1];
				
				switch(command)
				{
					case RemoteCommands.LOG:
						
						const txt : String = bits[2];
						const type : String = bits[3];
						
						print(clientId + ": " + txt, type);
						break;
						
					default:
						
						print("Unknown command from slave: " + command, ConsoleMessageTypes.ERROR);
						break;
				}
			}
		}
		
		private function print(str : String, type : String = ConsoleMessageTypes.DEBUG) : void
		{
			_pm.console.print(str, type, PRINT_TAG);
		}
	}
}
