package com.furusystems.dconsole2.plugins.remote
{
	/**
	 * List of commands between remote console server and clients.
	 * 
	 * @author Juan Delgado
	 */
	public class RemoteCommands
	{
		/**
		 * Used to split up serialized commands.
		 */
		public static const TOKEN : String = "|";
		
		/**
		 * From master to slave to set up its id [SET_ID|clientid]. Clients
		 * are expected to store
		 */
		public static const SET_ID : String = "setid";
		
		/**
		 * From slave to master to log [CLIENT_ID|LOG|txt|type]
		 */
		public static const LOG : String = "log";		
	}
}
