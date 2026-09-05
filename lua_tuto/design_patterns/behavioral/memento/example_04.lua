local settings = { volume = 80, difficulty = "normal" }

function settings:save()
	return { volume = self.volume, difficulty = self.difficulty }
end

function settings:restore(snapshot)
	self.volume = snapshot.volume
	self.difficulty = snapshot.difficulty
end

local backup = settings:save()
settings.volume, settings.difficulty = 0, "hard"
settings:restore(backup)
assert(settings.volume == 80 and settings.difficulty == "normal")
print(settings.volume, settings.difficulty)
