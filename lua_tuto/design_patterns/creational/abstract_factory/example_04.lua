local sound_factory = {
	music = function() return "music.ogg" end,
	click = function() return "click.wav" end
}
local silent_factory = {
	music = function() return "silent" end,
	click = function() return "silent" end
}

local function create_audio(factory)
	return { music = factory.music(), click = factory.click() }
end

local audio = create_audio(silent_factory)
assert(audio.music == "silent" and audio.click == "silent")
print(audio.music, audio.click)
