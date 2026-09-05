local Config = {}
local values = { width = 800, height = 600 }

function Config.get(key)
    return values[key]
end

function Config.set(key, value)
    values[key] = value
end

local first = Config
local second = Config
second.set("width", 1024)

assert(first == second and first.get("width") == 1024)
print(first.get("width"), first == second)
