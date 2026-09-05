local function render(text) return text end
local function colored(action, color)
	return function(text) return "<" .. color .. ">" .. action(text) .. "</" .. color .. ">" end
end

local decorated = colored(render, "red")
assert(decorated("Danger") == "<red>Danger</red>")
print(decorated("Danger"))
