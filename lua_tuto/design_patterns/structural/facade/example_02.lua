local audio = { play = function(_, name) return "audio:" .. name end }
local ui = { show = function(_, name) return "ui:" .. name end }
local game = {}
function game:start()
	local music = audio:play("music")
	local hud = ui:show("hud")
	return music .. "+" .. hud
end

assert(game:start() == "audio:music+ui:hud")
print(game:start())
