import funkin.system.MusicBeatSubstate;

function update() {
	if (FlxG.keys.justPressed.SIX) {
		paused = true;
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new MusicBeatSubstate(true, "SelectChar"));
	}
}