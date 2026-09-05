local sounds = {}
local created = 0
local function sound_definition(name)
	if not sounds[name] then
		sounds[name] = { name = name, file = name .. ".wav" }
		created = created + 1
	end
	return sounds[name]
end

local first = { sound = sound_definition("hit") }
local second = { sound = sound_definition("hit") }
assert(first.sound == second.sound and created == 1)
print(first.sound.name, created)
