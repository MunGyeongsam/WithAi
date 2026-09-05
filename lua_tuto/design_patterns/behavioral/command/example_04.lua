local receiver = { value = 0 }
local history = {}

local function create_add_command(amount)
	local previous
	return {
		execute = function()
			previous = receiver.value
			receiver.value = receiver.value + amount
		end,
		undo = function()
			receiver.value = previous
		end
	}
end

local command = create_add_command(3)
command.execute()
history[#history + 1] = command
history[#history]:undo()
print(receiver.value)
