local EventBus = { listeners = {} }

function EventBus.on(event_name, listener)
    local listeners = EventBus.listeners[event_name] or {}
    listeners[#listeners + 1] = listener
    EventBus.listeners[event_name] = listeners
end

function EventBus.emit(event_name, value)
    for _, listener in ipairs(EventBus.listeners[event_name] or {}) do
        listener(value)
    end
end

local received = 0
local log = {}
EventBus.on("score", function(value) received = received + value end)
EventBus.on("score", function(value) log[#log + 1] = "score+" .. value end)
EventBus.emit("score", 10)
EventBus.emit("score", 5)
assert(received == 15)
assert(#log == 2 and log[1] == "score+10" and log[2] == "score+5")
print(received, table.concat(log, ","))
