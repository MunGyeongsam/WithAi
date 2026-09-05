local load_count = 0
local function load(name)
    load_count = load_count + 1
    return name
end
local function cached(action)
    local cache = {}
    return function(name)
        if not cache[name] then cache[name] = action(name) end
        return cache[name]
    end
end

local decorated = cached(load)
local first = decorated("sprite")
local second = decorated("sprite")
assert(first == second and load_count == 1)
print(first, load_count)
