-- Fixed start sequence with a required step, a default hook, and an optional override.
local function start_game(steps)
	local events = {}
	local assets = steps.load_assets()
	events[#events + 1] = "load"
	local on_ready = steps.on_ready or function() end
	on_ready(events)
	local menu = steps.show_menu(assets)
	events[#events + 1] = "menu"
	return menu, events
end

local with_hook, hook_events = start_game({
	load_assets = function() return "assets" end,
	on_ready = function(events) events[#events + 1] = "warmup" end,
	show_menu = function(assets) return "menu:" .. assets end
})

local default_hook, default_events = start_game({
	load_assets = function() return "assets" end,
	show_menu = function(assets) return "menu:" .. assets end
})

assert(with_hook == "menu:assets")
assert(table.concat(hook_events, "->") == "load->warmup->menu")
assert(default_hook == "menu:assets")
assert(table.concat(default_events, "->") == "load->menu")
print(table.concat(hook_events, "->"), table.concat(default_events, "->"))
