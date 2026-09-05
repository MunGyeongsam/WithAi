local old_audio = { playSound = function(_, name) return "play:" .. name end }
local audio = { play = function(name) return old_audio:playSound(name) end }
assert(audio.play("hit") == "play:hit")
print(audio.play("hit"))
