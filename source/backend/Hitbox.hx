package backend;

import flixel.FlxObject;

class Hitbox extends FlxObject
{
	@:allow(states.PlayState) @:allow(editor.EditorState) var keepAlive:Bool = false;

	override function destroy()
	{
		if (!keepAlive)
			super.destroy();
		keepAlive = false;
	}
}
