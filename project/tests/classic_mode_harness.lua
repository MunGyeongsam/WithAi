package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local ClassicMode = require("03_game.modes.classicMode")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local mode = ClassicMode.new()
local game = {
    score = 0,
}

mode:onReset(game)
assertEq(game.score, 0, "score reset")
assertEq(game.combo.count, 0, "combo reset count")
assertEq(game.combo.multiplier, 1, "combo reset multiplier")

local gained1 = mode:awardBrickPoints(game, 100)
assertEq(gained1, 100, "first hit points")
assertEq(game.combo.count, 1, "first hit count")

local gained2 = mode:awardBrickPoints(game, 100)
assertEq(gained2, 100, "second hit points")
assertEq(game.combo.count, 2, "second hit count")

mode:update(game, 3.0)
assertEq(game.combo.count, 0, "combo timeout reset")
assertEq(game.combo.multiplier, 1, "combo timeout multiplier reset")

mode:awardBrickPoints(game, 100)
assertEq(game.combo.count, 1, "combo restarted")
mode:onLifeLost(game)
assertEq(game.combo.count, 0, "life lost resets combo")

mode:awardBrickPoints(game, 100)
assertEq(game.combo.count, 1, "combo restarted after life lost")
mode:onLevelTransition(game)
assertEq(game.combo.count, 0, "level transition resets combo")

print("classic_mode_harness: all checks passed")
