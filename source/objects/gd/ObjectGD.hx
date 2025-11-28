package objects.gd;

import flixel.util.FlxColor;
import states.PlayState;
import backend.Hitbox;
import backend.StfUtils;
import editor.EditorState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUISpriteButton;
import flixel.math.FlxPoint;

class ObjectGD extends FlxSprite
{
	/**
	 * Starting `gridX`
	 */
	public var ogGridX(default, null):Float = 0;

	/**
	 * Starting `gridY`
	 */
	public var ogGridY(default, null):Float = 0;

	/**
	 * Starting `angle`
	 */
	public var ogAngle(default, null):Float = 0;

	/**
	 * Starting `scale`
	 */
	public var ogScale(default, null):FlxPoint = FlxPoint.get(1, 1);

	/**
	 * The object's ID in the object palette, not the level
	 * 
	 * Negative values are reserved for triggers. Essentially doubling the (theoretical) ammount of palette object slots
	 * from 2,147,483,647 (GD 1.0 - 2.204 (PC)/2.205 (Mobile)) to 4,294,967,296 (ADR) in 32 bits with 2,147,483,648 objects and 2,147,483,648
	 * triggers max!
	 */
	public var id(default, null):Int = 0;

	public var groups:Array<Int> = [];

	// "Addresses"
	static var addrEnumerator:Int = 0;

	/**
	 * The object's ID in the level, not its actual address in RAM
	 */
	public var addr(default, null):Int = addrEnumerator++;

	/**
	 * Just like the inherited `x` property from `FlxObject`, but in grid space
	 */
	public var gridX(get, set):Float;

	/**
	 * Just like the inherited `y` property from `FlxObject`, but in grid space
	 */
	public var gridY(get, set):Float;

	/**
	 * The color channel the object uses
	 */
	public var colorChannel:Int = 0;

	/**
	 * Just like `TriggerGD`'s `args` but for certain objects!
	 * > I also renamed it so there's no conflict between the two feilds
	 */
	public var parameters:Array<Dynamic>;

	// Hitbox

	/**
	 * The object's hitbox
	 */
	public var hitbox(default, null):Hitbox;

	/**
	 * The hitbox's offsets
	 */
	public var hitboxOffset(default, null):FlxPoint;

	// Additional group stuff
	public static var objGroupMap:Map<ObjectGD, Array<Int>> = [];
	public static var groupObjMap:Map<Int, Array<ObjectGD>> = [-1 => []];

	@:allow(states.PlayState) @:allow(editor.EditorState) var dontDestroy:Bool = false;

	/**
	 * Creates an object from Geometry Dash
	 * @param Id The object ID. Negative IDs are reserved for `TriggerGD` objects
	 * @param GridX The object's `x` in the grid. Goes to `object.gridX` and `object.ogGridX`
	 * @param GridY The object's `y` in the grid. Goes to `object.gridY` and `object.ogGridY`
	 * @param Angle The object's spawning `angle`. Goes to `object.angle` and `object.ogAngle`
	 * @param Scale **Stretch** (Goes to `object.scale` and `object.ogScale`)
	 * @param Groups `Groups` (Yeah I have no idea what to put here)
	 * @param Args Object arguments (Only applies to certain objects like text and triggers)
	 */
	public function new(Id:Int = 0, GridX:Float = 0, GridY:Float = 0, Angle:Float = 0, ?Scale:FlxPoint, ?Groups:Array<Int>, ?ColorChannel:Int = 0,
			?Args:Array<Dynamic>)
	{
		// trace(addr);
		moves = !(immovable = true);
		ogGridX = gridX = GridX;
		ogGridY = gridY = GridY++;
		ogAngle = angle = Angle;
		colorChannel = ColorChannel;
		if (Args != null)
			parameters = Args;
		if (Scale != null)
			ogScale = scale = Scale;
		super(GridX * 60, FlxG.height - GridY * 60, Id >= 0 ? 'assets/images/objects/ids/$Id.png' : 'assets/images/triggers/ids/${- Id}.png');
		id = Id;
		// var j:Int = 0;
		if (Groups == null)
			groups = [-1];
		else
			groups = [-1].concat(Groups);
		objGroupMap.set(this, groups);
		color = PlayState.level.data.colors[colorChannel];
		for (group in groups)
		{
			// if (groupObjMap.exists(group) && groupObjMap.get(group).contains(this))
			// 	continue;
			if (groupObjMap.exists(group))
			{
				var groupHasThis:Bool = false;
				for (obj in groupObjMap[group])
				{
					if (obj == null)
					{
						obj = this;
						continue;
					}
					// trace('obj.addr: ${obj.addr}, this.addr: ${this.addr}');
					if (obj.addr == this.addr)
					{
						// trace('${obj.addr} == ${this.addr}');
						groupHasThis = true;
					}
				}
				if (groupHasThis)
					continue;
				groupObjMap.get(group).push(this);
			}
			else
				groupObjMap.set(group, [this]);
		}
		if (Id <= -1)
		{
			hitbox = new Hitbox(0, 0, 60, 60);
			hitbox.immovable = !(hitbox.moves = false);
			update_hitboxOffs();
			visible = false;
			return;
		}

		// Defining the object's hitbox
		switch (id)
		{
			case 1:
				hitbox = new Hitbox(25, 17, 10, 27);
			default:
				hitbox = new Hitbox(0, 0, 60, 60);
		}
		update_hitboxOffs();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		hitbox.setPosition(hitboxOffset.x + x, hitboxOffset.y + y);
		color = PlayState.level.data.colors[colorChannel];
	}

	public function editorUpdate(elapsed:Float)
	{
		//// Wait for selecting to be implemented, then do this
		color = PlayState.level.data.colors[colorChannel];
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this) && EditorState.palleteMode == 1)
		{
			var isSelectable:Bool = true;
			for (i in EditorState.selection)
				if (i.addr == this.addr)
					isSelectable = false; // If object already selected, no need to select it again
			if (isSelectable)
			{
				if (FlxG.keys.pressed.SHIFT)
					EditorState.selection.push(this);
				else
					EditorState.selection = [this];
			}
			trace('Selection: ${EditorState.selection}');
		}

		for (i in EditorState.selection)
			if (i.addr == this.addr)
				this.color = FlxColor.LIME;
	}

	public function getGridPosition(?fallbackResult:FlxPoint):FlxPoint
	{
		// return FlxPoint.get(gridX, gridY);
		return StfUtils.convertToGridPoint(getPosition(fallbackResult));
	}

	public function setGridPosition(GridX:Float = 0.0, GridY:Float = 0.0):FlxPoint
	{
		// return FlxPoint.get(gridX, gridY);
		gridX = GridX;
		gridY = GridY;
		return StfUtils.convertToGridPoint(getGridPosition(FlxPoint.weak()));
	}

	function update_hitboxOffs()
	{
		if (hitboxOffset == null)
			hitboxOffset = FlxPoint.get(hitbox.x, hitbox.y);
	}

	@:noCompletion private function set_gridX(value:Float):Float
	{
		return x = StfUtils.convertFromGridPoint(FlxPoint.weak(value, 0)).x;
	}

	@:noCompletion private function set_gridY(value:Float):Float
	{
		return y = StfUtils.convertFromGridPoint(FlxPoint.weak(0, value)).y;
	}

	@:noCompletion private function get_gridX():Float
	{
		return StfUtils.convertToGridPoint(getPosition()).x;
	}

	@:noCompletion private function get_gridY():Float
	{
		return StfUtils.convertToGridPoint(getPosition()).y;
	}

	override function destroy()
	{
		if (!dontDestroy)
		{
			super.destroy();
			objGroupMap = [];
			groupObjMap = [-1 => []];
		}
		dontDestroy = false;
		// addrEnumerator = 0;
	}

	@:allow(states.PlayState) @:allow(editor.EditorState) function resetObject()
	{
		scale = ogScale;
		gridX = ogGridX;
		gridY = ogGridY;
		angle = ogAngle;
		alpha = 1;
	}

	override function toString():String
	{
		return super.toString() + ' | ' + flixel.util.FlxStringUtil.getDebugString([
			flixel.util.FlxStringUtil.LabelValuePair.weak("id", id),
			flixel.util.FlxStringUtil.LabelValuePair.weak("gridX", gridX),
			flixel.util.FlxStringUtil.LabelValuePair.weak("gridY", gridY),
			flixel.util.FlxStringUtil.LabelValuePair.weak("addr", addr)
		]);
	}
}

@:allow(editor.EditorState) class EditorObjectGD extends FlxUISpriteButton
{
	public var id:Int = 0;

	public static final sprOffset = FlxPoint.get();

	public function new(Id:Int = 0, i:Int = 0)
	{
		id = Id;
		super((i * 70) % Math.floor(FlxG.width / 70) * 70, Math.floor((i * 70) / Math.floor(FlxG.width / 70)) * 70,
			new FlxSprite(sprOffset.x, sprOffset.y, Id >= 0 ? 'assets/images/objects/ids/$Id.png' : 'assets/images/triggers/ids/${- Id}.png'),
			setObjectToCursor);
		resize(2 * sprOffset.x + 60, 60 + sprOffset.y * 2);
	}

	@:access(editor.EditorState)
	function setObjectToCursor()
	{
		EditorState.atCursor = id;
	}
}
