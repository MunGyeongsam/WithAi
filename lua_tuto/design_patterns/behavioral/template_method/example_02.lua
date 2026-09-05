local function start_game(load_assets, show_menu)
	local assets = load_assets()
	return show_menu(assets)
end

local events = {}
local result = start_game(
	function()
		events[#events + 1] = "load"
		return "assets"
	end,
	function(value)
		events[#events + 1] = "menu"
		return "menu:" .. value
	end
)

assert(result == "menu:assets")
assert(table.concat(events, "->") == "load->menu")
print(result, table.concat(events, "->"))
