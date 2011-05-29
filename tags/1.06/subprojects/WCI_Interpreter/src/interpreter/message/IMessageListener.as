package interpreter.message 
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IMessageListener 
	{
		function messageReceived(message:Message):void;
	}
	
}