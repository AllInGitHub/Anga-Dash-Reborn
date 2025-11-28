package backend;

import flixel.FlxG;
import flixel.util.FlxSave;

/**
 * Save data made for settings
 */
class SaveData
{
	public var test:Dynamic;

	public function new() {}
}

/**
 * Save data not made for settings! (Go add setting fields in `SaveData` instead)
 */
class SaveDataOther
{
	/*
		Format:
		[  "Name"   ,       0.0       ,        0.0        ,        false       ]
		 Level Name | Normal Progress | Practice Progress | (OPTIONAL) Unlocked

		Note: The "Unlocked" optional property was made soley for the demon, tower, and secret levels
		(["Name", 0.0, 0.0])
		(["Name", 0.0, 0.0, false])

		(
			["", 0.0, 0.0],
			["", 0.0, 0.0]
		)

		(
			["", 0.0, 0.0, false],
			["", 0.0, 0.0, false]
		)
	 */
	public var mainLevels:Array<Array<Dynamic>> = [
		// Classic (from Geometry Dash)
		["Stereo Madness", 0.0, 0.0], // ForeverBound
		["Back on Track", 0.0, 0.0], // DJVI
		["Polargeist", 0.0, 0.0], // Step
		["Dry Out", 0.0, 0.0], // DJVI
		["Base After Base", 0.0, 0.0], // DJVI
		["Can't Let Go", 0.0, 0.0], // DJVI
		["Jumper", 0.0, 0.0], // Waterflame
		["Time Machine", 0.0, 0.0], // Waterflame
		["Cycles", 0.0, 0.0], // DJVI
		["xStep", 0.0, 0.0], // DJVI
		["Clutterfunk", 0.0, 0.0], // Waterflame
		["Theory of Everything", 0.0, 0.0], // DJ Nate
		["Electroman Adventures", 0.0, 0.0], // Waterflame
		["Clubstep", 0.0, 0.0, false], // DJ Nate
		["Electrodynamix", 0.0, 0.0], // DJ Nate
		["Hexagon Force", 0.0, 0.0], // Waterflame
		["Blast Processing", 0.0, 0.0], // Waterflame
		["Theory of Everything 2", 0.0, 0.0, false], // DJ Nate
		["Geometrical Dominator", 0.0, 0.0], // Waterflame
		["Deadlocked", 0.0, 0.0, false], // F-777
		["Fingerdash", 0.0, 0.0], // MDK
		["Dash", 0.0, 0.0], // MDK
		// Platformer (from Geometry Dash)
		["The Tower", 0.0, 0.0, true], // Kevin Macleod (Desert City)
		["The Sewers", 0.0, 0.0, false], // Kevin Macleod (Scheeming Weasel Faster), Sebaravila (Stranding)
		["The Cellar", 0.0, 0.0, false], // Cyberwave Orchestra (The Secret Cave), Atlas Reach (Dungeon 09)
		["The Secret Hollow", 0.0, 0.0, false], // Daniel Carl (Awakening of Darknes), Ostinarium (Casual Game Music 09), Boom Kitty (Tomb)
		// Classic (Anga)
		["Badland", 0.0, 0.0], // Boom Kitty
		["What's Your Favorite Retro Bass", 0.0, 0.0], // HeeminYT
		["What's Your Favorite Retro Bass 2", 0.0, 0.0], // HeeminYT
		["What's Your Favorite Retro Bass Full", 0.0, 0.0, false], // HeeminYT
		["What's Your Favorite Retro Bass RMX", 0.0, 0.0, false], // AGhostJR
		["BANGER WANGER GEOMETRY PLAYER", 0.0, 0.0], // KingSammelot
		["RESONATING RACE", 0.0, 0.0], // KingSammelot
		["Jazzy Juice", 0.0, 0.0], // KingSammelot
		["Moon Fries", 0.0, 0.0], // KingSammelot
		["SHPLOINK OVERDOSE", 0.0, 0.0, false], // KingSammelot
		// ["At The Speed of Light", 0.0, 0.0, false], // Dimrain47
		["Peepee Song", 0.0, 0.0], // Boom Kitty
		["StanleyMIX (Name Unofficial)", 0.0, 0.0, false], // DJSweets
		["Woah", 0.0, 0.0], // Wulzy (ft. Juniper)
		["Dash All Night", 0.0, 0.0, false], // Sdslayer
		[
			"Good Idea (Why People Say This Sound Like JSAB and Geometry Dash)", // Is this even a name anymore?
			0.0,
			0.0,
			false
		], // Suchro
		// Platformer (Anga)
		// Secrets (Anga Exclusive)
		["Messing Around with The 2A03", 0.0, 0.0, false], // SquareWave
		["Triangle In The Club", 0.0, 0.0, false], // Lukas Erikson (Triangle tweakin')
		["The Scariest Sound Chip", 0.0, 0.0, false], // TIA: Terrifyingly
		["TECHNO.COM", 0.0, 0.0, false], // >>Do not touch the keyboard<<
		["Famicom Music Slander", 0.0, 0.0, false], // HeeminYT
		["Sunsoft Bass Party", 0.0, 0.0, false], // HeeminYT
		["Square Thing", 0.0, 0.0, false], // HeeminYT
		["1STPAI", 0.0, 0.0, false],
		["Messing Arround zith The QY8910", 0.0, 0.0, false],
		/*
			Here are my ideas on how to unlock the levels:
			4D 65 73 73 69 6E 67 20 41 72 6F 75 6E 64 20 77 69 74 68 20 54 68 65 20 32 41 30 33 3A 20 44 69 65 20 6F 72 20 72 65 73 65 74 20 30 78 32 41 30 33 20 28 31 30 37 35 35 29 20 74 69 6D 65 73 20 69 6E 20 61 6E 79 20 6C 65 76 65 6C 0D 0A 54 72 69 61 6E 67 6C 65 20 49 6E 20 54 68 65 20 43 6C 75 62 3A 20 43 72 65 61 74 65 20 61 20 64 61 73 68 20 6F 72 62 20 72 6F 74 61 74 65 64 20 74 68 65 20 77 72 6F 6E 67 20 77 61 79 0D 0A 54 68 65 20 53 63 61 72 69 65 73 74 20 53 6F 75 6E 64 20 43 68 69 70 3A 20 42 65 61 74 20 4D 65 73 73 69 6E 67 20 41 72 6F 75 6E 64 20 77 69 74 68 20 54 68 65 20 32 41 30 33 20 64 75 72 69 6E 67 20 4F 63 74 6F 62 65 72 20 6F 72 20 67 65 74 20 39 35 2D 39 39 25 20 6F 6E 20 4D 65 73 73 69 6E 67 20 41 72 6F 75 6E 64 20 77 69 74 68 20 54 68 65 20 32 41 30 33 0D 0A 54 45 43 48 4E 4F 2E 43 4F 4D 3A 20 54 79 70 65 20 22 54 45 43 48 4E 4F 22 20 77 68 69 6C 65 20 69 6E 20 74 68 65 20 6D 65 6E 75 0D 0A 46 61 6D 69 63 6F 6D 20 4D 75 73 69 63 20 53 6C 61 6E 64 65 72 3A 20 54 79 70 65 20 22 55 73 65 72 53 6E 69 70 65 72 22 20 77 68 69 6C 65 20 69 6E 20 74 68 65 20 6D 65 6E 75 20 0D 0A 53 71 75 61 72 65 20 54 68 69 6E 67 3A 20 53 75 63 75 6D 62 20 74 6F 20 74 68 65 20 32 41 30 33 20 28 44 69 65 20 61 74 20 31 25 20 6F 6E 20 4D 65 73 73 69 6E 67 20 41 72 6F 75 6E 64 20 77 69 74 68 20 54 68 65 20 32 41 30 33 29 0D 0A 31 53 54 50 41 49 3A 20 54 79 70 65 20 22 74 61 69 6B 6F 20 6C 76 6C 20 33 31 22 20 77 68 69 6C 65 20 69 6E 20 74 68 65 20 6D 65 6E 75
		 */
	];

	/*
		Format:
		[  "Name"   ,       0.0       ,        0.0        , false]
		 Level Name | Normal Progress | Practice Progress | Faved

		(["Name", 0.0, 0.0]) INVALID
		(["Name", 0.0, 0.0, false]) VALID

		(
			["", 0.0, 0.0], // INVALID
			["", 0.0, 0.0] // INVALID
		)

		(
			["", 0.0, 0.0, false], // VALID
			["", 0.0, 0.0, false] // VALID
		)
	 */
	public var downloadedCustomLevels:Array<Array<Dynamic>> = [];

	public function new() {}
}

class ClientPrefs
{
	// Settings
	public static final defaultData:SaveData = new SaveData();
	public static var data:SaveData = new SaveData();

	// Not Settings
	public static final defaultDataOther:SaveDataOther = new SaveDataOther();
	public static var dataOther:SaveDataOther = new SaveDataOther();

	/**
	 * A custom savefile for things other than settings
	 */
	public static var saveFile(default, null):FlxSave;

	/**
	 * Used in `Main.hx`
	 */
	public static function setup()
	{
		if (saveFile == null)
			saveFile = new FlxSave();
		if (FlxG.save.isBound && saveFile.isBound)
			return; // Save already bound
		trace("Making save data for settings using FlxG.save.bind");
		FlxG.save.bind('AngaDashRebornSettings');
		trace("Done!");
		trace("Making save data for other s**t using ClientPrefs.saveFile.bind");
		saveFile.bind('AngaDashRebornOther');
		trace("Done!");
	}

	public static function saveSettings()
	{
		for (k in Reflect.fields(data))
		{
			Reflect.setField(FlxG.save.data, k, Reflect.field(data, k));
		}
	}

	public static function saveOther()
	{
		for (k in Reflect.fields(dataOther))
		{
			Reflect.setField(saveFile.data, k, Reflect.field(dataOther, k));
		}
	}

	/**
	 * Saves everything to save files!
	 */
	public static function save()
	{
		saveSettings();
		saveOther();
	}

	/**
	 * Loads the save files!
	 */
	public static function load()
	{
		for (k in Reflect.fields(FlxG.save.data))
		{
			if (/* Reflect.hasField(FlxG.save.data, k) && */ Reflect.hasField(data, k))
			{
				Reflect.setField(data, k, Reflect.field(FlxG.save.data, k));
			}
		}
		for (k in Reflect.fields(saveFile.data))
		{
			if (/* Reflect.hasField(saveFile.data, k) && */ Reflect.hasField(dataOther, k))
			{
				Reflect.setField(dataOther, k, Reflect.field(saveFile.data, k));
			}
		}
	}

	/**
	 * A risky action!
	 * 
	 * Wipes all your save files (both `FlxG.save` (linked to `ClientPrefs.data`
	 * and `ClientPrefs.defaultData`) and `ClientPrefs.saveFile` (linked to
	 * `ClientPrefs.dataOther` and `ClientPrefs.defaultDataOther`))
	 * 
	 * When this is called. The player must say goodbye to their save files.
	 * Hope they've backed it up before this is called
	 */
	public static function wipe()
	{
		return FlxG.save.erase() && saveFile.erase();
	}
}
