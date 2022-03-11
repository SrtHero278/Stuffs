local opponentPlay = false;
local scriptDad = "dad";
local scriptBF = "bf";
local charSwap = false;
local flipDad = {false, false};
local flipBF = {false, false};
local layerDad = 0;
local layerBF = 0;
local swaps = 0

function setOppo(value)
    if value or value == "true" then -- in case it's a string
	return false
    end
    return true
end

function onUpdatePost()
    if getPropertyFromClass('flixel.FlxG', 'keys.pressed.NINE') and getPropertyFromClass('flixel.FlxG', 'keys.justPressed.O') then -- in case O is a keybind.
	opponentPlay = setOppo(opponentPlay);
	swaps = swaps + 1

	scriptBF = boyfriendName; -- So they don't become the same character.
	scriptDad = dadName;
	charSwap = true;
	triggerEvent('Change Character', 0, scriptDad);
	triggerEvent('Change Character', 1, scriptBF);
	charSwap = false;

	if string.sub(boyfriendName, 1, 2) == "gf" then
	layerBF = getObjectOrder('boyfriendGroup');
	layerDad = getObjectOrder('gfGroup');
	else
	layerBF = getObjectOrder('boyfriendGroup');
	layerDad = getObjectOrder('dadGroup');
	end
	if opponentPlay then
	    setProperty('dadGroup.x', defaultBoyfriendX);
	    setProperty('dadGroup.y', defaultBoyfriendY);
	    if string.sub(boyfriendName, 1, 2) == "gf" then
	    	setProperty('boyfriendGroup.x', defaultGirlfriendX);
	    	setProperty('boyfriendGroup.y', defaultGirlfriendY);
		setProperty('gf.visible', false);
	    else
	    	setProperty('boyfriendGroup.x', defaultOpponentX);
	    	setProperty('boyfriendGroup.y', defaultOpponentY);
	    end
	    if swaps % 2 ~= 1 or swaps == 1 then -- to fix a direction glitch that was happing.
	    	 setProperty('dad.flipX', setOppo(getProperty('dad.flipX')));
	    	 setProperty('boyfriend.flipX', setOppo(getProperty('boyfriend.flipX')));
	    end
	else
	    if string.sub(dadName, 1, 2) ~= "gf" then
	    	setProperty('dadGroup.x', defaultOpponentX);
	    	setProperty('dadGroup.y', defaultOpponentY);
	    end
	    setProperty('boyfriendGroup.x', defaultBoyfriendX);
	    setProperty('boyfriendGroup.y', defaultBoyfriendY);
	end
	flipDad[1] = getProperty('dad.flipX');
	flipBF[1] = getProperty('boyfriend.flipX');
	flipDad[2] = getProperty('dad.originalFlipX');
	flipBF[2] = getProperty('boyfriend.originalFlipX');
	setObjectOrder('boyfriendGroup', layerDad);
	setObjectOrder('dadGroup', layerBF);

	for i = 0, getProperty('unspawnNotes.length')-1 do
	    setPropertyFromGroup('unspawnNotes', i, 'mustPress', setOppo(getPropertyFromGroup('unspawnNotes', i, 'mustPress')));
	end

	if getProperty('notes.length') > 0 then -- some notes might spawn so I'm getting those as well.
	    for i = 0, getProperty('notes.length')-1 do
		setPropertyFromGroup('notes', i, 'mustPress', setOppo(getPropertyFromGroup('notes', i, 'mustPress')));
	    end
	end

	if getProperty('eventNotes.length') > 0 then
	    for e = 0, getProperty('eventNotes.length')-1 do -- fixing
		 if getPropertyFromGroup('eventNotes', e, 1) == "Change Character" then
		    if getPropertyFromGroup('eventNotes', e, 2) == "1" or getPropertyFromGroup('eventNotes', e, 2) == 1 or getPropertyFromGroup('eventNotes', e, 2) == 'dad' or getPropertyFromGroup('eventNotes', e, 2) == 'opponent' then
			 setPropertyFromGroup('eventNotes', e, 2 , 'bf');
		    elseif getPropertyFromGroup('eventNotes', e, 2) == "2" or getPropertyFromGroup('eventNotes', e, 2) == 2 or getPropertyFromGroup('eventNotes', e, 2) == 'gf' or getPropertyFromGroup('eventNotes', e, 2) == 'girlfriend' then
			 -- do nothin. it was originally *elseif value1 is not girlfriend stuff* but that broke it.
		    else
			 setPropertyFromGroup('eventNotes', e, 2 , 'dad');
		    end
		 elseif getPropertyFromGroup('eventNotes', e, 1) == "Play Animation" then
		    if getPropertyFromGroup('eventNotes', e, 3) == "1" or getPropertyFromGroup('eventNotes', e, 3) == 'bf' or getPropertyFromGroup('eventNotes', e, 3) == 'boyfriend' then
			 setPropertyFromGroup('eventNotes', e, 3 , 'dad');
		    elseif getPropertyFromGroup('eventNotes', e, 3) == "2" or getPropertyFromGroup('eventNotes', e, 3) == 'gf' or getPropertyFromGroup('eventNotes', e, 3) == 'girlfriend' then
			 -- i've explained this.
		    else
			 setPropertyFromGroup('eventNotes', e, 3 , 'bf');
		    end
		 elseif getPropertyFromGroup('eventNotes', e, 1) == "Alt Idle Animation" then
		    if getPropertyFromGroup('eventNotes', e, 2) == "1" or getPropertyFromGroup('eventNotes', e, 2) == 'bf' or getPropertyFromGroup('eventNotes', e, 2) == 'boyfriend' then
			 setPropertyFromGroup('eventNotes', e, 2 , 'dad');
		    elseif getPropertyFromGroup('eventNotes', e, 2) == "2" or getPropertyFromGroup('eventNotes', e, 2) == 'gf' or getPropertyFromGroup('eventNotes', e, 2) == 'girlfriend' then
			 -- do you like cheese?
		    else
			 setPropertyFromGroup('eventNotes', e, 2 , 'bf');
		    end
		 end
	    end
	end

	setProperty('healthBar.flipX', setOppo(getProperty('healthBar.flipX')));
	setProperty('iconP1.flipX', setOppo(getProperty('iconP1.flipX')));
	setProperty('iconP2.flipX', setOppo(getProperty('iconP2.flipX')));

	if opponentPlay and not getPropertyFromClass('ClientPrefs', 'middleScroll') then
	    noteTweenX('move0', 0, defaultPlayerStrumX0, 0.01, 'linear');
	    noteTweenX('move1', 1, defaultPlayerStrumX1, 0.01, 'linear');
	    noteTweenX('move2', 2, defaultPlayerStrumX2, 0.01, 'linear');
	    noteTweenX('move3', 3, defaultPlayerStrumX3, 0.01, 'linear');
	    noteTweenX('move4', 4, defaultOpponentStrumX0, 0.01, 'linear');
	    noteTweenX('move5', 5, defaultOpponentStrumX1, 0.01, 'linear');
	    noteTweenX('move6', 6, defaultOpponentStrumX2, 0.01, 'linear');
	    noteTweenX('move7', 7, defaultOpponentStrumX3, 0.01, 'linear');
	else
	    noteTweenX('move0', 0, defaultOpponentStrumX0, 0.01, 'linear');
	    noteTweenX('move1', 1, defaultOpponentStrumX1, 0.01, 'linear');
	    noteTweenX('move2', 2, defaultOpponentStrumX2, 0.01, 'linear');
	    noteTweenX('move3', 3, defaultOpponentStrumX3, 0.01, 'linear');
	    noteTweenX('move4', 4, defaultPlayerStrumX0, 0.01, 'linear');
	    noteTweenX('move5', 5, defaultPlayerStrumX1, 0.01, 'linear');
	    noteTweenX('move6', 6, defaultPlayerStrumX2, 0.01, 'linear');
	    noteTweenX('move7', 7, defaultPlayerStrumX3, 0.01, 'linear');
	end
	debugPrint("toggled opponent play") -- it's nice to know.
    end

    if opponentPlay then -- making the health bar go right
	if getProperty('health') < 1.99 then
	    setProperty('iconP1.x', getProperty('healthBar.x') + getProperty('healthBar.width') * (getProperty('health') / 2) - 130);
	    setProperty('iconP2.x', getProperty('healthBar.x') + getProperty('healthBar.width') * (getProperty('health') / 2) - 26);
	else
	    setProperty('iconP1.x', getProperty('healthBar.x') + getProperty('healthBar.width') - 130);
	    setProperty('iconP2.x', getProperty('healthBar.x') + getProperty('healthBar.width') - 26);
	end
      setProperty('boyfriend.stunned', false);
    end
end

function onEvent(n, v1, v2)
    if n == "Hey!" and opponentPlay then -- to make bf play Hey!
	 if v1 ~= 'gf' or v1 ~= "girlfriend" or v1 ~= "1" then
	    characterPlayAnim('dad', 'hey', true);
	 end
    elseif n == "Change Character" and opponentPlay and not charSwap then -- to fix the direction.
	 if v1 == "1" or v1 == "dad" or v1 == "opponent" then
	 if getProperty('dad.originalFlipX') == flipDad[2] then
	    setProperty('dad.flipX', flipDad[1]);
	 else
	    setProperty('dad.flipX', setOppo(flipDad[1]));
	 end
	 elseif v1 ~= "gf" or v1 ~= "girlfriend" or v1 ~= "2" then
	 if getProperty('boyfriend.originalFlipX') == flipBF[2] then
	    setProperty('boyfriend.flipX', flipBF[1]);
	 else
	    setProperty('boyfriend.flipX', setOppo(flipBF[1]));
	 end
	 end
    end
end

local anims = {'singLEFT-alt', 'singDOWN-alt', 'singUP-alt', 'singRIGHT-alt'}
function goodNoteHit(i, d, t, s)
    if opponentPlay then -- you don't play alts when you're the player.
	 if string.lower(songName) ~= "tutorial" then setProperty('camZooming', true); end
	 if altAnim or t == "Alt Animation" then
	    characterPlayAnim('bf', anims[d + 1], true);
	 end
    end
end

function onMoveCamera(c)
    if opponentPlay then -- fixing the camera.
    if c == "boyfriend" then
	if getPropertyFromClass('PlayState', 'curStage') == "limo" then
	    setProperty('camFollow.x', getProperty('dad.x') + getProperty('dad.width') * 0.5 - 300 - getProperty('dad.cameraPosition')[1]);
	    setProperty('camFollow.y', getProperty('dad.y') + getProperty('dad.height') * 0.5 - 100 + getProperty('dad.cameraPosition')[2]);
	elseif getPropertyFromClass('PlayState', 'curStage') == "mall" then
	    setProperty('camFollow.x', getProperty('dad.x') + getProperty('dad.width') * 0.5 - 100 - getProperty('dad.cameraPosition')[1]);
	    setProperty('camFollow.y', getProperty('dad.y') + getProperty('dad.height') * 0.5 - 200 + getProperty('dad.cameraPosition')[2]);
	elseif getPropertyFromClass('PlayState', 'curStage') == "school" or getPropertyFromClass('PlayState', 'curStage') == "schoolEvil" then
	    setProperty('camFollow.x', getProperty('dad.x') + getProperty('dad.width') * 0.5 - 200 - getProperty('dad.cameraPosition')[1]);
	    setProperty('camFollow.y', getProperty('dad.y') + getProperty('dad.height') * 0.5 - 200 + getProperty('dad.cameraPosition')[2]);
	else
	    setProperty('camFollow.x', getProperty('dad.x') + getProperty('dad.width') * 0.5 - 100 - getProperty('dad.cameraPosition')[1]);
	    setProperty('camFollow.y', getProperty('dad.y') + getProperty('dad.height') * 0.5 - 100 + getProperty('dad.cameraPosition')[2]);
	end
    elseif c == "dad" then
	setProperty('camFollow.x', getProperty('boyfriend.x') + getProperty('boyfriend.width') * 0.5 + 150 + getProperty('boyfriend.cameraPosition')[1]);
	setProperty('camFollow.y', getProperty('boyfriend.y') + getProperty('boyfriend.height') * 0.5 - 100 + getProperty('boyfriend.cameraPosition')[2]);
    end
    end
end