package states;

import backend.StfUtils;
import editor.EditorState;
import editor.MetadataState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import objects.Cube;
import objects.gd.ObjectGD;
import objects.gd.TriggerGD;

@:allow(editor.EditorState)
@:access(editor.EditorState)
class PlayState extends FlxState
{
	// public static var camBG:FlxCamera; // Damn :(
	public static var camGame:FlxCamera; // Plagarized from FNF Psych Engine
	public static var camHUD:FlxCamera; // Plagarized from FNF Psych Engine
	public static var camOther:FlxCamera; // Plagarized from FNF Psych Engine

	public static var level:AngaLevel;
	public static var levelContents:Array<ObjectGD> = [];
	@:allow(states.PlayState)
	static var usingDummy:Bool = false;

	static var attempts:Int = 0;

	// Objects
	#if debug
	static var debugTxt:FlxText;
	#end

	var cubbi:Cube;
	var bgs:Array<FlxSprite>;
	var attemptTxt:FlxText;

	override public function create()
	{
		attempts++;
		removeObjs();
		// Cameras (my ass forgot to assign them as a new FlxCamera object 💀)
		FlxG.cameras.reset(/* FlxG.camera */);
		// FlxG.cameras.add(camBG);
		FlxG.cameras.add(camGame = new FlxCamera(), true);
		camGame.bgColor.alpha = 0x00;
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor.alpha = 0x00;
		FlxG.cameras.add(camOther = new FlxCamera(), false);
		camOther.bgColor.alpha = 0x00;
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.setDefaultDrawTarget(FlxG.camera, false);

		bgs = [new FlxSprite(0, 0, "assets/images/bg1.png"), null, null, null];
		// bgs[3] = (bgs[2] = (bgs[1] = bgs[0].clone()).clone()).clone();
		bgs[1] = bgs[0].clone();
		bgs[2] = bgs[1].clone();
		bgs[3] = bgs[2].clone();

		for (bg in bgs)
		{
			bg.cameras = [FlxG.camera];
			bg.color = PlayState.level.data.colors[-1];
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);
		}
		// Objects
		cubbi = new Cube(level.data.type);
		cubbi.speed = level.data.spdid;
		cubbi.cameras = [PlayState.camGame];
		add(cubbi);

		addObjs();

		attemptTxt = new FlxText(0, 360, 0, 'Attempt *$attempts*');
		attemptTxt.applyMarkup(attemptTxt.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(null, null, true), "*")]);
		attemptTxt.size = 22;
		if (FlxG.state is PlayState)
			add(attemptTxt);

		#if debug
		debugTxt = new FlxText(0, 0, FlxG.width, "", 16);
		debugTxt.cameras = [camOther];
		debugTxt.scrollFactor.set();
		add(debugTxt);
		// trace(ObjectGD.groupObjMap);
		// trace(ObjectGD.objGroupMap);
		#end
		super.create();
	}

	public function new(?Level:AngaLevel)
	{
		var notProvided:Bool = Level == null;
		if (notProvided)
			Level = new AngaLevel();
		level = Level;
		if (notProvided)
		{
			level.data.type = PLAT;
			level.level = [
				// new ObjectGD(0, 2),
				// new ObjectGD(0, 2, 1, 0, null, [0]),
				// new ObjectGD(1, 5),
				// new TriggerGD(1, 1, 10, [1, -1, 1, "circInOut", 0])
				{
					id: 0,
					gridX: 2,
					gridY: 0,
					angle: 0,
					scale: FlxPoint.weak(1, 1)
				},
				{
					id: 0,
					gridX: 2,
					gridY: 1,
					angle: 0,
					scale: FlxPoint.weak(1, 1),
					groups: [0]
				},
				{
					id: 1,
					gridX: 5,
					gridY: 0,
					angle: 0,
					scale: FlxPoint.weak(1, 1)
				},
				{
					id: -1,
					gridX: 1,
					gridY: 10,
					angle: 0,
					scale: FlxPoint.weak(1, 1),
					arguments: [1, -1, 1, ({name: CIRCULAR, type: INOUT} : Ease), 0]
				},
				{
					id: 1,
					gridX: 10,
					gridY: 0,
					angle: 0,
					scale: FlxPoint.weak(1, 1)
				},
				{
					id: 1,
					gridX: 11,
					gridY: 0,
					angle: 0,
					scale: FlxPoint.weak(1, 1)
				},
				{
					id: 1,
					gridX: 12,
					gridY: 0,
					angle: 0,
					scale: FlxPoint.weak(1, 1)
				}
			];
		}
		super();
	}

	/**
	 * Returns `true` if the player pressed
	 * - The `W` key
	 * - The `SPACE` key
	 * - The `UP` arrow key
	 * - The left mouse button (`M1`)
	 */
	public static var input(get, never):Bool;

	/**
	 * Returns `true` if the player pressed
	 * - The `A` key
	 * - The `LEFT` arrow key
	 */
	public static var inputPlatL(get, never):Bool;

	/**
	 * Returns `true` if the player pressed
	 * - The `D` key
	 * - The `RIGHT` arrow key
	 */
	public static var inputPlatR(get, never):Bool;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		// if (/* FlxG.camera.x + */ cubbi.x > 150)
		// {
		// camGame.scroll.x = 150 * cubbi.dirf - cubbi.x;
		// camGame.scroll.x = ((FlxG.width + cubbi.width) / 2 + cubbi.x) - 150 * cubbi.dirf;
		FlxG.camera.scroll.x = camGame.scroll.x = (cubbi.x - (FlxG.width - cubbi.width) / 2) + 150 * cubbi.dirf;
		// }
		#if debug
		// addDebugText(camGame.scroll.x);
		if (!(FlxG.state is EditorState) && !(FlxG.state is MetadataState))
		{
			if (FlxG.keys.justPressed.SEVEN)
			{
				StfUtils.trans(new EditorState(this));
				for (object in levelContents)
				{
					object.dontDestroy = object.hitbox.keepAlive = true;
					// object.resetObject();
					// object.destroy();
				}
			}
			else if (FlxG.keys.justPressed.EIGHT)
			{
				StfUtils.trans(new MetadataState());
			}
		}
		#end
	}

	static function addDebugText(message:Dynamic = "Lorem Ipsum"):String
	{
		trace(message);
		#if debug
		return debugTxt.text += Std.string(message) + "\n";
		#end
		return Std.string(message);
	}

	// I feel like using FlxG.resetState will load the dummy level no matter what
	public static inline function reset()
	{
		cast(FlxG.state, PlayState).removeObjs();
		FlxG.switchState(new PlayState(level));
	}

	/**
	 * For readability, `Reflect` isn't being used. So the name can have spaces
	 * and can scatter around types (structures, classes, abstracts, enums, etc...)
	 * @param name The name
	 * @return The value. Note: When calling this function, please use a cast or a type check: `cast getReadonlyVarFromName("Input")`,
	 * `cast(getReadonlyVarFromName("Input"), Bool)` or `(getReadonlyVarFromName("Input") : Bool)`
	 */
	public static function getReadonlyVarFromName(name:String):Dynamic
	{
		return switch (name.toLowerCase())
		{
			case "input": input; // Bool
			case "input left plat": inputPlatL; // Bool
			case "input right plat": inputPlatR; // Bool
			case "screen width": FlxG.width; // Int
			case "screen height": FlxG.height; // Int
			case "initial screen width": FlxG.initialWidth; // Int
			case "initial screen height": FlxG.initialHeight; // Int
			case "fps cap", "max fps", "max framerate", "framerate cap": Math.min(FlxG.updateFramerate, FlxG.drawFramerate); // Float
			case "attenpts", "attempt count", "attempt number": attempts; // Int
			default: name; // String
		}
	}

	function moveCamera(pos:FlxPoint)
	{
		// FlxG.camera.scroll.x += pos.x;
		// camGame.scroll.x = pos.x;
		// FlxG.camera.scroll.y += pos.y;
		// camGame.scroll.y = pos.y;
		FlxG.camera.scroll += pos;
		camGame.scroll += pos;
		pos.put();
	}

	function removeObjs()
	{
		@:privateAccess
		for (obj in levelContents)
		{
			ObjectGD.addrEnumerator = 0;
			remove(obj);
			remove(obj.hitbox);
		}
		levelContents = [];
	}

	@:access(objects.gd.ObjectGD)
	function addObjs()
	{
		ObjectGD.addrEnumerator = 0;
		for (obj in level.level)
		{
			var object = (obj.id >= 0) ? new ObjectGD(obj.id, obj.gridX, obj.gridY, obj.angle, obj.scale,
				obj.groups) : new TriggerGD(-obj.id, obj.gridX, obj.gridY, obj.arguments, obj.angle, obj.scale, obj.groups);
			levelContents.push(object);
		}

		for (obj in levelContents)
		{
			obj.cameras = [camGame];
			obj.update(0.0);
			add(obj);
			obj.hitbox.cameras = [camGame];
			add(obj.hitbox);
		}
	}

	function updateObjs()
	{
		removeObjs();
		addObjs();
	}

	override function destroy()
	{
		FlxG.cameras.reset();
		removeObjs();
		super.destroy();
	}

	@:noCompletion private static function get_input():Bool
	{
		return FlxG.keys.anyPressed([FlxKey.SPACE, FlxKey.W, FlxKey.UP]) || FlxG.mouse.pressed;
	}

	@:noCompletion private static function get_inputPlatL():Bool
	{
		return FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT]);
	}

	@:noCompletion private static function get_inputPlatR():Bool
	{
		return FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT]);
	}
}

class AngaLevel
{
	/**
	 * Dummy Level
	 */
	public static final dummy:AngaLevelData = {
		spdid: ONE_X,
		mode: CUBE,
		mini: false,
		masterFont: PUSAB,
		colors: [
			-8 => 0xFF2878FF,
			-7 => 0xFF2878FF,
			-6 => FlxColor.WHITE,
			-5 => FlxColor.WHITE,
			-4 => FlxColor.WHITE,
			-3 => 0xFF0066FF,
			-2 => 0xFF0066FF,
			-1 => 0xFF2878FF,
			0 => FlxColor.WHITE
		],
		type: CLASSIC
	};

	// Used by the editor
	public static final base:AngaLevelData = {
		spdid: ONE_X,
		mode: CUBE,
		mini: false,
		masterFont: PUSAB,
		/*
			-1 - BG
			-2 - G1
			-3 - G2
			-4 - Line
			-5 - Obj
			-6 - 3DL
			-7 - MG1
			-8 - MG2
		 */
		colors: [
			-8 => 0xFF2878FF,
			-7 => 0xFF2878FF,
			-6 => FlxColor.WHITE,
			-5 => FlxColor.WHITE,
			-4 => FlxColor.WHITE,
			-3 => 0xFF0066FF,
			-2 => 0xFF0066FF,
			-1 => 0xFF2878FF,
			0 => FlxColor.WHITE
		],
		type: CLASSIC
	};

	public var data:AngaLevelData;
	public var level:AngaLevelContents = [];

	@:allow(objects.gd.TriggerGD) @:allow(objects.Cube) var levelTriggers:Array<TriggerGD> = [];

	public function new(?Data:AngaLevelData, ?LVL:AngaLevelContents)
	{
		if (PlayState.usingDummy = Data == null)
			data = dummy;
		else
			data = Data;
		for (id in 0...10000)
		{
			if (!data.colors.exists(id) || data.colors.get(id) == null)
				data.colors.set(id, FlxColor.WHITE);
			else if (traces)
				trace('Color id $id already exists (${data.colors.get(id)})');
		}
	}

	public static final traces:Bool = false;
}

typedef AngaLevelData =
{
	var spdid:Speed;
	var mode:GameMode;
	var mini:Bool;
	var masterFont:Font;

	/**
	 * The level's color palette
	 * 
	 * IDs:
	 * 
	 * - `-1` - BG
	 * - `-2` - G1
	 * - `-3` - G2
	 * - `-4` - Line
	 * - `-5` - Obj
	 * - `-6` - 3DL
	 * - `-7` - MG1
	 * - `-8` - MG2
	 * 
	 * * `0` - Col1
	 * * `1` - Col2
	 * * `2` - Col3
	 * * `3` - Col4
	 * * `4` - Col5
	 * * `5` - Col6
	 * * `6` - Col7
	 * * `7` - Col8
	 * * `8` - Col9
	 * * `9` - Col10
	 * * ...
	 */
	var colors:ColorsGD;

	/**
	 * The Game Type
	 */
	var type:GameType;
}

enum Font
{
	PUSAB; // GD Font 1
	JOYSTIX; // GD Font 5
	DANCINGSCRIPT; // GD Font 7
	MINECRAFTORY; // GD Font 10
	SM256; // GD Font 11
	KETCHUM; // GD Font 12

	NOKIAFCSMALL; // ADR Font 1
}

/**
 * - `-1` - BG
 * - `-2` - G1
 * - `-3` - G2
 * - `-4` - Line
 * - `-5` - Obj
 * - `-6` - 3DL
 * - `-7` - MG1
 * - `-8` - MG2
 * 
 * * `0` - Col1
 * * `1` - Col2
 * * `2` - Col3
 * * `3` - Col4
 * * `4` - Col5
 * * `5` - Col6
 * * `6` - Col7
 * * `7` - Col8
 * * `8` - Col9
 * * `9` - Col10
 * * ...
 */
typedef ColorsGD = Map<Int, FlxColor>;

enum GameType
{
	CLASSIC;
	PLAT;
}

typedef AngaLevelContents = Array<
	{
		id:Int,
		gridX:Float,
		gridY:Float,
		angle:Float,
		?scale:FlxPoint,
		?groups:Array<Int>,
		?arguments:Array<Dynamic>
	}>;

// typedef AngaLevelTriggers = Array<TriggerGD>;

class PlayStateEventListener
{
	public var mapEventTrigger:Map<PlayStateEvent, Array<Int>> = [ONDEATH => []];

	public function dispatch(e:PlayStateEvent)
	{
		var groups = [for (g in mapEventTrigger[e]) StfUtils.getGroup(g)];
		for (group in groups)
		{
			for (obj in group)
			{
				if (obj is TriggerGD)
				{
					var trigger = cast(obj, TriggerGD);
					trigger.trigger();
				}
			}
		}
	}

	public function add(e:PlayStateEvent, g:Int)
	{
		if (!mapEventTrigger.exists(e))
		{
			mapEventTrigger.set(e, [g]);
			return;
		}
		mapEventTrigger[e].push(g);
	}

	public function remove(e:PlayStateEvent, ?g:Int)
	{
		if (!mapEventTrigger.exists(e))
			return;
		if (mapEventTrigger[e].length <= 1)
		{
			mapEventTrigger.remove(e);
			return;
		}
		if (g == null)
		{
			mapEventTrigger[e].pop();
			return;
		}
		mapEventTrigger[e].remove(g);
	}
}

enum PlayStateEvent
{
	ONDEATH;
	ITEMCOUNT;
	VARCOUNT;
	ONEXPRESS;
	COLLISION;
}
