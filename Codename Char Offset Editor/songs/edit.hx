function update() {
	if (FlxG.keys.justPressed.SIX) {
		paused = true;
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new ModSubState("SelectChar"));
	}
}
