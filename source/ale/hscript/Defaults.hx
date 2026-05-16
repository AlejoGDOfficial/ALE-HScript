package ale.hscript;

import sys.FileSystem;
import sys.io.File;

class Defaults
{
    public static var FILE_CHECKER:String -> Bool = FileSystem.exists;
    public static var FILE_READER:String -> String = File.getContent;

    public static final IMPORTS:Array<Class<Dynamic>> = [
        Array,
        Date,
        DateTools,
        EReg,
        IntIterator,
        Lambda,
        List,
        Math,
        Reflect,
        Std,
        Type,
        StringBuf,
        StringTools,
        Sys,
        Xml
    ];
    public static final ABSTRACTS:Array<String> = [];
    public static final TYPEDEFS:Map<String, Class<Dynamic>> = [];
    public static final VARIABLES:Map<String, Dynamic> = [];

    public static var SCRIPT_EXTENSION:String = '.hx';
    public static var SCRIPT_PATH:String = 'scripts/';

    public static var MODULE_EXTENSION:String = '.hx';
    public static var MODULE_PATH:String = 'classes/';

    public static var INTERP_NAME:String = 'ALEHScript.hx';

    public static var ERROR_HANDLER:String -> Void = (e) -> Sys.println('[ ERROR ] ' + e);
}