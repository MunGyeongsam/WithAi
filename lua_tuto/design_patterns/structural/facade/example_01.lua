local assets = { load = function(_, name) return "asset:" .. name end }
local audio = { play = function(_, name) return "audio:" .. name end }
local hud = { show = function(_, name) return "hud:" .. name end }

-- Facade: the scene owns the startup order of several subsystems.
local scene = {}
function scene:start()
	local stage = assets:load("stage")
	local music = audio:play("stage_music")
	local status = hud:show("stage_hud")
	return "scene:" .. stage .. "+" .. music .. "+" .. status
end

local result = scene:start()
assert(result == "scene:asset:stage+audio:stage_music+hud:stage_hud")
print(result)
