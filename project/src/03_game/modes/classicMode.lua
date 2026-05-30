local Combo = require("03_game.combo")
local ModeBalance = require("03_game.modes.modeBalance")

local ClassicMode = {}
ClassicMode.__index = ClassicMode

function ClassicMode.new(tuning)
    local self = setmetatable({}, ClassicMode)
    self.tuning = tuning or ModeBalance.get("classic")
    self.comboConfig = self.tuning.comboConfig or {
        windowSeconds = 1.8,
        stepMultiplier = 0.25,
        hitsPerStep = 4,
        maxMultiplier = 2.5,
    }
    return self
end

function ClassicMode:onReset(game)
    game.score = 0
    game.combo = Combo.new(
        self.comboConfig.windowSeconds,
        self.comboConfig.stepMultiplier,
        self.comboConfig.hitsPerStep,
        self.comboConfig.maxMultiplier
    )
end

function ClassicMode:update(game, dt)
    Combo.tick(game.combo, dt)
end

function ClassicMode:onLifeLost(game)
    Combo.reset(game.combo)
end

function ClassicMode:onLevelTransition(game)
    Combo.reset(game.combo)
end

function ClassicMode:applyLevelRules(game, levelInfo)
    local _ = game
    local __ = levelInfo
end

function ClassicMode:awardBrickPoints(game, basePoints)
    return Combo.registerHit(game.combo, basePoints)
end

return ClassicMode
