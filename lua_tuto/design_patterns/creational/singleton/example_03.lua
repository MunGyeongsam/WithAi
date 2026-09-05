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
EventBus.on("score", function(value) received = received + value end)
EventBus.emit("score", 10)
assert(received == 10)
print(received)
