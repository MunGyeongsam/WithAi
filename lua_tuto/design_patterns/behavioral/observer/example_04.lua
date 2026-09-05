local Achievement = { unlocked = {}, listeners = {} }

function Achievement.on_unlock(listener)
    Achievement.listeners[#Achievement.listeners + 1] = listener
end

function Achievement.unlock(name)
    if Achievement.unlocked[name] then return end
    Achievement.unlocked[name] = true
    for _, listener in ipairs(Achievement.listeners) do listener(name) end
end

local unlocked_name = ""
Achievement.on_unlock(function(name) unlocked_name = name end)
Achievement.unlock("첫 승리")
Achievement.unlock("첫 승리")
assert(unlocked_name == "첫 승리")
print(unlocked_name)
