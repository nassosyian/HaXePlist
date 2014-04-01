package plist;
import Sys;
import haxe.xml.*;
import haxe.ds.StringMap;
import Std;

class PlistXml 
{
	public static var debug:Bool = false;

	
	// static public function main()
	// {
	// }

	private static function parseArray(xml:Xml, printName:String = "", indent:String = "") : Array<Dynamic>
	{
		var fast:Fast = new haxe.xml.Fast(xml);

		var ret:Array<Dynamic> = new Array<Dynamic>();
		var value:Dynamic = null;
		var i:Int = 0;
		var nodename:String = "";

		if (debug)	Sys.print(indent+printName + " [");
		try
		{
			for (element in fast.elements) 
			{ 
				nodename = element.x.nodeName;

				switch (nodename) {
					case "true":	value = true;
					case "false":	value = false;
					case "integer":	value = element.innerHTML!=null ? Std.parseInt(element.innerHTML) : 0;
					case "real":	value = element.innerHTML!=null ? Std.parseFloat(element.innerHTML) : 0.0;
					case "string":	value = element.innerHTML!=null ? Std.string(element.innerHTML) : "";
					case "dict":	if (debug)	Sys.println("");
									value = element.innerHTML!=null ? parseDict(element.x, "", indent+"  ") : new StringMap<Dynamic>();
					case "array":	if (debug)	Sys.println("");
									value = element.innerHTML!=null ? parseArray(element.x, "", indent+"  ") : new Array<Dynamic>();
					default:		value = null;
				}

				if (value!=null)
				{
					ret.push(value);
					if (debug)
					{
						Sys.print((i > 0 ? "," : ""));
						switch (nodename) {
							case "dict": Sys.print("");
							case "string": Sys.print("'"+Std.string(value)+"'");
							default: Sys.print(Std.string(value));
						}
					}
					value = null;
				}

				i++;
			}	// for end
		}
		catch (ex : Dynamic)
		{
			var msg:String = ('parseArray elem[$i] ($nodename) exception : '+Std.string(ex));
			//if (debug)
			{	trace (msg);	Sys.println(msg);	}
		}
		if (debug)	Sys.print("]");

		return ret;
	}

	private static function parseDict(xml:Xml, printName:String = "", indent:String = "") : haxe.ds.StringMap<Dynamic>
	{
		var fast:Fast = new haxe.xml.Fast(xml);

		var map:StringMap<Dynamic> = new StringMap<Dynamic>();
		var keyname:String = null;
		var value:Dynamic = null;
		var nodename:String = "";
		var i:Int = 0;

		if (debug)	Sys.println(indent+printName + "{");
		try
		{
			for (element in fast.elements) 
			{ 
				nodename = element.x.nodeName;
				switch (nodename) {
					case "key":		keyname = element.innerHTML;		value = null;
					case "true":	value = true;
					case "false":	value = false;
					case "integer":	value = element.innerHTML!=null ? Std.parseInt(element.innerHTML) : 0;
					case "real":	value = element.innerHTML!=null ? Std.parseFloat(element.innerHTML) : 0.0;
					case "string":	value = element.innerHTML!=null ? Std.string(element.innerHTML) : "";
					case "dict":	value = element.innerHTML!=null ? parseDict(element.x, keyname, indent+"  ") : new StringMap<Dynamic>();
					case "array":	value = element.innerHTML!=null ? parseArray(element.x, keyname, indent+"  ") : new Array<Dynamic>();
				}

				if (keyname!=null && value!=null)
				{
					map.set(keyname, value);

					if (debug)
					switch (nodename) {
						case "dict":	Sys.print("");
										// Sys.println(indent+'"$keyname" => {}');
						case "array":	//Sys.println(indent+'"$keyname" => [${value.length}]');
										Sys.println('(${value.length})');
						case "string":	Sys.println(indent+'"$keyname" => "${value}"');
						default:		Sys.println(indent+'"$keyname" => '+Std.string(value));
					}

					keyname = null;
					value = null;
				}

				i++;
			}	// for end
		}
		catch (ex : Dynamic)
		{
			var msg:String = ('parseDict elem[$i] ($nodename) exception : '+Std.string(ex));
			//if (debug)
			{	trace (msg);	Sys.println(msg);	}
		}

		if (debug)	Sys.println(indent+"}");

		return map;
	}

	public static function parseXml(xml:Xml) : haxe.ds.StringMap<Dynamic>
	{
		var rootDict = xml.firstElement();
		if (rootDict == null)
		{
			throw "root dict not found";
			return null;
		}

		return parseDict(rootDict);
	}

	public static function parse(fileContents:String) : haxe.ds.StringMap<Dynamic>
	{
		return parseXml(Xml.parse(fileContents).firstElement());
	}
}