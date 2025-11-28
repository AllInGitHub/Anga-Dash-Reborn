package editor;

import backend.StfUtils;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.StrNameLabel;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import haxe.exceptions.NotImplementedException;
import objects.gd.ObjectGD.EditorObjectGD;
import objects.gd.ObjectGD;
import objects.gd.TriggerGD;
import states.PlayState;

class EditorState extends FlxUIState
{
	// State
	var playState:PlayState;

	// Enums
	var testState:PlaytestState = STOPPED;
	var mode:EditorMode = PANNING;

	// UI
	// Data
	public static final pallete:Map<String, Array<Int>> = ["Blocks" => [0], "Hazards" => [1], "Triggers" => [-1]];

	// Objects
	var playTestButtoneer:FlxButton;
	var pauseTestButtoneer:FlxButton;
	var palleteUIBox:FlxUITabMenu;
	var editUIBox:FlxUITabMenu;
	var settingsUIBox:FlxUITabMenu;

	// Placing (Vars)
	static var atCursor:Null<Int> = null;

	// Sececton (FINALLY)
	public static var selection:Array<ObjectGD> = [];

	override function create()
	{
		playState.closeSubState();
		playState.create();
		playTestButtoneer = new FlxButton(0, 0, "Playtest (ENTER)", () ->
		{
			if (testState != STOPPED)
			{
				playTestButtoneer.text = "Playtest";
				testState = STOPPED;
				// playState.cubbi.update(0);
				playState.cubbi.setPosition();
				playState.create();
			}
			else
			{
				playTestButtoneer.text = "Stop Playtesting";
				testState = PLAYING;
				playState.removeObjs();
				playState.create();
				playState.cubbi.update(0);
			}
			playTestButtoneer.text += " (ENTER)";
		});
		playTestButtoneer.screenCenter(Y);
		add(playTestButtoneer);
		pauseTestButtoneer = new FlxButton(0, 0, "Pause (SHIFT + ENTER)", () ->
		{
			if (testState != PLAYING)
			{
				pauseTestButtoneer.text = "Pause";
				testState = PLAYING;
			}
			else
			{
				pauseTestButtoneer.text = "Resume / Unpause";
				testState = PAUSED;
			}
			pauseTestButtoneer.text += " (SHIFT + ENTER)";
		});
		pauseTestButtoneer.screenCenter(Y);
		pauseTestButtoneer.y += pauseTestButtoneer.height + 10;
		pauseTestButtoneer.visible = pauseTestButtoneer.active = false;
		// pauseTestButtoneer.cameras = [PlayState.cam];
		add(pauseTestButtoneer);

		// Palette
		var paletteTabs:Array<{name:String, label:String}> = [];
		paletteTabs.push({label: 'Settings', name: '.Settings'});
		for (key => _ in pallete)
		{
			paletteTabs.push({label: key, name: key});
		}

		palleteUIBox = new FlxUITabMenu(null, null, paletteTabs, FlxPoint.weak(), true);
		palleteUIBox.resize(FlxG.width, 100);
		palleteUIBox.setPosition(0, FlxG.height - palleteUIBox.height);
		palleteUIBox.scrollFactor.set();
		// palleteUIBox.tab;
		add(palleteUIBox);

		addSettingsTab();
		for (c => _ in pallete)
		{
			addObjectsToPallete(c);
		}

		var editTabs:Array<{name:String, label:String}> = [
			{
				name: 'mv',
				label: "Move"
			},
			{
				name: 'rt',
				label: "Rotate"
			},
			{
				name: 'sc',
				label: "Transform"
			},
			{
				name: 'flp',
				label: "Flip"
			},
		];
		editTabs.push({label: 'Settings', name: '.Settings'});
		editUIBox = new FlxUITabMenu(null, null, editTabs, FlxPoint.weak(), true);
		editUIBox.resize(FlxG.width, 100);
		editUIBox.setPosition(0, FlxG.height - palleteUIBox.height);
		editUIBox.scrollFactor.set();
		add(editUIBox);

		addSettingsTab(false);
		for (tab in editTabs)
		{
			addEditTabs(tab.name);
		}

		var settingsTabs = [{name: 'mde', label: "Mode"}];
		settingsUIBox = new FlxUITabMenu(null, null, settingsTabs, FlxPoint.weak(), true);
		settingsUIBox.resize(FlxG.width, 50);
		settingsUIBox.scrollFactor.set();
		add(settingsUIBox);

		for (tab in settingsTabs)
		{
			addSettingsTabs(tab.name);
		}

		super.create();
	}

	public static final palleteModes = ["Build", "Edit"];
	public static var palleteMode:Int = 0;

	function addSettingsTab(pallete = true)
	{
		var modeDropDown:FlxUIDropDownMenu;
		var dropDownData = {
			pos: FlxPoint.get(60, 10),
			callback: (s:String) ->
			{
				trace('id: $s');
				// set [palleteMode] to (s)
				palleteMode = Std.parseInt(s);
				if (pallete)
				{
					modeDropDown.selectedLabel = palleteModes[0];
				}
				else
				{
					modeDropDown.selectedLabel = palleteModes[1];
				}
			}
		};
		if (pallete)
		{
			var settingsTabGroup:FlxUI = new FlxUI(null, palleteUIBox);
			settingsTabGroup.name = '.Settings';

			// var palleteModesDropDownHeader:FlxUIDropDownHeader = new FlxUIDropDownHeader(120, null);
			var palleteModesDropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(dropDownData.pos.x, dropDownData.pos.y,
				FlxUIDropDownMenu.makeStrIdLabelArray(palleteModes, true), dropDownData.callback);
			palleteModesDropDown.selectedLabel = palleteModes[0];
			modeDropDown = palleteModesDropDown;

			// settingsTabGroup.add(palleteModesDropDownHeader);
			settingsTabGroup.add(palleteModesDropDown);

			palleteUIBox.addGroup(settingsTabGroup);
		}
		else
		{
			var settingsTabGroup:FlxUI = new FlxUI(null, editUIBox);
			settingsTabGroup.name = '.Settings';

			var palleteModesDropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(dropDownData.pos.x, dropDownData.pos.y,
				FlxUIDropDownMenu.makeStrIdLabelArray(palleteModes, true), dropDownData.callback);
			palleteModesDropDown.selectedLabel = palleteModes[1];
			modeDropDown = palleteModesDropDown;

			settingsTabGroup.add(palleteModesDropDown);

			editUIBox.addGroup(settingsTabGroup);
		}
	}

	function addSettingsTabs(name:String)
	{
		var tabGroup = new FlxUI(null, settingsUIBox);
		tabGroup.name = name;

		switch (name)
		{
			case 'mde':
				var modeThing:FlxUIDropDownMenu = new FlxUIDropDownMenu(FlxG.width / 2 - 60, 5,
					FlxUIDropDownMenu.makeStrIdLabelArray(EditorMode.getConstructors(), true), s ->
				{
					mode = EditorMode.createByIndex(Std.parseInt(s));
				});
				modeThing.selectedLabel = mode.getName();

				tabGroup.add(modeThing);
		}

		settingsUIBox.addGroup(tabGroup);
	}

	function addObjectsToPallete(category:String = 'Blocks')
	{
		var objectTabGroup:FlxUI = new FlxUI(null, palleteUIBox);
		objectTabGroup.name = category;
		// switch (category)
		// {
		// 	case 'Blocks':

		// 	default:
		// 		trace('Category $category not available yet');
		// }

		for (objId in pallete[category])
		{
			objectTabGroup.add(new EditorObjectGD(objId));
		}

		palleteUIBox.addGroup(objectTabGroup);
	}

	var objMoveAmt:Float = 60; // 1 block = 60 * 60 = 3,600 pixel sq

	function addEditTabs(category:String = 'mv')
	{
		if (category == 'Settings')
			return;
		var tabGroup = new FlxUI(null, settingsUIBox);
		tabGroup.name = category;

		switch (category)
		{
			case 'mv':
				final margin = 10;
				final spacing = 40;
				final size = 30;

				var dummyCallback = (dir:Int) ->
				{
					if (FlxG.random.bool(1)) // 1% chance of crashing (with '2' if CRASH_HANDLER_GEODE flag is set)
					{
						throw new NotImplementedException("No selection");
					}
					else
					{
						switch (dir)
						{
							case 0:
								lime.app.Application.current.window.x -= Std.int(objMoveAmt);
							case 1:
								lime.app.Application.current.window.y += Std.int(objMoveAmt);
							case 2:
								lime.app.Application.current.window.y -= Std.int(objMoveAmt);
							case 3:
								lime.app.Application.current.window.x += Std.int(objMoveAmt);
							default:
						}
					}
				}

				var mv_left:FlxUIButton = new FlxUIButton(margin, margin, '<', () ->
				{
					if (selection.length > 0)
					{
						for (obj in selection)
						{
							obj.x -= objMoveAmt;
							PlayState.level.level[obj.addr].gridX -= objMoveAmt / 60;
						}
					}
					else
						dummyCallback(0);
				});

				var mv_down:FlxUIButton = new FlxUIButton(margin + spacing, margin, 'V', () ->
				{
					if (selection.length > 0)
					{
						for (obj in selection)
						{
							obj.y += objMoveAmt;
							PlayState.level.level[obj.addr].gridY += objMoveAmt / 60;
						}
					}
					else
						dummyCallback(1);
				});

				var mv_up:FlxUIButton = new FlxUIButton(margin + spacing * 2, margin, '^', () ->
				{
					if (selection.length > 0)
					{
						for (obj in selection)
						{
							obj.y -= objMoveAmt;
							PlayState.level.level[obj.addr].gridY -= objMoveAmt / 60;
						}
					}
					else
						dummyCallback(2);
				});

				var mv_right:FlxUIButton = new FlxUIButton(margin + spacing * 3, margin, '>', () ->
				{
					if (selection.length > 0)
					{
						for (obj in selection)
						{
							obj.x += objMoveAmt;
							PlayState.level.level[obj.addr].gridX += objMoveAmt / 60;
						}
					}
					else
						dummyCallback(3);
				});

				mv_left.resize(size, size);
				mv_down.resize(size, size);
				mv_up.resize(size, size);
				mv_right.resize(size, size);

				tabGroup.add(mv_left);
				tabGroup.add(mv_down);
				tabGroup.add(mv_up);
				tabGroup.add(mv_right);

				var mv_amt:FlxUIDropDownMenu = new FlxUIDropDownMenu(margin, margin + spacing, [
					new StrNameLabel('0.5', "1/120 blocks (0.5 units)"),
					new StrNameLabel('1', "1/60 blocks (1 unit)"),
					new StrNameLabel('2', "1/30 blocks (2 units)"),
					new StrNameLabel('6', "1/10 blocks (6 units)"),
					new StrNameLabel('15', "1/4 blocks (15 units)"),
					new StrNameLabel('30', "1/2 blocks (30 units)"),
					new StrNameLabel('60', "1 block (60 units)"),
					new StrNameLabel('120', "2 blocks (120 units)"),
					new StrNameLabel('300', "5 blocks (300 units)"),
				], s ->
				{
					objMoveAmt = Std.parseFloat(s);
				});

				mv_amt.dropDirection = FlxUIDropDownMenuDropDirection.Up;
				mv_amt.selectedId = '60';

				tabGroup.add(mv_amt);
			default:
				var text = new FlxText(50, 0, FlxG.width, "Hello");
				// text.font = "assets/";
				tabGroup.add(text);
		}

		editUIBox.addGroup(tabGroup);
	}

	// Placing (Functions)
	function place()
	{
		if (palleteMode != 0)
			return;
		trace('Object at cursor: $atCursor');
		if (atCursor == null)
			return;
		var placePos:FlxPoint = StfUtils.convertToIntGridPoint(FlxG.mouse.getPosition());
		var placeData = {
			id: (atCursor : Int),
			gridX: placePos.x,
			gridY: placePos.y,
			angle: 0.0,
			scale: FlxPoint.weak(1, 1),
			arguments: ([] : Array<Dynamic>)
		};
		// PlayState.level.level.push(placeData);
		if (placeData.id < 0)
		{
			placeData.arguments = switch (placeData.id)
			{
				case -1: [0, 0, 0.5, {name: LINEAR, type: IN}, -1];
				case -2: [0, 0, 0.5, {name: LINEAR, type: IN}, -1];
				case -3: [1, 1, false, false, 0.5, {name: LINEAR, type: IN}, -1];
				default: [];
			}
			var placedTrigger:TriggerGD = new TriggerGD(-placeData.id, placeData.gridX, placeData.gridY, placeData.arguments);
			PlayState.level.level.push(placeData);
			playState.updateObjs();
			selection = [placedTrigger];
			return;
		}
		var placedObject:ObjectGD = new ObjectGD(atCursor, placePos.x, placePos.y, 0, null, []);
		PlayState.level.level.push(placeData);
		playState.updateObjs();
		selection = [placedObject];
	}

	public function new(fromState:FlxState, ?FallbackLevel:AngaLevel, ?FallbackLvlData:AngaLevelData, ?FallbackLvlContents:AngaLevelContents)
	{
		/* var nulls:Int = 0;
			if (FallbackLvlData == null)
				nulls++;
			if (FallbackLvlContents == null)
				nulls++;
			if (nulls == 1)
				FlxG.log.warn("FallbackLvlData == null XOR FallbackLvlContents == null is returning true!"); */
		if (StfUtils.xor(FallbackLvlData == null, FallbackLvlContents == null))
			FlxG.log.warn("FallbackLvlData == null XOR FallbackLvlContents == null is returning true!");
		super();
		if (fromState is PlayState)
		{
			var _stateLevel:AngaLevel = PlayState.level;
			playState = new PlayState(_stateLevel);
			// playState = cast(fromState, PlayState);
			// playState = new PlayState(new AngaLevel(_stateLevel.data, _stateLevel.level));
		}
		else
		{
			playState = new PlayState(FallbackLevel ?? new AngaLevel(FallbackLvlData ?? AngaLevel.base, FallbackLvlContents ?? []));
		}
	}

	override function update(elapsed:Float)
	{
		playState.cubbi.visible = true;
		if (testState == PLAYING)
			playState.tryUpdate(elapsed);
		else if (testState == STOPPED)
			playState.cubbi.visible = false;
		pauseTestButtoneer.visible = pauseTestButtoneer.active = (testState != STOPPED);
		if (FlxG.keys.justPressed.ENTER)
		{
			if (FlxG.keys.pressed.SHIFT)
				pauseTestButtoneer.onUp.fire(); // SHIFT + Enter
			else
				playTestButtoneer.onUp.fire(); // Enter
		}
		if (FlxG.mouse.pressed && testState != PLAYING && (mode == PANNING || mode == PANNENNING))
		{
			playState.moveCamera(FlxPoint.weak(-FlxG.mouse.deltaScreenX, -FlxG.mouse.deltaScreenY));
		}
		if (FlxG.mouse.justReleased && testState != PLAYING && mode == PLACING && palleteUIBox.visible)
			place();
		var visibilityChange = false;
		if (testState != PLAYING && (palleteUIBox.visible || editUIBox.visible))
			visibilityChange = true;
		switch (palleteModes[palleteMode])
		{
			case "Build":
				palleteUIBox.visible = palleteUIBox.active = testState != PLAYING;
				editUIBox.visible = editUIBox.active = false;
			case "Edit":
				palleteUIBox.visible = palleteUIBox.active = false;
				editUIBox.visible = editUIBox.active = testState != PLAYING;
			case "Delete": // Unused
			case "View": // Unused
		}
		// palleteUIBox.visible = palleteUIBox.active = testState != PLAYING;
		// editUIBox.visible = editUIBox.active = testState != PLAYING;
		settingsUIBox.visible = settingsUIBox.active = testState != PLAYING;
		@:privateAccess
		if (visibilityChange)
		{
			palleteUIBox._onTabEvent(palleteUIBox._selected_tab_id);
			editUIBox._onTabEvent(editUIBox._selected_tab_id);
			settingsUIBox._onTabEvent(settingsUIBox._selected_tab_id);
		}
		if (testState != PLAYING)
		{
			for (obj in PlayState.levelContents)
			{
				obj.editorUpdate(elapsed);
			}
		}
		else
			selection = []; // Clear Selecton
		super.update(elapsed);
	}

	override function draw()
	{
		playState.draw();
		super.draw();
	}

	override function destroy()
	{
		atCursor = null;
		selection = [];
		super.destroy();
	}
}

enum PlaytestState
{
	STOPPED;
	PAUSED;
	PLAYING;
}

enum EditorMode
{
	PLACING;
	PANNING;
	PANNENNING; // Get it? Pan? Pannen? Pannenkoek2012?
}
