local old_audio = {
	playSound = function(_, name, volume, loop)
		return string.format("play:%s:volume=%d:loop=%s", name, volume, tostring(loop))
	end
}

-- Before: game code must know the legacy signature and defaults.
assert(old_audio:playSound("hit", 100, false) == "play:hit:volume=100:loop=false")

-- After: the Adapter owns the legacy signature and game-friendly defaults.
local audio = {
	play = function(name, options)
		options = options or {}
		local volume = options.volume or 1.0
		local loop = options.loop or false
		return old_audio:playSound(name, math.floor(volume * 100), loop)
	end
}

assert(audio.play("hit") == "play:hit:volume=100:loop=false")
assert(audio.play("music", { volume = 0.5, loop = true }) == "play:music:volume=50:loop=true")
print(audio.play("hit"))
