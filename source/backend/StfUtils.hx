package backend;

import backend.SwagSongMeta.SwagSavedSongMeta;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.StrNameLabel;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import objects.gd.ObjectGD;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import states.PlayState;
import sys.io.File;

/**
 * The first `backend` class - The main STFGames utility function
 * 
 * Formerly `StoffUtils`
 */
class StfUtils
{
	// Grid
	public static function convertToGridPoint(pnt:FlxPoint)
		return FlxPoint.get(pnt.x / 60, FlxG.height - pnt.y / 60);

	public static function convertToIntGridPoint(pnt:FlxPoint)
		return FlxPoint.get(Std.int(pnt.x / 60), Std.int(FlxG.height - pnt.y / 60));

	public static function convertFromGridPoint(pnt:FlxPoint)
		return FlxPoint.get(pnt.x * 60, FlxG.height - pnt.y * 60);

	public static function isPointOnGrid(pnt:FlxPoint)
	{
		var pntGrid = convertToGridPoint(pnt);
		var pntX = Math.round(pntGrid.x);
		var pntY = Math.round(pntGrid.y);
		pntGrid.put();
		return pntX == pnt.x && pntY == pnt.y;
	}

	// Transitions
	public static var transType:TransitionType = FADE;

	/**
	 * -ition
	 * 
	 * Transition
	 * 
	 * "Transitions" between the two `FlxState`s (`FlxG.state` (the current one) and `to`)
	 * @param to The next state
	 * @param dur How long the transition takes (in total)
	 */
	public static function trans(to:FlxState, dur:Float = 1.0)
	{
		final mainFunc:() -> Void = function() FlxG.switchState(to);
		to._trans = {
			type: transType,
			duration: dur
		};
		switch (transType)
		{
			case FADE:
				FlxG.cameras.fade(FlxColor.BLACK, dur / 2, false, mainFunc);
			default:
				mainFunc();
		}
	}

	// Exclusive Or

	/**
	 * DEPRECATED: THIS FUNCTION USES AN OLD METHOD
	 * 
	 * Runs the exclusive or (XOR / EOR) operator for `a` and `b`
	 * @param a Left-hand side of the xor operator
	 * @param b Right-hand side of the xor operator
	 * @return `a` xor `b`
	 */
	@:deprecated("StfUtils.xorDep is deprecated. It uses an old method. Use StfUtils.xor instead. It uses a new mthond and it's inline")
	public static function xorDep(a:Bool, b:Bool):Bool
	{
		var trues:Int = 0;
		if (a)
			trues++;
		if (b)
			trues++;
		return trues == 1;
	}

	/**
	 * Runs the exclusive or (XOR / EOR) operator for `a` and `b`
	 * @param a Left-hand side of the xor operator
	 * @param b Right-hand side of the xor operator
	 * @return `a` xor `b`
	 */
	public static inline function xor(a:Bool, b:Bool):Bool
	{
		return (a || b) && !(a && b);
	}

	// Group Handling
	public static function getGroup(g:Int = 0):Array<ObjectGD>
	{
		// return ObjectGD.groupObjMap[g];
		var objsOfGroup:Array<ObjectGD> = [];
		// for (obj => gs in ObjectGD.objGroupMap)
		// {
		// 	if (gs.contains(g))
		// 		objsOfGroup.push(obj);
		// }
		if (g < 0)
			throw "";
		for (obj in PlayState.levelContents)
		{
			if (obj.groups.contains(g))
				objsOfGroup.push(obj);
		}
		return objsOfGroup;
	}

	// Array<String>-String Parsing

	/**
	 * More readable than `arr.toString`!
	 * @param arr The array that will be parsed
	 * @return The better `arr.toString` result
	 */
	public static function arrayToStr(arr:Array<String>):String
	{
		// var arrStr:String = Std.string(arr);
		var result = "";
		for (i => i2 in arr)
		{
			result += i2.trim();
			if (i < arr.length - 1)
				result += ", ";
		}
		return result;
	}

	/**
	 * What if `String`s had a `toArray` function?
	 * @param str The string that will be encoded
	 * @return The `str.toArray` result
	 */
	public static function stringToArr(str:String):Array<String>
	{
		var result:Array<String> = str.split(',');
		for (i in result)
		{
			i = i.trim();
		}
		return result;
	}

	// Dialogs
	static var loadedFile:String = "No file";

	/**
	 * Opens the explorer dialog on Windows
	 * @param doSave If `true`, saves instead of loads
	 * @param onConfirm A confirm callback
	 * @param onCancel A cancel callback
	 * @param onError A save/load error callback
	 * @param data Used if `doSave` is `true`
	 * @param fileName Used if `doSave` is `false`
	 * @param exts An array of `openfl.net.FileFilter`s
	 */
	public static function openDialog(doSave:Bool = false, ?onConfirm:(Event) -> Void, ?onCancel:(Event) -> Void, ?onError:(Event) -> Void, data:String = "",
			?fileName:FileName, ?exts:Array<FileFilter>)
	{
		if (fileName == null)
			fileName = {name: "Untitled", ext: "txt"};
		var fr = new FileReference();
		if (onConfirm != null)
		{
			fr.addEventListener(doSave ? Event.COMPLETE : Event.SELECT, event ->
			{
				var path:String = "";
				@:privateAccess
				if (fr.__path != null)
					path = fr.__path;
				if (!doSave && fr.data != null)
				{
					loadedFile = fr.data.toString();
					// loadedFile = fr.
				}
				else if (!doSave && path.length != 0)
				{
					#if sys
					loadedFile = File.getContent(path);
					#else
					loadedFile = "Error!";
					onError(IOErrorEvent.IO_ERROR);
					#end
				}
				trace(loadedFile);
				onConfirm(event);
			});
		}
		if (onCancel != null)
			fr.addEventListener(Event.CANCEL, onCancel);
		if (onError != null)
			fr.addEventListener(IOErrorEvent.IO_ERROR, onError);
		if (doSave)
			fr.save(data, '${fileName.name}.${fileName.ext}');
		else if (exts != null)
			fr.browse(exts);
		else
			fr.browse([new FileFilter("Any file", "*")]);
		// return !doSave ? fr.data.toString() : "";
	}

	// Songs: Metadata

	/**
	 * Converts a `SwagSongMeta` to a `SwagSavedSongMeta`
	 * @param meta The metadata
	 * @throws String if `meta.composer` and `meta.composers` have not been provided
	 * @return The `SwagSavedSongMeta`
	 */
	public static function saveMeta(meta:SwagSongMeta):SwagSavedSongMeta
	{
		var isComposerNull:Bool = meta.composer == null;
		var areComposersNull:Bool = meta.composers == null;
		var noComposers:Bool = true;
		if (!areComposersNull)
			noComposers = meta.composers.length == 0;
		var multiComp:SwagSavedSongMeta = {
			name: meta.name,
			composers: meta.composers,
			daw: meta.daw.getName()
		};
		var oneComp:SwagSavedSongMeta = {
			name: meta.name,
			composer: meta.composer,
			daw: meta.daw.getName()
		};
		var noComp:SwagSavedSongMeta = {
			name: meta.name,
			daw: meta.daw.getName()
		};
		if (isComposerNull && noComposers)
			throw "Is this a song made by a bot?";
		return noComposers ? oneComp : multiComp;
	}

	/**
	 * Converts a `SwagSavedSongMeta` to a `SwagSongMeta`
	 * @param meta The saved metadata
	 * @throws (Crash) if `meta.daw` (`String`) is not a `SwagSongDaw` (result unspecified)
	 * @throws String if `meta.composer` and `meta.composers` have not been provided
	 * @return The `SwagSongMeta`
	 */
	public static function loadMeta(meta:SwagSavedSongMeta):SwagSongMeta
	{
		var isComposerNull:Bool = meta.composer == null;
		var areComposersNull:Bool = meta.composers == null;
		var noComposers:Bool = true;
		if (!areComposersNull)
			noComposers = meta.composers.length == 0;
		var multiComp:SwagSongMeta = {
			name: meta.name,
			composers: meta.composers,
			daw: SwagSongDaw.createByName(meta.daw)
		};
		var oneComp:SwagSongMeta = {
			name: meta.name,
			composer: meta.composer,
			daw: SwagSongDaw.createByName(meta.daw)
		};
		var noComp:SwagSongMeta = {
			name: meta.name,
			daw: SwagSongDaw.createByName(meta.daw)
		};
		if (isComposerNull && noComposers)
			throw "Is this a song made by a bot? Did you edit the file? Were you bored?";
		return noComposers ? oneComp : multiComp;
	}

	// Levels

	/**
	 * Gets not just the name, but also the normal and practice mode progresses
	 * and wether the level is locked
	 * @param name The name of the level you want
	 * @return A struct of the save data
	 * @throws ArgumentException if the level is not main
	 */
	public static function getMainLevelData(name:String):MainLevelSaveData
	{
		for (id => data in ClientPrefs.dataOther.mainLevels)
		{
			if ((data[0] : String).toLowerCase() == name.toLowerCase())
			{
				if (data.length == 3)
				{
					return {
						name: (data[0] : String),
						progressN: (data[1] : Float),
						progressP: (data[2] : Float),
						locked: false
					};
				}
				else if (data.length >= 4)
				{
					return {
						name: (data[0] : String),
						progressN: (data[1] : Float),
						progressP: (data[2] : Float),
						locked: !(data[3] : Bool)
					};
				}
			}
			// else
			// {
			// 	throw new haxe.exceptions.ArgumentException("name", '$name is not a level');
			// }
		}
		throw new haxe.exceptions.ArgumentException("name", '$name is not a main level');
		// return {
		// 	name: name,
		// 	progressN: 0.00,
		// 	progressP: 0.00,
		// 	locked: false
		// };
	}

	/**
	 * Gets not just the name, but also the normal and practice mode progresses
	 * and wether you've favorited the level
	 * @param name The name of the level you want
	 * @return A struct of the save data
	 * @throws ArgumentException if the level has not been downloaded by Anga Dash Reborn
	 */
	public static function getCustomLevelData(name:String):CustomLevelSaveData
	{
		for (id => data in ClientPrefs.dataOther.downloadedCustomLevels)
		{
			if ((data[0] : String).toLowerCase() == name.toLowerCase())
			{
				if (data.length == 4)
				{
					return {
						name: (data[0] : String),
						progressN: (data[1] : Float),
						progressP: (data[2] : Float),
						faved: (data[3] : Bool)
					};
				}
				else
					break;
			}
		}
		throw new haxe.exceptions.ArgumentException("name", '$name has not been downloaded or has an incorrect save data');
	}

	/**
	 * Sets the normal and practice mode progresses and wether the level is locked
	 * @param name The name of the level you want
	 * @param value The struct of the save data
	 * @throws ArgumentException if the level is not main or `name` != `value.name`
	 */
	public static function setMainLevelData(name:String, value:MainLevelSaveData)
	{
		for (id => data in ClientPrefs.dataOther.mainLevels)
		{
			if (value.name != name)
				throw new haxe.exceptions.ArgumentException("name", '$name != ${value.name}');
			if ((data[0] : String).toLowerCase() == value.name.toLowerCase())
			{
				/* if (data.length == 3)
					{
						return {
							name: (data[0] : String),
							progressN: (data[1] : Float),
							progressP: (data[2] : Float),
							locked: false
						};
					}
					else if (data.length >= 4)
					{
						return {
							name: (data[0] : String),
							progressN: (data[1] : Float),
							progressP: (data[2] : Float),
							locked: !(data[3] : Bool)
						};
				}*/
				if (value.locked == null)
				{
					data[0] = value.name;
					data[1] = value.progressN;
					data[2] = value.progressP;
				}
				else
				{
					data[0] = value.name;
					data[1] = value.progressN;
					data[2] = value.progressP;
					data[3] = value.locked;
				}
			}
			// else
			// {
			// 	throw new haxe.exceptions.ArgumentException("name", '$name is not a level');
			// }
		}
		throw new haxe.exceptions.ArgumentException("name", '$name is not a main level');
		// return {
		// 	name: name,
		// 	progressN: 0.00,
		// 	progressP: 0.00,
		// 	locked: false
		// };
	}

	/**
	 * Sets the normal and practice mode progresses and wether you've favorited it. If the level has
	 * not been downloaded yet, the game will just download the level
	 * @param name The name of the level you want
	 * @param value The struct of the save data
	 * @throws ArgumentException `if (name != value.name)` I'm not joking. Just let that sink in
	 */
	public static function setCustomLevelData(name:String, value:CustomLevelSaveData)
	{
		for (id => data in ClientPrefs.dataOther.downloadedCustomLevels)
		{
			if (value.name != name)
				throw new haxe.exceptions.ArgumentException("name", '$name != ${value.name}');
			if ((data[0] : String).toLowerCase() == value.name.toLowerCase())
			{
				data[0] = value.name;
				data[1] = value.progressN;
				data[2] = value.progressP;
				data[3] = value.faved;
			}
		}
		// throw new haxe.exceptions.ArgumentException("name", '$name has not been downloaded or has an incorrect save data');
		downloadCustomLevel(name, value);
	}

	/**
	 * Sets the normal and practice mode progresses and wether you've favorited the level
	 * @param name The name of the level you want
	 * @param value The struct of the save data
	 * @throws ArgumentException `if (name != value.name)` I'm not joking. Just let that sink in
	 */
	public static function downloadCustomLevel(name:String, value:CustomLevelSaveData)
	{
		if (value.name != name)
			throw new haxe.exceptions.ArgumentException("name", '$name != ${value.name}');
		ClientPrefs.dataOther.downloadedCustomLevels.push([value.name, value.progressN, value.progressP, value.faved]);
	}

	// Easings
	static var easeNames:Map<EaseName, String> = [
		LINEAR => 'linear',
		QUADRATIC => 'quad',
		CUBIC => 'cube',
		QUARTIC => 'quart',
		QUINTIC => 'quint',
		SMOOTHSTEP => 'smoothStep',
		SMOOTHERSTEP => 'smootherStep',
		SINUSOIDAL => 'sine',
		BOUNCE => 'bounce',
		CIRCULAR => 'circ',
		EXPONENTIAL => 'expo',
		BACKWARDS => 'back',
		ELASTIC => 'elastic'
	];

	static var easeNamesShort:Map<EaseNameShort, String> = [
		LINEAR => 'linear',
		QUAD => 'quad',
		CUBE => 'cube',
		QUART => 'quart',
		QUINT => 'quint',
		SMOOTHSTEP => 'smoothStep',
		SMOOTHERSTEP => 'smootherStep',
		SINE => 'sine',
		BOUNCE => 'bounce',
		CIRC => 'circ',
		EXPO => 'expo',
		BACK => 'back',
		ELASTIC => 'elastic'
	];

	static var easeTypes:Map<EaseType, String> = [IN => 'In', OUT => 'Out', INOUT => 'InOut'];

	static var availableEases:Map<String, (t:Float) -> Float> = [
		'linear' => FlxEase.linear,
		'quadIn' => FlxEase.quadIn,
		'quadOut' => FlxEase.quadOut,
		'quadInOut' => FlxEase.quadInOut,
		'cubeIn' => FlxEase.cubeIn,
		'cubeOut' => FlxEase.cubeOut,
		'cubeInOut' => FlxEase.cubeInOut,
		'quartIn' => FlxEase.quartIn,
		'quartOut' => FlxEase.quartOut,
		'quartInOut' => FlxEase.quartInOut,
		'quintIn' => FlxEase.quintIn,
		'quintOut' => FlxEase.quintOut,
		'quintInOut' => FlxEase.quintInOut,
		'smoothStepIn' => FlxEase.smoothStepIn,
		'smoothStepOut' => FlxEase.smoothStepOut,
		'smoothStepInOut' => FlxEase.smoothStepInOut,
		'smootherStepIn' => FlxEase.smootherStepIn,
		'smootherStepOut' => FlxEase.smootherStepOut,
		'smootherStepInOut' => FlxEase.smootherStepInOut,
		'sineIn' => FlxEase.sineIn,
		'sineOut' => FlxEase.sineOut,
		'sineInOut' => FlxEase.sineInOut,
		'bounceIn' => FlxEase.bounceIn,
		'bounceOut' => FlxEase.bounceOut,
		'bounceInOut' => FlxEase.bounceInOut,
		'circIn' => FlxEase.circIn,
		'circOut' => FlxEase.circOut,
		'circInOut' => FlxEase.circInOut,
		'expoIn' => FlxEase.expoIn,
		'expoOut' => FlxEase.expoOut,
		'expoInOut' => FlxEase.expoInOut,
		'backIn' => FlxEase.backIn,
		'backOut' => FlxEase.backOut,
		'backInOut' => FlxEase.backInOut,
		'elasticIn' => FlxEase.elasticIn,
		'elasticOut' => FlxEase.elasticOut,
		'elasticInOut' => FlxEase.elasticInOut
	];

	/**
	 * Gets an easing from `FlxEase` from a `name`
	 * @param name The easing function name in `FlxEase`
	 * @return The ease function from `FlxEase`
	 */
	@:deprecated("StfUtils.getEaseRaw is deprecated. Please refer to StfUtils.getEase or StfUtils.getEaseFromShortName")
	public static function getEaseRaw(name:String = 'linear'):EaseFunction
	{
		var eases = Type.getClassFields(FlxEase);

		for (ease in eases)
		{
			if (ease == name)
				return Reflect.getProperty(FlxEase, name);
		}
		return FlxEase.linear;
	}

	/**
	 * Gets an easing function from `FlxEase` from a `name` and `type`
	 * @param name The easing name of no truncation
	 * @param type The easing type (can be "in" (`in`, `IN`), "out" (`out`, `OUT`), and "in out" (`inOut`, `INOUT`))
	 * @return The ease function from `FlxEase`
	 */
	public static function getEase(name:EaseName, type:EaseType):EaseFunction
	{
		if (name == LINEAR)
			return FlxEase.linear;
		var easeName = easeNames[name] + easeTypes[type];
		return availableEases[easeName];
	}

	/**
	 * Gets an easing function from `FlxEase` from a `name` and `type`
	 * @param name The easing name of trunc lvl 1
	 * @param type The easing type (can be "in" (`in`, `IN`), "out" (`out`, `OUT`), and "in out" (`inOut`, `INOUT`))
	 * @return The ease function from `FlxEase`
	 */
	public static function getEaseFromShortName(name:EaseNameShort, type:EaseType):EaseFunction
	{
		if (name == LINEAR)
			return FlxEase.linear;
		var easeName = easeNamesShort[name] + easeTypes[type];
		return availableEases[easeName];
	}

	/**
	 * Help me
	 * @param short `EaseNameShort`
	 * @return `EaseName`
	 */
	public static function easeShortToLongName(short:EaseNameShort):EaseName
	{
		var shortToLong:Map<EaseNameShort, EaseName> = [
			LINEAR => LINEAR,
			QUAD => QUADRATIC,
			CUBE => CUBIC,
			QUART => QUARTIC,
			QUINT => QUINTIC,
			SMOOTHSTEP => SMOOTHSTEP,
			SMOOTHERSTEP => SMOOTHERSTEP,
			SINE => SINUSOIDAL,
			BOUNCE => BOUNCE,
			CIRC => CIRCULAR,
			EXPO => EXPONENTIAL,
			BACK => BACKWARDS,
			ELASTIC => ELASTIC
		];
		return shortToLong[short];
	}

	/**
	 * Help me²
	 * @param long `EaseName`
	 * @return `EaseNameShort`
	 */
	public static function easeLongToShortName(long:EaseName):EaseNameShort
	{
		var longToShort:Map<EaseName, EaseNameShort> = [
			LINEAR => LINEAR,
			QUADRATIC => QUAD,
			CUBIC => CUBE,
			QUARTIC => QUART,
			QUINTIC => QUINT,
			SMOOTHSTEP => SMOOTHSTEP,
			SMOOTHERSTEP => SMOOTHERSTEP,
			SINUSOIDAL => SINE,
			BOUNCE => BOUNCE,
			CIRCULAR => CIRC,
			EXPONENTIAL => EXPO,
			BACKWARDS => BACK,
			ELASTIC => ELASTIC
		];
		return longToShort[long];
	}

	// Other/Misc

	/**
	 * Depreacated in favor of FlxUIDropDownMenu.makeStrIdLabelArray
	 * @param arr `arr`
	 * @return `FlxUIDropDownMenu.makeStrIdLabelArray(arr, false)`
	 */
	@:deprecated("StfUtils.strNameLabelArrayFromStrArray is depreacated in favor of FlxUIDropDownMenu.makeStrIdLabelArray")
	public static function strNameLabelArrayFromStrArray(arr:Array<String>):Array<StrNameLabel>
	{
		var output:Array<StrNameLabel> = [];
		for (str in arr)
		{
			output.push(new StrNameLabel(str.replace(" ", ""), str));
		}
		return output;
	}
}

typedef TransitionData =
{
	var type:TransitionType;
	var duration:Float;
}

enum TransitionType
{
	NONE;
	FADE;
}

typedef FileName =
{
	var name:String;
	var ext:String;
}

typedef MainLevelSaveData =
{
	var name:String;
	var progressN:Float;
	var progressP:Float;
	var ?locked:Bool;
}

typedef CustomLevelSaveData =
{
	var name:String;
	var progressN:Float;
	var progressP:Float;
	var faved:Bool;
}

enum EaseNameShort
{
	LINEAR;
	QUAD;
	CUBE;
	QUART;
	QUINT;
	SMOOTHSTEP;
	SMOOTHERSTEP;
	SINE;
	BOUNCE;
	CIRC;
	EXPO;
	BACK;
	ELASTIC;
}

enum EaseName
{
	LINEAR;
	QUADRATIC;
	CUBIC;
	QUARTIC;
	QUINTIC;
	SMOOTHSTEP;
	SMOOTHERSTEP;
	SINUSOIDAL;
	BOUNCE;
	CIRCULAR;
	EXPONENTIAL;
	BACKWARDS;
	ELASTIC;
}

enum EaseType
{
	IN;
	OUT;
	INOUT;
}

typedef Ease =
{
	var name:EaseName;
	var type:EaseType;
}

typedef EaseShortName =
{
	var name:EaseNameShort;
	var type:EaseType;
}
