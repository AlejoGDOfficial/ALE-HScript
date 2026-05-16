package;

import ale.hscript.Script;

class Main
{
	static function main()
	{
		final script:Script = new Script('test');

		#if VERBOSE_TEST
		Sys.println('\n--- ALE HScript Test --- \n\n' + script.content + '\n\n---\n');
		#end

		script.execute();

		#if VERBOSE_TEST
		Sys.println('\n---\n\nLexer: ' + script.lexerTime + ' ms\nParser: ' + script.parserTime + ' ms\nInterp: ' + script.interpTime + ' ms\n');
		#end
	}
}
