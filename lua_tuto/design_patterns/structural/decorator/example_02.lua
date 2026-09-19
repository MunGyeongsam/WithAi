local function attack(damage) return damage end
local function critical(action, multiplier)
	return function(value) return action(value) * multiplier end
end
local function logged(action, log)
	return function(value)
		log[#log + 1] = value
		return action(value)
	end
end

local log = {}
local decorated = logged(critical(attack, 2), log)
local damage = decorated(10)
assert(damage == 20 and log[1] == 10 and #log == 1)
print(damage, log[1])
