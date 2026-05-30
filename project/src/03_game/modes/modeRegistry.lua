local ClassicMode = require("03_game.modes.classicMode")
local ComboRushMode = require("03_game.modes.comboRushMode")

local ModeRegistry = {}

local FACTORIES = {
    classic = function()
        return ClassicMode.new()
    end,
    combo_rush = function()
        return ComboRushMode.new()
    end,
}

function ModeRegistry.create(modeId)
    local id = modeId
    if type(id) ~= "string" or FACTORIES[id] == nil then
        id = "classic"
    end

    return id, FACTORIES[id]()
end

return ModeRegistry
