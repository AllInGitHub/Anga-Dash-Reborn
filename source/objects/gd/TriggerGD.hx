package objects.gd;

import backend.StfUtils;
import editor.EditorState;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;

@:access(states.PlayState)
class TriggerGD extends ObjectGD
{
	public static final mapArg:Map<Int, Array<Dynamic>> = [
		1 => [Float, Float, Float, String, Int], // [X, Y, Dur, Ease, Group]
		2 => [Float, Int, Float, String, Int], // [Rot, Extra360s, Dur, Ease, Group]
		3 => [Float, Float, Bool, Bool, Float, String, Int] // [ScaleX, ScaleY, FlipScaleX, FlipScaleY, Dur, Ease, Group]
	];

	public static final mapName:Map<Int, String> = [1 => "Move", 2 => "Rotate", 3 => "Scale"];

	public static final mapID:Map<Int, String> = [1 => 'move', 2 => 'obj_rot', 3 => 'scale'];

	public static final mapFunc:Map<String, (Args:Array<Dynamic>) -> Void> = [
		'move' => (Args) ->
		{
			// ObjectGD.objGroupMap;
			/* for (object => groups in ObjectGD.objGroupMap)
				{
					if (groups.contains(arguments[4]))
					{
						FlxTween.tween(object, {gridX: arguments[0], gridY: arguments[1]});
					}
			}*/
			// trace(cast(Args[4], Int));
			// trace(StfUtils.getGroup(cast(Args[4], Int)));
			// var esing:Dynamic = Args[3];
			// if (Args[3] is EaseShortName)
			// {
			// 	esing.name = StfUtils.easeShortToLong(Args[3].name);
			// }
			// var easing:Ease = cast(esing, {name: EaseName, type: EaseType});
			for (object in StfUtils.getGroup(cast(Args[4], Int)))
			{
				// gridX: Args[0], gridY: Args[1]
				var oldWorldPos = object.getPosition();
				var newWorldPos = StfUtils.convertFromGridPoint(FlxPoint.weak(object.gridX + cast(Args[0], Float), object.gridY + cast(Args[1], Float)));
				/* FlxTween.tween(object, {gridX: object.gridX + cast(Args[0], Float), gridY: object.gridY + cast(Args[1], Float)}, cast(Args[2], Float), {
					ease: StfUtils.getEase(Args[3].name, Args[3].type)
				});*/
				/* FlxTween.tween(object, {x: newWorldPos.x, y: newWorldPos.y}, Math.abs(cast(Args[2], Float)), {
					ease: StfUtils.getEase((Args[3] : Ease).name, (Args[3] : Ease).type)
				});*/
				FlxTween.tween(object, {x: object.x + (Args[0] : Float) * 60, y: object.y - (Args[1] : Float) * 60}, Math.abs(cast(Args[2], Float)), {
					ease: StfUtils.getEase((Args[3] : Ease).name, (Args[3] : Ease).type)
				});
				/* FlxTween.num(0.0, 1.0, Math.abs(cast(Args[2], Float)), {
						ease: StfUtils.getEase((Args[3] : Ease).name, (Args[3] : Ease).type)
					}, function(v)
					{
						object.x = FlxMath.lerp(oldWorldPos.x, newWorldPos.x, v);
						object.y = FlxMath.lerp(newWorldPos.y, oldWorldPos.y, 1.0 - v);
				});*/
			}
		},
		'obj_rot' => (Args) ->
		{
			for (object in StfUtils.getGroup(cast(Args[4], Int)))
			{
				FlxTween.tween(object, {angle: object.angle + cast(Args[0], Float) + cast(Args[1], Int) * 360}, cast(Args[2], Float), {
					ease: StfUtils.getEase((Args[3] : Ease).name, (Args[3] : Ease).type)
				});
			}
		},
		'scale' => (Args) ->
		{
			for (object in StfUtils.getGroup(cast(Args[6], Int)))
			{
				if (cast(Args[2], Bool))
					Args[0] = 1 / Args[0];
				if (cast(Args[3], Bool))
					Args[1] = 1 / Args[1];
				var scaley:FlxPoint = object.scale;
				FlxTween.tween(object.scale, {x: scaley.x * cast(Args[0], Float), y: scaley.y * cast(Args[1], Float)}, cast(Args[4], Float), {
					ease: StfUtils.getEase((Args[5] : Ease).name, (Args[5] : Ease).type)
				});
			}
		}
	];

	public var triggerID(default, null):Int = 1;
	public var args(default, null):Array<Dynamic> = [];

	/**
	 * Creates a Geometry Dash trigger
	 * @param Id Diddo
	 * @param GridX Diddo
	 * @param GridY Diddo
	 * @param Args Diddo but *only* applies to triggers
	 * @param Angle Diddo
	 * @param Scale Diddo
	 * @param Groups Diddo
	 */
	public function new(Id:Int = 1, GridX:Float = 0, GridY:Float = 0, ?Args:Array<Dynamic>, Angle:Float = 0, ?Scale:FlxPoint, ?Groups:Array<Int>)
	{
		if (Id <= 0)
			throw "Invalid trigger ID. The \"trigger\" will be treated as an object";
		if (Args == null)
			throw "Why? HOW!?";
		if (Args.length != mapArg[Id].length)
			throw "This is either a fuck up on my end, the modder's end, or you edited the level file because you were bored";
		super(-(triggerID = Id), GridX, GridY, Angle, Scale, Groups);
		args = Args;
		PlayState.level.levelTriggers.push(this);
	}

	var alreadyTriggered:Bool = false;

	public function trigger()
	{
		if (mapFunc.exists(mapID[triggerID]))
		{
			if (!alreadyTriggered)
			{
				alreadyTriggered = true;
				mapFunc[mapID[triggerID]](args);
			}
			// else
			// 	trace("Post trigger");
		}
		else
		{
			if (!(mapName.exists(triggerID) && mapID.exists(triggerID)))
				throw 'The trigger of ID ${triggerID} doesn\'t exist or is unfinished!';
			var data = 'The function for the ${mapName[triggerID]} trigger doesn\'t exist!';
			trace(data);
			FlxG.log.warn(data);
			#if debug
			if (PlayState.debugTxt != null)
				PlayState.addDebugText(data);
			#end
		}
	}

	override function update(elapsed:Float)
	{
		visible = FlxG.state is EditorState;
		visible = Std.isOfType(FlxG.state, EditorState);
		super.update(elapsed);
	}

	override function draw()
	{
		// I put `visible = FlxG.state is EditorState;` and
		// `visible = Std.isOfType(FlxG.state, EditorState);` here!
		// Where the property `visible` decides if it can be called!
		// I'm a dumbass! :D
		//												-All 69 Stoff
		super.draw();
	}
}
