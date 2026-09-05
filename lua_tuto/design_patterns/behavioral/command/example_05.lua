local log = {}
local function create_command(name)
	return {
		execute = function()
			log[#log + 1] = name
		end
	}
end

local macro = {
	commands = { create_command("move"), create_command("attack") },
	execute = function(self)
		for _, command in ipairs(self.commands) do
			command.execute()
		end
	end
}

macro:execute()
print(table.concat(log, ","))
