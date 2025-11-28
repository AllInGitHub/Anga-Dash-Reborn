package substates;

import backend.ClientPrefs;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import flixel.FlxSubState;

class CodeSubState extends FlxSubState
{
	var inputBox:FlxInputText;
	var goButton:FlxButton;
	var statusTxt:FlxText;

	var character:String;
	var code:String;
	var userOnNerves:Int = 0;

	override function create()
	{
		inputBox = new FlxInputText(-1, 150, 150, character, 18);
		inputBox.callback = (s1, s2) ->
		{
			code = s1;
		};
		inputBox.screenCenter(X);
		add(inputBox);

		goButton = new FlxButton(-1, FlxG.height - 200, "Check", () ->
		{
			function codeInvalid()
			{
				updateStatus('Invalid code: $code', FlxColor.RED);
				userOnNerves = 0;
			}
			switch (code)
			{
				case "":
					updateStatus("Please type in a code", FlxColor.RED);
				case 'a code', 'in a code':
					if (userOnNerves != 0)
					{
						codeInvalid();
						return;
					}
					updateStatus("Nice try! That code is invalid too!", FlxColor.RED);
					userOnNerves++;
				case 'invalid', 'invalid too':
					if (userOnNerves != 1)
					{
						codeInvalid();
						return;
					}
					updateStatus("That's... Still not a valid code...", FlxColor.RED);
					userOnNerves++;
				case 'not a valid code', 'still not a valid code':
					if (userOnNerves != 2)
					{
						codeInvalid();
						return;
					}
					updateStatus("THAT'S IT! SEE YA!", FlxColor.RED.getDarkened(0.5));
					throw "THAT'S IT! SEE YA!";
				case 'exit', 'close', 'leave':
					close();
				case 'kill', 'terminate', 'quit':
					ClientPrefs.saveOther();
					Sys.exit(0);
				case 'crash':
					throw 'Test Crash';
				default:
					codeInvalid();
			}
		});
		goButton.screenCenter(X);
		add(goButton);

		statusTxt = new FlxText(0, FlxG.height - 100, FlxG.width, '', 18);
		statusTxt.alignment = CENTER;
		add(statusTxt);
		super.create();
	}

	public function new(c:String)
	{
		if (c.length > 1)
			c = c.charAt(0);
		code = character = c;
		super(0x7f000000);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function updateStatus(text:String = "", color:FlxColor = FlxColor.WHITE)
	{
		statusTxt.text = text;
		statusTxt.color = color;
	}
}
