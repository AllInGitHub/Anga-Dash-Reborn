package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets", true, null, null, function renameFileName(name:String):String
{
	var resultA = name.toLowerCase().split("/");
	var result = resultA[resultA.length - 1].split("-").join("_").split(" ").join("_").split(".").join("__");
	switch (result.charAt(0))
	{
		case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
			return '';
	}
	return result;
}))
class AssetPaths {}
