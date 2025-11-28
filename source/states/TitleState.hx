package states;

import substates.CodeSubState;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.FlxSprite;
import flixel.FlxState;

class TitleState extends FlxState
{
	var logo:FlxSprite;
	var playButton:FlxButton;

	override function create()
	{
		logo = new FlxSprite();
		logo.loadGraphic(AssetPaths.logo__png);
		logo.screenCenter(X);
		logo.y = 50;
		add(logo);

		playButton = new FlxButton(0, 0, "Play", () ->
		{
			StfUtils.trans(new PlayState());
		});
		playButton.screenCenter();
		add(playButton);
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var c:String = switch (FlxG.keys.firstJustPressed())
		{
			case FlxKey.A: 'a';
			case FlxKey.B: 'b';
			case FlxKey.C: 'c';
			case FlxKey.D: 'd';
			case FlxKey.E: 'e';
			case FlxKey.F: 'f';
			case FlxKey.G: 'g';
			case FlxKey.H: 'h';
			case FlxKey.I: 'i';
			case FlxKey.J: 'j';
			case FlxKey.K: 'k';
			case FlxKey.L: 'l';
			case FlxKey.M: 'm';
			case FlxKey.N: 'n';
			case FlxKey.O: 'o';
			case FlxKey.P: 'p';
			case FlxKey.Q: 'q';
			case FlxKey.R: 'r';
			case FlxKey.S: 's';
			case FlxKey.T: 't';
			case FlxKey.U: 'u';
			case FlxKey.V: 'v';
			case FlxKey.W: 'w';
			case FlxKey.X: 'x';
			case FlxKey.Y: 'y';
			case FlxKey.Z: 'z';
			case FlxKey.ZERO, FlxKey.NUMPADZERO: '0';
			case FlxKey.ONE, FlxKey.NUMPADONE: '1';
			case FlxKey.TWO, FlxKey.NUMPADTWO: '2';
			case FlxKey.THREE, FlxKey.NUMPADTHREE: '3';
			case FlxKey.FOUR, FlxKey.NUMPADFOUR: '4';
			case FlxKey.FIVE, FlxKey.NUMPADFIVE: '5';
			case FlxKey.SIX, FlxKey.NUMPADSIX: '6';
			case FlxKey.SEVEN, FlxKey.NUMPADSEVEN: '7';
			case FlxKey.EIGHT, FlxKey.NUMPADEIGHT: '8';
			case FlxKey.NINE, FlxKey.NUMPADNINE: '9';
			case _: "";
		}

		if (FlxG.keys.pressed.SHIFT)
			c = c.toUpperCase();

		if (c != '')
			openSubState(new CodeSubState(c));
	}
}
