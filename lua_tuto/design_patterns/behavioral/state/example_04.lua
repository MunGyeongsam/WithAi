local door = { state = nil, message = "" }

local open, closed
open = {}
function open:handle(context, action)
    if action == "close" then
        context.message = "door closed"
        context:set_state(closed)
    else
        context.message = "already open"
    end
end

closed = {}
function closed:handle(context, action)
    if action == "open" then
        context.message = "door opened"
        context:set_state(open)
    else
        context.message = "already closed"
    end
end

function door:set_state(next_state) self.state = next_state end
function door:handle(action) self.state:handle(self, action) end

door:set_state(closed)
door:handle("open")
assert(door.state == open and door.message == "door opened")
door:handle("open")
assert(door.state == open and door.message == "already open")
print(door.state == open, door.message)
