package interpreter.message 
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public interface IMessageProducer 
	{
		function addMessageListener(listener:IMessageListener):Boolean;
		function removeMessageListener(listener:IMessageListener):Boolean;
		function sendMessage(message:Message):void;
	}
	
}