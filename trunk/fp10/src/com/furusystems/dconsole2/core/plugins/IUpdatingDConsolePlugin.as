package no.doomsday.dconsole2.core.plugins 
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IUpdatingDConsolePlugin extends IDConsolePlugin
	{
		/**
		 * Called every frame update the plugin is visible
		 * @param	pm
		 */
		function update(pm:PluginManager):void;
	}
	
}