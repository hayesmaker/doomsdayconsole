package  
{
	import interpreter.backend.Backend;
	import interpreter.backend.BackendFactory;
	import interpreter.frontend.FrontendFactory;
	import interpreter.frontend.Parser;
	import interpreter.frontend.Source;
	import interpreter.intermediate.IiCode;
	import interpreter.intermediate.ISymTab;
	import utils.BufferedReader;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Pascal
	{
		private var parser:Parser;
		private var source:Source;
		private var iCode:IiCode;
		private var symTab:ISymTab
		private var backend:Backend;
		public function Pascal(operation:String, statement:String, flags:String) 
		{
			var intermediate:Boolean = flags.indexOf("i") > -1;
			var xref:Boolean = flags.indexOf("x") > -1;
			source = new Source(new BufferedReader(statement));
			source.addMessageListener(new SourceMessageListener);
			parser = FrontendFactory.createParser("pascal", "top-down", source);
			parser.addMessageListener(new ParserMessageListener);
			backend = BackendFactory.createBackend("execute");
			backend.addMessageListener(new BackendMessageListener);
			
			parser.parse();
			source.close();
			
			iCode = parser.getICode();
			symTab = parser.getSymtab();
			
			backend.process(iCode, symTab);
		}
		
	}

}