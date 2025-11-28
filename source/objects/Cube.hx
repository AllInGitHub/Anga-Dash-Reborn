package objects;

import flixel.system.FlxAssets;
import backend.StfUtils;
import editor.EditorState;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import objects.gd.TriggerGD;
import states.PlayState;

class Cube extends FlxSprite
{
	public static final speeds:Map<Speed, Float> = [HALF_X => 8.6, ONE_X => 10.4, TWO_X => 12.96, THREE_X => 15.6, FOUR_X => 19.27];

	public var speed:Speed = ONE_X;
	public var gameType(default, null):GameType = CLASSIC;
	public var airborne(get, set):Bool;
	public var grounded(get, set):Bool;

	// Constant Multipliers
	// 1599.486
	public static final jumpForce:Float = 399.8715; // Yikes!
	public static final spaceTimeMod:Float = 1.5;
	public static final jumpMultMain:Float = 3;

	// Properties the creator can mess with in the editor
	public var jumpMult:Float = 1.0;
	public var gravityMult:Float = 1.0;
	public var reversed:Bool = false;

	public var dir(default, null):Int = 1;
	public var dirf(default, null):Float = 1.0;
	public var dir2(default, null):Int = 1;
	public var dirf2(default, null):Float = 1.0;

	@:noCompletion var _airborne:Bool = true;
	@:noCompletion var _grounded:Bool = false;
	var airTime:Float = 0;

	// var _cache:{grounded:Bool} = {
	// 	grounded: false
	// };

	public function new(?gametype:GameType)
	{
		gameType = gametype == null ? CLASSIC : gametype;
		super();
		loadGraphic("assets/images/cube.png");
		// cameras = [PlayState.camGame];
		// screenCenter(X);
		// x -= 150;
		y = StfUtils.convertFromGridPoint(FlxPoint.get(0, 1)).y;
		// if (gameType == CLASSIC)
		// 	velocity.x = speeds.get(speed) * FlxG.updateFramerate;
		// else
		// 	dirf = 0;
		if (gameType == PLAT)
			dirf = 0;
		velocity.zero();
		maxVelocity.y = 2 * Math.abs(jumpForce * jumpMultMain);
	}

	override function update(elapsed:Float)
	{
		if (airborne)
			airTime += elapsed;
		acceleration.y = 4467.8412 * gravityMult * spaceTimeMod; // Yikes²!
		grounded = y >= FlxG.height - height;
		super.update(elapsed);
		// updateObjCollision();
		dirf = FlxMath.lerp(dirf, dir, 0.1 * spaceTimeMod);
		dirf2 = FlxMath.lerp(dirf2, dir2, 0.1 * spaceTimeMod);
		updateObjCollision();
		if (grounded)
		{
			// Ground Case
			if (y >= FlxG.height - height)
			{
				y = FlxG.height - height;
			}
			// Snap angle to the nearest multiple of 90
			angle = (Math.fround(angle / 90) * 90) % 360;
			// Reset velocity and angularVelocity
			velocity.y = angularVelocity = 0;
			// You can jump while grounded!
			if (PlayState.input)
			{
				jump();
			}
		}
		else
		{
			angularVelocity = 360 * dirf2;
		}

		if (gameType == PLAT)
		{
			if (PlayState.inputPlatL)
				dir2 = dir = -1;
			else if (PlayState.inputPlatR)
				dir2 = dir = 1;
			else
				dir2 = 0;
		}
		else
		{
			dirf2 = dir2 = 1;
		}
		velocity.x = dirf2 * speeds.get(speed) * FlxG.updateFramerate * spaceTimeMod;
		/* for (obj in PlayState.level.level)
			{
				if ((obj is TriggerGD) && obj.x <= x)
					cast(obj, TriggerGD).trigger();
		}*/
		for (trigger in PlayState.level.levelTriggers)
		{
			if (trigger.x <= x)
				trigger.trigger();
		}
		// updateObjCollision();
	}

	function updateObjCollision()
	{
		// FlxObject.SEPARATE_BIAS = 10;
		for (obj in PlayState.levelContents)
		{
			// Ignore this
			/* FlxG.overlap(this, obj.hitbox, function objectCollision(_a:FlxBasic, _b:FlxBasic)
				{
					switch (obj.id)
					{
						case 0:
							final maxDist:FlxPoint = FlxPoint.get(0, 10); // maxDist.x is not used
							var oldPos:FlxPoint = getPosition();
							if (gameType == PLAT)
								FlxObject.separate(this, obj.hitbox);
							var dist:FlxPoint = oldPos - getPosition();
							if (gameType == PLAT)
							{
								// else
								grounded = true;
								if (dist.x != 0)
									dirf2 = dir2 = 0;
								FlxG.collide(this, obj.hitbox);
								grounded = true;
								velocity.x = velocity.y = 0;
								/* for (i in 0...60)
									{
										y--;
								}*
								if (dist.x == 0)
								{
									// y--;
									// y -= 60;
								}
								else
								{
									// x += (obj.x - x) / Math.abs(obj.x - x);
									// x += (obj.width - (obj.x - x)) / 2;
								}
								// if (FlxG.overlap(this, obj.hitbox))
								// 	setPosition(x, oldPos.y);
								FlxObject.separate(this, obj.hitbox);
								return;
							}
							if (dist.x != 0 || Math.abs(dist.y) > Math.abs(maxDist.y))
							{
								setPosition(oldPos.x, oldPos.y);
								PlayState.reset();
							}
						default:
							trace('Not implemented (yet)');
					}
			});*/
			if (FlxG.overlap(this, obj.hitbox))
			{
				switch (obj.id)
				{
					case 0:
						final maxIterations:Int = 20; // Had to bump it up from 10 to 20 because some unexpected shit happened
						final distMult:Int = 1;
						final iterationCancel:Int = 60;
						#if debug
						final allowDebugTraces:Bool = false;
						#end
						var dist:FlxPoint = getPosition() - obj.hitbox.getPosition();
						// dist = dist.normalize();
						var iterations:Int = 0;
						var altiterations:Int = 0;
						var movedY:Bool = false;
						if (movedY = Math.abs(dist.x) <= Math.abs(dist.y))
						{
							grounded = true;
							// var oldPos = getPosition();
							while (FlxG.overlap(this, obj.hitbox))
							{
								y += FlxMath.signOf(dist.y) * distMult;
								iterations++;
								altiterations += FlxMath.signOf(dist.y);
							}
						}
						else if (gameType == CLASSIC)
						{
							unalive();
							return;
						}
						else
						{
							while (FlxG.overlap(this, obj.hitbox))
							{
								x += FlxMath.signOf(dist.x) * distMult;
								iterations++;
								altiterations += FlxMath.signOf(dist.x);
							}
						}
						if (!movedY)
							dirf2 = dir2 = 0;
						else
							velocity.y = 0;
						#if debug
						if (allowDebugTraces)
						{
							trace('iterations > maxIterations ($iterations > $maxIterations) is returning ${iterations > maxIterations}');
							trace('altiterations = $altiterations');
							trace('dist.x = ${dist.x}, dist.y = ${dist.y}, ${movedY ? 'Y moved' : 'X moved'}');
							trace("-------------------------------------------------------------------------");
						}
						#end
						if (iterations >= iterationCancel)
						{
							if (movedY)
								y -= altiterations * distMult;
							else
								x -= altiterations * distMult;
							continue;
						}
						if (iterations > maxIterations && airborne)
							unalive();
					case 1:
						unalive();
					default:
						if (obj.id >= 0)
							trace('Not implemented (yet)');
				}
			}
		}
	}

	function jump(jumptype:JumpType = REGULAR)
	{
		final pinkMult:Float = 0.5;
		final redOrbYellowPadMult:Float = 1.5;
		final redPadMult:Float = 2.0;
		var finalMult:Float = 1.0;
		final mainMult:Float = jumpMultMain;

		switch (jumptype)
		{
			case PINKORB:
				finalMult = pinkMult;
			case REDORB_YELLOWPAD:
				finalMult = redOrbYellowPadMult;
			case REDPAD:
				finalMult = redPadMult;
			default:
				finalMult = 1;
		}

		finalMult *= jumpMult * 1.125;
		// updateObjCollision();
		velocity.y = -Math.abs(jumpForce * finalMult * mainMult);
	}

	var reviveTimer:FlxTimer = new FlxTimer();

	/**
	 * Player unalives (dies) when this is called. (Restarts the level after 1.00s)
	 */
	@:access(editor.EditorState)
	public function unalive()
	{
		if (FlxG.state is PlayState)
		{
			FlxG.sound.load(FlxAssets.getSound("assets/sounds/death.ogg"), 1, false, null, true, true);
			kill();
			reviveTimer.start(1, timer ->
			{
				PlayState.reset();
			});
		}
		else if (FlxG.state is EditorState)
		{
			if (cast(FlxG.state, EditorState).testState == PLAYING)
				cast(FlxG.state, EditorState).playTestButtoneer.onUp.fire();
		}
	}

	@:noCompletion function get_grounded():Bool
	{
		return _grounded;
	}

	@:noCompletion function set_grounded(value:Bool):Bool
	{
		return _grounded = !(_airborne = !value);
	}

	@:noCompletion function get_airborne():Bool
	{
		return _airborne;
	}

	@:noCompletion function set_airborne(value:Bool):Bool
	{
		return _airborne = !(_grounded = !value);
	}
}

enum Speed
{
	HALF_X;
	ONE_X;
	TWO_X;
	THREE_X;
	FOUR_X;
}

enum JumpType
{
	REGULAR;
	PINKORB;
	REDORB_YELLOWPAD;
	REDPAD;
}

enum GameMode
{
	CUBE;
	SHIP;
	BALL;
	UFO;
	WAVE;
	ROBOT;
	SPIDER;
	SWING; // Short for "Swing Copter"
}
