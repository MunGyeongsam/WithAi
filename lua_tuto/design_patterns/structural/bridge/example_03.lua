local keyboard = { read = function() return "A" end }
local gamepad = { read = function() return "button1" end }
local controller = { device = keyboard }
function controller:set_device(device)
	self.device = device
end
function controller:action() return "move:" .. self.device:read() end
assert(controller:action() == "move:A")
print(controller:action())
controller:set_device(gamepad)
assert(controller:action() == "move:button1")
print(controller:action())
