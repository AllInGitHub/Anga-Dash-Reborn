package backend;

import flixel.FlxObject;

class Hitbox extends FlxObject
{
	@:allow(states.PlayState) @:allow(editor.EditorState) var keepAlive:Bool = false;

	public function new(x:Float = 0, y:Float = 0, width:Float = 60, height:Float = 60)
	{
		super(x, y, width, height);
		immovable = true;
		moves = false;
	}

	override function destroy()
	{
		immovable = true;
		moves = false;
		if (!keepAlive)
			super.destroy();
		keepAlive = false;
	}
}
