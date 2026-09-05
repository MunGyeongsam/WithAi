local ui = { status = "" }
function ui:show_status(source, message)
	self.status = source.name .. ":" .. message
end

local mediator = {}
function mediator:notify(source, message)
	ui:show_status(source, message)
end

local network = { name = "network" }
function network:connect()
	mediator:notify(self, "connected")
end

network:connect()
assert(ui.status == "network:connected")
print(ui.status)
