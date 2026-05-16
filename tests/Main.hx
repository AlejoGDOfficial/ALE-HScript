package;

import ale.hscript.Script;

class Main
{
	static function main()
	{
		final script:Script = new Script('test');

		Sys.println('\n--- ALE HScript Test --- \n\n' + script.content + '\n\n---\n');

		script.execute();
	}
}
