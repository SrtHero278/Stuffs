import funkin.system.MusicBeatState;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.FlxCamera;
import funkin.ui.Alphabet;
import haxe.io.Path;

var chars:Array<String> = [];
var curSelected:Int = 0;
var pauseMusic:FlxSound;
var grpMenuShit:FlxTypedGroup<Alphabet>;
var betArray:Array<Alphabet> = []; //IT WOULDNT LET DO grpMenuShit.members!!!!

function create() {
	chars = [for (file in Paths.getFolderContent("data/characters/"))
		if (Path.extension(file).toLowerCase() == "xml")
			file.substr(0, file.length-4)
	];
	if (PlayState.instance != null) {
		chars.insert(0, "Current Opponent");
		chars.insert(0, "Current Spectator");
		chars.insert(0, "Current Player");

		pauseMusic = new FlxSound().loadEmbedded(Paths.music("breakfast"), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);
	}

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	bg.alpha = 0;
	bg.scrollFactor.set();
	add(bg);

	var grpMenuShit = new FlxTypedGroup();
	for (i in 0...chars.length) {
		var songText:Alphabet = new Alphabet(0, (70 * i) + 30, chars[i], true, false);
		songText.isMenuItem = true;
		songText.targetY = i;
		grpMenuShit.add(songText);
		betArray.push(songText);
	}
	var songText:Alphabet = new Alphabet(0, (70 * betArray.length) + 30, "Cancel", true, false);
	songText.isMenuItem = true;
	songText.targetY = betArray.length;
	grpMenuShit.add(songText);
	betArray.push(songText);

	add(grpMenuShit);

	FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

	var camera = new FlxCamera();
	camera.bgColor = 0;
	FlxG.cameras.add(camera, false);
	cameras = [camera];

	changeSelection(0);
}

if (PlayState.instance != null) {

function update(elapsed:Float) {
	pauseMusic.volume += 0.01 * elapsed * (pauseMusic.volume < 0.5);

	if (controls.ACCEPT) {
		if (curSelected == betArray.length - 1) {close(); return;}

		var state = new MusicBeatState(true, "CharEdit");
		var boolIndex = [(curSelected == 0), (curSelected == 1), (curSelected == 2), true].indexOf(true);
		var charArray = [
			PlayState.instance.boyfriend.curCharacter,
			PlayState.instance.gf.curCharacter,
			PlayState.instance.dad.curCharacter, 
			chars[curSelected]
		];
		state.stateScript.set("daAnim", charArray[boolIndex]);
		FlxG.switchState(state);
	} else if (controls.BACK)
		close();
	else if (controls.UP_P || controls.DOWN_P)
		changeSelection(1 * controls.DOWN_P - 1 * controls.UP_P);
}

function changeSelection(change:Int = 0) {
	curSelected += change;

	if (curSelected < 0)
		curSelected = betArray.length - 1;
	else if (curSelected >= betArray.length)
		curSelected = 0;

	var bullShit:Int = 0;
	for (item in betArray) {
		item.targetY = (bullShit + 1 * (bullShit >= 3)) - curSelected;
		if (curSelected >= 3)
			item.targetY--;
		bullShit++;

		item.alpha = 0.6;

		if (bullShit - 1 == curSelected)//(item.targetY == 0)
			item.alpha = 1;
	}

	CoolUtil.playMenuSFX(0, 0.4);
}

function onDestroy()
	if (pauseMusic != null) pauseMusic.destroy();

} else {

function update(elapsed:Float) {
	if (controls.ACCEPT) {
		if (curSelected == betArray.length - 1) {close(); return;}

		var state = new MusicBeatState(true, "CharEdit");
		state.stateScript.set("daAnim", chars[curSelected]);
		FlxG.switchState(state);
	} else if (controls.BACK)
		close();
	else if (controls.UP_P || controls.DOWN_P)
		changeSelection(1 * controls.DOWN_P - 1 * controls.UP_P);
}

function changeSelection(change:Int = 0) {
	curSelected += change;

	if (curSelected < 0)
		curSelected = betArray.length - 1;
	else if (curSelected >= betArray.length)
		curSelected = 0;

	var bullShit:Int = 0;
	for (item in betArray) {
		item.targetY = bullShit - curSelected;
		bullShit++;

		item.alpha = 0.6;

		if (bullShit - 1 == curSelected)//(item.targetY == 0)
			item.alpha = 1;
	}

	CoolUtil.playMenuSFX(0, 0.4);
}

}