local player = { hp = 100 }

function player:save()
	return { hp = self.hp }
end

function player:restore(snapshot)
	self.hp = snapshot.hp
end

local snapshot = player:save()
player.hp = 40
player:restore(snapshot)
assert(player.hp == 100)
print(player.hp)
