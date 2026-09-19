-- FSM: a transition table changes state, but states do not own behavior.
local transitions = {
    red = { tick = "yellow", emergency = "red" },
    yellow = { tick = "green", emergency = "red" },
    green = { tick = "red", emergency = "red" }
}

local traffic_light = { state = "red" }

function traffic_light:transition(event)
    local next_state = transitions[self.state][event]
    if not next_state then
        return false
    end

    self.state = next_state
    return true
end

assert(traffic_light:transition("tick") and traffic_light.state == "yellow")
assert(traffic_light:transition("tick") and traffic_light.state == "green")
assert(not traffic_light:transition("open") and traffic_light.state == "green")
assert(traffic_light:transition("emergency") and traffic_light.state == "red")
print(traffic_light.state)