local player = { state = nil, velocity_y = 0, animation = "", message = "" }

local idle, airborne
airborne = {}
function airborne:handle(context, action)
    if action == "update" then
        context.velocity_y = context.velocity_y - 1
        context.animation = "jump"
    elseif action == "land" then
        context.velocity_y = 0
        context:set_state(idle)
    else
        context.message = "ignored: " .. action
    end
end

idle = {}
function idle:handle(context, action)
    if action == "jump" then
        context.velocity_y = 8
        context.animation = "jump_start"
        context:set_state(airborne)
    elseif action == "update" then
        context.animation = "idle"
    else
        context.message = "ignored: " .. action
    end
end

function player:set_state(next_state) self.state = next_state end
function player:handle(action) self.state:handle(self, action) end

player:set_state(idle)
player:handle("land")
assert(player.state == idle and player.message == "ignored: land")
player:handle("jump")
assert(player.state == airborne and player.velocity_y == 8 and player.animation == "jump_start")
player:handle("update")
assert(player.velocity_y == 7 and player.animation == "jump")
print(player.state == airborne, player.velocity_y, player.animation)
