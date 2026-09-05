local load_count = 0
local real = {
	load = function(_, name)
		load_count = load_count + 1
		return "loaded:" .. name
	end
}
local proxy = { cache = {} }
function proxy:load(name)
	self.cache[name] = self.cache[name] or real:load(name)
	return self.cache[name]
end

assert(proxy:load("map") == "loaded:map")
assert(proxy:load("map") == "loaded:map" and load_count == 1)
print(proxy:load("map"), load_count)
