import funkin.editors.EditorTreeMenu;
import flixel.effects.FlxFlicker;

var stageIndex = -1;

function create() {
	for (i in 0...options.length)
		stageIndex = (options[i].name == "Stage Editor") ? i : stageIndex;
	if (stageIndex > -1)
		options[stageIndex].state = ModState;
}

var overrodeFlicker = false;
function update() {
	if (stageIndex <= -1 || overrodeFlicker) return;

	if (curSelected == stageIndex && selected && FlxFlicker.isFlickering(sprites[stageIndex].label)) {
		FlxFlicker._boundObjects[sprites[stageIndex].label].completionCallback = function(flick) {
			subCam.fade(0xFF000000, 0.25, false, function() {
				var state = new EditorTreeMenu();
				state.scriptName = "stageEditor/selector/StageSelector"; // OVERRIDING NEW AIANT GON STOP ME OPTIONS.TREEMENU
				FlxG.switchState(state);
			});
		}
		overrodeFlicker = true;
	}
}