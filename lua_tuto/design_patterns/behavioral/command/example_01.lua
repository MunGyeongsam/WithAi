local player = { x = 0 }

local function create_move_command(receiver, distance)
	return {
		execute = function()
			receiver.x = receiver.x + distance
		end,
		undo = function()
			receiver.x = receiver.x - distance
		end
	}
end

local move = create_move_command(player, 3)
move.execute()
assert(player.x == 3)
move.undo()
print(player.x)
