local Combo = require("03_game.combo")

local ComboRushMode = {}
ComboRushMode.__index = ComboRushMode

function ComboRushMode.new()
    local self = setmetatable({}, ComboRushMode)
    self.comboConfig = {
        windowSeconds = 1.1,
        stepMultiplier = 0.35,
        hitsPerStep = 3,
        maxMultiplier = 3.2,
    }
    self.levelClearBonus = 250
    return self
end

function ComboRushMode:onReset(game)
    game.score = 0
    game.combo = Combo.new(
        self.comboConfig.windowSeconds,
        self.comboConfig.stepMultiplier,
        self.comboConfig.hitsPerStep,
        self.comboConfig.maxMultiplier
    )
end

function ComboRushMode:update(game, dt)
    Combo.tick(game.combo, dt)
end

function ComboRushMode:onLifeLost(game)
    Combo.reset(game.combo)
end

function ComboRushMode:onLevelTransition(game)
    Combo.reset(game.combo)
    game.score = game.score + self.levelClearBonus
end

function ComboRushMode:awardBrickPoints(game, basePoints)
    return Combo.registerHit(game.combo, basePoints)
end

return ComboRushMode
