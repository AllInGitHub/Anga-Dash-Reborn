package backend;

import backend.SwagSongDaw;

typedef SwagSongMeta =
{
	var name:String;
	var ?composer:String;
	var ?composers:Array<String>;
	var daw:SwagSongDaw;
}

typedef SwagSavedSongMeta =
{
	var name:String;
	var ?composer:String;
	var ?composers:Array<String>;
	var daw:String;
}
