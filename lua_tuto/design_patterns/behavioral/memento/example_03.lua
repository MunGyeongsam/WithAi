local game = { level = 1, score = 0 }

function game:save()
	return { level = self.level, score = self.score }
end

function game:restore(snapshot)
	self.level = snapshot.level
	self.score = snapshot.score
end

local checkpoints = { game:save() }
game.level, game.score = 2, 100
checkpoints[#checkpoints + 1] = game:save()
game.level, game.score = 3, 250
game:restore(checkpoints[2])
assert(game.level == 2 and game.score == 100)
print(game.level, game.score)
