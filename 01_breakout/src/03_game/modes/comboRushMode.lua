local Combo = require("03_game.combo")
local ModeBalance = require("03_game.modes.modeBalance")

local ComboRushMode = {}
ComboRushMode.__index = ComboRushMode

function ComboRushMode.new(tuning)
    local self = setmetatable({}, ComboRushMode)
    self.tuning = tuning or ModeBalance.get("combo_rush")
    self.comboConfig = self.tuning.comboConfig or {
        windowSeconds = 1.1,
        stepMultiplier = 0.35,
        hitsPerStep = 3,
        maxMultiplier = 3.2,
    }
    self.levelClearBonusByLevel = self.tuning.levelClearBonusByLevel or {
        [1] = 250,
    }
    self.ballSpeedScaleByLevel = self.tuning.ballSpeedScaleByLevel or {}
    self.paddleSpeedScaleByLevel = self.tuning.paddleSpeedScaleByLevel or {}
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
    local bonus = self.levelClearBonusByLevel[game.level] or 0
    game.score = game.score + bonus
end

function ComboRushMode:applyLevelRules(game, levelInfo)
    local level = game.level or 1
    local ballScale = self.ballSpeedScaleByLevel[level] or 1
    local paddleScale = self.paddleSpeedScaleByLevel[level] or 1

    game.ballSpeed = math.floor((levelInfo.ballSpeed or game.ballSpeed) * ballScale)
    game.paddle.speed = math.floor((levelInfo.paddleSpeed or game.paddle.speed) * paddleScale)
end

function ComboRushMode:awardBrickPoints(game, basePoints)
    return Combo.registerHit(game.combo, basePoints)
end

return ComboRushMode
