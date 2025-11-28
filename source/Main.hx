package;

import backend.ClientPrefs;
import flixel.FlxGame;
import openfl.display.Sprite;

using StringTools;

#if CRASH_HANDLER
import flixel.FlxG;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

class Main extends Sprite
{
	public function new()
	{
		trace('Sprite.new (super constructor call)');
		super();
		trace('Starting game with addChild');
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
		ClientPrefs.setup();
		addChild(new FlxGame(0, 0, states.TitleState));
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String /*  = "WTF!? THEY CRASHED MY BALLS!\n\n" */;
		final pathMain:String = #if CRASH_HANDLER_GEODE "./crashlogs/" #else "./crash/" #end;
		var path:String = pathMain;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_"); // Underscore
		dateNow = dateNow.replace(":", "꞉"); // Modifier Letter Colon
		dateNow = dateNow.replace("-", "∕"); // Division Slash

		path += "AngaDashReborn_" + dateNow + ".txt";
		#if CRASH_HANDLER_GEODE
		errMsg = '$dateNow\nWoopsies! An unhandled exception has occurred and the game crashed!\n';
		errMsg += "\n== Game Info ==\n";
		errMsg += 'HaxeFlixel Version: ${FlxG.VERSION.toString()}\n';
		errMsg += 'Anga Dash Reborn Version: ${Application.current.meta["version"]}\n';
		#end
		#if CRASH_HANDLER_GEODE
		errMsg += "\n== Stack Traceback ==\n"; // Hey! It rhymes!
		#end
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.print('');
			}
		}

		#if CRASH_HANDLER_GEODE
		var stateOfCrash = FlxG.state;
		while (stateOfCrash.subState != null)
			stateOfCrash = stateOfCrash.subState;
		errMsg += "\n== Crash Exception Info ==";
		errMsg += '\nState of crash: ${Type.getClassName(Type.getClass(stateOfCrash))}';
		#end
		errMsg += #if !CRASH_HANDLER_GEODE "\nUncaught Error: " #else "\nHaxe Exception: " #end + e.error +
		"\n\n> Crash Handler stolen from \"FNF Psych Engine\" written by: sqirra-rng" #if CRASH_HANDLER_GEODE +
		"\n> Styled around the Geometry Dash Mod Loader Geode by: All 69 Stoff" #end;

		if (!FileSystem.exists(pathMain))
			FileSystem.createDirectory(pathMain);

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Anga Dash (Reborn) Crashed!");
		Sys.exit(1);
	}
	#end
}
