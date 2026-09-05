local invoker = { queue = {} }

function invoker:enqueue(command)
	self.queue[#self.queue + 1] = command
end

function invoker:run_all()
	local results = {}
	for _, command in ipairs(self.queue) do
		results[#results + 1] = command:execute()
	end
	self.queue = {}
	return results
end

local function create_action(name)
	return { execute = function() return name end }
end

invoker:enqueue(create_action("jump"))
invoker:enqueue(create_action("attack"))
local results = invoker:run_all()
print(table.concat(results, ","))
