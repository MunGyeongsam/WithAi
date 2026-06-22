local ClassicMode = require("03_game.modes.classicMode")
local ComboRushMode = require("03_game.modes.comboRushMode")
local ModeBalance = require("03_game.modes.modeBalance")

local ModeRegistry = {}

local FACTORIES = {
    classic = function(tuning)
        return ClassicMode.new(tuning)
    end,
    combo_rush = function(tuning)
        return ComboRushMode.new(tuning)
    end,
}

function ModeRegistry.create(modeId)
    local id = modeId
    if type(id) ~= "string" or FACTORIES[id] == nil then
        id = "classic"
    end

    local tuning = ModeBalance.get(id)
    return id, FACTORIES[id](tuning)
end

return ModeRegistry
