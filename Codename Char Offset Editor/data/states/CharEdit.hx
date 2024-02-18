import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;

import haxe.ds.StringMap; //This works for me.

var init:Bool = false;

var gridBG:FlxSprite;

var offsetType:String = "animation";
//var daAnim:String = 'spooky';
var char:Character;
var ghostChar:Character;
var cameraPoint:FlxSprite;

var danceAnim:String = "idle";

var textAnim:FlxText;
var dumbTexts:FlxText;
var optionsInfo:FlxText;

var animList:Array<String> = [];
var animXmls:StringMap<Xml>;
var curAnim:Int = 0;
var camFollow:FlxObject;

function postCreate() {
	init = true;

	if (FlxG.sound.music != null)
		FlxG.sound.music.stop();

	gridBG = FlxGridOverlay.create(50, 50);
	gridBG.scrollFactor.set(0, 0);
	gridBG.color = 0xFF3B3B3B;
	add(gridBG);

	ghostChar = new Character(0, 0, daAnim);
	ghostChar.debugMode = true;
	ghostChar.alpha = 0.5;
	add(ghostChar);

	if (ghostChar.isDanceLeftDanceRight)
		danceAnim = "danceLeft";

	char = new Character(0, 0, daAnim);
	char.debugMode = true;
	add(char);

	if (char.playerOffsets) {
		CoolUtil.switchAnimFrames(char.animation.getByName('singRIGHT'), char.animation.getByName('singLEFT'));
		CoolUtil.switchAnimFrames(char.animation.getByName('singRIGHTmiss'), char.animation.getByName('singLEFTmiss'));
		char.switchOffset('singLEFT', 'singRIGHT');
		char.switchOffset('singLEFTmiss', 'singRIGHTmiss');
		char.flipX = !char.flipX;
		char.__baseFlipped = char.flipX;
		char.isPlayer = true;

		CoolUtil.switchAnimFrames(ghostChar.animation.getByName('singRIGHT'), ghostChar.animation.getByName('singLEFT'));
		CoolUtil.switchAnimFrames(ghostChar.animation.getByName('singRIGHTmiss'), ghostChar.animation.getByName('singLEFTmiss'));
		ghostChar.switchOffset('singLEFT', 'singRIGHT');
		ghostChar.switchOffset('singLEFTmiss', 'singRIGHTmiss');
		ghostChar.flipX = !ghostChar.flipX;
		ghostChar.__baseFlipped = ghostChar.flipX;
		ghostChar.isPlayer = true;
	}

	var hud = new HudCamera();
	hud.bgColor = 0; // transparent
	FlxG.cameras.add(hud, false);

	dumbTexts = new FlxText(16, 60, 0, "", 15);
	dumbTexts.scrollFactor.set();
	dumbTexts.cameras = [hud];
	add(dumbTexts);

	textAnim = new FlxText(16, 16);
	textAnim.scrollFactor.set();
	textAnim.cameras = [hud];
	textAnim.size = 26;
	add(textAnim);

	optionsInfo = new FlxText(0, 715, 1270, "Current Char: " + daAnim + "\n"
	+ "Current Offset Type: " + offsetType.toUpperCase() + "\n\n"
	+ "[1] - Switch Offset Type\n"
	+ "[2] - Save Offsets\n"
	+ "[3] - Reset Camera Position\n"
	+ "[4] - Switch Character\n\n"
	+ "[SHIFT] - Faster Cam/Offset Speed\n\n"
	+ "[I/J/K/L] - Move Camera\n"
	+ "[E/Q] - Zoom Camera\n\n"
	+ "[SPACE] - Replay Animation\n"
	+ "[W/S] - Switch Animation\n"
	+ "[ARROWS] - Move Offset\n\n"
	+ "[ESC] - Exit To PlayState", 12);
	optionsInfo.alignment = "right";
	optionsInfo.y -= optionsInfo.height;
	optionsInfo.scrollFactor.set();
	optionsInfo.cameras = [hud];
	add(optionsInfo);

	genBoyOffsets(true);
	char.playAnim(animList[curAnim], true);
	ghostChar.playAnim(danceAnim, true);
	dumbTexts.text = ">>> " + dumbTexts.text;

	camFollow = new FlxObject(0, 0, 2, 2);
	camFollow.screenCenter();
	add(camFollow);

	FlxG.camera.follow(camFollow);

	var groundLine = new FlxSprite(0, 767).makeGraphic(1280, 5, 0x80FFFFFF);
	groundLine.scrollFactor.set(0, 1);
	groundLine.scale.set(4, 1);
	add(groundLine);

	var charCam = char.getCameraPosition();
	cameraPoint = new FlxSprite(charCam.x - 300, charCam.y - 300).makeGraphic(600, 600, 0xFFFFFFFF);
	cameraPoint.shader = new FunkinShader("
#pragma header

void main() {
	float dist = distance(openfl_TextureCoordv, vec2(0.5));
	vec4 color = vec4(1);
	color = color * (1 - step(0.05, dist));
	color.rgb *= 1 - step(0.0475, dist);
	bool inBorderRange = ((openfl_TextureCoordv.x >= 0.49 && openfl_TextureCoordv.x <= 0.51) || (openfl_TextureCoordv.y >= 0.49 && openfl_TextureCoordv.y <= 0.51));
	bool inRange = ((openfl_TextureCoordv.x >= 0.4925 && openfl_TextureCoordv.x <= 0.5075) || (openfl_TextureCoordv.y >= 0.4925 && openfl_TextureCoordv.y <= 0.5075));
	if (!inBorderRange)
		color *= 0;
	else if (inBorderRange && !inRange)
		color.rgb *= 0;
	gl_FragColor = color;
}
	");
	cameraPoint.antialiasing = true;
	add(cameraPoint);

	var invalidAnims = [];
	animXmls = new StringMap();
	for (anim in char.xml.elementsNamed("anim")) {
		animXmls.set(anim.get("name"), anim);

		if (!char.hasAnimation(anim.get("name")))
			invalidAnims.push(anim.get("name"));
	}

	if (invalidAnims.length <= 0) return;

	var invalidTxt = new FlxText(0, 640, 1280, 
	"The game was\n"
	+ "unable to add\n"
	+ "these animations:\r\n" + invalidAnims.join("\n"), 24);
	invalidTxt.y -= invalidTxt.height;
	invalidTxt.alignment = "center";
	invalidTxt.color = 0xFFFFFF00;
	invalidTxt.scrollFactor.set();
	invalidTxt.cameras = [hud];
	add(invalidTxt);
	FlxTween.tween(invalidTxt, {alpha: 0}, 1, {startDelay: 3, onComplete: function(twn:FlxTween) { 
		remove(invalidTxt);
		invalidTxt.destroy();
	}});
	CoolUtil.playMenuSFX(0, 0.4);
}

function genBoyOffsets(pushList:Bool = true):Void
{
	dumbTexts.text = "";
	for (anim in char.animOffsets.keys()) {
		var offsets = char.animOffsets[anim];
		if (offsets == null || !char.hasAnimation(anim)) continue;
		var prefix = (anim == animList[curAnim]) ? ">>> " : "";
		dumbTexts.text += prefix + anim + ": " + offsets + "\n";

		if (pushList)
			animList.push(anim);
	}
	dumbTexts.text += "\nGlobal Offset: " + char.globalOffset + "\nCamera Offset: " + char.cameraOffset;
}

function update(elapsed:Float) {
	if (!init) return;
	textAnim.text = "Current Animation: " + char.getAnimName();

	if (FlxG.keys.justPressed.E || FlxG.keys.justPressed.Q) {
		FlxG.camera.zoom += 0.25 - 0.5 * (FlxG.keys.justPressed.Q);
		if (FlxG.camera.zoom <= 0)
			FlxG.camera.zoom = 0.25;
		else if (FlxG.camera.zoom >= 1 + 0.25 * 31)
			FlxG.camera.zoom = 1 + 0.25 * 30;

		var zoomScale:Float = 1 / FlxG.camera.zoom;
		gridBG.scale.set(zoomScale, zoomScale);
	}

	var multiplier:Int = 1;
	if (FlxG.keys.pressed.SHIFT)
		multiplier = 10;

	camFollow.velocity.x = 90 * (FlxG.keys.pressed.L) - 90 * (FlxG.keys.pressed.J);
	camFollow.velocity.y = 90 * (FlxG.keys.pressed.K) - 90 * (FlxG.keys.pressed.I);
	camFollow.velocity.x *= multiplier;
	camFollow.velocity.y *= multiplier;

	curAnim += 1 * (FlxG.keys.justPressed.S) - 1 * (FlxG.keys.justPressed.W);

	if (curAnim < 0)
		curAnim = animList.length - 1;
	else if (curAnim >= animList.length)
		curAnim = 0;

	if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE) {
		char.playAnim(animList[curAnim], true);
		ghostChar.playAnim(danceAnim, true);

		genBoyOffsets(false);
	}

	var upP = FlxG.keys.justPressed.UP;
	var rightP = FlxG.keys.justPressed.RIGHT;
	var downP = FlxG.keys.justPressed.DOWN;
	var leftP = FlxG.keys.justPressed.LEFT;

	if (upP || rightP || downP || leftP) {
		var offsetFunctions = [updateAnimOffset, updateGlobalOffset, updateCameraOffset];
		offsetFunctions[["animation", "global", "camera"].indexOf(offsetType)](leftP, downP, upP, rightP, multiplier);
	}

	switch ([FlxG.keys.justPressed.ONE, FlxG.keys.justPressed.TWO, FlxG.keys.justPressed.THREE, FlxG.keys.justPressed.FOUR, FlxG.keys.justPressed.ESCAPE].indexOf(true)) {
		case 0:
			var newTypes = [
				"animation" => "global",
				"global" => "camera",
				"camera" => "animation"
			];
			offsetType = newTypes[offsetType];
			optionsInfo.text = "Current Char: " + daAnim + "\n"
			+ "Current Offset Type: " + offsetType.toUpperCase() + "\n\n"
			+ "[1] - Switch Offset Type\n"
			+ "[2] - Save Offsets\n"
			+ "[3] - Reset Camera Position\n"
			+ "[4] - Switch Character\n\n"
			+ "[SHIFT] - Faster Cam/Offset Speed\n\n"
			+ "[I/J/K/L] - Move Camera\n"
			+ "[E/Q] - Zoom Camera\n\n"
			+ "[SPACE] - Replay Animation\n"
			+ "[W/S] - Switch Animation\n"
			+ "[ARROWS] - Move Offset\n\n"
			+ "[ESC] - Exit To PlayState";
			FlxTween.color(optionsInfo, 0.5, 0xFF00FF88, 0xFFFFFFFF);
			CoolUtil.playMenuSFX(0, 0.4);
		case 1: 
			saveXml();
		case 2:
			FlxG.camera.zoom = 1;
			gridBG.scale.set(1, 1);
			camFollow.screenCenter();
		case 3: 
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSubState("SelectChar"));
		case 4: 
			FlxG.switchState(new PlayState());
	}
}

function updateAnimOffset(leftP:Bool, downP:Bool, upP:Bool, rightP:Bool, multiplier:Int) {
	var multiplierO = multiplier * (1 - 2 * rightP);
	char.animOffsets[animList[curAnim]].x += 1 * multiplierO * (leftP || rightP);
	multiplierO = multiplier * (1 - 2 * downP);
	char.animOffsets[animList[curAnim]].y += 1 * multiplierO * (upP || downP);

	animXmls[animList[curAnim]].set("x", char.animOffsets[animList[curAnim]].x);
	animXmls[animList[curAnim]].set("y", char.animOffsets[animList[curAnim]].y);

	ghostChar.animOffsets[danceAnim].set(char.animOffsets[danceAnim].x, char.animOffsets[danceAnim].y);
	genBoyOffsets(false);
	char.playAnim(animList[curAnim], true);
	ghostChar.playAnim(danceAnim, true);
}

function updateGlobalOffset(leftP:Bool, downP:Bool, upP:Bool, rightP:Bool, multiplier:Int) {
	var multiplierO = multiplier * (1 - 2 * leftP);
	char.globalOffset.x += 1 * multiplierO * (leftP || rightP);
	cameraPoint.x += 1 * multiplierO * (leftP || rightP);
	multiplierO = multiplier * (1 - 2 * upP);
	char.globalOffset.y += 1 * multiplierO * (upP || downP);
	cameraPoint.y += 1 * multiplierO * (upP || downP);

	ghostChar.globalOffset.set(char.globalOffset.x, char.globalOffset.y);

	char.xml.set("x", char.globalOffset.x);
	char.xml.set("y", char.globalOffset.y);

	char.playAnim(animList[curAnim], true);
	ghostChar.playAnim(danceAnim, true);

	genBoyOffsets(false);
}

function updateCameraOffset(leftP:Bool, downP:Bool, upP:Bool, rightP:Bool, multiplier:Int) {
	var multiplierO = multiplier * (1 - 2 * leftP);
	char.cameraOffset.x += 1 * multiplierO * (leftP || rightP);
	multiplierO = multiplier * (1 - 2 * upP);
	char.cameraOffset.y += 1 * multiplierO * (upP || downP);

	char.xml.set("camx", char.cameraOffset.x);
	char.xml.set("camy", char.cameraOffset.y);

	genBoyOffsets(false);

	var camPos = char.getCameraPosition();
	cameraPoint.setPosition(camPos.x - 300, camPos.y - 300);
}

//I used Wizard's Char Converter to help with File Dialog.

import Xml;
import haxe.xml.Printer;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import openfl.net.FileReference;
import sys.io.File;
import StringTools;

function saveXml() {
	var xmlString = "<!DOCTYPE codename-engine-character>\n" + Std.string(char.xml);
	while (StringTools.contains(xmlString, "\n\n"))
		xmlString = StringTools.replace(xmlString, "\n\n", "\n");
	xmlString = StringTools.replace(xmlString, "/>", "/>\n");
	xmlString = StringTools.replace(xmlString, "/>\n\n</", "/>\n</");

	var fDial = new FileDialog();
	fDial.onSelect.add(function(file) {
		//File.saveContent(file, Printer.print(xml, true));
		File.saveContent(file, xmlString);
	});
	fDial.browse(FileDialogType.SAVE, 'xml', null, 'Save Codename Character XML.');
}