package;

import ale.hscript.Script;

import haxe.Log;

class Main
{
	static function main()
	{
		final script:Script = new Script('test');

		#if VERBOSE_TEST
		Log.trace('\n--- ALE HScript Test --- \n\n' + script.content + '\n\n---\n', null);
		#end

		script.execute();

		#if VERBOSE_TEST
		Log.trace('\n---\n\nLexer: ' + script.lexerTime + ' ms\nParser: ' + script.parserTime + ' ms\nInterp: ' + script.interpTime + ' ms\n', null);
		#end
	}
}
