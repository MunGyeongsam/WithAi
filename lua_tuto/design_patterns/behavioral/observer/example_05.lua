local Event = { listeners = {} }

function Event.on(name, listener)
    Event.listeners[name] = Event.listeners[name] or {}
    Event.listeners[name][#Event.listeners[name] + 1] = listener
    return listener
end

function Event.off(name, listener)
    for index, current in ipairs(Event.listeners[name] or {}) do
        if current == listener then
            table.remove(Event.listeners[name], index)
            return
        end
    end
end

function Event.emit(name, payload)
    local listeners = Event.listeners[name] or {}
    local snapshot = {}
    for index, listener in ipairs(listeners) do snapshot[index] = listener end
    for _, listener in ipairs(snapshot) do listener(payload) end
end

local log = ""
local damage_listener
damage_listener = function(amount)
    log = log .. "once=" .. amount
    Event.off("damage", damage_listener)
end
Event.on("damage", damage_listener)
Event.on("damage", function(amount) log = log .. "damage=" .. amount end)
Event.on("heal", function(amount) log = log .. "heal=" .. amount end)
Event.emit("damage", 15)
Event.emit("heal", 5)
Event.emit("damage", 20)
assert(log == "once=15damage=15heal=5damage=20")
print(log)
