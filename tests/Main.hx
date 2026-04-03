package;

import ale.hscript.Script;

class Main
{
	static function main()
	{
		final script:Script = new Script();
		script.execute(sys.io.File.getContent('test.hx'));
	}
}
