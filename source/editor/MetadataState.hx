package editor;

import backend.StfUtils;
import backend.SwagSongDaw;
import backend.SwagSongMeta;
import flixel.FlxG;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.StrNameLabel;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.net.FileFilter;
import tjson.TJSON.FancyStyle;

class MetadataState extends FlxUIState
{
	var nameField:FlxUIInputText;
	var composerField:FlxUIInputText;
	var dawField:FlxUIInputText;
	var dawDropDown:FlxUIDropDownMenu;
	var saveBtn:FlxUIButton;
	var loadBtn:FlxUIButton;

	var dataProvided:Bool = true;
	var jsonData:SwagSongMeta = {
		name: "Unknown",
		composer: "Nobody",
		composers: ["Nobody", "NoOne", "NoPony"],
		daw: UNKNOWN
	};
	var saved:Bool = false;

	function getFieldWidth():Int
		return Std.int(FlxG.width / 3);

	override function create()
	{
		if (dataProvided)
			saved = true;
		// Defining Objects
		nameField = new FlxUIInputText(0, 0, getFieldWidth(), dataProvided
			|| jsonData != null ? jsonData.name : "Unknown", 16, 0xFF000000, 0xFFFFFFFF);
		composerField = new FlxUIInputText(0, 0,
			getFieldWidth(), dataProvided || jsonData != null ? (jsonData.composers == null ? jsonData.composer : StfUtils.arrayToStr(jsonData.composers)) : "Nobody",
			16,
			0xFF000000, 0xFFFFFFFF);
		dawField = new FlxUIInputText(0, 0, getFieldWidth(), dataProvided
			|| jsonData != null ? jsonData.daw.getName() : UNKNOWN.getName(), 16, 0xFF000000,
			0xFFFFFFFF);
		dawDropDown = new FlxUIDropDownMenu(0, 0, FlxUIDropDownMenu.makeStrIdLabelArray(SwagSongDaw.getConstructors(), false), s ->
		{
			saved = false;
			// if (SwagSongDaw.getConstructors().contains(s))
			jsonData.daw = SwagSongDaw.createByName(s);
		});
		// var a = FlxUIDropDownMenu.makeStrIdLabelArray(SwagSongDaw.getConstructors(), true);
		saveBtn = new FlxUIButton(0, 0, "Save", save, true, false);
		loadBtn = new FlxUIButton(0, 0, "Load", load, true, false);

		// Positioning
		nameField.screenCenter();
		nameField.y -= nameField.height + 10;
		composerField.screenCenter();
		dawField.screenCenter();
		dawField.y += composerField.height + 10;
		dawDropDown.screenCenter();
		dawDropDown.y = composerField.y + composerField.height + 10;
		saveBtn.screenCenter();
		loadBtn.screenCenter();
		saveBtn.y += composerField.height + dawField.height + 20;
		loadBtn.y += composerField.height + dawField.height + 20;
		saveBtn.x -= saveBtn.width / 2 + 5;
		loadBtn.x += loadBtn.width / 2 + 5;

		// Misc Modifications
		nameField.callback = (s1, s2) ->
		{
			saved = false;
			jsonData.name = nameField.text;
		};

		composerField.callback = (s1, s2) ->
		{
			saved = false;
			if (composerField.text.contains(","))
			{
				jsonData.composers = StfUtils.stringToArr(composerField.text);
				jsonData.composer = null;
			}
			else
			{
				jsonData.composer = composerField.text;
				jsonData.composers = null;
			}
		};

		dawField.callback = (s1, s2) ->
		{
			saved = false;
			if (SwagSongDaw.getConstructors().contains(dawField.text))
				jsonData.daw = SwagSongDaw.createByName(dawField.text);
		};

		dawDropDown.selectedLabel = jsonData.daw.getName();

		// Adding
		add(nameField);
		add(composerField);
		// add(dawField);
		add(dawDropDown);
		add(saveBtn);
		add(loadBtn);
		// Extra Sprites
		add(new FlxText(0, nameField.y, nameField.x, "Song Name: ").setFormat(null, 16, 0xffffffff, FlxTextAlign.RIGHT));
		add(new FlxText(0, composerField.y, composerField.x, "Composer(s): ").setFormat(null, 16, 0xffffffff, FlxTextAlign.RIGHT));
		add(new FlxText(0, dawField.y, dawField.x, "DAW Used: ").setFormat(null, 16, 0xffffffff, FlxTextAlign.RIGHT));
		super.create();
	}

	public function save()
	{
		// Save Meta
		StfUtils.openDialog(true, event -> {}, event -> {}, event -> {}, Json.encode(StfUtils.saveMeta(jsonData), new FancyStyle("\t")), {
			name: "metadata",
			ext: 'json'
		});
		saved = true;
	}

	@:access(backend.StfUtils)
	public function load()
	{
		// Load Meta
		var data = "";
		if (!saved)
			lime.app.Application.current.window.alert("Are you sure you want to load another song's metadata? All changes will be lost\nAfter clicking OK, click Cancel on the dialog popup if you want to go back and save",
				"Unsaved Song Data!");
		StfUtils.openDialog(false, event ->
		{
			data = StfUtils.loadedFile;
			// var decoded:SwagSongMeta = {
			// 	name: "Bluu Song",
			// 	composer: "KawaiiSprite",
			// 	composers: ["KawaiiSprite", "Funkin' Sound Team"],
			// 	daw: ABLETON
			// };
			var decoded:SwagSavedSongMeta = {
				name: "Bluu Song",
				composer: "KawaiiSprite",
				composers: ["KawaiiSprite", "Funkin' Sound Team"],
				daw: "ABLETON"
			};
			var dummyDecoded:Dynamic = {};

			if (data.startsWith("{") && data.endsWith("}"))
			{
				dummyDecoded = cast Json.parse(data);
				var loadFailed:Bool = false;
				// for (field in Reflect.fields(dummyDecoded))
				// {
				if ((!Reflect.hasField(dummyDecoded, "name") || !Reflect.hasField(dummyDecoded, "daw"))
					|| (!Reflect.hasField(dummyDecoded, "composer") && !Reflect.hasField(dummyDecoded, "composers")))
				{
					loadFailed = true;
					// break;
				}
				// }

				if (loadFailed)
				{
					dummyDecoded = {
						name: "Song Load Failed",
						composer: "Song does not have required fields",
						daw: "UNKNOWN"
					};
					data = Json.encode(dummyDecoded, new FancyStyle('\t'));
				}
				decoded = cast dummyDecoded;
				FlxG.switchState(new MetadataState(data));
				// jsonData = StfUtils.loadMeta(decoded);
			}
			trace("Metadata loaded successfuly");
		}, event -> {}, event -> {}, "Json.encode(jsonData, new FancyStyle(\"\\t\"))", {
				name: "metadata",
				ext: 'json'
		}, [new FileFilter("JSON Metadata", "json")]);
	}

	public function new(?JsonData:String)
	{
		try
		{
			if (JsonData != null)
				jsonData = cast StfUtils.loadMeta(Json.parse(JsonData));
			else
				dataProvided = false;
		}
		catch (e)
		{
			dataProvided = false;
			jsonData = {
				name: "Unknown",
				composer: "Nobody",
				composers: ["Nobody", "NoOne", "NoPony"],
				daw: UNKNOWN
			};
		}
		super();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
