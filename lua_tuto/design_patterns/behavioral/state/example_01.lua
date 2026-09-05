local traffic_light = { state = nil, color = "" }

local red, yellow, green
red = {}
function red:enter(light) light.color = "stop" end
function red:handle(light, action)
    if action == "tick" then
        light:set_state(yellow)
    end
end

yellow = {}
function yellow:enter(light) light.color = "ready" end
function yellow:handle(light, action)
    if action == "tick" then
        light:set_state(green)
    end
end

green = {}
function green:enter(light) light.color = "go" end
function green:handle(light, action)
    if action == "tick" then
        light:set_state(red)
    end
end

function traffic_light:set_state(next_state)
    if self.state and self.state.exit then self.state:exit(self) end
    self.state = next_state
    if self.state.enter then self.state:enter(self) end
end

function traffic_light:handle(action)
    self.state:handle(self, action)
end

traffic_light:set_state(red)
traffic_light:handle("tick")
assert(traffic_light.state == yellow and traffic_light.color == "ready")
print(traffic_light.state == yellow, traffic_light.color)
