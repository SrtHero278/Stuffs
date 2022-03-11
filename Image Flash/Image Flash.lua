function mysplit (inputstr, sep)
    if sep == nil then
        sep = "%s";
    end
    local t={};
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str);
    end
    return t;
end

function onEvent(name, value1, value2)
local tabledos=mysplit(value2,",");
local table=mysplit(value1,",");
    if name == "Image Flash" then
	makeLuaSprite('image', tabledos[1], table[1], table[2]);
	scaleObject('image', table[3], table[3]);
	addLuaSprite('image', true);
	setProperty('image.alpha', 0);
	doTweenAlpha('hello', 'image', 1, 0.3, 'linear');
	setObjectCamera('image', tabledos[2]);
	if tabledos[2] == "hud" then
	    setObjectOrder('image', 1);
	end
	runTimer('wait', tabledos[3]);
    end
end

function onTimerCompleted(tag, loops, loopsleft)
   if tag == 'wait' then
	doTweenAlpha('byebye', 'image', 0, 0.3, 'linear');
   end
end

function onTweenCompleted(tag)
    if tag == 'byebye' then
	removeLuaSprite('image', true);
    end
end